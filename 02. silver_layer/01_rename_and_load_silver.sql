-- =========================================================================
-- SILVER LAYER STRUCTURAL TRANSFORMATION & DATA LOAD SCRIPT
-- 
-- PURPOSE:
--   1. Rename all 52 legacy tables to modern, contextual ERP naming.
--   2. Rename ALL columns from legacy codes (cu_name) to clean names (name).
--   3. Execute a full data load using PK-based deduplication.
-- =========================================================================

DO $$
BEGIN

-- -------------------------------------------------------------------------
-- PHASE 1: RENAME TABLES AND COLUMNS
-- -------------------------------------------------------------------------

ALTER TABLE IF EXISTS silver.apclass RENAME TO ap_classification;
ALTER TABLE IF EXISTS silver.ap_classification RENAME COLUMN "cl_company" TO "company_id";
ALTER TABLE IF EXISTS silver.ap_classification RENAME COLUMN "cl_code" TO "code";
ALTER TABLE IF EXISTS silver.ap_classification RENAME COLUMN "cl_desc" TO "desc";
ALTER TABLE IF EXISTS silver.ap_classification RENAME COLUMN "cl_crlser" TO "crlser";
ALTER TABLE IF EXISTS silver.ap_classification RENAME COLUMN "cl_dscser" TO "dscser";
ALTER TABLE IF EXISTS silver.ap_classification RENAME COLUMN "cl_salser" TO "salser";
ALTER TABLE IF EXISTS silver.ap_classification RENAME COLUMN "cl_ldesc" TO "ldesc";
ALTER TABLE IF EXISTS silver.aphdr RENAME TO ap_invoice_header;
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_company" TO "company_id";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_type" TO "type";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_date" TO "date";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_fcy" TO "fcy";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_ftotal" TO "ftotal";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_fcyrate" TO "fcyrate";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_ltotal" TO "ltotal";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_cucode" TO "customer_code";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_desc1" TO "desc1";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_ser" TO "ser";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_rlsd" TO "rlsd";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_posted" TO "posted";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_trxsrc" TO "trxsrc";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_sysdate" TO "sysdate";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_lcnet" TO "lcnet";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_fcnet" TO "fcnet";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_lccnet" TO "lccnet";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "hd_fccnet" TO "fccnet";
ALTER TABLE IF EXISTS silver.ap_invoice_header RENAME COLUMN "clcode" TO "class_code";
ALTER TABLE IF EXISTS silver.apdtl RENAME TO ap_invoice_detail;
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_company" TO "company_id";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_type" TO "type";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_date" TO "date";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_lcamt" TO "lcamt";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_paidamt" TO "paidamt";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_discamt" TO "discamt";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_cucode" TO "customer_code";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_fcy" TO "fcy";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_trxsrc" TO "trxsrc";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_fcamt" TO "fcamt";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_fpydamt" TO "fpydamt";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_fdscamt" TO "fdscamt";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_lcaloc" TO "lcaloc";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_fcaloc" TO "fcaloc";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_aloctd" TO "aloctd";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_pdinv" TO "pdinv";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_duedate" TO "duedate";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_desc" TO "desc";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_chkno" TO "chkno";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_chkdate" TO "chkdate";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_chkbnk" TO "chkbnk";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_dbcr" TO "dbcr";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_ackey" TO "ackey";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_folio" TO "folio";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_rcvno" TO "rcvno";
ALTER TABLE IF EXISTS silver.ap_invoice_detail RENAME COLUMN "dt_lstdate" TO "lstdate";
ALTER TABLE IF EXISTS silver.arhdr RENAME TO ar_invoice_header;
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_company" TO "company_id";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_type" TO "type";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_date" TO "date";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_fcy" TO "fcy";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_ftotal" TO "ftotal";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_fcyrate" TO "fcyrate";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_ltotal" TO "ltotal";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_cucode" TO "customer_code";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_desc1" TO "desc1";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_ser" TO "ser";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_rlsd" TO "rlsd";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_posted" TO "posted";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_trxsrc" TO "trxsrc";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_sysdate" TO "sysdate";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_lcnet" TO "lcnet";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_fcnet" TO "fcnet";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_lccnet" TO "lccnet";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "hd_fccnet" TO "fccnet";
ALTER TABLE IF EXISTS silver.ar_invoice_header RENAME COLUMN "clcode" TO "class_code";
ALTER TABLE IF EXISTS silver.ardtl RENAME TO ar_invoice_detail;
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_company" TO "company_id";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_type" TO "type";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_date" TO "date";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_lcamt" TO "lcamt";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_paidamt" TO "paidamt";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_discamt" TO "discamt";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_cucode" TO "customer_code";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_fcy" TO "fcy";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_trxsrc" TO "trxsrc";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_fcamt" TO "fcamt";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_fpydamt" TO "fpydamt";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_fdscamt" TO "fdscamt";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_lcaloc" TO "lcaloc";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_fcaloc" TO "fcaloc";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_aloctd" TO "aloctd";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_pdinv" TO "pdinv";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_duedate" TO "duedate";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_desc" TO "desc";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_chkno" TO "chkno";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_chkdate" TO "chkdate";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_chkbnk" TO "chkbnk";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_dbcr" TO "dbcr";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_ackey" TO "ackey";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_folio" TO "folio";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_rcvno" TO "rcvno";
ALTER TABLE IF EXISTS silver.ar_invoice_detail RENAME COLUMN "dt_lstdate" TO "lstdate";
ALTER TABLE IF EXISTS silver.bkbank RENAME TO bank;
ALTER TABLE IF EXISTS silver.bank RENAME COLUMN "bkcode" TO "code";
ALTER TABLE IF EXISTS silver.bank RENAME COLUMN "bkname" TO "name";
ALTER TABLE IF EXISTS silver.bank RENAME COLUMN "bklname" TO "lname";
ALTER TABLE IF EXISTS silver.bkacct RENAME TO bank_account;
ALTER TABLE IF EXISTS silver.bank_account RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.bank_account RENAME COLUMN "bkcode" TO "code";
ALTER TABLE IF EXISTS silver.bank_account RENAME COLUMN "actcode" TO "account_code";
ALTER TABLE IF EXISTS silver.bank_account RENAME COLUMN "bkbrname" TO "brname";
ALTER TABLE IF EXISTS silver.brselected RENAME TO branch_selection;
ALTER TABLE IF EXISTS silver.branch_selection RENAME COLUMN "brnno" TO "nno";
ALTER TABLE IF EXISTS silver.branch_selection RENAME COLUMN "priceupdt" TO "iceupdt";
ALTER TABLE IF EXISTS silver.classfil RENAME TO classification_file;
ALTER TABLE IF EXISTS silver.classification_file RENAME COLUMN "cl_company" TO "company_id";
ALTER TABLE IF EXISTS silver.classification_file RENAME COLUMN "cl_code" TO "code";
ALTER TABLE IF EXISTS silver.classification_file RENAME COLUMN "cl_desc" TO "desc";
ALTER TABLE IF EXISTS silver.classification_file RENAME COLUMN "cl_crlser" TO "crlser";
ALTER TABLE IF EXISTS silver.classification_file RENAME COLUMN "cl_dscser" TO "dscser";
ALTER TABLE IF EXISTS silver.classification_file RENAME COLUMN "cl_salser" TO "salser";
ALTER TABLE IF EXISTS silver.classification_file RENAME COLUMN "cl_ldesc" TO "ldesc";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_name" TO "name";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_company" TO "company_id";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_code" TO "code";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_class" TO "class";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_addrs" TO "addrs";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_tel" TO "tel";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_fax" TO "fax";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_tlx" TO "tlx";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_email" TO "email";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_cntactp" TO "cntactp";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_title" TO "title";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_crlmt" TO "crlmt";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_pymnt" TO "pymnt";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_status" TO "status";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_opnbal" TO "opnbal";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_curbal" TO "curbal";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_xrf" TO "xrf";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_alwcr" TO "alwcr";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_ctlser" TO "ctlser";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_lcaloc" TO "lcaloc";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_fcaloc" TO "fcaloc";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_instlmnt" TO "instlmnt";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_instldays" TO "instldays";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_install" TO "install";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_lname" TO "lname";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_city" TO "city";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_type" TO "type";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_laddrs" TO "laddrs";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_carrier" TO "carrier";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_mobile" TO "mobile";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_sendsms" TO "sendsms";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_onlycsh" TO "onlycsh";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_kind" TO "kind";
ALTER TABLE IF EXISTS silver.customer RENAME COLUMN "cu_invdsc" TO "invdsc";
ALTER TABLE IF EXISTS silver.delchghdr RENAME TO delivery_charge_header;
ALTER TABLE IF EXISTS silver.delivery_charge_header RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.delivery_charge_header RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.delivery_charge_header RENAME COLUMN "invtype" TO "invoice_type";
ALTER TABLE IF EXISTS silver.delivery_charge_header RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.delivery_charge_header RENAME COLUMN "pricetp" TO "icetp";
ALTER TABLE IF EXISTS silver.delivery_charge_header RENAME COLUMN "prpaidamt" TO "paidamt";
ALTER TABLE IF EXISTS silver.delivery_charge_header RENAME COLUMN "pricevattype" TO "icevattype";
ALTER TABLE IF EXISTS silver.delchgdtl RENAME TO delivery_charge_detail;
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "invtype" TO "invoice_type";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "price" TO "ice";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "sl_acfm" TO "acfm";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "jdtext" TO "text";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "brxref" TO "xref";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "dt_duedate" TO "duedate";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "dt_chkno" TO "chkno";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "dt_chkdate" TO "chkdate";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "dt_lstdate" TO "lstdate";
ALTER TABLE IF EXISTS silver.delivery_charge_detail RENAME COLUMN "dt_folio" TO "folio";
ALTER TABLE IF EXISTS silver.glchart RENAME TO gl_chart_of_accounts;
ALTER TABLE IF EXISTS silver.glcurr RENAME TO gl_currency;
ALTER TABLE IF EXISTS silver.glfcimage_rate RENAME TO gl_exchange_rate;
ALTER TABLE IF EXISTS silver.gl_exchange_rate RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.gljrhdr RENAME TO gl_journal_header;
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhcomp" TO "company_id";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhtype" TO "type";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhref" TO "reference_number";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhdate" TO "date";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhtext" TO "text";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhamt" TO "amt";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhentries" TO "entries";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhsrc" TO "src";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhsysdate" TO "sysdate";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhcurr" TO "curr";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhfcflag" TO "fcflag";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhrate" TO "rate";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhreleased" TO "released";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhposted" TO "posted";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhlccrttl" TO "lccrttl";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhlcdbttl" TO "lcdbttl";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhfccrttl" TO "fccrttl";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhfcdbttl" TO "fcdbttl";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhimgrate" TO "imgrate";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "brxref" TO "xref";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "brxfrm" TO "xfrm";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhcustno" TO "custno";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhtext1" TO "text1";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "jhfcamt" TO "fcamt";
ALTER TABLE IF EXISTS silver.gl_journal_header RENAME COLUMN "sc_codeyrtp" TO "codeyrtp";
ALTER TABLE IF EXISTS silver.gljrdtl RENAME TO gl_journal_detail;
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdcomp" TO "company_id";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdtype" TO "type";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdref" TO "reference_number";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdkey" TO "key";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jddate" TO "date";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdtext" TO "text";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdlcamt" TO "lcamt";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jddbcr" TO "dbcr";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdfcamt" TO "fcamt";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdcurr" TO "curr";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdfolio" TO "folio";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdfolno" TO "folno";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdsysdate" TO "sysdate";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdsrc" TO "src";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdfc_imgval" TO "fc_imgval";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jdcstval" TO "cstval";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "brnno" TO "nno";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "bracc" TO "acc";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "brxref" TO "xref";
ALTER TABLE IF EXISTS silver.gl_journal_detail RENAME COLUMN "jhcustno" TO "custno";
ALTER TABLE IF EXISTS silver.glsction RENAME TO gl_section;
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_code" TO "code";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_name" TO "name";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_lname" TO "lname";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_company" TO "company_id";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_whno" TO "whno";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_arcode" TO "arcode";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_nowh" TO "nowh";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_m_center" TO "m_center";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "pricevattype" TO "icevattype";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_card_srlno" TO "card_srlno";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_card_jvno" TO "card_jvno";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_lvlno" TO "lvlno";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_lvl1" TO "lvl1";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_lvl2" TO "lvl2";
ALTER TABLE IF EXISTS silver.gl_section RENAME COLUMN "sc_lvl3" TO "lvl3";
ALTER TABLE IF EXISTS silver.orcountry RENAME TO country;
ALTER TABLE IF EXISTS silver.orpacking RENAME TO packing_type;
ALTER TABLE IF EXISTS silver.pricehst RENAME TO price_history;
ALTER TABLE IF EXISTS silver.price_history RENAME COLUMN "prcode" TO "code";
ALTER TABLE IF EXISTS silver.price_history RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.price_history RENAME COLUMN "promotion" TO "omotion";
ALTER TABLE IF EXISTS silver.price_history RENAME COLUMN "prm_start" TO "m_start";
ALTER TABLE IF EXISTS silver.price_history RENAME COLUMN "prm_end" TO "m_end";
ALTER TABLE IF EXISTS silver.pudept RENAME TO purchase_department;
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_name" TO "name";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_brno" TO "brno";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_dept" TO "dept";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_cashser" TO "cashser";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_cslser" TO "cslser";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_oslser" TO "oslser";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_rcslser" TO "rcslser";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_roslser" TO "roslser";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_custser" TO "custser";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_expser" TO "expser";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_okdiff" TO "okdiff";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_diffser" TO "diffser";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_mainwh" TO "mainwh";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_rtrnwh" TO "rtrnwh";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_comp" TO "company_id";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "dp_lname" TO "lname";
ALTER TABLE IF EXISTS silver.purchase_department RENAME COLUMN "sc_code" TO "code";
ALTER TABLE IF EXISTS silver.puhdr RENAME TO purchase_order_header;
ALTER TABLE IF EXISTS silver.purchase_order_header RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.purchase_order_header RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.purchase_order_header RENAME COLUMN "invtype" TO "invoice_type";
ALTER TABLE IF EXISTS silver.purchase_order_header RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.purchase_order_header RENAME COLUMN "pricetp" TO "icetp";
ALTER TABLE IF EXISTS silver.purchase_order_header RENAME COLUMN "prodrate" TO "odrate";
ALTER TABLE IF EXISTS silver.purchase_order_header RENAME COLUMN "priceincludevat" TO "iceincludevat";
ALTER TABLE IF EXISTS silver.pudtl RENAME TO purchase_order_detail;
ALTER TABLE IF EXISTS silver.purchase_order_detail RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.purchase_order_detail RENAME COLUMN "invtype" TO "invoice_type";
ALTER TABLE IF EXISTS silver.purchase_order_detail RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.purchase_order_detail RENAME COLUMN "price" TO "ice";
ALTER TABLE IF EXISTS silver.purchase_order_detail RENAME COLUMN "sl_acfm" TO "acfm";
ALTER TABLE IF EXISTS silver.salecntr RENAME TO sales_center;
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_name" TO "name";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_brno" TO "brno";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_dept" TO "dept";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_cashser" TO "cashser";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_cslser" TO "cslser";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_oslser" TO "oslser";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_rcslser" TO "rcslser";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_roslser" TO "roslser";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_custser" TO "custser";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_expser" TO "expser";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_okdiff" TO "okdiff";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_diffser" TO "diffser";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_mainwh" TO "mainwh";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_rtrnwh" TO "rtrnwh";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_comp" TO "company_id";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_fccrdt" TO "fccrdt";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_crdcardac" TO "crdcardac";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_rplsac" TO "rplsac";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_cardcomm" TO "cardcomm";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "dp_lname" TO "lname";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "prpaidcrdac" TO "paidcrdac";
ALTER TABLE IF EXISTS silver.sales_center RENAME COLUMN "sc_code" TO "code";
ALTER TABLE IF EXISTS silver.sales_hd RENAME TO sales_order_header;
ALTER TABLE IF EXISTS silver.sales_order_header RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.sales_order_header RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.sales_order_header RENAME COLUMN "invtype" TO "invoice_type";
ALTER TABLE IF EXISTS silver.sales_order_header RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.sales_order_header RENAME COLUMN "pricetp" TO "icetp";
ALTER TABLE IF EXISTS silver.sales_order_header RENAME COLUMN "prpaidamt" TO "paidamt";
ALTER TABLE IF EXISTS silver.sales_order_header RENAME COLUMN "pricevattype" TO "icevattype";
ALTER TABLE IF EXISTS silver.sales_order_header RENAME COLUMN "pricetacfeestype" TO "icetacfeestype";
ALTER TABLE IF EXISTS silver.sales_dt RENAME TO sales_order_detail;
ALTER TABLE IF EXISTS silver.sales_order_detail RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.sales_order_detail RENAME COLUMN "invtype" TO "invoice_type";
ALTER TABLE IF EXISTS silver.sales_order_detail RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.sales_order_detail RENAME COLUMN "price" TO "ice";
ALTER TABLE IF EXISTS silver.sales_order_detail RENAME COLUMN "sl_acfm" TO "acfm";
ALTER TABLE IF EXISTS silver.sales_qh RENAME TO sales_quotation_header;
ALTER TABLE IF EXISTS silver.sales_quotation_header RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.sales_quotation_header RENAME COLUMN "invtype" TO "invoice_type";
ALTER TABLE IF EXISTS silver.sales_quotation_header RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.sales_quotation_header RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.sales_quotation_header RENAME COLUMN "pricetp" TO "icetp";
ALTER TABLE IF EXISTS silver.sales_qd RENAME TO sales_quotation_detail;
ALTER TABLE IF EXISTS silver.sales_quotation_detail RENAME COLUMN "invtype" TO "invoice_type";
ALTER TABLE IF EXISTS silver.sales_quotation_detail RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.sales_quotation_detail RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.sales_quotation_detail RENAME COLUMN "price" TO "ice";
ALTER TABLE IF EXISTS silver.sales_quotation_detail RENAME COLUMN "sl_acfm" TO "acfm";
ALTER TABLE IF EXISTS silver.salesmen RENAME TO sales_representative;
ALTER TABLE IF EXISTS silver.sales_representative RENAME COLUMN "sl_center" TO "center";
ALTER TABLE IF EXISTS silver.slinvexp RENAME TO sales_invoice_expense;
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "invtype" TO "invoice_type";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "broker_code" TO "oker_code";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "broker_amt" TO "oker_amt";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "broker_prcnt" TO "oker_prcnt";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "broker_vat_amt" TO "oker_vat_amt";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "broker_taxable" TO "oker_taxable";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "broker_ttlcmsn" TO "oker_ttlcmsn";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "broker_cmnamt" TO "oker_cmnamt";
ALTER TABLE IF EXISTS silver.sales_invoice_expense RENAME COLUMN "pricewithtransport" TO "icewithtransport";
ALTER TABLE IF EXISTS silver.starea RENAME TO stock_area;
ALTER TABLE IF EXISTS silver.stbranch RENAME TO stock_branch;
ALTER TABLE IF EXISTS silver.stock_branch RENAME COLUMN "brnno" TO "nno";
ALTER TABLE IF EXISTS silver.stock_branch RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.stock_branch RENAME COLUMN "pricetp" TO "icetp";
ALTER TABLE IF EXISTS silver.stock_branch RENAME COLUMN "pricevattype" TO "icevattype";
ALTER TABLE IF EXISTS silver.stock_branch RENAME COLUMN "sc_lvlno" TO "lvlno";
ALTER TABLE IF EXISTS silver.stbins RENAME TO stock_bin;
ALTER TABLE IF EXISTS silver.stock_bin RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.stclass RENAME TO stock_classification;
ALTER TABLE IF EXISTS silver.stcosttype RENAME TO stock_cost_type;
ALTER TABLE IF EXISTS silver.stock_cost_type RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.stock_cost_type RENAME COLUMN "brlastissue" TO "lastissue";
ALTER TABLE IF EXISTS silver.stcrtpuinv RENAME TO stock_purchase_invoice;
ALTER TABLE IF EXISTS silver.stock_purchase_invoice RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.stdtl RENAME TO stock_transaction_detail;
ALTER TABLE IF EXISTS silver.stock_transaction_detail RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.stock_transaction_detail RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.stfcyprice RENAME TO stock_foreign_currency_price;
ALTER TABLE IF EXISTS silver.sthdr RENAME TO stock_transaction_header;
ALTER TABLE IF EXISTS silver.stock_transaction_header RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.stock_transaction_header RENAME COLUMN "ref" TO "reference_number";
ALTER TABLE IF EXISTS silver.stock_transaction_header RENAME COLUMN "brsupp" TO "supp";
ALTER TABLE IF EXISTS silver.stock_transaction_header RENAME COLUMN "brxref" TO "xref";
ALTER TABLE IF EXISTS silver.stock_transaction_header RENAME COLUMN "pricetp" TO "icetp";
ALTER TABLE IF EXISTS silver.stitemrp RENAME TO stock_item_replacement;
ALTER TABLE IF EXISTS silver.stitems RENAME TO stock_item;
ALTER TABLE IF EXISTS silver.stock_item RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.stock_item RENAME COLUMN "prntasmitm" TO "ntasmitm";
ALTER TABLE IF EXISTS silver.stock_item RENAME COLUMN "prmdesc" TO "mdesc";
ALTER TABLE IF EXISTS silver.stock_item RENAME COLUMN "brand_id" TO "and_id";
ALTER TABLE IF EXISTS silver.stitmphoto RENAME TO stock_item_photo;
ALTER TABLE IF EXISTS silver.stprice RENAME TO stock_price;
ALTER TABLE IF EXISTS silver.streorderqp RENAME TO stock_reorder_level;
ALTER TABLE IF EXISTS silver.stunits RENAME TO stock_unit_of_measure;
ALTER TABLE IF EXISTS silver.stock_unit_of_measure RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.stock_unit_of_measure RENAME COLUMN "prmcode" TO "mcode";
ALTER TABLE IF EXISTS silver.stwhous RENAME TO warehouse;
ALTER TABLE IF EXISTS silver.warehouse RENAME COLUMN "branch" TO "anch";
ALTER TABLE IF EXISTS silver.warehouse RENAME COLUMN "prnt_fsh" TO "nt_fsh";
ALTER TABLE IF EXISTS silver.warehouse RENAME COLUMN "sc_code" TO "code";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_name" TO "name";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_company" TO "company_id";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_code" TO "code";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_class" TO "class";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_addrs" TO "addrs";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_tel" TO "tel";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_fax" TO "fax";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_tlx" TO "tlx";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_email" TO "email";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_cntactp" TO "cntactp";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_title" TO "title";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_crlmt" TO "crlmt";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_pymnt" TO "pymnt";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_status" TO "status";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_opnbal" TO "opnbal";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_curbal" TO "curbal";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_xrf" TO "xrf";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_alwcr" TO "alwcr";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_ctlser" TO "ctlser";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_lcaloc" TO "lcaloc";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_fcaloc" TO "fcaloc";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_lname" TO "lname";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_city" TO "city";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_country" TO "country";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_laddrs" TO "laddrs";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_mobile" TO "mobile";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_sendsms" TO "sendsms";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_kind" TO "kind";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "priceincludevat" TO "iceincludevat";
ALTER TABLE IF EXISTS silver.supplier RENAME COLUMN "cu_type" TO "type";
ALTER TABLE IF EXISTS silver.sysuse RENAME TO sys_user;
ALTER TABLE IF EXISTS silver.sys_user RENAME COLUMN "company" TO "company_id";
ALTER TABLE IF EXISTS silver.sys_user RENAME COLUMN "printinv" TO "intinv";
ALTER TABLE IF EXISTS silver.sys_user RENAME COLUMN "printtrx" TO "inttrx";
ALTER TABLE IF EXISTS silver.sys_user RENAME COLUMN "printbarcode" TO "intbarcode";
ALTER TABLE IF EXISTS silver.taxcategory RENAME TO tax_category;
ALTER TABLE IF EXISTS silver.taxperiod RENAME TO tax_period;
ALTER TABLE IF EXISTS silver.taxlog RENAME TO tax_log;


