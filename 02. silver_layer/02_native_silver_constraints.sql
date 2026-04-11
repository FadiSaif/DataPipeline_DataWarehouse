-- =========================================================================
-- SILVER LAYER NATIVE ERP CONSTRAINTS (Semantic Naming)
-- 
-- PURPOSE: Apply genuine MSSQL-derived constraints onto renamed tables/cols.
-- NOTE: Foreign Keys are set to NOT VALID to allow initial legacy load.
-- =========================================================================

DO $$
BEGIN

-- 1. PRIMARY KEYS
ALTER TABLE silver.ap_classification DROP CONSTRAINT IF EXISTS pk_ap_classification;
ALTER TABLE silver.ap_classification ADD CONSTRAINT pk_ap_classification PRIMARY KEY ("company_id", "code");
ALTER TABLE silver.ap_invoice_detail DROP CONSTRAINT IF EXISTS pk_ap_invoice_detail;
ALTER TABLE silver.ap_invoice_detail ADD CONSTRAINT pk_ap_invoice_detail PRIMARY KEY ("company_id", "type", "reference_number", "folio");
ALTER TABLE silver.ap_invoice_header DROP CONSTRAINT IF EXISTS pk_ap_invoice_header;
ALTER TABLE silver.ap_invoice_header ADD CONSTRAINT pk_ap_invoice_header PRIMARY KEY ("company_id", "type", "reference_number");
ALTER TABLE silver.ar_invoice_detail DROP CONSTRAINT IF EXISTS pk_ar_invoice_detail;
ALTER TABLE silver.ar_invoice_detail ADD CONSTRAINT pk_ar_invoice_detail PRIMARY KEY ("company_id", "type", "reference_number", "folio");
ALTER TABLE silver.ar_invoice_header DROP CONSTRAINT IF EXISTS pk_ar_invoice_header;
ALTER TABLE silver.ar_invoice_header ADD CONSTRAINT pk_ar_invoice_header PRIMARY KEY ("company_id", "type", "reference_number");
ALTER TABLE silver.bank_account DROP CONSTRAINT IF EXISTS pk_bank_account;
ALTER TABLE silver.bank_account ADD CONSTRAINT pk_bank_account PRIMARY KEY ("company_id", "code", "account_code");
ALTER TABLE silver.bank DROP CONSTRAINT IF EXISTS pk_bank;
ALTER TABLE silver.bank ADD CONSTRAINT pk_bank PRIMARY KEY ("code");
ALTER TABLE silver.classification_file DROP CONSTRAINT IF EXISTS pk_classification_file;
ALTER TABLE silver.classification_file ADD CONSTRAINT pk_classification_file PRIMARY KEY ("company_id", "code");
ALTER TABLE silver.customer DROP CONSTRAINT IF EXISTS pk_customer;
ALTER TABLE silver.customer ADD CONSTRAINT pk_customer PRIMARY KEY ("company_id", "code", "cf_fcy");
ALTER TABLE silver.delivery_charge_header DROP CONSTRAINT IF EXISTS pk_delivery_charge_header;
ALTER TABLE silver.delivery_charge_header ADD CONSTRAINT pk_delivery_charge_header PRIMARY KEY ("trx_id");
ALTER TABLE silver.gl_chart_of_accounts DROP CONSTRAINT IF EXISTS pk_gl_chart_of_accounts;
ALTER TABLE silver.gl_chart_of_accounts ADD CONSTRAINT pk_gl_chart_of_accounts PRIMARY KEY ("glkey", "glcurrency");
ALTER TABLE silver.gl_currency DROP CONSTRAINT IF EXISTS pk_gl_currency;
ALTER TABLE silver.gl_currency ADD CONSTRAINT pk_gl_currency PRIMARY KEY ("curcode");
ALTER TABLE silver.gl_exchange_rate DROP CONSTRAINT IF EXISTS pk_gl_exchange_rate;
ALTER TABLE silver.gl_exchange_rate ADD CONSTRAINT pk_gl_exchange_rate PRIMARY KEY ("company_id", "image_fc_usrid", "image_fc_date", "image_fc_srlno");
ALTER TABLE silver.gl_journal_detail DROP CONSTRAINT IF EXISTS pk_gl_journal_detail;
ALTER TABLE silver.gl_journal_detail ADD CONSTRAINT pk_gl_journal_detail PRIMARY KEY ("company_id", "type", "reference_number", "folio");
ALTER TABLE silver.gl_journal_header DROP CONSTRAINT IF EXISTS pk_gl_journal_header;
ALTER TABLE silver.gl_journal_header ADD CONSTRAINT pk_gl_journal_header PRIMARY KEY ("company_id", "type", "reference_number");
ALTER TABLE silver.country DROP CONSTRAINT IF EXISTS pk_country;
ALTER TABLE silver.country ADD CONSTRAINT pk_country PRIMARY KEY ("country_id");
ALTER TABLE silver.packing_type DROP CONSTRAINT IF EXISTS pk_packing_type;
ALTER TABLE silver.packing_type ADD CONSTRAINT pk_packing_type PRIMARY KEY ("pack_id");
ALTER TABLE silver.price_history DROP CONSTRAINT IF EXISTS pk_price_history;
ALTER TABLE silver.price_history ADD CONSTRAINT pk_price_history PRIMARY KEY ("code");
ALTER TABLE silver.purchase_department DROP CONSTRAINT IF EXISTS pk_purchase_department;
ALTER TABLE silver.purchase_department ADD CONSTRAINT pk_purchase_department PRIMARY KEY ("brno", "dept");
ALTER TABLE silver.purchase_order_detail DROP CONSTRAINT IF EXISTS pk_purchase_order_detail;
ALTER TABLE silver.purchase_order_detail ADD CONSTRAINT pk_purchase_order_detail PRIMARY KEY ("company_id", "invoice_type", "reference_number", "folio");
ALTER TABLE silver.purchase_order_header DROP CONSTRAINT IF EXISTS pk_purchase_order_header;
ALTER TABLE silver.purchase_order_header ADD CONSTRAINT pk_purchase_order_header PRIMARY KEY ("company_id", "invoice_type", "reference_number");
ALTER TABLE silver.sales_center DROP CONSTRAINT IF EXISTS pk_sales_center;
ALTER TABLE silver.sales_center ADD CONSTRAINT pk_sales_center PRIMARY KEY ("brno", "dept");
ALTER TABLE silver.sales_order_detail DROP CONSTRAINT IF EXISTS pk_sales_order_detail;
ALTER TABLE silver.sales_order_detail ADD CONSTRAINT pk_sales_order_detail PRIMARY KEY ("company_id", "invoice_type", "reference_number", "folio");
ALTER TABLE silver.sales_order_header DROP CONSTRAINT IF EXISTS pk_sales_order_header;
ALTER TABLE silver.sales_order_header ADD CONSTRAINT pk_sales_order_header PRIMARY KEY ("company_id", "invoice_type", "reference_number");
ALTER TABLE silver.sales_quotation_header DROP CONSTRAINT IF EXISTS pk_sales_quotation_header;
ALTER TABLE silver.sales_quotation_header ADD CONSTRAINT pk_sales_quotation_header PRIMARY KEY ("company_id", "reference_number");
ALTER TABLE silver.sales_representative DROP CONSTRAINT IF EXISTS pk_sales_representative;
ALTER TABLE silver.sales_representative ADD CONSTRAINT pk_sales_representative PRIMARY KEY ("slcompany", "slcode");
ALTER TABLE silver.sales_invoice_expense DROP CONSTRAINT IF EXISTS pk_sales_invoice_expense;
ALTER TABLE silver.sales_invoice_expense ADD CONSTRAINT pk_sales_invoice_expense PRIMARY KEY ("company_id", "invoice_type", "reference_number");
ALTER TABLE silver.stock_area DROP CONSTRAINT IF EXISTS pk_stock_area;
ALTER TABLE silver.stock_area ADD CONSTRAINT pk_stock_area PRIMARY KEY ("cmbkey");
ALTER TABLE silver.stock_bin DROP CONSTRAINT IF EXISTS pk_stock_bin;
ALTER TABLE silver.stock_bin ADD CONSTRAINT pk_stock_bin PRIMARY KEY ("anch", "itemno", "unicode", "whno", "binno");
ALTER TABLE silver.stock_classification DROP CONSTRAINT IF EXISTS pk_stock_classification;
ALTER TABLE silver.stock_classification ADD CONSTRAINT pk_stock_classification PRIMARY KEY ("cmbkey");
ALTER TABLE silver.stock_cost_type DROP CONSTRAINT IF EXISTS pk_stock_cost_type;
ALTER TABLE silver.stock_cost_type ADD CONSTRAINT pk_stock_cost_type PRIMARY KEY ("anch", "itemno", "unicode");
ALTER TABLE silver.stock_purchase_invoice DROP CONSTRAINT IF EXISTS pk_stock_purchase_invoice;
ALTER TABLE silver.stock_purchase_invoice ADD CONSTRAINT pk_stock_purchase_invoice PRIMARY KEY ("anch", "splycode", "fcy", "splyinv", "itemno", "unicode");
ALTER TABLE silver.stock_transaction_detail DROP CONSTRAINT IF EXISTS pk_stock_transaction_detail;
ALTER TABLE silver.stock_transaction_detail ADD CONSTRAINT pk_stock_transaction_detail PRIMARY KEY ("anch", "trtype", "reference_number", "folio");
ALTER TABLE silver.stock_foreign_currency_price DROP CONSTRAINT IF EXISTS pk_stock_foreign_currency_price;
ALTER TABLE silver.stock_foreign_currency_price ADD CONSTRAINT pk_stock_foreign_currency_price PRIMARY KEY ("itemno", "unicode");
ALTER TABLE silver.stock_transaction_header DROP CONSTRAINT IF EXISTS pk_stock_transaction_header;
ALTER TABLE silver.stock_transaction_header ADD CONSTRAINT pk_stock_transaction_header PRIMARY KEY ("anch", "trtype", "reference_number");
ALTER TABLE silver.stock_item DROP CONSTRAINT IF EXISTS pk_stock_item;
ALTER TABLE silver.stock_item ADD CONSTRAINT pk_stock_item PRIMARY KEY ("itemno");
ALTER TABLE silver.stock_item_photo DROP CONSTRAINT IF EXISTS pk_stock_item_photo;
ALTER TABLE silver.stock_item_photo ADD CONSTRAINT pk_stock_item_photo PRIMARY KEY ("itemno", "unicode");
ALTER TABLE silver.stock_reorder_level DROP CONSTRAINT IF EXISTS pk_stock_reorder_level;
ALTER TABLE silver.stock_reorder_level ADD CONSTRAINT pk_stock_reorder_level PRIMARY KEY ("itemno", "unicode");
ALTER TABLE silver.stock_unit_of_measure DROP CONSTRAINT IF EXISTS pk_stock_unit_of_measure;
ALTER TABLE silver.stock_unit_of_measure ADD CONSTRAINT pk_stock_unit_of_measure PRIMARY KEY ("itemno", "unicode");
ALTER TABLE silver.warehouse DROP CONSTRAINT IF EXISTS pk_warehouse;
ALTER TABLE silver.warehouse ADD CONSTRAINT pk_warehouse PRIMARY KEY ("whno");
ALTER TABLE silver.supplier DROP CONSTRAINT IF EXISTS pk_supplier;
ALTER TABLE silver.supplier ADD CONSTRAINT pk_supplier PRIMARY KEY ("company_id", "code", "cf_fcy");
ALTER TABLE silver.sys_user DROP CONSTRAINT IF EXISTS pk_sys_user;
ALTER TABLE silver.sys_user ADD CONSTRAINT pk_sys_user PRIMARY KEY ("username");
ALTER TABLE silver.tax_category DROP CONSTRAINT IF EXISTS pk_tax_category;
ALTER TABLE silver.tax_category ADD CONSTRAINT pk_tax_category PRIMARY KEY ("taxcatid");
ALTER TABLE silver.tax_period DROP CONSTRAINT IF EXISTS pk_tax_period;
ALTER TABLE silver.tax_period ADD CONSTRAINT pk_tax_period PRIMARY KEY ("taxprdcalcomp", "taxprdyrcode", "taxprdcode");

