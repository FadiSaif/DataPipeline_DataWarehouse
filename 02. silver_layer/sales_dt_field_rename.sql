/*
This script is used to test and verify column data and usability of each column. It also serves to rename each column based on 
the project's set naming convention 'snake_case' for better clarity over that of the data source.

CAUTION: Columns renamed or dropped may cause data migration errors if not done carefully with all its dependencies and relevant
data migration scripts
*/

-- Test columns and content to verify if there are any replicated postings
SELECT * FROM silver.sales_order_detail
WHERE replicated_posting = true;

-- Test cmbkey value against the similar item_number
SELECT COUNT(*) 
FROM silver.sales_order_detail 
WHERE TRIM(item_number) = TRIM(cmbkey) -- Same information in both fields

-- test both "ds_acfm" and "acfm" if there are different entries
-- in any of the two. 
SELECT 
	ds_acfm, -- only one
	COUNT(item_number) 
FROM silver.sales_order_detail 
GROUP BY ds_acfm;

-- Rename table columns and fields using project's naming convention
ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "ice" TO "unit_price";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "quantity" TO "item_quantity";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "qty" TO "quantity";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "fqty" TO "free_quantity";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "cost" TO "unit_cost";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "itemno" TO "item_number";

ALTER TABLE IF EXISTS silver.sales_order_header
RENAME COLUMN "invdate" TO "invoice_date";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "slcenter" TO "sales_center";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "fcy" TO "foreign_currency";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "custno" TO "customer_number";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "whno" TO "warehouse_number";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "branch" TO "branch_number";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "discpc" TO "discount_percent";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "rtnqty" TO "returned_quantity";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "frtqty" TO "freight_quantity";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "pack" TO "item_pack";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "shadd" TO "shadow_addition";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "pkqty" TO "pack_quantity";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "shdpk" TO "shadow_pack";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "shdqty" TO "shadow_quantity";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "taxtype" TO "tax_type";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "rplct_post" TO "replicated_posting";

ALTER TABLE IF EXISTS silver.sales_order_detail
RENAME COLUMN "dsc_amt" TO "discount_amount";
 
-- Drop columns not used in database, no business value
ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN cmbkey

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN acfm;

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN ds_acfm;

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN gclass;

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN imfcval;

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN ps_item_vat;

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN expdate;

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN item_price_net;

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN invdscamt;

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN item_vat;

ALTER TABLE IF EXISTS silver.sales_order_detail
DROP COLUMN unicode