-- -------------------------------------------------------------------------
-- PHASE 2: FULL DATA LOAD FROM BRONZE TO SILVER
-- 
-- We load data using 'SELECT DISTINCT ON (pk_cols)' to ensure the 
-- data integrity of logically unique rows across all 4 databases.
-- -------------------------------------------------------------------------

-- Load: bronze.apclass -> silver.ap_classification
TRUNCATE TABLE silver.ap_classification CASCADE;

INSERT INTO silver.ap_classification ("company_id", "code", "desc", "crlser", "dscser", "salser", "lastupdt", "modified", "ldesc", "rowguid", "cstcode", "classkey")
SELECT DISTINCT ON ("cl_company", "cl_code") "cl_company", "cl_code", "cl_desc", "cl_crlser", "cl_dscser", "cl_salser", "lastupdt", "modified", "cl_ldesc", "rowguid", "cstcode", "classkey"
FROM bronze.apclass 
ORDER BY "cl_company", "cl_code", _source_archive DESC;

-- Load: bronze.aphdr -> silver.ap_invoice_header
TRUNCATE TABLE silver.ap_invoice_header CASCADE;

INSERT INTO silver.ap_invoice_header ("company_id", "type", "reference_number", "date", "fcy", "ftotal", "fcyrate", "ltotal", "customer_code", "desc1", "ser", "rlsd", "posted", "trxsrc", "sysdate", "lcnet", "fcnet", "lccnet", "fccnet", "isit_opst", "opst_val", "opst_fcy", "lastupdt", "modified", "rcvdtrn", "usrid", "class_code", "clcmnd", "dscamt", "payinv", "rowguid", "bankref", "is_numerator")
SELECT DISTINCT ON ("hd_company", "hd_type", "hd_ref") "hd_company", "hd_type", "hd_ref", "hd_date", "hd_fcy", "hd_ftotal", "hd_fcyrate", "hd_ltotal", "hd_cucode", "hd_desc1", "hd_ser", "hd_rlsd", "hd_posted", "hd_trxsrc", "hd_sysdate", "hd_lcnet", "hd_fcnet", "hd_lccnet", "hd_fccnet", "isit_opst", "opst_val", "opst_fcy", "lastupdt", "modified", "rcvdtrn", "usrid", "clcode", "clcmnd", "dscamt", "payinv", "rowguid", "bankref", "is_numerator"
FROM bronze.aphdr 
ORDER BY "hd_company", "hd_type", "hd_ref", _source_archive DESC;

