/*
============================================================================
Gold Layer DDL — Sales Star Schema (Option 3: Header Dimension + Line Fact)

Database:    sales_DataWarehouse
Schema:      gold
Description: Star schema for sales analytics. All monetary fields are
             stored in SAR (Saudi Riyal).
             
             Architecture:
               - 6 Dimension Tables:
                   1. dim_date
                   2. dim_product
                   3. dim_customer
                   4. dim_currency
                   5. dim_sales_center
                   6. dim_sales_order (Invoice Header Metadata Dimension)
               - 1 Fact Table:
                   fact_sales (Line-item grain measures in SAR)

Source:      silver.sales_order_header, silver.sales_order_detail,
             silver.gl_currency, silver.stock_item
============================================================================
*/

-- ============================================================================
-- 0. Drop existing gold tables (in reverse dependency order)
-- ============================================================================
DROP TABLE IF EXISTS gold.fact_sales_header CASCADE;
DROP TABLE IF EXISTS gold.fact_sales        CASCADE;
DROP TABLE IF EXISTS gold.dim_sales_order   CASCADE;
DROP TABLE IF EXISTS gold.dim_date          CASCADE;
DROP TABLE IF EXISTS gold.dim_product       CASCADE;
DROP TABLE IF EXISTS gold.dim_customer      CASCADE;
DROP TABLE IF EXISTS gold.dim_currency      CASCADE;
DROP TABLE IF EXISTS gold.dim_sales_center  CASCADE;


-- ============================================================================
-- 1. Dimension: Date
-- ============================================================================
CREATE TABLE gold.dim_date (
    date_key        INTEGER         PRIMARY KEY,    -- YYYYMMDD integer (e.g., 20230101)
    full_date       DATE            NOT NULL,       -- Actual DATE value
    year            SMALLINT        NOT NULL,       -- Calendar year (e.g., 2023)
    quarter         SMALLINT        NOT NULL,       -- Quarter of the year (1-4)
    month           SMALLINT        NOT NULL,       -- Month of the year (1-12)
    day             SMALLINT        NOT NULL,       -- Day of the month (1-31)
    month_name      VARCHAR(10)     NOT NULL,       -- Full month name (e.g., 'January')
    day_name        VARCHAR(10)     NOT NULL,       -- Day of the week name (e.g., 'Monday')
    is_weekend      BOOLEAN         NOT NULL        -- TRUE if Saturday or Sunday
);


-- ============================================================================
-- 2. Dimension: Product
-- ============================================================================
CREATE TABLE gold.dim_product (
    product_key         SERIAL          PRIMARY KEY,    -- Surrogate key
    item_code           VARCHAR(16)     NOT NULL,       -- Natural key (silver.stock_item.itemno)
    item_name           VARCHAR(45),                    -- Primary item name
    item_name_alt       VARCHAR(40),                    -- Alternative language name
    vehicle_make_model  VARCHAR(50),                    -- Vehicle Make & Model (e.g. 'Hyundai Sonata')
    origin_quality      VARCHAR(30),                    -- Origin / Quality (e.g. 'Genuine', 'Korean', 'Chinese')
    part_category       VARCHAR(80),                    -- Part Category (e.g. 'Shock Absorber & Strut / مساعدات')
    vehicle_system      VARCHAR(60),                    -- Vehicle System (e.g. 'Suspension & Steering')
    item_type           VARCHAR(1)                      -- Item Type (e.g., Stock, Service, Asset)
);

CREATE UNIQUE INDEX uix_dim_product_item_code ON gold.dim_product (item_code);


-- ============================================================================
-- 3. Dimension: Customer
-- ============================================================================
CREATE TABLE gold.dim_customer (
    customer_key    SERIAL          PRIMARY KEY,    -- Surrogate key
    customer_code   VARCHAR(6)      NOT NULL,       -- Natural key (sales_order_header.customer_number)
    customer_name   VARCHAR(50)                     -- Customer name from the header
);

CREATE UNIQUE INDEX uix_dim_customer_code ON gold.dim_customer (customer_code);


-- ============================================================================
-- 4. Dimension: Currency
-- ============================================================================
CREATE TABLE gold.dim_currency (
    currency_key        SERIAL          PRIMARY KEY,    -- Surrogate key
    currency_code       VARCHAR(3)      NOT NULL,       -- Natural key (gl_currency.curcode)
    currency_name       VARCHAR(30),                    -- Currency full name
    currency_symbol     VARCHAR(5),                     -- Short symbol (e.g., YR, $, SAR)
    standard_iso_code   VARCHAR(3),                     -- ISO currency code (if available)
    sar_exchange_rate   NUMERIC(15,13)  NOT NULL        -- Conversion rate to SAR
);

CREATE UNIQUE INDEX uix_dim_currency_code ON gold.dim_currency (currency_code);


-- ============================================================================
-- 5. Dimension: Sales Center
-- ============================================================================
CREATE TABLE gold.dim_sales_center (
    sales_center_key    SERIAL          PRIMARY KEY,    -- Surrogate key
    sales_center_code   VARCHAR(2)      NOT NULL,       -- Natural key (sales_order_header.sales_center)
    company_id          VARCHAR(2)      NOT NULL        -- Company identifier
);

