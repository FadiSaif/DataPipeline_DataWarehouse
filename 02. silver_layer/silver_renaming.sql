SELECT * FROM silver.sales_order_header;

ALTER TABLE silver.sales_order_header
RENAME COLUMN slcenter TO sales_center;

ALTER TABLE silver.sales_order_header
RENAME COLUMN invdate TO invoice_date;

ALTER TABLE silver.sales_order_header
RENAME COLUMN duedate TO due_date;

ALTER TABLE silver.sales_order_header
RENAME COLUMN invttl TO invoice_total;

ALTER TABLE silver.sales_order_header
RENAME COLUMN invcst TO invoice_cost;

ALTER TABLE silver.sales_order_header
RENAME COLUMN custno TO customer_number;

ALTER TABLE silver.sales_order_header
RENAME COLUMN custnm TO customer_name;

ALTER TABLE silver.sales_order_header
RENAME COLUMN fcy TO currency;