-- Load: bronze.apdtl -> silver.ap_invoice_detail
TRUNCATE TABLE silver.ap_invoice_detail CASCADE;

INSERT INTO silver.ap_invoice_detail ("company_id", "type", "reference_number", "date", "lcamt", "paidamt", "discamt", "customer_code", "fcy", "trxsrc", "fcamt", "fpydamt", "fdscamt", "lcaloc", "fcaloc", "aloctd", "pdinv", "duedate", "desc", "chkno", "chkdate", "chkbnk", "dbcr", "ackey", "folio", "rcvno", "lstdate", "tdscdays", "tdscpcs", "match", "rplct_post", "rowguid")
SELECT DISTINCT ON ("dt_company", "dt_type", "dt_ref", "dt_folio") "dt_company", "dt_type", "dt_ref", "dt_date", "dt_lcamt", "dt_paidamt", "dt_discamt", "dt_cucode", "dt_fcy", "dt_trxsrc", "dt_fcamt", "dt_fpydamt", "dt_fdscamt", "dt_lcaloc", "dt_fcaloc", "dt_aloctd", "dt_pdinv", "dt_duedate", "dt_desc", "dt_chkno", "dt_chkdate", "dt_chkbnk", "dt_dbcr", "dt_ackey", "dt_folio", "dt_rcvno", "dt_lstdate", "tdscdays", "tdscpcs", "match", "rplct_post", "rowguid"
FROM bronze.apdtl 
ORDER BY "dt_company", "dt_type", "dt_ref", "dt_folio", _source_archive DESC;

-- Load: bronze.arhdr -> silver.ar_invoice_header
TRUNCATE TABLE silver.ar_invoice_header CASCADE;

INSERT INTO silver.ar_invoice_header ("company_id", "type", "reference_number", "date", "fcy", "ftotal", "fcyrate", "ltotal", "customer_code", "desc1", "ser", "rlsd", "posted", "trxsrc", "sysdate", "lcnet", "fcnet", "lccnet", "fccnet", "isit_opst", "opst_val", "opst_fcy", "lastupdt", "modified", "rcvdtrn", "usrid", "class_code", "clcmnd", "dscamt", "payinv", "is_numerator", "discountedbill")
SELECT DISTINCT ON ("hd_company", "hd_type", "hd_ref") "hd_company", "hd_type", "hd_ref", "hd_date", "hd_fcy", "hd_ftotal", "hd_fcyrate", "hd_ltotal", "hd_cucode", "hd_desc1", "hd_ser", "hd_rlsd", "hd_posted", "hd_trxsrc", "hd_sysdate", "hd_lcnet", "hd_fcnet", "hd_lccnet", "hd_fccnet", "isit_opst", "opst_val", "opst_fcy", "lastupdt", "modified", "rcvdtrn", "usrid", "clcode", "clcmnd", "dscamt", "payinv", "is_numerator", "discountedbill"
FROM bronze.arhdr 
ORDER BY "hd_company", "hd_type", "hd_ref", _source_archive DESC;

-- Load: bronze.ardtl -> silver.ar_invoice_detail
TRUNCATE TABLE silver.ar_invoice_detail CASCADE;

INSERT INTO silver.ar_invoice_detail ("company_id", "type", "reference_number", "date", "lcamt", "paidamt", "discamt", "customer_code", "fcy", "trxsrc", "fcamt", "fpydamt", "fdscamt", "lcaloc", "fcaloc", "aloctd", "pdinv", "duedate", "desc", "chkno", "chkdate", "chkbnk", "dbcr", "ackey", "folio", "rcvno", "lstdate", "tdscdays", "tdscpcs", "match", "rplct_post")
SELECT DISTINCT ON ("dt_company", "dt_type", "dt_ref", "dt_folio") "dt_company", "dt_type", "dt_ref", "dt_date", "dt_lcamt", "dt_paidamt", "dt_discamt", "dt_cucode", "dt_fcy", "dt_trxsrc", "dt_fcamt", "dt_fpydamt", "dt_fdscamt", "dt_lcaloc", "dt_fcaloc", "dt_aloctd", "dt_pdinv", "dt_duedate", "dt_desc", "dt_chkno", "dt_chkdate", "dt_chkbnk", "dt_dbcr", "dt_ackey", "dt_folio", "dt_rcvno", "dt_lstdate", "tdscdays", "tdscpcs", "match", "rplct_post"
FROM bronze.ardtl 
ORDER BY "dt_company", "dt_type", "dt_ref", "dt_folio", _source_archive DESC;

-- Load: bronze.bkbank -> silver.bank
TRUNCATE TABLE silver.bank CASCADE;

INSERT INTO silver.bank ("code", "name", "lname", "lastupdt")
SELECT DISTINCT ON ("bkcode") "bkcode", "bkname", "bklname", "lastupdt"
FROM bronze.bkbank 
ORDER BY "bkcode", _source_archive DESC;

-- Load: bronze.bkacct -> silver.bank_account
TRUNCATE TABLE silver.bank_account CASCADE;

INSERT INTO silver.bank_account ("company_id", "code", "account_code", "brname", "actname", "actno", "glact", "srlcode", "addrs", "stopped", "autonm", "actlname", "lastupdt")
SELECT DISTINCT ON ("company", "bkcode", "actcode") "company", "bkcode", "actcode", "bkbrname", "actname", "actno", "glact", "srlcode", "addrs", "stopped", "autonm", "actlname", "lastupdt"
FROM bronze.bkacct 
ORDER BY "company", "bkcode", "actcode", _source_archive DESC;

-- Load: bronze.brselected -> silver.branch_selection
TRUNCATE TABLE silver.branch_selection CASCADE;

INSERT INTO silver.branch_selection ("name", "nno", "selectd", "newbarcode", "iceupdt", "noupdate")
SELECT DISTINCT "name", "brnno", "selectd", "newbarcode", "priceupdt", "noupdate" FROM bronze.brselected;

-- Load: bronze.classfil -> silver.classification_file
TRUNCATE TABLE silver.classification_file CASCADE;

INSERT INTO silver.classification_file ("company_id", "code", "desc", "crlser", "dscser", "salser", "lastupdt", "modified", "ldesc", "cstcode")
SELECT DISTINCT ON ("cl_company", "cl_code") "cl_company", "cl_code", "cl_desc", "cl_crlser", "cl_dscser", "cl_salser", "lastupdt", "modified", "cl_ldesc", "cstcode"
FROM bronze.classfil 
ORDER BY "cl_company", "cl_code", _source_archive DESC;

-- Load: bronze.customer -> silver.customer
TRUNCATE TABLE silver.customer CASCADE;

INSERT INTO silver.customer ("name", "company_id", "code", "class", "addrs", "tel", "fax", "tlx", "email", "cntactp", "title", "crlmt", "pymnt", "status", "opnbal", "curbal", "cf_fcy", "cf_opnfcy", "cf_curfcy", "xrf", "alwcr", "ctlser", "lastupdt", "lcaloc", "fcaloc", "instlmnt", "instldays", "install", "modified", "cmncode", "lname", "city", "type", "laddrs", "carrier", "mobile", "section", "sendsms", "onlycsh", "clnt_taxcode", "taxfree", "kind", "ok_free", "ok_no_pay", "ok_no_down_payment", "exduplimit", "individual_clnt", "location", "usrid", "usridchg", "added_date", "invdsc", "lst_inv_excd_duedate", "slcode")
SELECT DISTINCT ON ("cu_company", "cu_code", "cf_fcy") "cu_name", "cu_company", "cu_code", "cu_class", "cu_addrs", "cu_tel", "cu_fax", "cu_tlx", "cu_email", "cu_cntactp", "cu_title", "cu_crlmt", "cu_pymnt", "cu_status", "cu_opnbal", "cu_curbal", "cf_fcy", "cf_opnfcy", "cf_curfcy", "cu_xrf", "cu_alwcr", "cu_ctlser", "lastupdt", "cu_lcaloc", "cu_fcaloc", "cu_instlmnt", "cu_instldays", "cu_install", "modified", "cmncode", "cu_lname", "cu_city", "cu_type", "cu_laddrs", "cu_carrier", "cu_mobile", "section", "cu_sendsms", "cu_onlycsh", "clnt_taxcode", "taxfree", "cu_kind", "ok_free", "ok_no_pay", "ok_no_down_payment", "exduplimit", "individual_clnt", "location", "usrid", "usridchg", "added_date", "cu_invdsc", "lst_inv_excd_duedate", "slcode"
FROM bronze.customer 
ORDER BY "cu_company", "cu_code", "cf_fcy", _source_archive DESC;

-- Load: bronze.delchghdr -> silver.delivery_charge_header
TRUNCATE TABLE silver.delivery_charge_header CASCADE;