-- 2. FOREIGN KEYS (NOT VALID to allow legacy orphaned data)
ALTER TABLE silver.ap_invoice_detail DROP CONSTRAINT IF EXISTS fk_ap_invoice_detail_ap_invoice_header_phdr1;
ALTER TABLE silver.ap_invoice_detail ADD CONSTRAINT fk_ap_invoice_detail_ap_invoice_header_phdr1 
    FOREIGN KEY ("company_id", "type", "reference_number") REFERENCES silver.ap_invoice_header ("company_id", "type", "reference_number") NOT VALID;
ALTER TABLE silver.ar_invoice_detail DROP CONSTRAINT IF EXISTS fk_ar_invoice_detail_ar_invoice_header_rhdr1;
ALTER TABLE silver.ar_invoice_detail ADD CONSTRAINT fk_ar_invoice_detail_ar_invoice_header_rhdr1 
    FOREIGN KEY ("company_id", "type", "reference_number") REFERENCES silver.ar_invoice_header ("company_id", "type", "reference_number") NOT VALID;
ALTER TABLE silver.delivery_charge_detail DROP CONSTRAINT IF EXISTS fk_delivery_charge_detail_delivery_charge_header_hghdr;
ALTER TABLE silver.delivery_charge_detail ADD CONSTRAINT fk_delivery_charge_detail_delivery_charge_header_hghdr 
    FOREIGN KEY ("trx_id") REFERENCES silver.delivery_charge_header ("trx_id") NOT VALID;
