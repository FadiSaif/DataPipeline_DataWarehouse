/*
============================================================================
Gold Layer LOAD — Option 3: Header Dimension + Line Fact (SAR-Normalized)

Database:    sales_DataWarehouse
Schema:      gold
Description: Populates the gold star schema tables from the silver layer.
             Includes full text parsing & classification of products:
               - Vehicle Make & Model (main_group)
               - Origin / Quality: Genuine, Korean, Chinese, Other (sub_group)
               - Normalized Part Category (category)
               - Vehicle System Classification (classification_key)

Load order:
  1. dim_date          (generated date series 2023-2030)
  2. dim_product       (classified from silver.stock_item)
  3. dim_customer      (from silver.sales_order_header)
  4. dim_currency      (from silver.gl_currency)
  5. dim_sales_center  (from silver.sales_order_header)
  6. dim_sales_order   (from silver.sales_order_header)
  7. fact_sales        (from silver.sales_order_detail + dimensions)

Currency Conversion to SAR:
    CASE
        WHEN TRIM(currency) = '01' THEN 0.002421307506053   -- YER → SAR
        WHEN TRIM(currency) = '02' THEN 3.8                  -- USD → SAR
        ELSE 1                                                -- SAR (03 or blank)
    END
============================================================================
*/


-- ============================================================================
-- 1. Load dim_date (2023-01-01 through 2030-12-31)
-- ============================================================================
TRUNCATE TABLE gold.dim_date CASCADE;

INSERT INTO gold.dim_date (date_key, full_date, year, quarter, month, day, month_name, day_name, is_weekend)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER         AS date_key,
    d                                        AS full_date,
    EXTRACT(YEAR FROM d)::SMALLINT           AS year,
    EXTRACT(QUARTER FROM d)::SMALLINT        AS quarter,
    EXTRACT(MONTH FROM d)::SMALLINT          AS month,
    EXTRACT(DAY FROM d)::SMALLINT            AS day,
    TO_CHAR(d, 'FMMonth')                    AS month_name,
    TO_CHAR(d, 'FMDay')                      AS day_name,
    EXTRACT(ISODOW FROM d) IN (6, 7)         AS is_weekend