INSERT INTO silver.delivery_charge_header ("slcenter", "anch", "company_id", "invoice_type", "reference_number", "invdate", "custno", "custnm", "glser", "dsctype", "pstmode", "fcy", "fcyrate", "duedate", "invttl", "invcst", "invdspc", "invdsvl", "valafds", "invpaid", "caser", "entries", "released", "posted", "fixrate", "extamt", "extser", "icetp", "ischeque", "chkno", "chkdate", "lastupdt", "jvgenrt", "cccommsn", "belowbal", "fcy2", "ccpayment", "rplsamt", "pdother", "slcode", "paidamt", "instldays", "instflag", "slcmnd", "inv_printed", "bendit", "modified", "rqstorder", "rqststld", "carrier", "rcvdtrn", "usrid", "address", "suspend", "rtnref", "ispurchase", "stkjvno", "posinv", "whodelete", "action_type", "action_tdate", "src", "trx_id", "icevattype", "clnt_kind", "vat_amt_rcvd", "vat_percent", "crtd_fm_batch_ref", "diffamount", "fld1", "fld2", "fld3")
SELECT DISTINCT ON ("trx_id") "slcenter", "branch", "company", "invtype", "ref", "invdate", "custno", "custnm", "glser", "dsctype", "pstmode", "fcy", "fcyrate", "duedate", "invttl", "invcst", "invdspc", "invdsvl", "valafds", "invpaid", "caser", "entries", "released", "posted", "fixrate", "extamt", "extser", "pricetp", "ischeque", "chkno", "chkdate", "lastupdt", "jvgenrt", "cccommsn", "belowbal", "fcy2", "ccpayment", "rplsamt", "pdother", "slcode", "prpaidamt", "instldays", "instflag", "slcmnd", "inv_printed", "bendit", "modified", "rqstorder", "rqststld", "carrier", "rcvdtrn", "usrid", "address", "suspend", "rtnref", "ispurchase", "stkjvno", "posinv", "whodelete", "action_type", "action_tdate", "src", "trx_id", "pricevattype", "clnt_kind", "vat_amt_rcvd", "vat_percent", "crtd_fm_batch_ref", "diffamount", "fld1", "fld2", "fld3"
FROM bronze.delchghdr 
ORDER BY "trx_id", _source_archive DESC;

-- Load: bronze.delchgdtl -> silver.delivery_charge_detail
TRUNCATE TABLE silver.delivery_charge_detail CASCADE;

INSERT INTO silver.delivery_charge_detail ("slcenter", "company_id", "invoice_type", "reference_number", "invdate", "itemno", "unicode", "qty", "fqty", "ice", "discpc", "cost", "ds_acfm", "acfm", "gclass", "custno", "fcy", "barcode", "imfcval", "pack", "pkqty", "shadd", "shdpk", "shdqty", "frtqty", "rtnqty", "whno", "cmbkey", "trx_id", "text", "dbcr", "src", "fld1", "fld2", "acc", "xref", "match", "duedate", "chkno", "chkdate", "lstdate", "folio", "tdscdays", "taxtype", "amtincldvat", "vndr_name", "fld3", "fld4", "fld5", "fld6", "fld7", "fld8", "fld9")
SELECT DISTINCT "slcenter", "company", "invtype", "ref", "invdate", "itemno", "unicode", "qty", "fqty", "price", "discpc", "cost", "ds_acfm", "sl_acfm", "gclass", "custno", "fcy", "barcode", "imfcval", "pack", "pkqty", "shadd", "shdpk", "shdqty", "frtqty", "rtnqty", "whno", "cmbkey", "trx_id", "jdtext", "dbcr", "src", "fld1", "fld2", "acc", "brxref", "match", "dt_duedate", "dt_chkno", "dt_chkdate", "dt_lstdate", "dt_folio", "tdscdays", "taxtype", "amtincldvat", "vndr_name", "fld3", "fld4", "fld5", "fld6", "fld7", "fld8", "fld9" FROM bronze.delchgdtl;

-- Load: bronze.glchart -> silver.gl_chart_of_accounts
TRUNCATE TABLE silver.gl_chart_of_accounts CASCADE;

INSERT INTO silver.gl_chart_of_accounts ("glname", "glkey", "glcomp", "glcurbal", "glopnbal", "glopndate", "glamnd", "glacttyp", "glgroup", "glactive", "glpurge", "accontrol", "glp_lcode", "glcurrency", "glbal01", "glbal02", "glbal03", "glbal04", "glbal05", "glbal06", "glbal07", "glbal08", "glbal09", "glbal10", "glbal11", "glbal12", "glbal13", "fccurbal", "fcopnbal", "fcbal01", "fcbal02", "fcbal03", "fcbal04", "fcbal05", "fcbal06", "fcbal07", "fcbal08", "fcbal09", "fcbal10", "fcbal11", "fcbal12", "fcbal13", "glsgrp", "imopnbal", "imcurbal", "lastupdt", "gleval", "acprotect", "pkey", "chkey", "cashbnk", "modified", "gllname", "section", "isbracc", "actlvl", "glackind", "rowguid", "usrid", "usridchg")
SELECT DISTINCT ON ("glkey", "glcurrency") "glname", "glkey", "glcomp", "glcurbal", "glopnbal", "glopndate", "glamnd", "glacttyp", "glgroup", "glactive", "glpurge", "accontrol", "glp_lcode", "glcurrency", "glbal01", "glbal02", "glbal03", "glbal04", "glbal05", "glbal06", "glbal07", "glbal08", "glbal09", "glbal10", "glbal11", "glbal12", "glbal13", "fccurbal", "fcopnbal", "fcbal01", "fcbal02", "fcbal03", "fcbal04", "fcbal05", "fcbal06", "fcbal07", "fcbal08", "fcbal09", "fcbal10", "fcbal11", "fcbal12", "fcbal13", "glsgrp", "imopnbal", "imcurbal", "lastupdt", "gleval", "acprotect", "pkey", "chkey", "cashbnk", "modified", "gllname", "section", "isbracc", "actlvl", "glackind", "rowguid", "usrid", "usridchg"
FROM bronze.glchart 
ORDER BY "glkey", "glcurrency", _source_archive DESC;

-- Load: bronze.glcurr -> silver.gl_currency
TRUNCATE TABLE silver.gl_currency CASCADE;

INSERT INTO silver.gl_currency ("curname", "curcode", "currate", "curfix", "cursname", "lastupdt", "curparts", "modified", "curlname", "curlsname", "curlparts", "fcimage_rate", "fcwh_rate", "is_numerator", "curminrate", "curmaxrate", "standard_fcy_code", "posrate", "posusrid")
SELECT DISTINCT ON ("curcode") "curname", "curcode", "currate", "curfix", "cursname", "lastupdt", "curparts", "modified", "curlname", "curlsname", "curlparts", "fcimage_rate", "fcwh_rate", "is_numerator", "curminrate", "curmaxrate", "standard_fcy_code", "posrate", "posusrid"
FROM bronze.glcurr 
ORDER BY "curcode", _source_archive DESC;

-- Load: bronze.glfcimage_rate -> silver.gl_exchange_rate
TRUNCATE TABLE silver.gl_exchange_rate CASCADE;

INSERT INTO silver.gl_exchange_rate ("company_id", "image_fc_usrid", "image_fc_date", "image_fc_srlno", "image_fc_rate", "image_fc_datetime", "image_fc_fcy", "main_fc_fcy", "main_fcy_rate")
SELECT DISTINCT ON ("company", "image_fc_usrid", "image_fc_date", "image_fc_srlno") "company", "image_fc_usrid", "image_fc_date", "image_fc_srlno", "image_fc_rate", "image_fc_datetime", "image_fc_fcy", "main_fc_fcy", "main_fcy_rate"
FROM bronze.glfcimage_rate 
ORDER BY "company", "image_fc_usrid", "image_fc_date", "image_fc_srlno", _source_archive DESC;

-- Load: bronze.gljrhdr -> silver.gl_journal_header
TRUNCATE TABLE silver.gl_journal_header CASCADE;

INSERT INTO silver.gl_journal_header ("company_id", "type", "reference_number", "date", "text", "amt", "entries", "src", "sysdate", "curr", "fcflag", "rate", "released", "posted", "lastupdt", "lccrttl", "lcdbttl", "fccrttl", "fcdbttl", "imgrate", "modified", "serial_no", "rcvdtrn", "suspend", "usrid", "isbrtrx", "xref", "xfrm", "custno", "hide_jv", "rowguid", "bankref", "vat_percent", "text1", "is_numerator", "fcamt", "zatca_rounding", "codeyrtp")
SELECT DISTINCT ON ("jhcomp", "jhtype", "jhref") "jhcomp", "jhtype", "jhref", "jhdate", "jhtext", "jhamt", "jhentries", "jhsrc", "jhsysdate", "jhcurr", "jhfcflag", "jhrate", "jhreleased", "jhposted", "lastupdt", "jhlccrttl", "jhlcdbttl", "jhfccrttl", "jhfcdbttl", "jhimgrate", "modified", "serial_no", "rcvdtrn", "suspend", "usrid", "isbrtrx", "brxref", "brxfrm", "jhcustno", "hide_jv", "rowguid", "bankref", "vat_percent", "jhtext1", "is_numerator", "jhfcamt", "zatca_rounding", "sc_codeyrtp"
FROM bronze.gljrhdr 
ORDER BY "jhcomp", "jhtype", "jhref", _source_archive DESC;

-- Load: bronze.gljrdtl -> silver.gl_journal_detail
TRUNCATE TABLE silver.gl_journal_detail CASCADE;

INSERT INTO silver.gl_journal_detail ("company_id", "type", "reference_number", "key", "date", "text", "lcamt", "dbcr", "fcamt", "curr", "folio", "folno", "sysdate", "src", "fc_imgval", "cstval", "cstkey", "nno", "acc", "xref", "match", "rplct_post", "rowguid", "taxcatid", "custno")
SELECT DISTINCT ON ("jdcomp", "jdtype", "jdref", "jdfolio") "jdcomp", "jdtype", "jdref", "jdkey", "jddate", "jdtext", "jdlcamt", "jddbcr", "jdfcamt", "jdcurr", "jdfolio", "jdfolno", "jdsysdate", "jdsrc", "jdfc_imgval", "jdcstval", "cstkey", "brnno", "bracc", "brxref", "match", "rplct_post", "rowguid", "taxcatid", "jhcustno"
FROM bronze.gljrdtl 
ORDER BY "jdcomp", "jdtype", "jdref", "jdfolio", _source_archive DESC;

-- Load: bronze.glsction -> silver.gl_section
TRUNCATE TABLE silver.gl_section CASCADE;

INSERT INTO silver.gl_section ("code", "name", "lname", "company_id", "whno", "arcode", "nowh", "m_center", "lastupdt", "rebate_act", "lossrebateact", "jv_01", "jv_02", "jv_03", "jv_04", "jv_05", "jv_06", "jv_07", "jv_08", "jv_09", "jv_10", "jv_11", "jv_12", "jv_13", "jv_14", "jv_16", "jv_17", "jv_18", "jv_19", "jv_20", "jv_21", "jv_22", "jv_23", "jv_24", "jv_26", "jv_27", "jv_28", "jv_30", "jv_31", "jv_32", "jv_33", "jv_34", "jv_37", "jv_45", "jv_46", "jv_51", "jv_55", "jv_56", "jv_60", "jv_61", "sysno", "no_round_nm", "icevattype", "mkt_frc_rounding", "is_dsc_amt", "auto_dsc_hll", "max_dsc_hll", "card_srlno", "card_jvno", "ar_dscser", "ap_dscser", "lvlno", "jv_105", "jv_106", "jv_107", "jv_108", "jv_109", "jv_110", "jv_205", "jv_209", "jv_210", "jv_211", "jv_212", "jv_213", "jv_214", "jv_215", "jv_216", "jv_301", "jv_501", "jv_502", "cashser", "lvl1", "lvl2", "lvl3", "chkey", "pkey")
SELECT DISTINCT "sc_code", "sc_name", "sc_lname", "sc_company", "sc_whno", "sc_arcode", "sc_nowh", "sc_m_center", "lastupdt", "rebate_act", "lossrebateact", "jv_01", "jv_02", "jv_03", "jv_04", "jv_05", "jv_06", "jv_07", "jv_08", "jv_09", "jv_10", "jv_11", "jv_12", "jv_13", "jv_14", "jv_16", "jv_17", "jv_18", "jv_19", "jv_20", "jv_21", "jv_22", "jv_23", "jv_24", "jv_26", "jv_27", "jv_28", "jv_30", "jv_31", "jv_32", "jv_33", "jv_34", "jv_37", "jv_45", "jv_46", "jv_51", "jv_55", "jv_56", "jv_60", "jv_61", "sysno", "no_round_nm", "pricevattype", "mkt_frc_rounding", "is_dsc_amt", "auto_dsc_hll", "max_dsc_hll", "sc_card_srlno", "sc_card_jvno", "ar_dscser", "ap_dscser", "sc_lvlno", "jv_105", "jv_106", "jv_107", "jv_108", "jv_109", "jv_110", "jv_205", "jv_209", "jv_210", "jv_211", "jv_212", "jv_213", "jv_214", "jv_215", "jv_216", "jv_301", "jv_501", "jv_502", "cashser", "sc_lvl1", "sc_lvl2", "sc_lvl3", "chkey", "pkey" FROM bronze.glsction;

