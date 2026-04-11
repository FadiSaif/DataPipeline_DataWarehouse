SELECT COUNT(ref)
  FROM bronze.sales_hd;

SELECT
    inv_year,
    "company", "invtype", "ref", "folio",
    COUNT(*) AS occurrences
FROM (
    SELECT 
        EXTRACT(YEAR FROM invdate::DATE) AS inv_year,
        branch, 
        ref 
    FROM bronze.sales_hd
) AS sub
GROUP BY inv_year, ref
HAVING COUNT(*) > 1
ORDER BY inv_year, ref;

-- "invoice_date",

ALTER TABLE silver.sales_order_detail 
	DROP CONSTRAINT IF EXISTS pk_sales_order_detail CASCADE;
	
ALTER TABLE silver.sales_order_detail 
	ADD CONSTRAINT pk_sales_order_detail 
	PRIMARY KEY ("company_id", "invoice_type", "reference_number", "folio", "invoice_date");
	
ALTER TABLE silver.sales_order_header 
	DROP CONSTRAINT IF EXISTS pk_sales_order_header CASCADE;
	
ALTER TABLE silver.sales_order_header 
	ADD CONSTRAINT pk_sales_order_header
	PRIMARY KEY ("company_id", "invoice_type", "reference_number", "invoice_date");
	
ALTER TABLE silver.sales_order_detail
	DROP CONSTRAINT IF EXISTS fk_sales_order_detail_sales_order_header_es_hd CASCADE;
ALTER TABLE silver.sales_order_detail
	ADD CONSTRAINT fk_sales_order_detail_sales_order_header_es_hd 
    FOREIGN KEY ("company_id", "invoice_type", "reference_number", "invoice_date") 
	REFERENCES silver.sales_order_header ("company_id", "invoice_type", "reference_number", "invoice_date") NOT VALID;


SELECT * FROM silver.sales_order_header;
SELECT * FROM silver.sales_order_detail;


SELECT COUNT(ref)
  FROM bronze.sales_dt;

SELECT DISTINCT COUNT(ref)
  FROM bronze.sales_dt;