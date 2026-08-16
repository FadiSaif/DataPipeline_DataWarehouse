SELECT * FROM silver.sales_order_detail
ORDER BY company_id ASC, invoice_type ASC, reference_number ASC, folio ASC;

ALTER TABLE silver.sales_order_detail
RENAME COLUMN slcenter TO sales_center;

ALTER TABLE silver.sales_order_detail
RENAME COLUMN invdate TO invoice_date;

ALTER TABLE silver.sales_order_detail
RENAME COLUMN itemno TO item_code;

ALTER TABLE silver.sales_order_detail
RENAME COLUMN qty TO quantity;

ALTER TABLE silver.sales_order_detail
RENAME COLUMN ice TO item_price;

ALTER TABLE silver.sales_order_detail
RENAME COLUMN discpc TO discounted_price;

ALTER TABLE silver.sales_order_detail
RENAME COLUMN cost TO item_cost;

ALTER TABLE silver.sales_order_detail
RENAME COLUMN custno TO customer_number;

ALTER TABLE silver.sales_order_detail
RENAME COLUMN fcy TO currency;