-- Load: bronze.orcountry -> silver.country
TRUNCATE TABLE silver.country CASCADE;

INSERT INTO silver.country ("country_id", "cnname", "lcnname", "standard_country_code")
SELECT DISTINCT ON ("country_id") "country_id", "cnname", "lcnname", "standard_country_code"
FROM bronze.orcountry 
ORDER BY "country_id", _source_archive DESC;

-- Load: bronze.orpacking -> silver.packing_type
TRUNCATE TABLE silver.packing_type CASCADE;

INSERT INTO silver.packing_type ("pack_id", "pkname", "lpkname", "pkorder", "pkdfqty", "pkwhlsl", "standard_unit_code")
SELECT DISTINCT ON ("pack_id") "pack_id", "pkname", "lpkname", "pkorder", "pkdfqty", "pkwhlsl", "standard_unit_code"
FROM bronze.orpacking 
ORDER BY "pack_id", _source_archive DESC;

-- Load: bronze.pricehst -> silver.price_history
TRUNCATE TABLE silver.price_history CASCADE;

INSERT INTO silver.price_history ("code", "oldprice", "newprice", "tdate", "usrid", "qty", "cmbkey", "company_id", "xitemkey", "modified", "slcenter", "omotion", "m_start", "m_end", "barcode")
SELECT DISTINCT ON ("prcode") "prcode", "oldprice", "newprice", "tdate", "usrid", "qty", "cmbkey", "company", "xitemkey", "modified", "slcenter", "promotion", "prm_start", "prm_end", "barcode"
FROM bronze.pricehst 
ORDER BY "prcode", _source_archive DESC;

-- Load: bronze.pudept -> silver.purchase_department
TRUNCATE TABLE silver.purchase_department CASCADE;

INSERT INTO silver.purchase_department ("name", "brno", "dept", "cashser", "cslser", "oslser", "rcslser", "roslser", "custser", "expser", "okdiff", "diffser", "mainwh", "rtrnwh", "lastupdt", "company_id", "modified", "cstcode", "serfrt", "serins", "sercst", "serpvl", "sersmp", "serfn", "sertkt", "serfre", "sertrn", "seroth", "lname", "vat_paid_act", "chk_serfrt", "chk_serins", "chk_sercst", "chk_serpvl", "chk_sersmp", "chk_serfn", "chk_sertkt", "chk_serfre", "chk_sertrn", "chk_seroth", "vat_auto_calc", "suspended", "code")
SELECT DISTINCT ON ("dp_brno", "dp_dept") "dp_name", "dp_brno", "dp_dept", "dp_cashser", "dp_cslser", "dp_oslser", "dp_rcslser", "dp_roslser", "dp_custser", "dp_expser", "dp_okdiff", "dp_diffser", "dp_mainwh", "dp_rtrnwh", "lastupdt", "dp_comp", "modified", "cstcode", "serfrt", "serins", "sercst", "serpvl", "sersmp", "serfn", "sertkt", "serfre", "sertrn", "seroth", "dp_lname", "vat_paid_act", "chk_serfrt", "chk_serins", "chk_sercst", "chk_serpvl", "chk_sersmp", "chk_serfn", "chk_sertkt", "chk_serfre", "chk_sertrn", "chk_seroth", "vat_auto_calc", "suspended", "sc_code"
FROM bronze.pudept 
ORDER BY "dp_brno", "dp_dept", _source_archive DESC;

-- Load: bronze.puhdr -> silver.purchase_order_header
TRUNCATE TABLE silver.purchase_order_header CASCADE;

INSERT INTO silver.purchase_order_header ("slcenter", "anch", "company_id", "invoice_type", "reference_number", "invdate", "custno", "custnm", "glser", "dsctype", "pstmode", "fcy", "fcyrate", "duedate", "invttl", "invcst", "invdspc", "invdsvl", "valafds", "invpaid", "caser", "entries", "released", "posted", "fixrate", "spply_exp", "icetp", "isglact", "chkno", "chkdate", "lastupdt", "jvgenrt", "imfcval", "lcser", "frieght", "insurexp", "customfee", "portexp", "samplexp", "lcinvexp", "fcinvexp", "lcothrexp", "fineexp", "lcttlexp", "fcttlexp", "tktexp", "freexp", "transexp", "odrate", "isl_c", "binno", "aprxcst", "aprxpc", "aprxser", "expser", "modified", "splyinv", "isorder", "settled", "rcvdtrn", "fcothrexp", "usrid", "jvdsc", "paylcl", "tdscpcs", "tdscdays", "orderno", "slcode", "lccode", "shpdate", "edm", "gntd_fm_lc", "lc_ship_no", "xfr_amt", "xfr_acc", "vat_amt_paid", "taxfree_purchase", "vatnot4vender", "vndr_taxcode", "expns4vat", "tax_pd_mthd", "vndr_kind", "manulvat", "dscamt_type", "hlldscnt", "iceincludevat", "vat_percent", "fqtyval", "fc_whrate", "is_numerator", "datetime_stamp")
SELECT DISTINCT ON ("company", "invtype", "ref") "slcenter", "branch", "company", "invtype", "ref", "invdate", "custno", "custnm", "glser", "dsctype", "pstmode", "fcy", "fcyrate", "duedate", "invttl", "invcst", "invdspc", "invdsvl", "valafds", "invpaid", "caser", "entries", "released", "posted", "fixrate", "spply_exp", "pricetp", "isglact", "chkno", "chkdate", "lastupdt", "jvgenrt", "imfcval", "lcser", "frieght", "insurexp", "customfee", "portexp", "samplexp", "lcinvexp", "fcinvexp", "lcothrexp", "fineexp", "lcttlexp", "fcttlexp", "tktexp", "freexp", "transexp", "prodrate", "isl_c", "binno", "aprxcst", "aprxpc", "aprxser", "expser", "modified", "splyinv", "isorder", "settled", "rcvdtrn", "fcothrexp", "usrid", "jvdsc", "paylcl", "tdscpcs", "tdscdays", "orderno", "slcode", "lccode", "shpdate", "edm", "gntd_fm_lc", "lc_ship_no", "xfr_amt", "xfr_acc", "vat_amt_paid", "taxfree_purchase", "vatnot4vender", "vndr_taxcode", "expns4vat", "tax_pd_mthd", "vndr_kind", "manulvat", "dscamt_type", "hlldscnt", "priceincludevat", "vat_percent", "fqtyval", "fc_whrate", "is_numerator", "datetime_stamp"
FROM bronze.puhdr 
ORDER BY "company", "invtype", "ref", _source_archive DESC;

-- Load: bronze.pudtl -> silver.purchase_order_detail
TRUNCATE TABLE silver.purchase_order_detail CASCADE;

INSERT INTO silver.purchase_order_detail ("slcenter", "company_id", "invoice_type", "reference_number", "invdate", "itemno", "unicode", "qty", "fqty", "ice", "discpc", "cost", "ds_acfm", "acfm", "gclass", "custno", "fcy", "barcode", "imfcval", "pack", "pkqty", "expdate", "binno", "shdqty", "shdpk", "shadd", "frtqty", "cmbkey", "folio", "rplct_post", "whno", "splyinv", "edm_value", "garntee_amt", "taxtype")
SELECT DISTINCT ON ("company", "invtype", "ref", "folio") "slcenter", "company", "invtype", "ref", "invdate", "itemno", "unicode", "qty", "fqty", "price", "discpc", "cost", "ds_acfm", "sl_acfm", "gclass", "custno", "fcy", "barcode", "imfcval", "pack", "pkqty", "expdate", "binno", "shdqty", "shdpk", "shadd", "frtqty", "cmbkey", "folio", "rplct_post", "whno", "splyinv", "edm_value", "garntee_amt", "taxtype"
FROM bronze.pudtl 
ORDER BY "company", "invtype", "ref", "folio", _source_archive DESC;

-- Load: bronze.salecntr -> silver.sales_center
TRUNCATE TABLE silver.sales_center CASCADE;

INSERT INTO silver.sales_center ("name", "brno", "dept", "cashser", "cslser", "oslser", "rcslser", "roslser", "custser", "expser", "okdiff", "diffser", "mainwh", "rtrnwh", "lastupdt", "company_id", "fccrdt", "nochg_print", "modified", "srcst", "cstcode", "crdcardac", "rplsac", "cardcomm", "lname", "slwhsrc", "paidcrdac", "frc_crsl_fc", "inv_form_no", "code", "sanedcrd_act", "no_of_invcopies", "vat_rcvd_act", "custody_ac", "stcpay_act", "suspended", "qitaf_act", "slscmnact", "webcmnact", "tprtexpact", "bldg_no", "bldg_no_l", "street_name", "street_name_l", "area_name", "area_name_l", "extra_address_no", "extra_address_no_l", "district", "district_l", "city_text", "city_text_l", "postal_code", "street_name2", "street_name2_l", "group_vat_id", "other_id_schemeid", "country_code", "other_scheme_type", "manafith_api")
SELECT DISTINCT ON ("dp_brno", "dp_dept") "dp_name", "dp_brno", "dp_dept", "dp_cashser", "dp_cslser", "dp_oslser", "dp_rcslser", "dp_roslser", "dp_custser", "dp_expser", "dp_okdiff", "dp_diffser", "dp_mainwh", "dp_rtrnwh", "lastupdt", "dp_comp", "dp_fccrdt", "nochg_print", "modified", "srcst", "cstcode", "dp_crdcardac", "dp_rplsac", "dp_cardcomm", "dp_lname", "slwhsrc", "prpaidcrdac", "frc_crsl_fc", "inv_form_no", "sc_code", "sanedcrd_act", "no_of_invcopies", "vat_rcvd_act", "custody_ac", "stcpay_act", "suspended", "qitaf_act", "slscmnact", "webcmnact", "tprtexpact", "bldg_no", "bldg_no_l", "street_name", "street_name_l", "area_name", "area_name_l", "extra_address_no", "extra_address_no_l", "district", "district_l", "city_text", "city_text_l", "postal_code", "street_name2", "street_name2_l", "group_vat_id", "other_id_schemeid", "country_code", "other_scheme_type", "manafith_api"
FROM bronze.salecntr 
ORDER BY "dp_brno", "dp_dept", _source_archive DESC;

-- Load: bronze.sales_hd -> silver.sales_order_header
TRUNCATE TABLE silver.sales_order_header CASCADE;