ALTER TABLE silver.gl_journal_detail DROP CONSTRAINT IF EXISTS fk_gl_journal_detail_gl_journal_header_jrhdr;
ALTER TABLE silver.gl_journal_detail ADD CONSTRAINT fk_gl_journal_detail_gl_journal_header_jrhdr 
    FOREIGN KEY ("company_id", "type", "reference_number") REFERENCES silver.gl_journal_header ("company_id", "type", "reference_number") NOT VALID;
ALTER TABLE silver.purchase_order_detail DROP CONSTRAINT IF EXISTS fk_purchase_order_detail_purchase_order_header_puhdr;
ALTER TABLE silver.purchase_order_detail ADD CONSTRAINT fk_purchase_order_detail_purchase_order_header_puhdr 
    FOREIGN KEY ("company_id", "invoice_type", "reference_number") REFERENCES silver.purchase_order_header ("company_id", "invoice_type", "reference_number") NOT VALID;
ALTER TABLE silver.sales_order_detail DROP CONSTRAINT IF EXISTS fk_sales_order_detail_sales_order_header_es_hd;
ALTER TABLE silver.sales_order_detail ADD CONSTRAINT fk_sales_order_detail_sales_order_header_es_hd 
    FOREIGN KEY ("company_id", "invoice_type", "reference_number") REFERENCES silver.sales_order_header ("company_id", "invoice_type", "reference_number") NOT VALID;