FROM GENERATE_SERIES('2023-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) AS d;


-- ============================================================================
-- 2. Load dim_product (from enriched silver.stock_item)
--    Classification logic lives in: 02. silver_layer/03_enrich_stock_item.sql
-- ============================================================================
TRUNCATE TABLE gold.dim_product CASCADE;

INSERT INTO gold.dim_product (
    item_code,
    item_name,
    item_name_alt,
    vehicle_make_model,
    origin_quality,
    part_category,
    vehicle_system,
    item_type
)
SELECT
    TRIM(itemno)            AS item_code,
    TRIM(name)              AS item_name,
    TRIM(lname)             AS item_name_alt,
    vehicle_make_model,
    origin_quality,
    part_category,
    vehicle_system,
    TRIM(itemtype)          AS item_type
FROM silver.stock_item;



-- ============================================================================
-- 3. Load dim_customer (denormalized from silver.sales_order_header)
-- ============================================================================
TRUNCATE TABLE gold.dim_customer CASCADE;

INSERT INTO gold.dim_customer (customer_code, customer_name)
SELECT DISTINCT ON (TRIM(custno))
    TRIM(custno)   AS customer_code,
    TRIM(custnm)   AS customer_name
FROM silver.sales_order_header
WHERE custno IS NOT NULL
ORDER BY TRIM(custno), custnm NULLS LAST;


-- ============================================================================
-- 4. Load dim_currency (from silver.gl_currency + SAR rate)
-- ============================================================================
TRUNCATE TABLE gold.dim_currency CASCADE;

INSERT INTO gold.dim_currency (currency_code, currency_name, currency_symbol, standard_iso_code, sar_exchange_rate)
SELECT
    TRIM(curcode)               AS currency_code,
    TRIM(curname)               AS currency_name,
    TRIM(cursname)              AS currency_symbol,
    TRIM(standard_fcy_code)     AS standard_iso_code,
    CASE
        WHEN TRIM(curcode) = '01' THEN 0.002421307506053    -- YER → SAR
        WHEN TRIM(curcode) = '02' THEN 3.8                   -- USD → SAR
        ELSE 1                                                -- SAR (curcode '03') or others
    END                         AS sar_exchange_rate
FROM silver.gl_currency;

-- Ensure default SAR / Local currency row exists
INSERT INTO gold.dim_currency (currency_code, currency_name, currency_symbol, standard_iso_code, sar_exchange_rate)
VALUES ('03', 'ريال سعودي', 'SAR', 'SAR', 1.0)
ON CONFLICT (currency_code) DO NOTHING;


-- ============================================================================
-- 5. Load dim_sales_center (from silver.sales_order_header)
-- ============================================================================
TRUNCATE TABLE gold.dim_sales_center CASCADE;

INSERT INTO gold.dim_sales_center (sales_center_code, company_id)
SELECT DISTINCT
    TRIM(slcenter)     AS sales_center_code,
    TRIM(company_id)   AS company_id
FROM silver.sales_order_header
WHERE slcenter IS NOT NULL;


-- ============================================================================
-- 6. Load dim_sales_order (Invoice Header Metadata Dimension)
-- ============================================================================
TRUNCATE TABLE gold.dim_sales_order CASCADE;

INSERT INTO gold.dim_sales_order (
    company_id,
    invoice_type,
    reference_number,
    line_item_count,
    salesman_code,
    header_discount_pct,
    vat_percent,
    is_posted,
    is_released,
    is_cheque,
    payment_mode,
    due_date_key
)
SELECT DISTINCT ON (TRIM(hd.company_id), TRIM(hd.invoice_type), hd.reference_number)
    TRIM(hd.company_id)                                         AS company_id,
    TRIM(hd.invoice_type)                                       AS invoice_type,
    hd.reference_number                                         AS reference_number,
    hd.entries                                                  AS line_item_count,
    TRIM(hd.slcode)                                             AS salesman_code,
    hd.invdspc                                                  AS header_discount_pct,
    hd.vat_percent                                              AS vat_percent,
    hd.posted                                                   AS is_posted,
    hd.released                                                 AS is_released,
    hd.ischeque                                                 AS is_cheque,
    CASE
        WHEN COALESCE(hd.ccpayment, 0) > 0 AND COALESCE(hd.stcpay_amt, 0) > 0 THEN 'Mixed (Card+STCPay)'
        WHEN COALESCE(hd.ccpayment, 0) > 0 THEN 'Credit Card'
        WHEN COALESCE(hd.stcpay_amt, 0) > 0 THEN 'STCPay'
        WHEN hd.ischeque = TRUE THEN 'Cheque'
        ELSE 'Cash'
    END                                                         AS payment_mode,
    CASE
        WHEN hd.duedate IS NOT NULL AND TRIM(hd.duedate) ~ '^[0-9]{8}$'
        THEN CAST(TRIM(hd.duedate) AS INTEGER)
        ELSE NULL
    END                                                         AS due_date_key
FROM silver.sales_order_header hd
ORDER BY TRIM(hd.company_id), TRIM(hd.invoice_type), hd.reference_number;


-- ============================================================================
-- 7. Load fact_sales (Line-Item Grain Fact with SAR Normalization)
-- ============================================================================
TRUNCATE TABLE gold.fact_sales;

INSERT INTO gold.fact_sales (
    sales_order_key,
    date_key,
    product_key,
    customer_key,
    sales_center_key,
    currency_key,
    folio,
    quantity,
    unit_price_sar,
    unit_cost_sar,
    discount_pct,
    discount_amount_sar,
    net_price_sar,
    line_total_sar,
    vat_amount_sar,
    returned_quantity
)
SELECT
    -- Dimension Surrogate Keys (Star schema direct joins)
    dso.sales_order_key                                                 AS sales_order_key,
    CAST(dt.invdate AS INTEGER)                                         AS date_key,
    dp.product_key                                                      AS product_key,
    dc.customer_key                                                     AS customer_key,
    dsc.sales_center_key                                                AS sales_center_key,
    dcur.currency_key                                                   AS currency_key,

    -- Degenerate Line Item identifier
    dt.folio                                                            AS folio,

    -- Measures (SAR-converted)
    dt.qty                                                              AS quantity,

    ROUND((dt.ice  * sar_rate.rate)::NUMERIC, 4)                        AS unit_price_sar,
    ROUND((dt.cost * sar_rate.rate)::NUMERIC, 4)                        AS unit_cost_sar,

    dt.discpc                                                           AS discount_pct,

    ROUND((COALESCE(dt.dsc_amt, 0) * sar_rate.rate)::NUMERIC, 4)        AS discount_amount_sar,
    ROUND((COALESCE(dt.item_price_net, 0) * sar_rate.rate)::NUMERIC, 4)  AS net_price_sar,
    ROUND((dt.qty * dt.ice * sar_rate.rate)::NUMERIC, 4)                AS line_total_sar,
    ROUND((COALESCE(dt.item_vat, 0) * sar_rate.rate)::NUMERIC, 4)       AS vat_amount_sar,

    dt.rtnqty                                                           AS returned_quantity

FROM silver.sales_order_detail dt

-- Join header for customer link and fallback currency
INNER JOIN silver.sales_order_header hd
    ON  dt.company_id       = hd.company_id
    AND dt.invoice_type     = hd.invoice_type
    AND dt.reference_number = hd.reference_number

-- SAR conversion rate calculation
CROSS JOIN LATERAL (
    SELECT
        CASE
            WHEN TRIM(COALESCE(NULLIF(TRIM(dt.fcy), ''), NULLIF(TRIM(hd.fcy), ''), '03')) = '01'
                THEN 0.002421307506053
            WHEN TRIM(COALESCE(NULLIF(TRIM(dt.fcy), ''), NULLIF(TRIM(hd.fcy), ''), '03')) = '02'
                THEN 3.8
            ELSE 1
        END AS rate,
        TRIM(COALESCE(NULLIF(TRIM(dt.fcy), ''), NULLIF(TRIM(hd.fcy), ''), '03')) AS resolved_currency
) sar_rate

-- Dimension lookups
INNER JOIN gold.dim_sales_order dso
    ON  TRIM(dt.company_id)       = dso.company_id
    AND TRIM(dt.invoice_type)     = dso.invoice_type
    AND dt.reference_number       = dso.reference_number

INNER JOIN gold.dim_product dp
    ON TRIM(dt.itemno) = dp.item_code

INNER JOIN gold.dim_customer dc
    ON TRIM(hd.custno) = dc.customer_code

INNER JOIN gold.dim_currency dcur
    ON sar_rate.resolved_currency = dcur.currency_code

INNER JOIN gold.dim_sales_center dsc
    ON  TRIM(dt.slcenter)   = dsc.sales_center_code
    AND TRIM(dt.company_id) = dsc.company_id

-- Filter to target date series range (2023+)
INNER JOIN gold.dim_date dd
    ON CAST(dt.invdate AS INTEGER) = dd.date_key;

