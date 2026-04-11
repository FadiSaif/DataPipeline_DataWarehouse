WITH temp_sales AS (
    SELECT 
        EXTRACT(YEAR FROM invoice_date::DATE) AS invoice_year,
        CASE 
            WHEN TRIM(foreign_currency) = '01' THEN 0.002421307506053::NUMERIC
            ELSE 1
        END AS foreign_currency_rate,
        (unit_price * quantity) AS raw_total_price,
        (unit_cost * quantity) AS raw_total_cost,
        (unit_price * quantity - unit_cost * quantity) AS raw_profit
    FROM silver.sales_order_detail
    WHERE company_id IS NOT NULL
),
yearly_totals AS (
    SELECT 
        invoice_year,
        SUM(raw_total_price * foreign_currency_rate) AS total_price_raw,
        SUM(raw_total_cost * foreign_currency_rate) AS total_cost_raw,
        SUM(raw_profit * foreign_currency_rate) AS total_profit_raw
    FROM temp_sales
    GROUP BY invoice_year
)
SELECT
    invoice_year,
    -- Formatting Cost
    to_char(total_cost_raw, 'FM999,999,999.00') AS annual_cost,
    -- Formatting Price
    to_char(total_price_raw, 'FM999,999,999.00') AS annual_sales,
	 -- Formatting Profit
    to_char(total_profit_raw, 'FM999,999,999.00') AS annual_profit,
    -- Window function formatted
    to_char(
        LAG(total_profit_raw) OVER (ORDER BY invoice_year), 
        'FM999,999,999.00'
    ) AS last_year_profit
FROM yearly_totals
ORDER BY invoice_year DESC;


WITH temp_sales AS (
    SELECT 
        EXTRACT(YEAR FROM invdate::DATE) AS invoice_year,
        CASE 
            WHEN TRIM(fcy) = '01' THEN 0.002421307506053::NUMERIC
            ELSE 1
        END AS fcy_rate,
        (price * qty) AS raw_total_price,
        (cost * qty) AS raw_total_cost,
        (price * qty - cost * qty) AS raw_profit
    FROM bronze.sales_dt
    WHERE company IS NOT NULL
),
yearly_totals AS (
    SELECT 
        invoice_year,
        SUM(raw_total_price * fcy_rate) AS total_price_raw,
        SUM(raw_total_cost * fcy_rate) AS total_cost_raw,
        SUM(raw_profit * fcy_rate) AS total_profit_raw
    FROM temp_sales
    GROUP BY invoice_year
)
SELECT
    invoice_year,
    -- Formatting Cost
    to_char(total_cost_raw, 'FM999,999,999.00') AS annual_cost,
    -- Formatting Price
    to_char(total_price_raw, 'FM999,999,999.00') AS annual_sales,
	 -- Formatting Profit
    to_char(total_profit_raw, 'FM999,999,999.00') AS annual_profit,
    -- Window function formatted
    to_char(
        LAG(total_profit_raw) OVER (ORDER BY invoice_year), 
        'FM999,999,999.00'
    ) AS last_year_profit
FROM yearly_totals
ORDER BY invoice_year DESC;