ALTER TABLE silver.sales_quotation_detail DROP CONSTRAINT IF EXISTS fk_sales_quotation_detail_sales_quotation_header_es_qh;
ALTER TABLE silver.sales_quotation_detail ADD CONSTRAINT fk_sales_quotation_detail_sales_quotation_header_es_qh 
    FOREIGN KEY ("company_id", "reference_number") REFERENCES silver.sales_quotation_header ("company_id", "reference_number") NOT VALID;
ALTER TABLE silver.stock_bin DROP CONSTRAINT IF EXISTS fk_stock_bin_stock_unit_of_measure_units;
ALTER TABLE silver.stock_bin ADD CONSTRAINT fk_stock_bin_stock_unit_of_measure_units 
    FOREIGN KEY ("itemno", "unicode") REFERENCES silver.stock_unit_of_measure ("itemno", "unicode") NOT VALID;
ALTER TABLE silver.stock_transaction_detail DROP CONSTRAINT IF EXISTS fk_stock_transaction_detail_stock_transaction_header_sthdr;
ALTER TABLE silver.stock_transaction_detail ADD CONSTRAINT fk_stock_transaction_detail_stock_transaction_header_sthdr 
    FOREIGN KEY ("anch", "trtype", "reference_number") REFERENCES silver.stock_transaction_header ("anch", "trtype", "reference_number") NOT VALID;
ALTER TABLE silver.stock_foreign_currency_price DROP CONSTRAINT IF EXISTS fk_stock_foreign_currency_price_stock_unit_of_measure_units;
ALTER TABLE silver.stock_foreign_currency_price ADD CONSTRAINT fk_stock_foreign_currency_price_stock_unit_of_measure_units 
    FOREIGN KEY ("itemno", "unicode") REFERENCES silver.stock_unit_of_measure ("itemno", "unicode") NOT VALID;
ALTER TABLE silver.stock_item_replacement DROP CONSTRAINT IF EXISTS fk_stock_item_replacement_stock_unit_of_measure_units;
ALTER TABLE silver.stock_item_replacement ADD CONSTRAINT fk_stock_item_replacement_stock_unit_of_measure_units 
    FOREIGN KEY ("itemno", "unicode") REFERENCES silver.stock_unit_of_measure ("itemno", "unicode") NOT VALID;
ALTER TABLE silver.stock_item_photo DROP CONSTRAINT IF EXISTS fk_stock_item_photo_stock_unit_of_measure_units;
ALTER TABLE silver.stock_item_photo ADD CONSTRAINT fk_stock_item_photo_stock_unit_of_measure_units 
    FOREIGN KEY ("itemno", "unicode") REFERENCES silver.stock_unit_of_measure ("itemno", "unicode") NOT VALID;
ALTER TABLE silver.stock_reorder_level DROP CONSTRAINT IF EXISTS fk_stock_reorder_level_stock_unit_of_measure_units;
ALTER TABLE silver.stock_reorder_level ADD CONSTRAINT fk_stock_reorder_level_stock_unit_of_measure_units 
    FOREIGN KEY ("itemno", "unicode") REFERENCES silver.stock_unit_of_measure ("itemno", "unicode") NOT VALID;

END $$;