INSERT INTO silver.sales_order_header ("slcenter", "anch", "company_id", "invoice_type", "reference_number", "invdate", "custno", "custnm", "glser", "dsctype", "pstmode", "fcy", "fcyrate", "duedate", "invttl", "invcst", "invdspc", "invdsvl", "valafds", "invpaid", "caser", "entries", "released", "posted", "fixrate", "extamt", "extser", "icetp", "ischeque", "chkno", "chkdate", "lastupdt", "jvgenrt", "cccommsn", "belowbal", "fcy2", "ccpayment", "rplsamt", "pdother", "slcode", "paidamt", "instldays", "instflag", "slcmnd", "inv_printed", "bendit", "modified", "rqstorder", "rqststld", "carrier", "rcvdtrn", "usrid", "address", "suspend", "rtnref", "ispurchase", "stkjvno", "posinv", "sanedcrd_amt", "remarks", "remarks2", "invlocked", "rtncash_dfrpl", "vat_amt_rcvd", "taxfree_sales", "clnt_taxcode", "clnt_kind", "hlldscnt", "sysno", "no_round_nm", "icevattype", "smssent", "stcpay_amt", "fc2lcamt", "qitaf_amt", "whlslinv", "vat_percent", "fsh_printed", "fqtyval", "fc_whrate", "is_numerator", "datetime_stamp", "fusrprintinv", "almnm_contract_section", "mobileno", "client_name", "installment_amt", "zatca_rounding", "tac_fees_percent", "tac_fees_amount", "tac_fees_account", "discountedbill", "icetacfeestype")
SELECT DISTINCT ON ("company", "invtype", "ref") "slcenter", "branch", "company", "invtype", "ref", "invdate", "custno", "custnm", "glser", "dsctype", "pstmode", "fcy", "fcyrate", "duedate", "invttl", "invcst", "invdspc", "invdsvl", "valafds", "invpaid", "caser", "entries", "released", "posted", "fixrate", "extamt", "extser", "pricetp", "ischeque", "chkno", "chkdate", "lastupdt", "jvgenrt", "cccommsn", "belowbal", "fcy2", "ccpayment", "rplsamt", "pdother", "slcode", "prpaidamt", "instldays", "instflag", "slcmnd", "inv_printed", "bendit", "modified", "rqstorder", "rqststld", "carrier", "rcvdtrn", "usrid", "address", "suspend", "rtnref", "ispurchase", "stkjvno", "posinv", "sanedcrd_amt", "remarks", "remarks2", "invlocked", "rtncash_dfrpl", "vat_amt_rcvd", "taxfree_sales", "clnt_taxcode", "clnt_kind", "hlldscnt", "sysno", "no_round_nm", "pricevattype", "smssent", "stcpay_amt", "fc2lcamt", "qitaf_amt", "whlslinv", "vat_percent", "fsh_printed", "fqtyval", "fc_whrate", "is_numerator", "datetime_stamp", "fusrprintinv", "almnm_contract_section", "mobileno", "client_name", "installment_amt", "zatca_rounding", "tac_fees_percent", "tac_fees_amount", "tac_fees_account", "discountedbill", "pricetacfeestype"
FROM bronze.sales_hd 
ORDER BY "company", "invtype", "ref", _source_archive DESC;

-- Load: bronze.sales_dt -> silver.sales_order_detail
TRUNCATE TABLE silver.sales_order_detail CASCADE;

INSERT INTO silver.sales_order_detail ("slcenter", "company_id", "invoice_type", "reference_number", "invdate", "itemno", "unicode", "qty", "fqty", "ice", "discpc", "cost", "ds_acfm", "acfm", "gclass", "custno", "fcy", "barcode", "imfcval", "pack", "pkqty", "shadd", "shdpk", "shdqty", "frtqty", "rtnqty", "whno", "cmbkey", "folio", "rplct_post", "sold_item_status", "taxtype", "ps_item_vat", "dsc_amt", "expdate", "item_price_net", "invdscamt", "item_vat")
SELECT DISTINCT ON ("company", "invtype", "ref", "folio") "slcenter", "company", "invtype", "ref", "invdate", "itemno", "unicode", "qty", "fqty", "price", "discpc", "cost", "ds_acfm", "sl_acfm", "gclass", "custno", "fcy", "barcode", "imfcval", "pack", "pkqty", "shadd", "shdpk", "shdqty", "frtqty", "rtnqty", "whno", "cmbkey", "folio", "rplct_post", "sold_item_status", "taxtype", "ps_item_vat", "dsc_amt", "expdate", "item_price_net", "invdscamt", "item_vat"
FROM bronze.sales_dt 
ORDER BY "company", "invtype", "ref", "folio", _source_archive DESC;

-- Load: bronze.sales_qh -> silver.sales_quotation_header
TRUNCATE TABLE silver.sales_quotation_header CASCADE;

INSERT INTO silver.sales_quotation_header ("slcenter", "anch", "invoice_type", "company_id", "reference_number", "invdate", "custno", "custnm", "glser", "dsctype", "pstmode", "fcy", "fcyrate", "duedate", "invttl", "invcst", "invdspc", "invdsvl", "valafds", "invpaid", "caser", "entries", "released", "posted", "fixrate", "extamt", "extser", "icetp", "ischeque", "chkno", "chkdate", "lastupdt", "jvgenrt", "imfcval", "slcode", "modified", "rcvdtrn", "remarks", "remarks2", "usrid", "vat_amt_rcvd", "taxfree_sales", "clnt_taxcode", "clnt_kind", "qhtype", "qhstatus", "newcstmrname", "newcstmrcntct", "cstmrmobile", "fc_whrate", "is_numerator")
SELECT DISTINCT ON ("company", "ref") "slcenter", "branch", "invtype", "company", "ref", "invdate", "custno", "custnm", "glser", "dsctype", "pstmode", "fcy", "fcyrate", "duedate", "invttl", "invcst", "invdspc", "invdsvl", "valafds", "invpaid", "caser", "entries", "released", "posted", "fixrate", "extamt", "extser", "pricetp", "ischeque", "chkno", "chkdate", "lastupdt", "jvgenrt", "imfcval", "slcode", "modified", "rcvdtrn", "remarks", "remarks2", "usrid", "vat_amt_rcvd", "taxfree_sales", "clnt_taxcode", "clnt_kind", "qhtype", "qhstatus", "newcstmrname", "newcstmrcntct", "cstmrmobile", "fc_whrate", "is_numerator"
FROM bronze.sales_qh 
ORDER BY "company", "ref", _source_archive DESC;

-- Load: bronze.sales_qd -> silver.sales_quotation_detail
TRUNCATE TABLE silver.sales_quotation_detail CASCADE;

INSERT INTO silver.sales_quotation_detail ("slcenter", "invoice_type", "company_id", "reference_number", "invdate", "itemno", "unicode", "itemdesc", "qty", "fqty", "ice", "discpc", "cost", "ds_acfm", "acfm", "gclass", "custno", "fcy", "barcode", "imfcval", "pack", "pkqty", "shadd", "shdpk", "shdqty", "frtqty", "cmbkey", "folio")
SELECT DISTINCT "slcenter", "invtype", "company", "ref", "invdate", "itemno", "unicode", "itemdesc", "qty", "fqty", "price", "discpc", "cost", "ds_acfm", "sl_acfm", "gclass", "custno", "fcy", "barcode", "imfcval", "pack", "pkqty", "shadd", "shdpk", "shdqty", "frtqty", "cmbkey", "folio" FROM bronze.sales_qd;

-- Load: bronze.salesmen -> silver.sales_representative
TRUNCATE TABLE silver.sales_representative CASCADE;

INSERT INTO silver.sales_representative ("slcompany", "slcode", "slshort", "slname", "slcomm", "clcomm", "sltarget", "cltarget", "salesman", "collector", "sltype", "lstcomm", "modified", "sllname", "lastupdt", "purshman", "notify_type", "notify_within", "slemail", "slmobile", "usrid", "slscmnact", "crdt_limit", "center")
SELECT DISTINCT ON ("slcompany", "slcode") "slcompany", "slcode", "slshort", "slname", "slcomm", "clcomm", "sltarget", "cltarget", "salesman", "collector", "sltype", "lstcomm", "modified", "sllname", "lastupdt", "purshman", "notify_type", "notify_within", "slemail", "slmobile", "usrid", "slscmnact", "crdt_limit", "sl_center"
FROM bronze.salesmen 
ORDER BY "slcompany", "slcode", _source_archive DESC;

-- Load: bronze.slinvexp -> silver.sales_invoice_expense
TRUNCATE TABLE silver.sales_invoice_expense CASCADE;

INSERT INTO silver.sales_invoice_expense ("company_id", "invoice_type", "reference_number", "fcy", "transportonus", "transportamt", "transport_vat", "slsmanprcnt", "slsmanamt", "oker_code", "oker_amt", "oker_prcnt", "oker_vat_amt", "oker_taxable", "oker_ttlcmsn", "oker_cmnamt", "trans_code", "trans_cost_per_pack", "driver_expnseamt", "trans_expnse", "driver_no", "is_vat", "icewithtransport")
SELECT DISTINCT ON ("company", "invtype", "ref") "company", "invtype", "ref", "fcy", "transportonus", "transportamt", "transport_vat", "slsmanprcnt", "slsmanamt", "broker_code", "broker_amt", "broker_prcnt", "broker_vat_amt", "broker_taxable", "broker_ttlcmsn", "broker_cmnamt", "trans_code", "trans_cost_per_pack", "driver_expnseamt", "trans_expnse", "driver_no", "is_vat", "pricewithtransport"
FROM bronze.slinvexp 
ORDER BY "company", "invtype", "ref", _source_archive DESC;

-- Load: bronze.starea -> silver.stock_area
TRUNCATE TABLE silver.stock_area CASCADE;

INSERT INTO silver.stock_area ("name", "cmbkey", "govrn", "city", "region", "modified", "lname", "lastupdt", "pkey", "chkey")
SELECT DISTINCT ON ("cmbkey") "name", "cmbkey", "govrn", "city", "region", "modified", "lname", "lastupdt", "pkey", "chkey"
FROM bronze.starea 
ORDER BY "cmbkey", _source_archive DESC;

-- Load: bronze.stbranch -> silver.stock_branch
TRUNCATE TABLE silver.stock_branch CASCADE;