CREATE UNIQUE INDEX uix_dim_sales_center ON gold.dim_sales_center (sales_center_code, company_id);


-- ============================================================================
-- 6. Dimension: Sales Order / Invoice Header (Header Metadata Dimension)
-- ============================================================================
-- Captures invoice-level attributes, salesman, status, payment method, and basket metadata
CREATE TABLE gold.dim_sales_order (
    sales_order_key         SERIAL          PRIMARY KEY,    -- Surrogate key

    -- Natural business keys
    company_id              VARCHAR(2)      NOT NULL,
    invoice_type            VARCHAR(2)      NOT NULL,
    reference_number        NUMERIC(6,0)    NOT NULL,

    -- Order & Basket Metadata
    line_item_count         NUMERIC(6,0),                   -- Total items in basket
    salesman_code           VARCHAR(2),                     -- Sales representative
    header_discount_pct     DOUBLE PRECISION,               -- Overall invoice discount percentage
    vat_percent             NUMERIC(5,2),                   -- VAT percentage applied
    
    -- Status & Workflow Flags
    is_posted               BOOLEAN,                        -- GL posted flag
    is_released             BOOLEAN,                        -- Document released flag
    is_cheque               BOOLEAN,                        -- Cheque payment flag
    
    -- Payment categorization
    payment_mode            VARCHAR(20),                    -- 'Cash', 'Card', 'STCPay', 'Mixed', etc.
    
    -- Linked Due Date Key (optional date lookup)
    due_date_key            INTEGER                         -- FK → dim_date
);

-- Unique index on natural invoice key
CREATE UNIQUE INDEX uix_dim_sales_order_inv 
    ON gold.dim_sales_order (company_id, invoice_type, reference_number);


-- ============================================================================
-- 7. Fact Table: Sales (Line-Item Grain)
-- ============================================================================
-- Grain: One row per invoice line item (one folio within one invoice).
-- All monetary measures are converted to SAR.
CREATE TABLE gold.fact_sales (
    fact_sales_key      SERIAL          PRIMARY KEY,        -- Surrogate key

    -- Dimension foreign keys (Star schema direct joins)
    sales_order_key     INTEGER         NOT NULL,           -- FK → dim_sales_order
    date_key            INTEGER         NOT NULL,           -- FK → dim_date
    product_key         INTEGER         NOT NULL,           -- FK → dim_product
    customer_key        INTEGER         NOT NULL,           -- FK → dim_customer
    sales_center_key    INTEGER         NOT NULL,           -- FK → dim_sales_center
    currency_key        INTEGER         NOT NULL,           -- FK → dim_currency

    -- Degenerate line identifier
    folio               NUMERIC(7,0)    NOT NULL,           -- Line item sequence number

    -- Measures (all in SAR)
    quantity            DOUBLE PRECISION,                   -- Quantity sold
    unit_price_sar      NUMERIC(14,4),                      -- Unit selling price in SAR
    unit_cost_sar       NUMERIC(14,4),                      -- Unit cost (COGS) in SAR
    discount_pct        DOUBLE PRECISION,                   -- Line item discount percentage
    discount_amount_sar NUMERIC(14,4),                      -- Discount amount in SAR
    net_price_sar       NUMERIC(14,4),                      -- Net item price after discounts in SAR
    line_total_sar      NUMERIC(14,4),                      -- qty × unit_price in SAR
    vat_amount_sar      NUMERIC(14,4),                      -- VAT amount in SAR
    returned_quantity   DOUBLE PRECISION,                   -- Returned quantity

    -- Foreign key constraints
    CONSTRAINT fk_fact_sales_order
        FOREIGN KEY (sales_order_key) REFERENCES gold.dim_sales_order (sales_order_key),
    CONSTRAINT fk_fact_sales_date
        FOREIGN KEY (date_key) REFERENCES gold.dim_date (date_key),
    CONSTRAINT fk_fact_sales_product
        FOREIGN KEY (product_key) REFERENCES gold.dim_product (product_key),
    CONSTRAINT fk_fact_sales_customer
        FOREIGN KEY (customer_key) REFERENCES gold.dim_customer (customer_key),
    CONSTRAINT fk_fact_sales_sales_center
        FOREIGN KEY (sales_center_key) REFERENCES gold.dim_sales_center (sales_center_key),
    CONSTRAINT fk_fact_sales_currency
        FOREIGN KEY (currency_key) REFERENCES gold.dim_currency (currency_key)
);

-- Analytical indexes
CREATE INDEX ix_fact_sales_order_key ON gold.fact_sales (sales_order_key);
CREATE INDEX ix_fact_sales_date_key  ON gold.fact_sales (date_key);
CREATE INDEX ix_fact_sales_prod_key  ON gold.fact_sales (product_key);
CREATE INDEX ix_fact_sales_cust_key  ON gold.fact_sales (customer_key);