INSERT INTO silver.stock_branch ("name", "nno", "govrn", "city", "area", "cmbkey", "company_id", "cashser", "modified", "bcserial", "jv_01", "jv_02", "jv_03", "jv_04", "jv_05", "jv_06", "jv_07", "jv_08", "jv_09", "jv_10", "jv_11", "jv_12", "jv_13", "jv_14", "jv_16", "jv_17", "jv_18", "jv_19", "jv_20", "jv_21", "jv_22", "jv_23", "jv_24", "jv_26", "jv_27", "jv_28", "jv_30", "jv_31", "jv_32", "jv_33", "jv_34", "jv_37", "jv_45", "jv_46", "jv_51", "jv_55", "jv_56", "jv_60", "jv_61", "calgl", "calar", "calap", "calst", "srdiff", "lname", "lastupdt", "stkxtoser", "stkxfmser", "baddress", "lbaddress", "phone", "fax", "dscalwser", "dscernser", "jv_101", "manualser", "smsdispname", "smsuser", "smsfooter", "rebate_act", "fm_price1", "to_price1", "doz_price1", "ctn_price1", "fm_price2", "to_price2", "doz_price2", "ctn_price2", "fm_price3", "to_price3", "doz_price3", "ctn_price3", "icetp", "rebate_loss", "sysno", "no_round_nm", "icevattype", "mkt_frc_rounding", "is_dsc_amt", "auto_dsc_hll", "max_dsc_hll", "pos_type", "lvlno", "vat_paid_act", "jv_105", "jv_106", "jv_107", "jv_108", "jv_109", "jv_110", "jv_205", "jv_209", "jv_210", "jv_211", "jv_212", "jv_213", "jv_214", "jv_215", "jv_216", "jv_301", "jv_501", "jv_502", "bldg_no", "bldg_no_l", "street_name", "street_name_l", "area_name", "area_name_l", "extra_address_no", "extra_address_no_l", "district", "district_l", "city_text", "city_text_l", "postal_code", "street_name2", "street_name2_l", "group_vat_id", "other_id_schemeid", "country_code", "other_scheme_type", "crdt_limit", "vat_rcvd_act", "remote_br_sqlserver", "rvnuact")
SELECT DISTINCT "name", "brnno", "govrn", "city", "area", "cmbkey", "company", "cashser", "modified", "bcserial", "jv_01", "jv_02", "jv_03", "jv_04", "jv_05", "jv_06", "jv_07", "jv_08", "jv_09", "jv_10", "jv_11", "jv_12", "jv_13", "jv_14", "jv_16", "jv_17", "jv_18", "jv_19", "jv_20", "jv_21", "jv_22", "jv_23", "jv_24", "jv_26", "jv_27", "jv_28", "jv_30", "jv_31", "jv_32", "jv_33", "jv_34", "jv_37", "jv_45", "jv_46", "jv_51", "jv_55", "jv_56", "jv_60", "jv_61", "calgl", "calar", "calap", "calst", "srdiff", "lname", "lastupdt", "stkxtoser", "stkxfmser", "baddress", "lbaddress", "phone", "fax", "dscalwser", "dscernser", "jv_101", "manualser", "smsdispname", "smsuser", "smsfooter", "rebate_act", "fm_price1", "to_price1", "doz_price1", "ctn_price1", "fm_price2", "to_price2", "doz_price2", "ctn_price2", "fm_price3", "to_price3", "doz_price3", "ctn_price3", "pricetp", "rebate_loss", "sysno", "no_round_nm", "pricevattype", "mkt_frc_rounding", "is_dsc_amt", "auto_dsc_hll", "max_dsc_hll", "pos_type", "sc_lvlno", "vat_paid_act", "jv_105", "jv_106", "jv_107", "jv_108", "jv_109", "jv_110", "jv_205", "jv_209", "jv_210", "jv_211", "jv_212", "jv_213", "jv_214", "jv_215", "jv_216", "jv_301", "jv_501", "jv_502", "bldg_no", "bldg_no_l", "street_name", "street_name_l", "area_name", "area_name_l", "extra_address_no", "extra_address_no_l", "district", "district_l", "city_text", "city_text_l", "postal_code", "street_name2", "street_name2_l", "group_vat_id", "other_id_schemeid", "country_code", "other_scheme_type", "crdt_limit", "vat_rcvd_act", "remote_br_sqlserver", "rvnuact" FROM bronze.stbranch;

-- Load: bronze.stbins -> silver.stock_bin
TRUNCATE TABLE silver.stock_bin CASCADE;

INSERT INTO silver.stock_bin ("anch", "itemno", "unicode", "whno", "binno", "qty", "rsvqty", "openbal", "lcost", "fcost", "openlcost", "openfcost", "expdate")
SELECT DISTINCT ON ("branch", "itemno", "unicode", "whno", "binno") "branch", "itemno", "unicode", "whno", "binno", "qty", "rsvqty", "openbal", "lcost", "fcost", "openlcost", "openfcost", "expdate"
FROM bronze.stbins 
ORDER BY "branch", "itemno", "unicode", "whno", "binno", _source_archive DESC;

-- Load: bronze.stclass -> silver.stock_classification
TRUNCATE TABLE silver.stock_classification CASCADE;

INSERT INTO silver.stock_classification ("name", "cmbkey", "mgroup", "sgroup", "category", "sercsh", "sercrd", "serrch", "serrcr", "serdsc", "serpcsh", "serpcrd", "serprch", "serprcr", "serpdsc", "sgroup3", "sgroup4", "modified", "pkey", "chkey", "lname", "lastupdt", "max_sl_limit")
SELECT DISTINCT ON ("cmbkey") "name", "cmbkey", "mgroup", "sgroup", "category", "sercsh", "sercrd", "serrch", "serrcr", "serdsc", "serpcsh", "serpcrd", "serprch", "serprcr", "serpdsc", "sgroup3", "sgroup4", "modified", "pkey", "chkey", "lname", "lastupdt", "max_sl_limit"
FROM bronze.stclass 
ORDER BY "cmbkey", _source_archive DESC;

-- Load: bronze.stcosttype -> silver.stock_cost_type
TRUNCATE TABLE silver.stock_cost_type CASCADE;

INSERT INTO silver.stock_cost_type ("anch", "itemno", "unicode", "lastlcost", "highlcost", "lowlcost", "lstrcvdate", "lastfcost", "frstrcvdate", "highfcost", "lowfcost", "lastrcvd01", "lastlcost01", "frstlcost01", "pufrstlcost", "lastissue")
SELECT DISTINCT ON ("branch", "itemno", "unicode") "branch", "itemno", "unicode", "lastlcost", "highlcost", "lowlcost", "lstrcvdate", "lastfcost", "frstrcvdate", "highfcost", "lowfcost", "lastrcvd01", "lastlcost01", "frstlcost01", "pufrstlcost", "brlastissue"
FROM bronze.stcosttype 
ORDER BY "branch", "itemno", "unicode", _source_archive DESC;

-- Load: bronze.stcrtpuinv -> silver.stock_purchase_invoice
TRUNCATE TABLE silver.stock_purchase_invoice CASCADE;

INSERT INTO silver.stock_purchase_invoice ("anch", "splycode", "fcy", "splyinv", "itemno", "unicode", "dbxyr", "idate", "lastupdt", "rplct_post", "slcode")
SELECT DISTINCT ON ("branch", "splycode", "fcy", "splyinv", "itemno", "unicode") "branch", "splycode", "fcy", "splyinv", "itemno", "unicode", "dbxyr", "idate", "lastupdt", "rplct_post", "slcode"
FROM bronze.stcrtpuinv 
ORDER BY "branch", "splycode", "fcy", "splyinv", "itemno", "unicode", _source_archive DESC;

-- Load: bronze.stdtl -> silver.stock_transaction_detail
TRUNCATE TABLE silver.stock_transaction_detail CASCADE;

INSERT INTO silver.stock_transaction_detail ("itemno", "unicode", "anch", "trtype", "qty", "fqty", "whno", "binno", "lcost", "trdate", "reference_number", "sysdate", "src", "lprice", "fcost", "fprice", "expdate", "towhno", "tobinno", "barcode", "cmbkey", "discpc", "pack", "shdpk", "shdqty", "folio", "rplct_post", "fcost_fcwh")
SELECT DISTINCT ON ("branch", "trtype", "ref", "folio") "itemno", "unicode", "branch", "trtype", "qty", "fqty", "whno", "binno", "lcost", "trdate", "ref", "sysdate", "src", "lprice", "fcost", "fprice", "expdate", "towhno", "tobinno", "barcode", "cmbkey", "discpc", "pack", "shdpk", "shdqty", "folio", "rplct_post", "fcost_fcwh"
FROM bronze.stdtl 
ORDER BY "branch", "trtype", "ref", "folio", _source_archive DESC;

-- Load: bronze.stfcyprice -> silver.stock_foreign_currency_price
TRUNCATE TABLE silver.stock_foreign_currency_price CASCADE;

INSERT INTO silver.stock_foreign_currency_price ("itemno", "unicode", "fcyprice1", "fcyprice2", "fcyprice3", "fcymnmprice")
SELECT DISTINCT ON ("itemno", "unicode") "itemno", "unicode", "fcyprice1", "fcyprice2", "fcyprice3", "fcymnmprice"
FROM bronze.stfcyprice 
ORDER BY "itemno", "unicode", _source_archive DESC;

-- Load: bronze.sthdr -> silver.stock_transaction_header
TRUNCATE TABLE silver.stock_transaction_header CASCADE;

INSERT INTO silver.stock_transaction_header ("anch", "trtype", "reference_number", "trdate", "text", "amnttl", "costttl", "sysdate", "src", "released", "posted", "fcy", "fcyrate", "whno", "entries", "lastupdt", "towhno", "modified", "rcvdtrn", "custno", "usrid", "supp", "tobrno", "xref", "glref", "isbrtrx", "asmtype", "repost", "items_rcvd", "trx_printed", "fc_whrate", "is_numerator", "icetp")
SELECT DISTINCT ON ("branch", "trtype", "ref") "branch", "trtype", "ref", "trdate", "text", "amnttl", "costttl", "sysdate", "src", "released", "posted", "fcy", "fcyrate", "whno", "entries", "lastupdt", "towhno", "modified", "rcvdtrn", "custno", "usrid", "brsupp", "tobrno", "brxref", "glref", "isbrtrx", "asmtype", "repost", "items_rcvd", "trx_printed", "fc_whrate", "is_numerator", "pricetp"
FROM bronze.sthdr 
ORDER BY "branch", "trtype", "ref", _source_archive DESC;

-- Load: bronze.stitemrp -> silver.stock_item_replacement
TRUNCATE TABLE silver.stock_item_replacement CASCADE;

INSERT INTO silver.stock_item_replacement ("itemno", "unicode", "rplitemno", "rplunicode", "cmbkey", "rplorder", "lastupdt")
SELECT DISTINCT "itemno", "unicode", "rplitemno", "rplunicode", "cmbkey", "rplorder", "lastupdt" FROM bronze.stitemrp;

-- Load: bronze.stitems -> silver.stock_item
TRUNCATE TABLE silver.stock_item CASCADE;

INSERT INTO silver.stock_item ("name", "itemno", "mgroup", "sgroup", "category", "fcy", "classkey", "exdatealw", "noofsbitem", "modified", "sgroup3", "sgroup4", "company_id", "lname", "country", "season", "splycode", "splylcact", "itemtype", "ntasmitm", "mdesc", "scndesc", "cmpprcnt", "dsctype", "and_id", "msplycode", "modelno", "nosales", "vprice", "fix_barcode", "taxfree", "taxtype", "raw_material")
SELECT DISTINCT ON ("itemno") "name", "itemno", "mgroup", "sgroup", "category", "fcy", "classkey", "exdatealw", "noofsbitem", "modified", "sgroup3", "sgroup4", "company", "lname", "country", "season", "splycode", "splylcact", "itemtype", "prntasmitm", "prmdesc", "scndesc", "cmpprcnt", "dsctype", "brand_id", "msplycode", "modelno", "nosales", "vprice", "fix_barcode", "taxfree", "taxtype", "raw_material"
FROM bronze.stitems 
ORDER BY "itemno", _source_archive DESC;

-- Load: bronze.stitmphoto -> silver.stock_item_photo
TRUNCATE TABLE silver.stock_item_photo CASCADE;

INSERT INTO silver.stock_item_photo ("itemno", "unicode", "remarks", "ipicture", "ord_qty", "mnimumdt", "cust_pctg", "is_double_width", "is_price_per_length", "is_accessory_stk_item", "dsc_amt1", "dsc_amt2", "dsc_amt3", "usrid", "usrid_lstchg", "exemption_reason_code", "sell_in_lcl_currncy", "extra_tax_p", "onlinesales", "startdate", "enddate")
SELECT DISTINCT ON ("itemno", "unicode") "itemno", "unicode", "remarks", "ipicture", "ord_qty", "mnimumdt", "cust_pctg", "is_double_width", "is_price_per_length", "is_accessory_stk_item", "dsc_amt1", "dsc_amt2", "dsc_amt3", "usrid", "usrid_lstchg", "exemption_reason_code", "sell_in_lcl_currncy", "extra_tax_p", "onlinesales", "startdate", "enddate"
FROM bronze.stitmphoto 
ORDER BY "itemno", "unicode", _source_archive DESC;

-- Load: bronze.stprice -> silver.stock_price
TRUNCATE TABLE silver.stock_price CASCADE;

INSERT INTO silver.stock_price ("name", "code", "disc", "lprice", "fprice", "minsal", "maxsal", "modified", "lname", "lastupdt")
SELECT DISTINCT "name", "code", "disc", "lprice", "fprice", "minsal", "maxsal", "modified", "lname", "lastupdt" FROM bronze.stprice;

-- Load: bronze.streorderqp -> silver.stock_reorder_level
TRUNCATE TABLE silver.stock_reorder_level CASCADE;

INSERT INTO silver.stock_reorder_level ("itemno", "unicode", "reorderq", "lastupdt", "reorderd", "reorderp")
SELECT DISTINCT ON ("itemno", "unicode") "itemno", "unicode", "reorderq", "lastupdt", "reorderd", "reorderp"
FROM bronze.streorderqp 
ORDER BY "itemno", "unicode", _source_archive DESC;

-- Load: bronze.stunits -> silver.stock_unit_of_measure
TRUNCATE TABLE silver.stock_unit_of_measure CASCADE;

INSERT INTO silver.stock_unit_of_measure ("name", "itemno", "unicode", "moved", "openlcost", "lcost", "lprice1", "fprice1", "maxdisc1", "lprice2", "fprice2", "maxdisc2", "lprice3", "fprice3", "maxdisc3", "openfcost", "fcost", "lrcvdate", "lastissue", "openbal", "curbal", "rsvqty", "minstk", "maxstk", "orderlevel", "leadday", "xdecimal", "barcode", "pack1", "pkqty1", "pack2", "pkqty2", "pack3", "pkqty3", "company_id", "modified", "pack0", "packtp", "scnname", "crtdate", "inactive", "mcode", "scncode", "cmbkey", "mnmprice", "lastupdt", "modelno", "splyitemno", "splyinv", "invprice", "invqty", "invpk", "pp2", "pp3")
SELECT DISTINCT ON ("itemno", "unicode") "name", "itemno", "unicode", "moved", "openlcost", "lcost", "lprice1", "fprice1", "maxdisc1", "lprice2", "fprice2", "maxdisc2", "lprice3", "fprice3", "maxdisc3", "openfcost", "fcost", "lrcvdate", "lastissue", "openbal", "curbal", "rsvqty", "minstk", "maxstk", "orderlevel", "leadday", "xdecimal", "barcode", "pack1", "pkqty1", "pack2", "pkqty2", "pack3", "pkqty3", "company", "modified", "pack0", "packtp", "scnname", "crtdate", "inactive", "prmcode", "scncode", "cmbkey", "mnmprice", "lastupdt", "modelno", "splyitemno", "splyinv", "invprice", "invqty", "invpk", "pp2", "pp3"
FROM bronze.stunits 
ORDER BY "itemno", "unicode", _source_archive DESC;

-- Load: bronze.stwhous -> silver.warehouse
TRUNCATE TABLE silver.warehouse CASCADE;

INSERT INTO silver.warehouse ("name", "whno", "anch", "manager", "phone", "address", "lastupdt", "srwhs", "modified", "lname", "fax", "nt_fsh", "ac_end_prd", "cstcode", "no_autosales", "code", "suspended", "binsrlno")
SELECT DISTINCT ON ("whno") "name", "whno", "branch", "manager", "phone", "address", "lastupdt", "srwhs", "modified", "lname", "fax", "prnt_fsh", "ac_end_prd", "cstcode", "no_autosales", "sc_code", "suspended", "binsrlno"
FROM bronze.stwhous 
ORDER BY "whno", _source_archive DESC;

-- Load: bronze.supplier -> silver.supplier
TRUNCATE TABLE silver.supplier CASCADE;

INSERT INTO silver.supplier ("name", "company_id", "code", "class", "addrs", "tel", "fax", "tlx", "email", "cntactp", "title", "crlmt", "pymnt", "status", "opnbal", "curbal", "cf_fcy", "cf_opnfcy", "cf_curfcy", "xrf", "alwcr", "ctlser", "lastupdt", "lcaloc", "fcaloc", "modified", "cmncode", "lname", "city", "country", "laddrs", "mobile", "sendsms", "rowguid", "whno", "vndr_taxcode", "taxfree", "kind", "section", "iceincludevat", "type", "usrid", "usridchg", "added_date")
SELECT DISTINCT ON ("cu_company", "cu_code", "cf_fcy") "cu_name", "cu_company", "cu_code", "cu_class", "cu_addrs", "cu_tel", "cu_fax", "cu_tlx", "cu_email", "cu_cntactp", "cu_title", "cu_crlmt", "cu_pymnt", "cu_status", "cu_opnbal", "cu_curbal", "cf_fcy", "cf_opnfcy", "cf_curfcy", "cu_xrf", "cu_alwcr", "cu_ctlser", "lastupdt", "cu_lcaloc", "cu_fcaloc", "modified", "cmncode", "cu_lname", "cu_city", "cu_country", "cu_laddrs", "cu_mobile", "cu_sendsms", "rowguid", "whno", "vndr_taxcode", "taxfree", "cu_kind", "section", "priceincludevat", "cu_type", "usrid", "usridchg", "added_date"
FROM bronze.supplier 
ORDER BY "cu_company", "cu_code", "cf_fcy", _source_archive DESC;

-- Load: bronze.sysuse -> silver.sys_user
TRUNCATE TABLE silver.sys_user CASCADE;

INSERT INTO silver.sys_user ("username", "password", "fullname", "emp_code", "grp", "company_id", "suspend", "uchgpas", "e_password", "formkey", "formsel", "formname", "uslatin", "showcost", "undrcost", "undrmin", "belowbal", "showitmcst", "usshowprofit", "nopriceblwcost", "noslsblwcst", "acssdisc", "chgprice", "acssfqty", "usalwchgprs", "alwchg_slrtn_price", "usslcsh", "usslcrd", "usslrcsh", "usslrcrd", "uspucsh", "uspucrd", "uspurcsh", "uspurcrd", "usjv", "usrcv", "usiss", "uschqrcv", "uschqiss", "ustrnsin", "ustrnsout", "usbnkin", "uscredit", "usdebit", "ussuspend", "ushide_jv", "editothers", "dsplyothers", "dsplyothersqh", "hideqhinfo", "chgperiod", "chgtdate", "noexratechg", "maxdsc", "maxfqty", "currate", "actallow", "openallow", "cstallow", "usrbrn", "uspright", "uswhalw", "uscntralw", "usdptalw", "ussctnalw", "posuser", "msuser", "mobileuser", "mobilno", "usmagnetic", "sendsms", "passwordpda", "usfpalw", "usfpimage", "usfpimage2", "confirmpurchase", "confirmbr", "confirmtrnsfr", "mgmtcnfrm", "noovrdrft", "onlyactrmt", "otp", "alwprntrpt", "intinv", "inttrx", "intbarcode", "inv_form_no", "max_inv_printed", "max_fsh_printed", "web_rights", "norgstrnosl", "alwchangevat", "blkassmbld", "smartsearch", "e_invrdy", "binno", "is_infosoft_equvlnt", "srvs_chgprice", "srvs_acssdisc", "srvs_maxdsc", "chg_rent_fcy", "opn_closed_ctrct", "alwslfrmslnobal", "alwsend_doc", "noadd_crdt_clnt", "archv_upload", "archv_download", "archv_open", "archv_delete", "alw2usewtsapp", "alw2chgwtsmbl", "check_in_after_check_out", "ok_chng_client_ban_security", "ok_show_client_ban_security", "ok_contract_check_out", "ok_contract_closing", "useprice1", "useprice2", "useprice3", "shwacprtct", "onlinepost", "usslprofit", "uschdlcshinv", "uschdlcshrcv", "uschdlchqrcv", "goblwmnmp", "usissrqst", "usstiss", "usstrcv")
SELECT DISTINCT ON ("username") "username", "password", "fullname", "emp_code", "grp", "company", "suspend", "uchgpas", "e_password", "formkey", "formsel", "formname", "uslatin", "showcost", "undrcost", "undrmin", "belowbal", "showitmcst", "usshowprofit", "nopriceblwcost", "noslsblwcst", "acssdisc", "chgprice", "acssfqty", "usalwchgprs", "alwchg_slrtn_price", "usslcsh", "usslcrd", "usslrcsh", "usslrcrd", "uspucsh", "uspucrd", "uspurcsh", "uspurcrd", "usjv", "usrcv", "usiss", "uschqrcv", "uschqiss", "ustrnsin", "ustrnsout", "usbnkin", "uscredit", "usdebit", "ussuspend", "ushide_jv", "editothers", "dsplyothers", "dsplyothersqh", "hideqhinfo", "chgperiod", "chgtdate", "noexratechg", "maxdsc", "maxfqty", "currate", "actallow", "openallow", "cstallow", "usrbrn", "uspright", "uswhalw", "uscntralw", "usdptalw", "ussctnalw", "posuser", "msuser", "mobileuser", "mobilno", "usmagnetic", "sendsms", "passwordpda", "usfpalw", "usfpimage", "usfpimage2", "confirmpurchase", "confirmbr", "confirmtrnsfr", "mgmtcnfrm", "noovrdrft", "onlyactrmt", "otp", "alwprntrpt", "printinv", "printtrx", "printbarcode", "inv_form_no", "max_inv_printed", "max_fsh_printed", "web_rights", "norgstrnosl", "alwchangevat", "blkassmbld", "smartsearch", "e_invrdy", "binno", "is_infosoft_equvlnt", "srvs_chgprice", "srvs_acssdisc", "srvs_maxdsc", "chg_rent_fcy", "opn_closed_ctrct", "alwslfrmslnobal", "alwsend_doc", "noadd_crdt_clnt", "archv_upload", "archv_download", "archv_open", "archv_delete", "alw2usewtsapp", "alw2chgwtsmbl", "check_in_after_check_out", "ok_chng_client_ban_security", "ok_show_client_ban_security", "ok_contract_check_out", "ok_contract_closing", "useprice1", "useprice2", "useprice3", "shwacprtct", "onlinepost", "usslprofit", "uschdlcshinv", "uschdlcshrcv", "uschdlchqrcv", "goblwmnmp", "usissrqst", "usstiss", "usstrcv"
FROM bronze.sysuse 
ORDER BY "username", _source_archive DESC;

-- Load: bronze.taxcategory -> silver.tax_category
TRUNCATE TABLE silver.tax_category CASCADE;

INSERT INTO silver.tax_category ("taxcatid", "taxcat_name", "taxcat_lname", "cat_protected", "lastupdt", "sysname", "in_out_tax", "txdsc_allowed")
SELECT DISTINCT ON ("taxcatid") "taxcatid", "taxcat_name", "taxcat_lname", "cat_protected", "lastupdt", "sysname", "in_out_tax", "txdsc_allowed"
FROM bronze.taxcategory 
ORDER BY "taxcatid", _source_archive DESC;

-- Load: bronze.taxperiod -> silver.tax_period
TRUNCATE TABLE silver.tax_period CASCADE;

INSERT INTO silver.tax_period ("taxprdcalcomp", "taxprdyrcode", "taxprdcode", "taxprdname", "taxprdlname", "taxprdstart", "taxprdend", "crtdate", "lastupdt", "lastmodifed", "taxtype", "lastusrupdt", "jv_vat_percent")
SELECT DISTINCT ON ("taxprdcalcomp", "taxprdyrcode", "taxprdcode") "taxprdcalcomp", "taxprdyrcode", "taxprdcode", "taxprdname", "taxprdlname", "taxprdstart", "taxprdend", "crtdate", "lastupdt", "lastmodifed", "taxtype", "lastusrupdt", "jv_vat_percent"
FROM bronze.taxperiod 
ORDER BY "taxprdcalcomp", "taxprdyrcode", "taxprdcode", _source_archive DESC;

-- Load: bronze.taxlog -> silver.tax_log
TRUNCATE TABLE silver.tax_log CASCADE;

INSERT INTO silver.tax_log ("fld1", "fld2", "fld3", "fld4", "fld5", "fld6", "fld7", "fld8", "fld9")
SELECT DISTINCT "fld1", "fld2", "fld3", "fld4", "fld5", "fld6", "fld7", "fld8", "fld9" FROM bronze.taxlog;

END $$;
