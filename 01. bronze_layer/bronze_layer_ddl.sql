/*
============================================================================
-- PostgreSQL Schema Definitions: Bronze Layer (Batch 1)
-- Description: Accounts Payable, Accounts Receivable, Banking, and Customer 
--              master data tables.
-- ============================================================================
*/

-- Safely drop existing tables before creation to ensure a clean deployment
DROP TABLE IF EXISTS bronze.apclass;
DROP TABLE IF EXISTS bronze.aphdr;
DROP TABLE IF EXISTS bronze.apdtl;
DROP TABLE IF EXISTS bronze.arhdr;
DROP TABLE IF EXISTS bronze.ardtl;
DROP TABLE IF EXISTS bronze.bkbank;
DROP TABLE IF EXISTS bronze.bkacct;
DROP TABLE IF EXISTS bronze.brselected;
DROP TABLE IF EXISTS bronze.classfil;
DROP TABLE IF EXISTS bronze.customer;

-- ============================================================================
-- 1. Accounts Payable (AP) Tables
-- ============================================================================

-- Table: apclass
-- Description: Defines classifications and general ledger mappings for Accounts Payable.
CREATE TABLE bronze.apclass (
    cl_company VARCHAR(2),      -- Company identifier code
    cl_code VARCHAR(2),         -- Classification code
    cl_desc VARCHAR(50),        -- Short description of the class
    cl_crlser VARCHAR(19),      -- GL serial link for credit accounts
    cl_dscser VARCHAR(19),      -- GL serial link for discount accounts
    cl_salser VARCHAR(19),      -- GL serial link for salary/settlement accounts
    lastupdt VARCHAR(8),        -- Last update date (format: YYYYMMDD)
    modified BOOLEAN,           -- Flag indicating if the record was modified
    cl_ldesc VARCHAR(50),       -- Long/alternative language description
    rowguid VARCHAR(255),       -- Unique row identifier for replication/sync
    cstcode VARCHAR(4),         -- Cost center code associated with the class
    classkey VARCHAR(2)         -- Unique key for the classification
);

-- Table: aphdr
-- Description: Accounts Payable Header table storing high-level vendor invoice and voucher data.
CREATE TABLE bronze.aphdr (
    hd_company VARCHAR(2),      -- Company identifier code
    hd_type VARCHAR(2),         -- AP transaction type (e.g., Invoice, Payment)
    hd_ref NUMERIC(6,0),        -- Transaction reference/document number
    hd_date VARCHAR(8),         -- Transaction date (format: YYYYMMDD)
    hd_fcy VARCHAR(3),          -- Foreign currency code (e.g., USD, EUR)
    hd_ftotal DOUBLE PRECISION, -- Total document amount in foreign currency
    hd_fcyrate DOUBLE PRECISION,-- Exchange rate applied at transaction time
    hd_ltotal DOUBLE PRECISION, -- Total document amount in local currency
    hd_cucode VARCHAR(6),       -- Vendor/Supplier code
    hd_desc1 VARCHAR(110),      -- Header-level description or notes
    hd_ser VARCHAR(19),         -- General Ledger serial number mapping
    hd_rlsd BOOLEAN,            -- Flag indicating if the document is released
    hd_posted BOOLEAN,          -- Flag indicating if the document is posted to the GL
    hd_trxsrc VARCHAR(2),       -- Source module of the transaction
    hd_sysdate VARCHAR(8),      -- System date of entry (format: YYYYMMDD)
    hd_lcnet DOUBLE PRECISION,  -- Net amount in local currency
    hd_fcnet DOUBLE PRECISION,  -- Net amount in foreign currency
    hd_lccnet DOUBLE PRECISION, -- Net cost amount in local currency
    hd_fccnet DOUBLE PRECISION, -- Net cost amount in foreign currency
    isit_opst BOOLEAN,          -- Flag indicating if this is an opening settlement
    opst_val DOUBLE PRECISION,  -- Opening settlement value
    opst_fcy VARCHAR(3),        -- Opening settlement currency code
    lastupdt VARCHAR(8),        -- Last update date (format: YYYYMMDD)
    modified BOOLEAN,           -- Flag indicating if the record was modified
    rcvdtrn BOOLEAN,            -- Flag indicating a received transfer transaction
    usrid VARCHAR(10),          -- System user ID who created the record
    clcode VARCHAR(2),          -- AP Class code linkage
    clcmnd BOOLEAN,             -- Command/commission flag
    dscamt DOUBLE PRECISION,    -- Discount amount applied at header level
    payinv BOOLEAN,             -- Flag indicating if this is a payment invoice
    rowguid VARCHAR(255),       -- Unique row identifier
    bankref VARCHAR(20),        -- Associated bank reference number
    is_numerator BOOLEAN        -- Flag for internal numerator logic
);

-- Table: apdtl
-- Description: Accounts Payable Details table storing line-item allocations for AP documents.
CREATE TABLE bronze.apdtl (
    dt_company VARCHAR(2),      -- Company identifier code
    dt_type VARCHAR(2),         -- Document type (matches aphdr)
    dt_ref NUMERIC(6,0),        -- Document reference number (matches aphdr)
    dt_date VARCHAR(8),         -- Detail line date (format: YYYYMMDD)
    dt_lcamt DOUBLE PRECISION,  -- Line amount in local currency
    dt_paidamt DOUBLE PRECISION,-- Amount paid against this line
    dt_discamt DOUBLE PRECISION,-- Discount amount applied to this line
    dt_cucode VARCHAR(6),       -- Vendor/Supplier code
    dt_fcy VARCHAR(3),          -- Currency code for the line item
    dt_trxsrc VARCHAR(2),       -- Transaction source module
    dt_fcamt DOUBLE PRECISION,  -- Line amount in foreign currency
    dt_fpydamt DOUBLE PRECISION,-- Paid amount in foreign currency
    dt_fdscamt DOUBLE PRECISION,-- Discount amount in foreign currency
    dt_lcaloc DOUBLE PRECISION, -- Allocated local currency amount
    dt_fcaloc DOUBLE PRECISION, -- Allocated foreign currency amount
    dt_aloctd VARCHAR(1),       -- Allocation status indicator
    dt_pdinv NUMERIC(6,0),      -- Paid invoice reference number
    dt_duedate VARCHAR(8),      -- Due date for the line item
    dt_desc VARCHAR(110),       -- Line-item description
    dt_chkno VARCHAR(8),        -- Check number (if applicable)
    dt_chkdate VARCHAR(8),      -- Check date (if applicable)
    dt_chkbnk VARCHAR(2),       -- Bank code associated with the check
    dt_dbcr VARCHAR(1),         -- Debit/Credit indicator (D or C)
    dt_ackey VARCHAR(19),       -- General Ledger account key mapping
    dt_folio NUMERIC(4,0),      -- Folio or page number reference
    dt_rcvno NUMERIC(6,0),      -- Receipt number reference
    dt_lstdate VARCHAR(8),      -- Last update date (format: YYYYMMDD)
    tdscdays NUMERIC(2,0),      -- Trade discount days permitted
    tdscpcs NUMERIC(5,2),       -- Trade discount percentage
    match BOOLEAN,              -- Flag indicating if the line is matched/reconciled
    rplct_post BOOLEAN,         -- Flag indicating if the posting is replicated
    rowguid VARCHAR(255)        -- Unique row identifier
);

-- ============================================================================
-- 2. Accounts Receivable (AR) Tables
-- ============================================================================

-- Table: arhdr
-- Description: Accounts Receivable Header table storing high-level customer invoice/receipt data.
CREATE TABLE bronze.arhdr (
    hd_company VARCHAR(2),      -- Company identifier code
    hd_type VARCHAR(2),         -- AR transaction type
    hd_ref NUMERIC(6,0),        -- Transaction reference/document number
    hd_date VARCHAR(8),         -- Transaction date (format: YYYYMMDD)
    hd_fcy VARCHAR(3),          -- Foreign currency code
    hd_ftotal DOUBLE PRECISION, -- Total document amount in foreign currency
    hd_fcyrate DOUBLE PRECISION,-- Exchange rate applied at transaction time
    hd_ltotal DOUBLE PRECISION, -- Total document amount in local currency
    hd_cucode VARCHAR(6),       -- Customer code
    hd_desc1 VARCHAR(110),      -- Header-level description
    hd_ser VARCHAR(19),         -- General Ledger serial number mapping
    hd_rlsd BOOLEAN,            -- Flag indicating if the document is released
    hd_posted BOOLEAN,          -- Flag indicating if the document is posted to the GL
    hd_trxsrc VARCHAR(2),       -- Source module of the transaction
    hd_sysdate VARCHAR(8),      -- System date of entry (format: YYYYMMDD)
    hd_lcnet DOUBLE PRECISION,  -- Net amount in local currency
    hd_fcnet DOUBLE PRECISION,  -- Net amount in foreign currency
    hd_lccnet DOUBLE PRECISION, -- Net cost amount in local currency
    hd_fccnet DOUBLE PRECISION, -- Net cost amount in foreign currency
    isit_opst BOOLEAN,          -- Flag indicating if this is an opening settlement
    opst_val DOUBLE PRECISION,  -- Opening settlement value
    opst_fcy VARCHAR(3),        -- Opening settlement currency code
    lastupdt VARCHAR(8),        -- Last update date (format: YYYYMMDD)
    modified BOOLEAN,           -- Flag indicating if the record was modified
    rcvdtrn BOOLEAN,            -- Flag indicating a received transfer transaction
    usrid VARCHAR(10),          -- System user ID who created the record
    clcode VARCHAR(2),          -- AR Class code linkage
    clcmnd BOOLEAN,             -- Command/commission flag
    dscamt DOUBLE PRECISION,    -- Discount amount applied at header level
    payinv BOOLEAN,             -- Flag indicating if this is a payment invoice
    is_numerator BOOLEAN,       -- Flag for internal numerator logic
    discountedBill BOOLEAN      -- Flag indicating if the bill was discounted
);

-- Table: ardtl
-- Description: Accounts Receivable Details table storing line-item allocations for AR documents.
CREATE TABLE bronze.ardtl (
    dt_company VARCHAR(2),      -- Company identifier code
    dt_type VARCHAR(2),         -- Document type (matches arhdr)
    dt_ref NUMERIC(6,0),        -- Document reference number (matches arhdr)
    dt_date VARCHAR(8),         -- Detail line date (format: YYYYMMDD)
    dt_lcamt DOUBLE PRECISION,  -- Line amount in local currency
    dt_paidamt DOUBLE PRECISION,-- Amount paid by customer against this line
    dt_discamt DOUBLE PRECISION,-- Discount amount given on this line
    dt_cucode VARCHAR(6),       -- Customer code
    dt_fcy VARCHAR(3),          -- Currency code for the line item
    dt_trxsrc VARCHAR(2),       -- Transaction source module
    dt_fcamt DOUBLE PRECISION,  -- Line amount in foreign currency
    dt_fpydamt DOUBLE PRECISION,-- Paid amount in foreign currency
    dt_fdscamt DOUBLE PRECISION,-- Discount amount in foreign currency
    dt_lcaloc DOUBLE PRECISION, -- Allocated local currency amount
    dt_fcaloc DOUBLE PRECISION, -- Allocated foreign currency amount
    dt_aloctd VARCHAR(1),       -- Allocation status indicator
    dt_pdinv NUMERIC(6,0),      -- Paid invoice reference number
    dt_duedate VARCHAR(8),      -- Due date for customer payment
    dt_desc VARCHAR(110),       -- Line-item description
    dt_chkno VARCHAR(12),       -- Check number (if applicable)
    dt_chkdate VARCHAR(8),      -- Check date (if applicable)
    dt_chkbnk VARCHAR(2),       -- Bank code associated with the check
    dt_dbcr VARCHAR(1),         -- Debit/Credit indicator (D or C)
    dt_ackey VARCHAR(19),       -- General Ledger account key mapping
    dt_folio NUMERIC(3,0),      -- Folio or page number reference
    dt_rcvno NUMERIC(9,0),      -- Receipt number reference
    dt_lstdate VARCHAR(8),      -- Last update date (format: YYYYMMDD)
    tdscdays NUMERIC(2,0),      -- Trade discount days permitted
    tdscpcs NUMERIC(4,2),       -- Trade discount percentage
    match BOOLEAN,              -- Flag indicating if the line is matched/reconciled
    rplct_post BOOLEAN          -- Flag indicating if the posting is replicated
);

-- ============================================================================
-- 3. Banking & System Configurations
-- ============================================================================

-- Table: bkbank
-- Description: Bank Master table defining banking institutions.
CREATE TABLE bronze.bkbank (
    bkcode VARCHAR(2),          -- Unique bank institution code
    bkname VARCHAR(30),         -- Primary name of the bank
    bklname VARCHAR(30),        -- Alternative language name of the bank
    lastupdt VARCHAR(8)         -- Last update date (format: YYYYMMDD)
);

-- Table: bkacct
-- Description: Bank Accounts table mapping internal accounts to banking institutions.
CREATE TABLE bronze.bkacct (
    company VARCHAR(2),         -- Company identifier code
    bkcode VARCHAR(2),          -- Bank institution code (maps to bkbank)
    actcode NUMERIC(3,0),       -- Internal account code
    bkbrname VARCHAR(30),       -- Bank branch name
    actname VARCHAR(35),        -- Primary account name
    actno VARCHAR(15),          -- Official bank account number (e.g., IBAN/Local)
    glact VARCHAR(19),          -- General Ledger account mapping
    srlcode NUMERIC(3,0),       -- Serial code for document generation
    addrs VARCHAR(40),          -- Bank branch address
    stopped BOOLEAN,            -- Flag indicating if the account is frozen/stopped
    autonm BOOLEAN,             -- Auto-naming flag
    actlname VARCHAR(35),       -- Alternative language account name
    lastupdt VARCHAR(8)         -- Last update date (format: YYYYMMDD)
);

-- Table: brselected
-- Description: Utility table storing operational flags for selected branches.
CREATE TABLE bronze.brselected (
    name VARCHAR(25),           -- Branch operational name
    brnno VARCHAR(2),           -- Branch number
    selectd BOOLEAN,            -- Flag indicating if the branch is currently selected
    newbarcode BOOLEAN,         -- Flag indicating if new barcode rules apply
    priceupdt BOOLEAN,          -- Flag indicating pending price updates
    noupdate BOOLEAN            -- Lock flag to prevent updates
);

-- Table: classfil
-- Description: System Classification File defining generic operational grouping categories.
CREATE TABLE bronze.classfil (
    cl_company VARCHAR(2),      -- Company identifier code
    cl_code VARCHAR(2),         -- Classification code
    cl_desc VARCHAR(30),        -- Primary classification description
    cl_crlser VARCHAR(19),      -- GL serial link for credit accounts
    cl_dscser VARCHAR(19),      -- GL serial link for discount accounts
    cl_salser VARCHAR(19),      -- GL serial link for salary/settlement accounts
    lastupdt VARCHAR(8),        -- Last update date (format: YYYYMMDD)
    modified BOOLEAN,           -- Flag indicating if the record was modified
    cl_ldesc VARCHAR(30),       -- Alternative language description
    cstcode VARCHAR(4)          -- Associated cost center code
);

-- ============================================================================
-- 4. Customer Master Data
-- ============================================================================

-- Table: customer
-- Description: Comprehensive Customer Master table tracking demographics, balances, and configuration.
CREATE TABLE bronze.customer (
    cu_name VARCHAR(60),        -- Customer's primary business name
    cu_company VARCHAR(2),      -- Company identifier code
    cu_code VARCHAR(6),         -- Unique customer identification code
    cu_class VARCHAR(2),        -- Customer classification/group
    cu_addrs VARCHAR(50),       -- Customer primary physical address
    cu_tel VARCHAR(30),         -- Telephone number
    cu_fax VARCHAR(50),         -- Fax number
    cu_tlx VARCHAR(50),         -- Telex number (legacy)
    cu_email VARCHAR(30),       -- Customer email address
    cu_cntactp VARCHAR(50),     -- Primary contact person's name
    cu_title VARCHAR(50),       -- Title of the primary contact person
    cu_crlmt NUMERIC(14,2),     -- Approved credit limit
    cu_pymnt NUMERIC(3,0),      -- Payment terms (e.g., standard days to pay)
    cu_status NUMERIC(1,0),     -- Account status code (e.g., 1=Active, 0=Inactive)
    cu_opnbal DOUBLE PRECISION, -- Opening balance in local currency
    cu_curbal DOUBLE PRECISION, -- Current outstanding balance in local currency
    cf_fcy VARCHAR(3),          -- Default foreign currency code for customer
    cf_opnfcy DOUBLE PRECISION, -- Opening balance in foreign currency
    cf_curfcy DOUBLE PRECISION, -- Current outstanding balance in foreign currency
    cu_xrf VARCHAR(6),          -- Cross-reference code to external systems
    cu_alwcr BOOLEAN,           -- Flag indicating if credit is allowed
    cu_ctlser VARCHAR(19),      -- Control serial for General Ledger integration
    lastupdt VARCHAR(8),        -- Last update date (format: YYYYMMDD)
    cu_lcaloc DOUBLE PRECISION, -- Allocated local currency balance
    cu_fcaloc DOUBLE PRECISION, -- Allocated foreign currency balance
    cu_instlmnt NUMERIC(11,2),  -- Default installment amount
    cu_instldays NUMERIC(2,0),  -- Days between installments
    cu_install BOOLEAN,         -- Flag indicating if this is an installment customer
    modified BOOLEAN,           -- Flag indicating if the record was modified
    cmncode VARCHAR(8),         -- Commission code applied to sales for this customer
    cu_lname VARCHAR(40),       -- Customer's alternative language name
    cu_city VARCHAR(6),         -- City code
    cu_type VARCHAR(1),         -- Customer type classification
    cu_laddrs VARCHAR(50),      -- Customer's alternative language address
    cu_carrier VARCHAR(3),      -- Default shipping carrier code
    cu_mobile VARCHAR(50),      -- Mobile telephone number
    section VARCHAR(6),         -- Business section or division mapping
    cu_sendsms BOOLEAN,         -- Flag to opt-in for SMS notifications
    cu_onlycsh BOOLEAN,         -- Flag to restrict customer to cash-only transactions
    clnt_taxcode VARCHAR(20),   -- Customer VAT/Tax Identification Number
    taxFree BOOLEAN,            -- Flag indicating if the customer is tax-exempt
    cu_kind VARCHAR(1),         -- Customer kind identifier
    ok_free BOOLEAN,            -- Flag allowing free items
    ok_no_pay BOOLEAN,          -- Flag allowing bypass of immediate payment
    ok_no_down_payment BOOLEAN, -- Flag allowing no down payment
    exduplimit BOOLEAN,         -- Flag allowing exceeding the duplicate limit
    individual_clnt BOOLEAN,    -- Flag indicating a B2C individual (vs B2B corporate)
    location VARCHAR(50),       -- Geographic location text
    usrid VARCHAR(10),          -- System user ID who created the record
    usridchg VARCHAR(10),       -- System user ID who last modified the record
    Added_date VARCHAR(8),      -- Date the customer record was created (format: YYYYMMDD)
    cu_invdsc NUMERIC(7,3),     -- Default invoice discount percentage
    lst_inv_excd_duedate BOOLEAN,-- Flag tracking if the last invoice exceeded its due date
    slcode VARCHAR(2)           -- Assigned Salesman code for this customer
);

-- Safely drop existing tables before creation to ensure a clean deployment
DROP TABLE IF EXISTS bronze.delchghdr;
DROP TABLE IF EXISTS bronze.delchgdtl;
DROP TABLE IF EXISTS bronze.glchart;
DROP TABLE IF EXISTS bronze.glcurr;
DROP TABLE IF EXISTS bronze.glfcimage_rate;
DROP TABLE IF EXISTS bronze.gljrhdr;
DROP TABLE IF EXISTS bronze.gljrdtl;
DROP TABLE IF EXISTS bronze.glsction;
DROP TABLE IF EXISTS bronze.orcountry;
DROP TABLE IF EXISTS bronze.orpacking;

-- ============================================================================
-- 1. Delivery & Charges (Sales Extensions)
-- ============================================================================

-- Table: delchghdr
-- Description: Header table for delivery and additional charge transactions.
CREATE TABLE bronze.delchghdr (
    slcenter VARCHAR(2),        -- Sales center identifier
    branch VARCHAR(2),          -- Branch identifier
    company VARCHAR(2),         -- Company identifier code
    invtype VARCHAR(2),         -- Invoice/Document type
    ref NUMERIC(6,0),           -- Document reference number
    invdate VARCHAR(8),         -- Invoice date (format: YYYYMMDD)
    custno VARCHAR(6),          -- Customer number
    custnm VARCHAR(110),        -- Customer name
    glser VARCHAR(19),          -- General Ledger serial link
    dsctype VARCHAR(1),         -- Discount type applied
    pstmode NUMERIC(1,0),       -- Posting mode
    fcy VARCHAR(3),             -- Foreign currency code
    fcyrate DOUBLE PRECISION,   -- Exchange rate at transaction time
    duedate VARCHAR(8),         -- Payment due date
    invttl DOUBLE PRECISION,    -- Total invoice amount
    invcst DOUBLE PRECISION,    -- Total invoice cost
    invdspc DOUBLE PRECISION,   -- Invoice discount percentage
    invdsvl DOUBLE PRECISION,   -- Invoice discount value
    valafds DOUBLE PRECISION,   -- Value after discount
    invpaid DOUBLE PRECISION,   -- Amount paid against the invoice
    caser VARCHAR(19),          -- Cash serial link
    entries NUMERIC(5,0),       -- Number of line entries
    released BOOLEAN,           -- Flag indicating if document is released
    posted BOOLEAN,             -- Flag indicating if document is posted to GL
    fixrate DOUBLE PRECISION,   -- Fixed exchange rate applied
    extamt DOUBLE PRECISION,    -- Extra/Additional amount
    extser VARCHAR(19),         -- Extra/Additional amount GL serial
    pricetp VARCHAR(1),         -- Price type code
    ischeque BOOLEAN,           -- Flag indicating payment by cheque
    chkno VARCHAR(8),           -- Cheque number
    chkdate VARCHAR(8),         -- Cheque date
    lastupdt VARCHAR(8),        -- Last update date
    jvgenrt BOOLEAN,            -- Flag indicating a Journal Voucher was generated
    cccommsn DOUBLE PRECISION,  -- Credit card commission amount
    belowbal BOOLEAN,           -- Flag for below-balance conditions
    fcy2 VARCHAR(3),            -- Secondary foreign currency code
    ccpayment DOUBLE PRECISION, -- Credit card payment amount
    rplsamt DOUBLE PRECISION,   -- Replacement amount
    pdother BOOLEAN,            -- Paid by other means flag
    slcode VARCHAR(2),          -- Salesman/Agent code
    prpaidamt DOUBLE PRECISION, -- Prepaid amount
    instldays NUMERIC(3,0),     -- Installment days
    instflag BOOLEAN,           -- Installment plan flag
    slcmnd BOOLEAN,             -- Sales command flag
    inv_printed NUMERIC(2,0),   -- Number of times the invoice was printed
    bendit BOOLEAN,             -- Backend edit flag
    modified BOOLEAN,           -- Flag indicating if the record was modified
    rqstorder NUMERIC(6,0),     -- Requested order reference
    rqststld BOOLEAN,           -- Requested order settled flag
    carrier VARCHAR(3),         -- Shipping carrier code
    rcvdtrn BOOLEAN,            -- Received transaction flag
    usrid VARCHAR(10),          -- User ID who created the record
    address VARCHAR(50),        -- Delivery address
    suspend BOOLEAN,            -- Flag indicating if transaction is suspended
    rtnref NUMERIC(6,0),        -- Return reference number
    ispurchase BOOLEAN,         -- Flag indicating if this is linked to a purchase
    stkjvno NUMERIC(6,0),       -- Stock Journal Voucher number
    posinv NUMERIC(1,0),        -- POS invoice indicator
    whodelete VARCHAR(10),      -- User ID who deleted/voided the record
    action_type BOOLEAN,        -- Action type flag
    action_tdate TIMESTAMP,     -- Timestamp of the action
    src VARCHAR(2),             -- Source module
    trx_id INTEGER,             -- Unique transaction ID
    pricevattype NUMERIC(1,0),  -- Price VAT type indicator
    clnt_kind VARCHAR(1),       -- Client kind indicator
    vat_amt_rcvd DOUBLE PRECISION, -- VAT amount received
    vat_percent NUMERIC(5,2),   -- VAT percentage applied
    crtd_fm_batch_ref INTEGER,  -- Created from batch reference ID
    diffamount DOUBLE PRECISION,-- Difference amount (e.g., rounding)
    fld1 DOUBLE PRECISION,      -- Custom flexible field 1
    fld2 DOUBLE PRECISION,      -- Custom flexible field 2
    fld3 INTEGER                -- Custom flexible field 3
);

-- Table: delchgdtl
-- Description: Detail/Line-item table for delivery and additional charge transactions.
CREATE TABLE bronze.delchgdtl (
    slcenter VARCHAR(2),        -- Sales center identifier
    company VARCHAR(2),         -- Company identifier code
    invtype VARCHAR(2),         -- Document type (matches header)
    ref NUMERIC(6,0),           -- Document reference number (matches header)
    invdate VARCHAR(8),         -- Invoice date
    itemno VARCHAR(16),         -- Item/Product number
    unicode VARCHAR(6),         -- Unit of measure code
    qty DOUBLE PRECISION,       -- Quantity
    fqty DOUBLE PRECISION,      -- Foreign/Secondary quantity
    price DOUBLE PRECISION,     -- Unit price
    discpc DOUBLE PRECISION,    -- Discount percentage
    cost DOUBLE PRECISION,      -- Unit cost
    ds_acfm NUMERIC(1,0),       -- Discount confirmation flag
    sl_acfm NUMERIC(1,0),       -- Sales confirmation flag
    gclass VARCHAR(12),         -- Item classification group
    custno VARCHAR(6),          -- Customer number
    fcy VARCHAR(3),             -- Foreign currency code
    barcode VARCHAR(20),        -- Item barcode
    imfcval DOUBLE PRECISION,   -- Import foreign currency value
    pack VARCHAR(1),            -- Packaging type
    pkqty DOUBLE PRECISION,     -- Packaging quantity
    shadd VARCHAR(1),           -- Shadow addition flag
    shdpk DOUBLE PRECISION,     -- Shadow pack quantity
    shdqty DOUBLE PRECISION,    -- Shadow standard quantity
    frtqty DOUBLE PRECISION,    -- Freight quantity
    rtnqty DOUBLE PRECISION,    -- Return quantity
    whno VARCHAR(2),            -- Warehouse number
    cmbkey VARCHAR(24),         -- Combined key for item/unit
    trx_id INTEGER,             -- Unique transaction ID
    jdtext VARCHAR(110),        -- Journal description text
    dbcr VARCHAR(1),            -- Debit/Credit indicator
    src VARCHAR(2),             -- Source module
    fld1 DOUBLE PRECISION,      -- Custom flexible field 1
    fld2 DOUBLE PRECISION,      -- Custom flexible field 2
    acc VARCHAR(19),            -- General Ledger account number
    brxref NUMERIC(6,0),        -- Branch cross-reference
    match BOOLEAN,              -- Line matched/reconciled flag
    dt_duedate VARCHAR(8),      -- Detail line due date
    dt_chkno VARCHAR(8),        -- Detail line cheque number
    dt_chkdate VARCHAR(8),      -- Detail line cheque date
    dt_lstdate VARCHAR(8),      -- Last update date
    dt_folio NUMERIC(5,0),      -- Folio reference
    tdscdays NUMERIC(3,0),      -- Trade discount days
    taxtype VARCHAR(1),         -- Tax type applied
    amtincldvat BOOLEAN,        -- Flag indicating if amount includes VAT
    vndr_name VARCHAR(50),      -- Vendor name (if applicable)
    fld3 DOUBLE PRECISION,      -- Custom flexible fields 3-9
    fld4 DOUBLE PRECISION, 
    fld5 DOUBLE PRECISION, 
    fld6 DOUBLE PRECISION, 
    fld7 DOUBLE PRECISION, 
    fld8 DOUBLE PRECISION, 
    fld9 DOUBLE PRECISION
);

-- ============================================================================
-- 2. General Ledger (GL) Tables
-- ============================================================================

-- Table: glchart
-- Description: The core Chart of Accounts master table.
CREATE TABLE bronze.glchart (
    glname VARCHAR(75),         -- Account name
    glkey VARCHAR(19),          -- Account number/key
    glcomp VARCHAR(2),          -- Company code
    glcurbal DOUBLE PRECISION,  -- Current balance (Local Currency)
    glopnbal DOUBLE PRECISION,  -- Opening balance (Local Currency)
    glopndate VARCHAR(8),       -- Opening balance date
    glamnd VARCHAR(8),          -- Last amended date
    glacttyp VARCHAR(1),        -- Account type (e.g., Asset, Liability)
    glgroup VARCHAR(1),         -- Account grouping level
    glactive VARCHAR(1),        -- Account active status
    glpurge VARCHAR(1),         -- Purge status
    accontrol BOOLEAN,          -- Control account flag (restricts manual entry)
    glp_lcode VARCHAR(1),       -- P&L code mapping
    glcurrency VARCHAR(3),      -- Default currency for the account
    -- Balances broken down by financial periods (1-13) in Local Currency
    glbal01 DOUBLE PRECISION, glbal02 DOUBLE PRECISION, glbal03 DOUBLE PRECISION, 
    glbal04 DOUBLE PRECISION, glbal05 DOUBLE PRECISION, glbal06 DOUBLE PRECISION, 
    glbal07 DOUBLE PRECISION, glbal08 DOUBLE PRECISION, glbal09 DOUBLE PRECISION, 
    glbal10 DOUBLE PRECISION, glbal11 DOUBLE PRECISION, glbal12 DOUBLE PRECISION, 
    glbal13 DOUBLE PRECISION, 
    fccurbal DOUBLE PRECISION,  -- Current balance (Foreign Currency)
    fcopnbal DOUBLE PRECISION,  -- Opening balance (Foreign Currency)
    -- Balances broken down by financial periods (1-13) in Foreign Currency
    fcbal01 DOUBLE PRECISION, fcbal02 DOUBLE PRECISION, fcbal03 DOUBLE PRECISION, 
    fcbal04 DOUBLE PRECISION, fcbal05 DOUBLE PRECISION, fcbal06 DOUBLE PRECISION, 
    fcbal07 DOUBLE PRECISION, fcbal08 DOUBLE PRECISION, fcbal09 DOUBLE PRECISION, 
    fcbal10 DOUBLE PRECISION, fcbal11 DOUBLE PRECISION, fcbal12 DOUBLE PRECISION, 
    fcbal13 DOUBLE PRECISION, 
    glsgrp VARCHAR(1),          -- Sub-group mapping
    imopnbal DOUBLE PRECISION,  -- Import opening balance
    imcurbal DOUBLE PRECISION,  -- Import current balance
    lastupdt VARCHAR(8),        -- Last update date
    gleval BOOLEAN,             -- Evaluation flag (e.g., for revaluation)
    acprotect BOOLEAN,          -- Account protected status
    pkey NUMERIC(5,0),          -- Parent account key (for hierarchy)
    chkey NUMERIC(5,0),         -- Child account key
    cashbnk BOOLEAN,            -- Flag indicating a cash or bank account
    modified BOOLEAN,           -- Record modified flag
    gllname VARCHAR(75),        -- Alternative language account name
    section VARCHAR(6),         -- Section/Division code mapping
    isbracc BOOLEAN,            -- Branch account flag
    actlvl INTEGER,             -- Account hierarchy level
    glackind VARCHAR(1),        -- Account kind
    rowguid VARCHAR(255),       -- Unique row identifier
    usrid VARCHAR(10),          -- User ID who created the account
    usridchg VARCHAR(10)        -- User ID who last changed the account
);

-- Table: glcurr
-- Description: Currency definitions and exchange rate master table.
CREATE TABLE bronze.glcurr (
    curname VARCHAR(30),        -- Currency name
    curcode VARCHAR(3),         -- Currency code (e.g., USD, YER)
    currate DOUBLE PRECISION,   -- Current standard exchange rate
    curfix DOUBLE PRECISION,    -- Fixed exchange rate (if pegged)
    cursname VARCHAR(5),        -- Currency short name/symbol
    lastupdt VARCHAR(8),        -- Last update date
    curparts VARCHAR(10),       -- Sub-unit name (e.g., Cents, Fils)
    modified BOOLEAN,           -- Record modified flag
    curlname VARCHAR(30),       -- Alternative language currency name
    curlsname VARCHAR(10),      -- Alternative language short name
    curlparts VARCHAR(10),      -- Alternative language sub-unit name
    fcimage_rate DOUBLE PRECISION, -- Foreign currency image rate (shadow rate)
    fcwh_rate DOUBLE PRECISION, -- Warehouse specific exchange rate
    is_numerator BOOLEAN,       -- True if rate is calculated via division vs multiplication
    curminrate NUMERIC(12,5),   -- Minimum allowable exchange rate
    curmaxrate NUMERIC(12,5),   -- Maximum allowable exchange rate
    standard_fcy_code VARCHAR(3),-- Standardized ISO currency code
    posrate DOUBLE PRECISION,   -- Rate specifically for POS systems
    posusrid VARCHAR(10)        -- User ID who set the POS rate
);

-- Table: glfcimage_rate
-- Description: History log for Foreign Currency Image (Shadow) rates.
CREATE TABLE bronze.glfcimage_rate (
    company VARCHAR(2),         -- Company code
    image_fc_usrid VARCHAR(10), -- User ID who updated the rate
    image_fc_date VARCHAR(8),   -- Date of update
    image_fc_srlno INTEGER,     -- Serial number for tracking
    image_fc_rate DOUBLE PRECISION, -- The specific image exchange rate
    image_fc_datetime TIMESTAMP,    -- Exact timestamp of the update
    image_fc_fcy VARCHAR(3),    -- Foreign currency code
    main_fc_fcy VARCHAR(3),     -- Base currency code compared against
    main_fcy_rate DOUBLE PRECISION  -- Corresponding base currency rate
);

-- Table: gljrhdr
-- Description: General Ledger Journal Voucher Header.
CREATE TABLE bronze.gljrhdr (
    jhcomp VARCHAR(2),          -- Company code
    jhtype VARCHAR(2),          -- Journal type (e.g., JV, CR, CP)
    jhref NUMERIC(6,0),         -- Journal reference number
    jhdate VARCHAR(8),          -- Journal entry date
    jhtext VARCHAR(110),        -- Header level description/narration
    jhamt DOUBLE PRECISION,     -- Total amount of the journal
    jhentries NUMERIC(4,0),     -- Number of detail lines in the journal
    jhsrc VARCHAR(2),           -- Source module generating the journal
    jhsysdate VARCHAR(8),       -- System date of entry
    jhcurr VARCHAR(3),          -- Currency code for the journal
    jhfcflag NUMERIC(1,0),      -- Foreign currency flag
    jhrate DOUBLE PRECISION,    -- Exchange rate applied to the journal
    jhreleased BOOLEAN,         -- Flag indicating if journal is released
    jhposted BOOLEAN,           -- Flag indicating if journal is posted
    lastupdt VARCHAR(8),        -- Last update date
    jhlccrttl DOUBLE PRECISION, -- Total Local Currency Credit
    jhlcdbttl DOUBLE PRECISION, -- Total Local Currency Debit
    jhfccrttl DOUBLE PRECISION, -- Total Foreign Currency Credit
    jhfcdbttl DOUBLE PRECISION, -- Total Foreign Currency Debit
    jhimgrate DOUBLE PRECISION, -- Image rate applied to journal
    modified BOOLEAN,           -- Record modified flag
    serial_no NUMERIC(4,0),     -- System generated serial number
    rcvdtrn BOOLEAN,            -- Received transaction flag
    suspend BOOLEAN,            -- Suspended status flag
    usrid VARCHAR(10),          -- User ID who created the journal
    isbrtrx BOOLEAN,            -- Is branch transaction flag
    brxref VARCHAR(8),          -- Branch cross-reference
    brxfrm VARCHAR(2),          -- Branch from (originating branch)
    jhcustno VARCHAR(6),        -- Customer number (if directly related)
    hide_jv BOOLEAN,            -- Flag to hide JV from standard views
    rowguid VARCHAR(255),       -- Unique row identifier
    bankref VARCHAR(20),        -- Bank reference number
    Vat_Percent NUMERIC(5,2),   -- VAT percentage applied
    jhtext1 VARCHAR(70),        -- Additional header description text
    is_numerator BOOLEAN,       -- Currency conversion methodology flag
    jhfcamt DOUBLE PRECISION,   -- Total foreign currency amount
    zatca_rounding BOOLEAN,     -- Tax authority (e.g., ZATCA) rounding rule applied
    sc_codeyrtp VARCHAR(9)      -- Section/Year type composite code
);

-- Table: gljrdtl
-- Description: General Ledger Journal Voucher Details (Debit/Credit lines).
CREATE TABLE bronze.gljrdtl (
    jdcomp VARCHAR(2),          -- Company code
    jdtype VARCHAR(2),          -- Journal type (matches header)
    jdref NUMERIC(6,0),         -- Journal reference (matches header)
    jdkey VARCHAR(19),          -- Target GL Account number
    jddate VARCHAR(8),          -- Detail line date
    jdtext VARCHAR(110),        -- Detail line description/narration
    jdlcamt DOUBLE PRECISION,   -- Line amount in Local Currency
    jddbcr VARCHAR(1),          -- Debit/Credit indicator (D or C)
    jdfcamt DOUBLE PRECISION,   -- Line amount in Foreign Currency
    jdcurr VARCHAR(3),          -- Currency code for the line
    jdfolio NUMERIC(4,0),       -- Folio reference
    jdfolno NUMERIC(3,0),       -- Folio number
    jdsysdate VARCHAR(8),       -- System date
    jdsrc VARCHAR(2),           -- Source module
    jdfc_imgval DOUBLE PRECISION, -- Line amount using FC image rate
    jdcstval DOUBLE PRECISION,  -- Cost center value mapping
    cstkey VARCHAR(22),         -- Cost center key
    brnno VARCHAR(2),           -- Branch number
    bracc VARCHAR(19),          -- Branch account link
    brxref NUMERIC(6,0),        -- Branch cross reference
    match BOOLEAN,              -- Line matched/reconciled flag
    rplct_post BOOLEAN,         -- Replicated post flag
    rowguid VARCHAR(255),       -- Unique row identifier
    taxcatId NUMERIC(3,0),      -- Tax category ID applied to the line
    jhcustno VARCHAR(6)         -- Associated customer number
);

-- Table: glsction
-- Description: GL Sections mapping (Cost centers, Divisions, automated JV routing).
CREATE TABLE bronze.glsction (
    sc_code VARCHAR(4),         -- Section/Division code
    sc_name VARCHAR(40),        -- Section name
    sc_lname VARCHAR(40),       -- Alternative language section name
    sc_company VARCHAR(2),      -- Company code mapping
    sc_whno VARCHAR(2),         -- Default warehouse for this section
    sc_arcode NUMERIC(6,0),     -- Associated AR code
    sc_nowh NUMERIC(1,0),       -- Number of warehouses
    sc_m_center BOOLEAN,        -- Flag indicating if it is a main center
    lastupdt VARCHAR(8),        -- Last update date
    rebate_act VARCHAR(19),     -- Rebate GL account
    lossRebateAct VARCHAR(19),  -- Loss Rebate GL account
    -- System routing hooks mapping business events to automated Journal Vouchers
    jv_01 NUMERIC(6,0), jv_02 NUMERIC(6,0), jv_03 NUMERIC(6,0), jv_04 NUMERIC(6,0), 
    jv_05 NUMERIC(6,0), jv_06 NUMERIC(6,0), jv_07 NUMERIC(6,0), jv_08 NUMERIC(6,0), 
    jv_09 NUMERIC(6,0), jv_10 NUMERIC(6,0), jv_11 NUMERIC(6,0), jv_12 NUMERIC(6,0), 
    jv_13 NUMERIC(6,0), jv_14 NUMERIC(6,0), jv_16 NUMERIC(6,0), jv_17 NUMERIC(6,0), 
    jv_18 NUMERIC(6,0), jv_19 NUMERIC(6,0), jv_20 NUMERIC(6,0), jv_21 NUMERIC(6,0), 
    jv_22 NUMERIC(6,0), jv_23 NUMERIC(6,0), jv_24 NUMERIC(6,0), jv_26 NUMERIC(6,0), 
    jv_27 NUMERIC(6,0), jv_28 NUMERIC(6,0), jv_30 NUMERIC(6,0), jv_31 NUMERIC(6,0), 
    jv_32 NUMERIC(6,0), jv_33 NUMERIC(6,0), jv_34 NUMERIC(6,0), JV_37 INTEGER, 
    jv_45 NUMERIC(10,0), jv_46 NUMERIC(6,0), jv_51 INTEGER, jv_55 INTEGER, 
    jv_56 INTEGER, jv_60 INTEGER, jv_61 INTEGER, 
    sysno NUMERIC(2,0),         -- System instance number
    No_round_nm BOOLEAN,        -- Rounding disable flag
    PriceVatType NUMERIC(1,0),  -- Pricing VAT logic type
    mkt_frc_rounding BOOLEAN,   -- Market force rounding flag
    is_dsc_amt BOOLEAN,         -- Discount amount calculation flag
    auto_dsc_hll BOOLEAN,       -- Auto discount fractional (halala) logic
    max_dsc_hll NUMERIC(3,2),   -- Max fractional discount allowed
    sc_card_srlno INTEGER,      -- Section card serial number
    sc_card_jvno INTEGER,       -- Section card JV number
    ar_dscser VARCHAR(19),      -- AR Discount serial link
    ap_dscser VARCHAR(19),      -- AP Discount serial link
    sc_lvlno INTEGER,           -- Section hierarchy level
    -- Additional system routing hooks for automated JVs
    jv_105 INTEGER, jv_106 INTEGER, jv_107 INTEGER, jv_108 INTEGER, jv_109 INTEGER, 
    jv_110 INTEGER, jv_205 INTEGER, jv_209 INTEGER, jv_210 INTEGER, jv_211 INTEGER, 
    jv_212 INTEGER, jv_213 INTEGER, jv_214 INTEGER, jv_215 INTEGER, jv_216 INTEGER, 
    jv_301 INTEGER, jv_501 INTEGER, jv_502 INTEGER, 
    cashser VARCHAR(19),        -- Cash GL serial link
    sc_lvl1 VARCHAR(2),         -- Hierarchy level 1 mapping
    sc_lvl2 VARCHAR(2),         -- Hierarchy level 2 mapping
    sc_lvl3 VARCHAR(2),         -- Hierarchy level 3 mapping
    CHKEY INTEGER,              -- Child Key
    PKEY INTEGER                -- Parent Key
);

-- ============================================================================
-- 3. System Lookup Tables
-- ============================================================================

-- Table: orcountry
-- Description: Country master dictionary for geographic lookup.
CREATE TABLE bronze.orcountry (
    country_id NUMERIC(3,0),    -- System specific country ID
    cnname VARCHAR(50),         -- Country name
    lcnname VARCHAR(50),        -- Alternative language country name
    standard_country_code VARCHAR(3) -- Standardized ISO country code
);

-- Table: orpacking
-- Description: Packaging types and definitions dictionary.
CREATE TABLE bronze.orpacking (
    pack_id VARCHAR(1),         -- Unique packaging identifier
    pkname VARCHAR(30),         -- Packaging name (e.g., Box, Pallet, Carton)
    lpkname VARCHAR(15),        -- Alternative language packaging name
    pkorder VARCHAR(1),         -- Ordering sorting priority
    pkdfqty NUMERIC(8,3),       -- Default quantity contained within this pack
    pkwhlsl BOOLEAN,            -- Flag indicating if this is a wholesale pack size
    standard_unit_code VARCHAR(5) -- Standardized ISO unit code
);

-- ============================================================================
-- PostgreSQL Schema Definitions: Bronze Layer (Batch 3)
-- Description: Purchasing, Sales, Quotations, Sales Centers, and Price History.
-- ============================================================================

-- Safely drop existing tables before creation to ensure a clean deployment
DROP TABLE IF EXISTS bronze.pricehst;
DROP TABLE IF EXISTS bronze.pudept;
DROP TABLE IF EXISTS bronze.puhdr;
DROP TABLE IF EXISTS bronze.pudtl;
DROP TABLE IF EXISTS bronze.salecntr;
DROP TABLE IF EXISTS bronze.sales_hd;
DROP TABLE IF EXISTS bronze.sales_dt;
DROP TABLE IF EXISTS bronze.sales_qh;
DROP TABLE IF EXISTS bronze.sales_qd;
DROP TABLE IF EXISTS bronze.salesmen;

-- ============================================================================
-- 1. Pricing & Sales Master Data
-- ============================================================================

-- Table: pricehst
-- Description: Audit log for historical price changes and promotions.
CREATE TABLE bronze.pricehst (
    prcode NUMERIC(12,0),       -- Unique price history record code
    oldprice NUMERIC(11,2),     -- Previous item price
    newprice NUMERIC(11,2),     -- New item price
    tdate VARCHAR(8),           -- Transaction date of the change (YYYYMMDD)
    usrid VARCHAR(10),          -- User ID who made the change
    qty NUMERIC(11,2),          -- Quantity threshold (if applicable for tier pricing)
    cmbkey VARCHAR(24),         -- Combined key (Item + Unit)
    company VARCHAR(2),         -- Company identifier code
    xitemkey VARCHAR(22),       -- Cross-reference item key
    modified BOOLEAN,           -- Record modified flag
    slcenter VARCHAR(2),        -- Associated sales center
    promotion BOOLEAN,          -- Flag indicating if this change is a temporary promotion
    prm_start VARCHAR(8),       -- Promotion start date (YYYYMMDD)
    prm_end VARCHAR(8),         -- Promotion end date (YYYYMMDD)
    barcode VARCHAR(20)         -- Associated barcode
);

-- Table: salesmen
-- Description: Master data for sales representatives, buyers, and collectors.
CREATE TABLE bronze.salesmen (
    slcompany VARCHAR(2),       -- Company identifier code
    slcode VARCHAR(2),          -- Unique salesman code
    slshort VARCHAR(10),        -- Short name/code
    slname VARCHAR(40),         -- Full name of the representative
    slcomm NUMERIC(4,2),        -- Sales commission percentage
    clcomm NUMERIC(4,2),        -- Collection commission percentage
    sltarget NUMERIC(12,2),     -- Sales target/quota amount
    cltarget NUMERIC(12,2),     -- Collection target amount
    salesman BOOLEAN,           -- Flag indicating role as Salesman
    collector BOOLEAN,          -- Flag indicating role as Collector
    sltype NUMERIC(1,0),        -- Salesman type (e.g., Internal vs External)
    lstcomm VARCHAR(8),         -- Date of last commission calculation
    modified BOOLEAN,           -- Record modified flag
    sllname VARCHAR(40),        -- Alternative language name
    lastupdt VARCHAR(8),        -- Last update date
    purshman BOOLEAN,           -- Flag indicating role as Purchasing Agent
    notify_type INTEGER,        -- System notification preference type
    notify_within INTEGER,      -- Notification timeframe
    slemail VARCHAR(60),        -- Email address
    slmobile VARCHAR(20),       -- Mobile phone number
    usrid VARCHAR(10),          -- System user ID linked to this salesman
    slscmnact VARCHAR(19),      -- General Ledger account for commissions
    crdt_limit DOUBLE PRECISION,-- Authorized credit limit to offer clients
    sl_center VARCHAR(2)        -- Assigned primary sales center
);

-- ============================================================================
-- 2. Purchasing & Receiving (PU)
-- ============================================================================

-- Table: pudept
-- Description: Purchasing Departments configuration and General Ledger mapping.
CREATE TABLE bronze.pudept (
    dp_name VARCHAR(30),        -- Department name
    dp_brno VARCHAR(2),         -- Branch number
    dp_dept VARCHAR(2),         -- Department code
    dp_cashser VARCHAR(19),     -- GL Serial link: Cash purchases
    dp_cslser VARCHAR(19),      -- GL Serial link: Cash sales
    dp_oslser VARCHAR(19),      -- GL Serial link: Credit sales
    dp_rcslser VARCHAR(19),     -- GL Serial link: Return cash sales
    dp_roslser VARCHAR(19),     -- GL Serial link: Return credit sales
    dp_custser VARCHAR(19),     -- GL Serial link: Customs
    dp_expser VARCHAR(19),      -- GL Serial link: Expenses
    dp_okdiff BOOLEAN,          -- Allow pricing differences flag
    dp_diffser VARCHAR(19),     -- GL Serial link: Price differences
    dp_mainwh VARCHAR(2),       -- Default main warehouse code
    dp_rtrnwh VARCHAR(2),       -- Default return warehouse code
    lastupdt VARCHAR(8),        -- Last update date
    dp_comp VARCHAR(2),         -- Company identifier code
    modified BOOLEAN,           -- Record modified flag
    cstcode VARCHAR(4),         -- Cost center code
    serfrt VARCHAR(19),         -- GL Serial link: Freight
    serins VARCHAR(19),         -- GL Serial link: Insurance
    sercst VARCHAR(19),         -- GL Serial link: Cost
    serpvl VARCHAR(19),         -- GL Serial link: Privileges/Duties
    sersmp VARCHAR(19),         -- GL Serial link: Samples
    serfn VARCHAR(19),          -- GL Serial link: Fines
    sertkt VARCHAR(19),         -- GL Serial link: Tickets/Travel
    serfre VARCHAR(19),         -- GL Serial link: Free items
    sertrn VARCHAR(19),         -- GL Serial link: Transport
    seroth VARCHAR(19),         -- GL Serial link: Other expenses
    dp_lname VARCHAR(30),       -- Alternative language department name
    vat_paid_act VARCHAR(19),   -- GL Account link: VAT Paid
    chk_serfrt BOOLEAN,         -- Flag to check freight serial validity
    chk_serins BOOLEAN,         -- Flag to check insurance serial validity
    chk_sercst BOOLEAN,         -- Flag to check cost serial validity
    chk_serpvl BOOLEAN,         -- Flag to check privilege serial validity
    chk_sersmp BOOLEAN,         -- Flag to check samples serial validity
    chk_serfn BOOLEAN,          -- Flag to check fines serial validity
    chk_sertkt BOOLEAN,         -- Flag to check tickets serial validity
    chk_serfre BOOLEAN,         -- Flag to check free items serial validity
    chk_sertrn BOOLEAN,         -- Flag to check transport serial validity
    chk_seroth BOOLEAN,         -- Flag to check other expense serial validity
    VAT_AUTO_CALC BOOLEAN,      -- Flag for automatic VAT calculation
    suspended BOOLEAN,          -- Suspended department flag
    sc_code VARCHAR(6)          -- Sales/Cost center linkage code
);

-- Table: puhdr
-- Description: Purchasing Header for Purchase Orders and Supplier Invoices.
CREATE TABLE bronze.puhdr (
    slcenter VARCHAR(2),        -- Sales/Purchasing center code
    branch VARCHAR(2),          -- Branch code
    company VARCHAR(2),         -- Company identifier code
    invtype VARCHAR(2),         -- Document type (e.g., PO, Invoice, Return)
    ref NUMERIC(6,0),           -- Document reference number
    invdate VARCHAR(8),         -- Document date (YYYYMMDD)
    custno VARCHAR(6),          -- Supplier code (reusing 'custno' naming convention)
    custnm VARCHAR(50),         -- Supplier name
    glser VARCHAR(19),          -- General Ledger serial link
    dsctype VARCHAR(1),         -- Discount type indicator
    pstmode NUMERIC(1,0),       -- Posting mode
    fcy VARCHAR(3),             -- Foreign currency code
    fcyrate DOUBLE PRECISION,   -- Exchange rate at transaction time
    duedate VARCHAR(8),         -- Payment due date
    invttl DOUBLE PRECISION,    -- Total invoice amount
    invcst DOUBLE PRECISION,    -- Total invoice cost
    invdspc DOUBLE PRECISION,   -- Total discount percentage
    invdsvl DOUBLE PRECISION,   -- Total discount value
    valafds DOUBLE PRECISION,   -- Value after discount
    invpaid DOUBLE PRECISION,   -- Amount paid
    caser VARCHAR(19),          -- Cash GL serial link
    entries NUMERIC(5,0),       -- Number of detail line items
    released BOOLEAN,           -- Document released flag
    posted BOOLEAN,             -- Document posted to GL flag
    fixrate DOUBLE PRECISION,   -- Fixed exchange rate applied
    spply_exp DOUBLE PRECISION, -- Supplier expenses
    pricetp VARCHAR(1),         -- Price type code
    isglact BOOLEAN,            -- Flag indicating direct GL account post
    chkno VARCHAR(8),           -- Cheque number
    chkdate VARCHAR(8),         -- Cheque date
    lastupdt VARCHAR(8),        -- Last update date
    jvgenrt BOOLEAN,            -- Flag indicating a Journal Voucher was generated
    imfcval DOUBLE PRECISION,   -- Import foreign currency value
    lcser VARCHAR(19),          -- Letter of Credit (LC) GL serial
    frieght NUMERIC(12,2),      -- Freight charges
    insurexp NUMERIC(12,2),     -- Insurance expenses
    customfee NUMERIC(12,2),    -- Customs fees
    portexp NUMERIC(12,2),      -- Port expenses
    samplexp NUMERIC(12,2),     -- Sample expenses
    lcinvexp DOUBLE PRECISION,  -- Local currency invoice expenses
    fcinvexp DOUBLE PRECISION,  -- Foreign currency invoice expenses
    lcothrexp NUMERIC(12,2),    -- Local currency other expenses
    fineexp NUMERIC(12,2),      -- Fine expenses
    lcttlexp DOUBLE PRECISION,  -- Total expenses (Local)
    fcttlexp DOUBLE PRECISION,  -- Total expenses (Foreign)
    tktexp NUMERIC(11,2),       -- Ticket expenses
    freexp NUMERIC(11,2),       -- Free item expenses
    transexp NUMERIC(11,2),     -- Transport expenses
    prodrate DOUBLE PRECISION,  -- Production/Yield rate
    isl_c BOOLEAN,              -- Is Letter of Credit transaction flag
    binno VARCHAR(6),           -- Receiving warehouse bin number
    aprxcst BOOLEAN,            -- Approximate cost flag
    aprxpc DOUBLE PRECISION,    -- Approximate cost percentage
    aprxser VARCHAR(19),        -- Approximate cost GL serial
    expser VARCHAR(19),         -- Expense GL serial
    modified BOOLEAN,           -- Record modified flag
    splyinv VARCHAR(20),        -- Original supplier invoice number
    isorder BOOLEAN,            -- Is Purchase Order flag
    settled BOOLEAN,            -- Is settled flag
    rcvdtrn BOOLEAN,            -- Received transaction flag
    fcothrexp NUMERIC(12,2),    -- Foreign currency other expenses
    usrid VARCHAR(10),          -- System user ID
    jvdsc NUMERIC(6,0),         -- Journal Voucher discount link
    paylcl BOOLEAN,             -- Pay in local currency flag
    tdscpcs NUMERIC(5,2),       -- Trade discount percentage
    tdscdays NUMERIC(2,0),      -- Trade discount days allowed
    orderno VARCHAR(20),        -- Associated PO number
    slcode VARCHAR(2),          -- Buyer/Purchasing agent code
    lccode VARCHAR(15),         -- Letter of Credit code
    shpdate VARCHAR(8),         -- Shipment date
    edm INTEGER,                -- Electronic Document Management ID
    gntd_fm_lc BOOLEAN,         -- Generated from Letter of Credit flag
    lc_ship_no NUMERIC(4,0),    -- LC Shipment Number
    xfr_amt DOUBLE PRECISION,   -- Transfer amount
    xfr_acc VARCHAR(19),        -- Transfer GL account
    vat_amt_paid DOUBLE PRECISION, -- VAT amount paid
    taxfree_purchase DOUBLE PRECISION, -- Tax-free purchase total
    VatNot4Vender BOOLEAN,      -- VAT not applicable to vendor flag
    vndr_taxcode VARCHAR(20),   -- Vendor Tax/VAT ID
    expns4vat DOUBLE PRECISION, -- Expenses subject to VAT
    tax_Pd_mthd VARCHAR(1),     -- Tax payment method indicator
    vndr_kind VARCHAR(1),       -- Vendor categorization kind
    manulvat DOUBLE PRECISION,  -- Manually entered VAT
    dscamt_type NUMERIC(1,0),   -- Discount amount type
    hlldscnt DOUBLE PRECISION,  -- Halala (fractional) discount adjustment
    PriceIncludeVat BOOLEAN,    -- Flag indicating if price includes VAT
    vat_percent NUMERIC(5,2),   -- VAT percentage applied
    fqtyval DOUBLE PRECISION,   -- Foreign quantity value
    fc_whrate DOUBLE PRECISION, -- Foreign currency warehouse specific rate
    is_numerator BOOLEAN,       -- Currency conversion methodology flag
    datetime_stamp TIMESTAMP    -- Record creation timestamp
);

-- Table: pudtl
-- Description: Purchasing Details for line items on POs and Supplier Invoices.
CREATE TABLE bronze.pudtl (
    slcenter VARCHAR(2),        -- Sales/Purchasing center code
    company VARCHAR(2),         -- Company identifier code
    invtype VARCHAR(2),         -- Document type (matches header)
    ref NUMERIC(6,0),           -- Document reference number (matches header)
    invdate VARCHAR(8),         -- Document date
    itemno VARCHAR(16),         -- Item/Product number
    unicode VARCHAR(6),         -- Unit of measure code
    qty DOUBLE PRECISION,       -- Quantity ordered/received
    fqty NUMERIC(10,3),         -- Foreign/Secondary quantity
    price DOUBLE PRECISION,     -- Unit price
    discpc NUMERIC(5,2),        -- Discount percentage
    cost NUMERIC(11,2),         -- Unit cost
    ds_acfm NUMERIC(1,0),       -- Discount confirmation flag
    sl_acfm NUMERIC(1,0),       -- Sales confirmation flag
    gclass VARCHAR(12),         -- Item classification group
    custno VARCHAR(6),          -- Supplier code
    fcy VARCHAR(3),             -- Foreign currency code
    barcode VARCHAR(20),        -- Item barcode
    imfcval DOUBLE PRECISION,   -- Import foreign currency value
    pack VARCHAR(1),            -- Packaging type
    pkqty NUMERIC(8,3),         -- Packaging quantity
    expdate VARCHAR(8),         -- Expiration date of the batch (YYYYMMDD)
    binno VARCHAR(6),           -- Warehouse bin number
    shdqty NUMERIC(9,3),        -- Shadow standard quantity
    shdpk NUMERIC(8,3),         -- Shadow pack quantity
    shadd VARCHAR(1),           -- Shadow addition flag
    frtqty NUMERIC(9,3),        -- Freight quantity
    cmbkey VARCHAR(24),         -- Combined key for item/unit
    folio NUMERIC(7,0),         -- Folio reference
    rplct_post BOOLEAN,         -- Replicated posting flag
    whno VARCHAR(2),            -- Target warehouse number
    splyinv VARCHAR(20),        -- Original supplier invoice number
    edm_value NUMERIC(10,3),    -- Electronic Document Management value
    garntee_amt DOUBLE PRECISION, -- Guarantee/Warranty amount
    Taxtype VARCHAR(1)          -- Tax type applied to the line
);

-- ============================================================================
-- 3. Sales Configuration & POS Locations
-- ============================================================================

-- Table: salecntr
-- Description: Sales Centers / Point of Sale Configuration and Integrations.
CREATE TABLE bronze.salecntr (
    dp_name VARCHAR(30),        -- Sales Center Name
    dp_brno VARCHAR(2),         -- Branch Number
    dp_dept VARCHAR(2),         -- Department Code
    dp_cashser VARCHAR(19),     -- GL Link: Cash drawer
    dp_cslser VARCHAR(19),      -- GL Link: Cash sales
    dp_oslser VARCHAR(19),      -- GL Link: Credit sales
    dp_rcslser VARCHAR(19),     -- GL Link: Return cash sales
    dp_roslser VARCHAR(19),     -- GL Link: Return credit sales
    dp_custser VARCHAR(19),     -- GL Link: Customs
    dp_expser VARCHAR(19),      -- GL Link: Expenses
    dp_okdiff BOOLEAN,          -- Allow pricing differences flag
    dp_diffser VARCHAR(19),     -- GL Link: Differences
    dp_mainwh VARCHAR(2),       -- Default main warehouse for sales
    dp_rtrnwh VARCHAR(2),       -- Default return warehouse
    lastupdt VARCHAR(10),       -- Last update date
    dp_comp VARCHAR(2),         -- Company identifier code
    dp_fccrdt BOOLEAN,          -- Foreign currency credit allowed flag
    nochg_print BOOLEAN,        -- No change print flag
    modified BOOLEAN,           -- Record modified flag
    srcst VARCHAR(19),          -- GL Link: Cost of Goods Sold
    cstcode VARCHAR(4),         -- Cost center code
    dp_crdcardac VARCHAR(19),   -- GL Link: Credit Card clearing account
    dp_rplsac VARCHAR(19),      -- GL Link: Replacements account
    dp_cardcomm VARCHAR(19),    -- GL Link: Card commissions expense
    dp_lname VARCHAR(30),       -- Alternative language center name
    slwhsrc NUMERIC(1,0),       -- Sales warehouse source configuration
    prpaidcrdac VARCHAR(19),    -- GL Link: Prepaid credit account
    FRC_CRSL_FC BOOLEAN,        -- Force Credit Sales to Foreign Currency flag
    inv_form_no NUMERIC(2,0),   -- Printed invoice layout/form ID
    sc_code VARCHAR(6),         -- Section/Center linkage code
    sanedcrd_act VARCHAR(19),   -- GL Link: Saned/Local credit network account
    no_of_invCopies NUMERIC(1,0), -- Default number of invoice copies to print
    vat_rcvd_act VARCHAR(19),   -- GL Link: VAT Received account
    custody_ac VARCHAR(19),     -- GL Link: Cash custody/petty cash
    stcpay_act VARCHAR(19),     -- GL Link: STCPay (E-Wallet) account
    suspended BOOLEAN,          -- Suspended center flag
    qitaf_act VARCHAR(19),      -- GL Link: Qitaf (Loyalty Points) account
    slscmnact VARCHAR(19),      -- GL Link: Salesman commissions account
    webcmnact VARCHAR(19),      -- GL Link: Web sales commission account
    tprtexpact VARCHAR(19),     -- GL Link: Transport expense account
    -- Localization and e-Invoicing mapping fields (e.g., for ZATCA/Manafith)
    bldg_no VARCHAR(50),        -- Building Number
    bldg_no_l VARCHAR(50),      -- Building Number (Alt Language)
    street_name VARCHAR(50),    -- Street Name
    street_name_l VARCHAR(50),  -- Street Name (Alt Language)
    area_name VARCHAR(50),      -- Area/Neighborhood Name
    area_name_l VARCHAR(50),    -- Area/Neighborhood Name (Alt Language)
    extra_address_no VARCHAR(50), -- Additional Address Info
    extra_address_no_l VARCHAR(50), -- Additional Address Info (Alt Language)
    district VARCHAR(50),       -- District Name
    district_l VARCHAR(50),     -- District Name (Alt Language)
    city_text VARCHAR(50),      -- City Name
    city_text_l VARCHAR(50),    -- City Name (Alt Language)
    postal_code VARCHAR(20),    -- Postal Code
    street_name2 VARCHAR(50),   -- Secondary Street Name
    street_name2_l VARCHAR(50), -- Secondary Street Name (Alt Language)
    Group_VAT_ID VARCHAR(30),   -- Tax Group VAT ID
    Other_id_SchemeID VARCHAR(20), -- Alternative Business ID Scheme (e.g., CR, MOMRA)
    country_code INTEGER,       -- ISO Country Code
    Other_Scheme_Type VARCHAR(10), -- Scheme Type categorization
    manafith_api VARCHAR(100)   -- Integration endpoint URL for Manafith/Customs API
);

-- ============================================================================
-- 4. Sales Transactions (Invoices & Quotes)
-- ============================================================================

-- Table: sales_hd
-- Description: Sales Header for outgoing customer invoices.
CREATE TABLE bronze.sales_hd (
    slcenter VARCHAR(2),        -- Sales center identifier
    branch VARCHAR(2),          -- Branch identifier
    company VARCHAR(2),         -- Company identifier
    invtype VARCHAR(2),         -- Invoice type (e.g., Cash, Credit, POS)
    ref NUMERIC(6,0),           -- Invoice reference number
    invdate VARCHAR(8),         -- Invoice date (YYYYMMDD)
    custno VARCHAR(6),          -- Customer number
    custnm VARCHAR(50),         -- Customer name
    glser VARCHAR(19),          -- General Ledger serial link
    dsctype VARCHAR(1),         -- Discount type indicator
    pstmode NUMERIC(1,0),       -- Posting mode
    fcy VARCHAR(3),             -- Foreign currency code
    fcyrate DOUBLE PRECISION,   -- Exchange rate at transaction time
    duedate VARCHAR(8),         -- Payment due date
    invttl DOUBLE PRECISION,    -- Total invoice amount
    invcst DOUBLE PRECISION,    -- Total invoice cost (COGS)
    invdspc DOUBLE PRECISION,   -- Overall discount percentage
    invdsvl DOUBLE PRECISION,   -- Overall discount value
    valafds DOUBLE PRECISION,   -- Total value after discounts
    invpaid DOUBLE PRECISION,   -- Amount paid by customer
    caser VARCHAR(19),          -- GL Cash serial
    entries NUMERIC(6,0),       -- Number of line items
    released BOOLEAN,           -- Document released flag
    posted BOOLEAN,             -- Document posted to GL flag
    fixrate DOUBLE PRECISION,   -- Fixed exchange rate applied
    extamt DOUBLE PRECISION,    -- Extra amount/fees
    extser VARCHAR(19),         -- GL serial for extra fees
    pricetp VARCHAR(1),         -- Price type tier used
    ischeque BOOLEAN,           -- Paid by cheque flag
    chkno VARCHAR(8),           -- Cheque number
    chkdate VARCHAR(8),         -- Cheque date
    lastupdt VARCHAR(8),        -- Last update date
    jvgenrt BOOLEAN,            -- Journal Voucher generated flag
    cccommsn DOUBLE PRECISION,  -- Credit card commission expense
    belowbal BOOLEAN,           -- Below balance sale flag
    fcy2 VARCHAR(3),            -- Secondary foreign currency
    ccpayment DOUBLE PRECISION, -- Amount paid via credit card
    rplsamt DOUBLE PRECISION,   -- Replacement amount
    pdother BOOLEAN,            -- Paid by other means flag
    slcode VARCHAR(2),          -- Salesman code
    prpaidamt DOUBLE PRECISION, -- Prepaid amount utilized
    instldays NUMERIC(2,0),     -- Installment days
    instflag BOOLEAN,           -- Installment plan flag
    slcmnd BOOLEAN,             -- Sales command flag
    inv_printed NUMERIC(2,0),   -- Print counter for the invoice
    bendit BOOLEAN,             -- Backend edit flag
    modified BOOLEAN,           -- Record modified flag
    rqstorder NUMERIC(6,0),     -- Associated request order number
    rqststld BOOLEAN,           -- Request order settled flag
    carrier VARCHAR(3),         -- Shipping carrier code
    rcvdtrn BOOLEAN,            -- Received transaction flag
    usrid VARCHAR(10),          -- System user ID
    address VARCHAR(50),        -- Shipping address
    suspend BOOLEAN,            -- Suspended invoice flag
    rtnref NUMERIC(6,0),        -- Original reference if this is a return
    ispurchase BOOLEAN,         -- Linked to purchase flag
    stkjvno NUMERIC(6,0),       -- Stock Journal Voucher link
    posinv NUMERIC(1,0),        -- POS invoice indicator
    sanedcrd_amt NUMERIC(12,2), -- Amount paid via Saned network
    remarks VARCHAR(1),         -- Short remarks flag
    remarks2 VARCHAR(80),       -- Detailed remarks text
    invlocked BOOLEAN,          -- Invoice locked flag
    rtncash_dfrpl NUMERIC(12,2),-- Return cash difference replacement
    vat_amt_rcvd DOUBLE PRECISION, -- VAT amount collected
    taxfree_sales DOUBLE PRECISION, -- Total tax-free sales value
    clnt_taxcode VARCHAR(20),   -- Client Tax/VAT ID
    clnt_kind VARCHAR(1),       -- Client kind categorization
    hlldscnt DOUBLE PRECISION,  -- Fractional (Halala) rounding discount
    sysno NUMERIC(2,0),         -- System instance number
    No_round_nm BOOLEAN,        -- No rounding flag
    PriceVatType NUMERIC(1,0),  -- Price VAT computation type
    smssent BOOLEAN,            -- SMS notification sent flag
    stcpay_amt DOUBLE PRECISION,-- Amount paid via STCPay E-Wallet
    fc2lcamt DOUBLE PRECISION,  -- Secondary FCY to Local amount
    qitaf_amt DOUBLE PRECISION, -- Amount paid via Qitaf points
    whlslinv BOOLEAN,           -- Wholesale invoice flag
    vat_percent NUMERIC(5,2),   -- VAT percentage applied
    fsh_printed NUMERIC(2,0),   -- Fiscal receipt print count
    fqtyval DOUBLE PRECISION,   -- Foreign quantity value
    fc_whrate DOUBLE PRECISION, -- Foreign currency warehouse rate
    is_numerator BOOLEAN,       -- Exchange rate numerator logic flag
    datetime_stamp TIMESTAMP,   -- Invoice creation timestamp
    Fusrprintinv VARCHAR(10),   -- User ID who printed the invoice
    almnm_contract_section NUMERIC(1,0), -- Contract section indicator
    mobileNo VARCHAR(20),       -- Customer mobile number
    client_name VARCHAR(60),    -- Overridden client name (for walk-ins)
    installment_amt DOUBLE PRECISION, -- Installment amount
    zatca_rounding BOOLEAN,     -- Saudi ZATCA e-invoicing rounding logic flag
    tac_fees_percent NUMERIC(6,2), -- Technical/Admin fee percentage
    tac_fees_amount DOUBLE PRECISION, -- Technical/Admin fee amount
    tac_fees_account VARCHAR(19), -- GL Account for Technical/Admin fees
    discountedBill BOOLEAN,     -- Flag indicating if the bill was discounted
    PriceTACfeesType NUMERIC(1,0) -- Logic flag for TAC fees computation
);

-- Table: sales_dt
-- Description: Sales Details representing line items on customer invoices.
CREATE TABLE bronze.sales_dt (
    slcenter VARCHAR(2),        -- Sales center identifier
    company VARCHAR(2),         -- Company identifier
    invtype VARCHAR(2),         -- Invoice type (matches header)
    ref NUMERIC(6,0),           -- Invoice reference number (matches header)
    invdate VARCHAR(8),         -- Invoice date
    itemno VARCHAR(16),         -- Item/Product number
    unicode VARCHAR(6),         -- Unit of measure code
    qty DOUBLE PRECISION,       -- Quantity sold
    fqty NUMERIC(11,3),         -- Foreign/Secondary quantity sold
    price DOUBLE PRECISION,     -- Unit selling price
    discpc DOUBLE PRECISION,    -- Discount percentage
    cost DOUBLE PRECISION,      -- Unit cost (COGS)
    ds_acfm NUMERIC(1,0),       -- Discount confirmation flag
    sl_acfm NUMERIC(1,0),       -- Sales confirmation flag
    gclass VARCHAR(12),         -- Item classification group
    custno VARCHAR(6),          -- Customer number
    fcy VARCHAR(3),             -- Foreign currency code
    barcode VARCHAR(20),        -- Item barcode scanned
    imfcval DOUBLE PRECISION,   -- Import foreign currency value
    pack VARCHAR(1),            -- Packaging type
    pkqty NUMERIC(8,3),         -- Packaging quantity
    shadd VARCHAR(1),           -- Shadow addition flag
    shdpk NUMERIC(8,3),         -- Shadow pack quantity
    shdqty NUMERIC(11,3),       -- Shadow standard quantity
    frtqty NUMERIC(9,3),        -- Freight quantity
    rtnqty DOUBLE PRECISION,    -- Returned quantity
    whno VARCHAR(2),            -- Dispatch warehouse number
    cmbkey VARCHAR(24),         -- Combined key for item/unit
    folio NUMERIC(7,0),         -- Folio reference
    rplct_post BOOLEAN,         -- Replicated posting flag
    sold_item_status NUMERIC(1,0), -- Delivery/Fulfilment status of item
    Taxtype VARCHAR(1),         -- Tax type applied to line
    ps_item_vat DOUBLE PRECISION, -- POS specific item VAT
    dsc_amt DOUBLE PRECISION,   -- Discount amount value
    expdate VARCHAR(8),         -- Batch expiration date (YYYYMMDD)
    item_price_net DOUBLE PRECISION, -- Net item price after discounts
    invdscamt DOUBLE PRECISION, -- Apportioned invoice level discount
    item_vat NUMERIC(12,3)      -- Calculated VAT for this specific line item
);

-- Table: sales_qh
-- Description: Sales Quotation Header for customer estimates.
CREATE TABLE bronze.sales_qh (
    slcenter VARCHAR(2),        -- Sales center identifier
    branch VARCHAR(2),          -- Branch identifier
    invtype VARCHAR(2),         -- Quote/Document type
    company VARCHAR(2),         -- Company identifier
    ref NUMERIC(6,0),           -- Quotation reference number
    invdate VARCHAR(8),         -- Quotation date (YYYYMMDD)
    custno VARCHAR(6),          -- Customer number
    custnm VARCHAR(50),         -- Customer name
    glser VARCHAR(19),          -- General Ledger serial link (if committed)
    dsctype VARCHAR(1),         -- Discount type indicator
    pstmode NUMERIC(1,0),       -- Posting mode
    fcy VARCHAR(3),             -- Foreign currency code
    fcyrate DOUBLE PRECISION,   -- Exchange rate at quote time
    duedate VARCHAR(8),         -- Quote validity / due date
    invttl DOUBLE PRECISION,    -- Total quotation amount
    invcst DOUBLE PRECISION,    -- Estimated cost (COGS)
    invdspc DOUBLE PRECISION,   -- Overall discount percentage
    invdsvl DOUBLE PRECISION,   -- Overall discount value
    valafds DOUBLE PRECISION,   -- Total value after discounts
    invpaid NUMERIC(14,2),      -- Advance amount paid (if any)
    caser VARCHAR(19),          -- GL Cash serial
    entries NUMERIC(5,0),       -- Number of line items
    released BOOLEAN,           -- Document released flag
    posted BOOLEAN,             -- Document posted flag (converted to order)
    fixrate NUMERIC(7,2),       -- Fixed exchange rate applied
    extamt DOUBLE PRECISION,    -- Extra amount/fees
    extser VARCHAR(19),         -- GL serial for extra fees
    pricetp VARCHAR(1),         -- Price type tier used
    ischeque BOOLEAN,           -- Expected payment by cheque flag
    chkno VARCHAR(8),           -- Cheque number
    chkdate VARCHAR(8),         -- Cheque date
    lastupdt VARCHAR(8),        -- Last update date
    jvgenrt BOOLEAN,            -- Journal Voucher generated flag
    imfcval NUMERIC(14,5),      -- Import foreign currency value
    slcode VARCHAR(2),          -- Salesman code
    modified BOOLEAN,           -- Record modified flag
    rcvdtrn BOOLEAN,            -- Received transaction flag
    remarks VARCHAR(65),        -- Short remarks text
    remarks2 VARCHAR(65),       -- Detailed remarks text
    usrid VARCHAR(10),          -- System user ID
    vat_amt_rcvd DOUBLE PRECISION, -- Estimated VAT amount
    taxfree_sales DOUBLE PRECISION, -- Estimated tax-free sales value
    clnt_taxcode VARCHAR(20),   -- Client Tax/VAT ID
    clnt_kind VARCHAR(1),       -- Client kind categorization
    qhtype VARCHAR(1),          -- Quotation specific type
    qhstatus VARCHAR(1),        -- Quotation status (e.g., Pending, Won, Lost)
    newcstmrname VARCHAR(50),   -- Walk-in prospect name
    newcstmrcntct VARCHAR(50),  -- Walk-in prospect contact info
    cstmrmobile VARCHAR(50),    -- Walk-in prospect mobile
    fc_whrate DOUBLE PRECISION, -- Foreign currency warehouse rate
    is_numerator BOOLEAN        -- Exchange rate numerator logic flag
);

-- Table: sales_qd
-- Description: Sales Quotation Details for line items on customer estimates.
CREATE TABLE bronze.sales_qd (
    slcenter VARCHAR(2),        -- Sales center identifier
    invtype VARCHAR(2),         -- Quote type (matches header)
    company VARCHAR(2),         -- Company identifier
    ref NUMERIC(6,0),           -- Quotation reference number (matches header)
    invdate VARCHAR(8),         -- Quotation date
    itemno VARCHAR(16),         -- Item/Product number
    unicode VARCHAR(6),         -- Unit of measure code
    itemdesc VARCHAR(30),       -- Overridden item description (if customized for quote)
    qty DOUBLE PRECISION,       -- Quantity quoted
    fqty NUMERIC(10,3),         -- Foreign/Secondary quantity quoted
    price DOUBLE PRECISION,     -- Unit selling price
    discpc NUMERIC(6,2),        -- Discount percentage
    cost DOUBLE PRECISION,      -- Estimated unit cost
    ds_acfm NUMERIC(1,0),       -- Discount confirmation flag
    sl_acfm NUMERIC(1,0),       -- Sales confirmation flag
    gclass VARCHAR(8),          -- Item classification group
    custno VARCHAR(6),          -- Customer number
    fcy VARCHAR(3),             -- Foreign currency code
    barcode VARCHAR(20),        -- Item barcode
    imfcval DOUBLE PRECISION,   -- Import foreign currency value
    pack VARCHAR(1),            -- Packaging type
    pkqty NUMERIC(9,3),         -- Packaging quantity
    shadd VARCHAR(1),           -- Shadow addition flag
    shdpk NUMERIC(9,3),         -- Shadow pack quantity
    shdqty NUMERIC(14,3),       -- Shadow standard quantity
    frtqty NUMERIC(12,3),       -- Freight quantity
    cmbkey VARCHAR(24),         -- Combined key for item/unit
    folio NUMERIC(4,0)          -- Folio reference
);


-- ============================================================================
-- PostgreSQL Schema Definitions: Bronze Layer (Batch 4)
-- Description: Inventory Master Data, Stock Transactions, Costing, and 
--              Sales Invoice Expenses.
-- ============================================================================

-- Safely drop existing tables before creation to ensure a clean deployment
DROP TABLE IF EXISTS bronze.slinvexp;
DROP TABLE IF EXISTS bronze.starea;
DROP TABLE IF EXISTS bronze.stbins;
DROP TABLE IF EXISTS bronze.stbranch;
DROP TABLE IF EXISTS bronze.stclass;
DROP TABLE IF EXISTS bronze.stcosttype;
DROP TABLE IF EXISTS bronze.stcrtpuinv;
DROP TABLE IF EXISTS bronze.stdtl;
DROP TABLE IF EXISTS bronze.stfcyprice;
DROP TABLE IF EXISTS bronze.sthdr;
DROP TABLE IF EXISTS bronze.stitemrp;

-- ============================================================================
-- 1. Extended Sales Transactions
-- ============================================================================

-- Table: slinvexp
-- Description: Sales Invoice Expenses tracking freight, broker commissions, and driver costs.
CREATE TABLE bronze.slinvexp (
    company VARCHAR(2),         -- Company identifier code
    invtype VARCHAR(2),         -- Invoice document type
    ref NUMERIC(6,0),           -- Associated invoice reference number
    fcy VARCHAR(3),             -- Foreign currency code
    transportOnUs BOOLEAN,      -- Flag indicating if the company covers transport costs
    transportamt DOUBLE PRECISION, -- Total transport amount
    transport_vat DOUBLE PRECISION, -- VAT calculated on transport
    slsmanprcnt NUMERIC(5,3),   -- Salesman commission percentage for this sale
    slsmanamt DOUBLE PRECISION, -- Salesman commission amount
    broker_code INTEGER,        -- Associated third-party broker ID
    broker_amt NUMERIC(10,3),   -- Brokerage base amount
    broker_prcnt NUMERIC(5,3),  -- Broker commission percentage
    broker_vat_amt DOUBLE PRECISION, -- VAT applied to broker commission
    broker_taxable BOOLEAN,     -- Flag indicating if broker commission is taxable
    broker_ttlcmsn DOUBLE PRECISION, -- Broker total commission including tax
    broker_cmnamt DOUBLE PRECISION, -- Broker net commission amount
    trans_code VARCHAR(3),      -- Transporter/Shipping company code
    trans_cost_per_pack DOUBLE PRECISION, -- Freight cost calculated per package
    driver_expnseamt DOUBLE PRECISION, -- Expenses allocated directly to the driver
    trans_expnse DOUBLE PRECISION, -- Overall transportation expense
    driver_no INTEGER,          -- Internal driver ID
    is_vat BOOLEAN,             -- General VAT flag for the expense line
    pricewithtransport BOOLEAN  -- Flag indicating if transport is rolled into item price
);

-- ============================================================================
-- 2. Inventory Infrastructure & Classifications
-- ============================================================================

-- Table: starea
-- Description: Stock geographic and operational areas dictionary.
CREATE TABLE bronze.starea (
    name VARCHAR(20),           -- Area name
    cmbkey VARCHAR(6),          -- Combined identifier key
    govrn VARCHAR(2),           -- Governorate code
    city VARCHAR(2),            -- City code
    region VARCHAR(2),          -- Region code
    modified BOOLEAN,           -- Record modified flag
    lname VARCHAR(20),          -- Alternative language area name
    lastupdt VARCHAR(8),        -- Last update date (YYYYMMDD)
    pkey INTEGER,               -- Parent hierarchy key
    chkey INTEGER               -- Child hierarchy key
);

-- Table: stbranch
-- Description: Comprehensive branch definitions, including GL hooks, pricing tiers, and tax IDs.
CREATE TABLE bronze.stbranch (
    name VARCHAR(40),           -- Branch name
    brnno VARCHAR(2),           -- Branch number
    govrn VARCHAR(2),           -- Associated governorate
    city VARCHAR(2),            -- Associated city
    area VARCHAR(2),            -- Associated area
    cmbkey VARCHAR(6),          -- Combined identifier key
    company VARCHAR(2),         -- Company identifier code
    cashser VARCHAR(19),        -- General Ledger serial link for cash
    modified BOOLEAN,           -- Record modified flag
    bcserial NUMERIC(13,0),     -- Current barcode generation serial counter
    -- Automated Journal Voucher (JV) hooks mapping branch events to GL accounts
    jv_01 NUMERIC(6,0), jv_02 NUMERIC(6,0), jv_03 NUMERIC(6,0), jv_04 NUMERIC(6,0), 
    jv_05 NUMERIC(6,0), jv_06 NUMERIC(6,0), jv_07 NUMERIC(6,0), jv_08 NUMERIC(6,0), 
    jv_09 NUMERIC(6,0), jv_10 NUMERIC(6,0), jv_11 NUMERIC(6,0), jv_12 NUMERIC(6,0), 
    jv_13 NUMERIC(6,0), jv_14 NUMERIC(6,0), jv_16 NUMERIC(6,0), jv_17 NUMERIC(6,0), 
    jv_18 NUMERIC(6,0), jv_19 NUMERIC(6,0), jv_20 NUMERIC(6,0), jv_21 NUMERIC(6,0), 
    jv_22 NUMERIC(6,0), jv_23 NUMERIC(6,0), jv_24 NUMERIC(6,0), jv_26 NUMERIC(6,0), 
    jv_27 NUMERIC(6,0), jv_28 NUMERIC(6,0), jv_30 NUMERIC(6,0), jv_31 NUMERIC(6,0), 
    jv_32 NUMERIC(6,0), jv_33 NUMERIC(6,0), jv_34 NUMERIC(8,0), Jv_37 INTEGER, 
    jv_45 NUMERIC(10,0), jv_46 NUMERIC(6,0), jv_51 INTEGER, jv_55 NUMERIC(10,0), 
    jv_56 NUMERIC(6,0), jv_60 INTEGER, jv_61 INTEGER, 
    calgl NUMERIC(2,0),         -- Calculator link: General Ledger
    calar NUMERIC(2,0),         -- Calculator link: Accounts Receivable
    calap NUMERIC(2,0),         -- Calculator link: Accounts Payable
    calst NUMERIC(2,0),         -- Calculator link: Stock
    srdiff VARCHAR(19),         -- GL serial link for stock differences
    lname VARCHAR(30),          -- Alternative language branch name
    lastupdt VARCHAR(8),        -- Last update date
    stkxtoser VARCHAR(19),      -- GL serial link: Stock Transfer To
    stkxfmser VARCHAR(19),      -- GL serial link: Stock Transfer From
    baddress VARCHAR(60),       -- Branch address
    lbaddress VARCHAR(10),      -- Alternative language address fragment
    phone VARCHAR(40),          -- Branch phone number
    fax VARCHAR(20),            -- Branch fax number
    dscalwser VARCHAR(19),      -- GL serial link: Discount Allowed
    dscernser VARCHAR(19),      -- GL serial link: Discount Earned
    jv_101 INTEGER,             -- Specific JV hook
    manualser BOOLEAN,          -- Manual serial numbering flag
    smsdispname VARCHAR(11),    -- SMS Display Sender Name (11 chars max)
    smsuser INTEGER,            -- SMS gateway user ID
    smsfooter VARCHAR(40),      -- SMS standard footer text
    rebate_act VARCHAR(19),     -- GL account for rebates
    -- Complex volume pricing tiers for retail, dozen, and carton sizes
    fm_price1 NUMERIC(6,0), to_price1 NUMERIC(6,0), doz_price1 NUMERIC(6,0), ctn_price1 NUMERIC(6,0), 
    fm_price2 NUMERIC(6,0), to_price2 NUMERIC(6,0), doz_price2 NUMERIC(6,0), ctn_price2 NUMERIC(6,0), 
    fm_price3 NUMERIC(6,0), to_price3 NUMERIC(6,0), doz_price3 NUMERIC(6,0), ctn_price3 NUMERIC(6,0), 
    pricetp VARCHAR(1),         -- Base price type configuration
    rebate_loss VARCHAR(19),    -- GL account for rebate losses
    sysno NUMERIC(2,0),         -- System deployment instance number
    No_round_nm BOOLEAN,        -- Numeric rounding disable flag
    PriceVatType NUMERIC(1,0),  -- Price VAT computation logic type
    mkt_frc_rounding BOOLEAN,   -- Market force rounding applied flag
    is_dsc_amt BOOLEAN,         -- Flag indicating discount by fixed amount vs percentage
    auto_dsc_hll BOOLEAN,       -- Automatic halala (fractional currency) discount
    max_dsc_hll NUMERIC(3,2),   -- Maximum allowable fractional discount
    pos_type INTEGER,           -- Point of Sale system type identifier
    sc_lvlno INTEGER,           -- Sales center hierarchy level
    vat_paid_act VARCHAR(19),   -- GL Account for VAT Paid
    -- Extended JV mapping hooks
    jv_105 INTEGER, jv_106 INTEGER, jv_107 INTEGER, jv_108 INTEGER, jv_109 INTEGER, 
    jv_110 INTEGER, jv_205 INTEGER, jv_209 INTEGER, jv_210 INTEGER, jv_211 INTEGER, 
    jv_212 INTEGER, jv_213 INTEGER, jv_214 INTEGER, jv_215 INTEGER, jv_216 INTEGER, 
    jv_301 INTEGER, jv_501 INTEGER, jv_502 INTEGER, 
    -- Official E-Invoicing (ZATCA/Manafith) localization fields
    bldg_no VARCHAR(50), bldg_no_l VARCHAR(50), 
    street_name VARCHAR(50), street_name_l VARCHAR(50), 
    area_name VARCHAR(50), area_name_l VARCHAR(50), 
    extra_address_no VARCHAR(50), extra_address_no_l VARCHAR(50), 
    district VARCHAR(50), district_l VARCHAR(50), 
    city_text VARCHAR(50), city_text_l VARCHAR(50), 
    postal_code VARCHAR(20), 
    Street_Name2 VARCHAR(50), Street_Name2_l VARCHAR(50), 
    Group_VAT_ID VARCHAR(30), Other_id_SchemeID VARCHAR(20), 
    country_code INTEGER, Other_Scheme_Type VARCHAR(10), 
    crdt_limit DOUBLE PRECISION, -- Branch global credit limit
    vat_rcvd_act VARCHAR(19),   -- GL Account for VAT Received
    remote_br_sqlserver VARCHAR(40), -- Connection string/IP for distributed branch DBs
    rvnuact VARCHAR(19)         -- GL Account for branch revenue
);

-- Table: stbins
-- Description: Granular physical storage mapping (Warehouse Bins) and batch levels.
CREATE TABLE bronze.stbins (
    branch VARCHAR(2),          -- Branch identifier
    itemno VARCHAR(16),         -- Item/Product number
    unicode VARCHAR(6),         -- Unit of measure code
    whno VARCHAR(2),            -- Warehouse number
    binno VARCHAR(6),           -- Specific Bin/Shelf location code
    qty DOUBLE PRECISION,       -- Current physical quantity in bin
    rsvqty DOUBLE PRECISION,    -- Reserved/Allocated quantity in bin
    openbal DOUBLE PRECISION,   -- Opening balance quantity
    lcost DOUBLE PRECISION,     -- Current local cost per unit
    fcost DOUBLE PRECISION,     -- Current foreign cost per unit
    openlcost DOUBLE PRECISION, -- Opening local cost per unit
    openfcost DOUBLE PRECISION, -- Opening foreign cost per unit
    expdate VARCHAR(8)          -- Expiry date of the stock batch currently in bin
);

-- Table: stclass
-- Description: Inventory grouping and hierarchy mapping.
CREATE TABLE bronze.stclass (
    name VARCHAR(30),           -- Classification name
    cmbkey VARCHAR(12),         -- Combined classification key
    mgroup VARCHAR(2),          -- Main group ID
    sgroup VARCHAR(2),          -- Sub-group 1 ID
    category VARCHAR(2),        -- Category ID
    -- GL Serials mapped to specific transaction types within this classification
    sercsh VARCHAR(19),         -- GL serial: Cash Sales
    sercrd VARCHAR(19),         -- GL serial: Credit Sales
    serrch VARCHAR(19),         -- GL serial: Return Cash
    serrcr VARCHAR(19),         -- GL serial: Return Credit
    serdsc VARCHAR(19),         -- GL serial: Discounts
    serpcsh VARCHAR(19),        -- GL serial: Purchase Cash
    serpcrd VARCHAR(19),        -- GL serial: Purchase Credit
    serprch VARCHAR(19),        -- GL serial: Purchase Return Cash
    serprcr VARCHAR(19),        -- GL serial: Purchase Return Credit
    serpdsc VARCHAR(19),        -- GL serial: Purchase Discount
    sgroup3 VARCHAR(3),         -- Sub-group 3 ID
    sgroup4 VARCHAR(3),         -- Sub-group 4 ID
    modified BOOLEAN,           -- Record modified flag
    pkey INTEGER,               -- Parent hierarchy key
    chkey INTEGER,              -- Child hierarchy key
    lname VARCHAR(20),          -- Alternative language classification name
    lastupdt VARCHAR(8),        -- Last update date
    max_sl_limit NUMERIC(12,3)  -- Maximum allowed sales limit for items in this class
);

-- ============================================================================
-- 3. Inventory Transactions & Adjustments
-- ============================================================================

-- Table: sthdr
-- Description: Stock Transactions Header (e.g., Internal Transfers, Adjustments, Assemblies).
CREATE TABLE bronze.sthdr (
    branch VARCHAR(2),          -- Originating branch
    trtype VARCHAR(2),          -- Transaction type (e.g., TR=Transfer, AD=Adjustment)
    ref NUMERIC(6,0),           -- Document reference number
    trdate VARCHAR(8),          -- Transaction date (YYYYMMDD)
    text VARCHAR(70),           -- Transaction description/narration
    amnttl DOUBLE PRECISION,    -- Total value amount
    costttl DOUBLE PRECISION,   -- Total cost value
    sysdate VARCHAR(8),         -- System creation date
    src VARCHAR(2),             -- Source module generating the transaction
    released BOOLEAN,           -- Document released flag
    posted BOOLEAN,             -- Document posted to GL/Stock ledger
    fcy VARCHAR(3),             -- Currency code
    fcyrate DOUBLE PRECISION,   -- Exchange rate applied
    whno VARCHAR(2),            -- Source warehouse
    entries NUMERIC(6,0),       -- Number of detailed line items
    lastupdt VARCHAR(8),        -- Last update date
    towhno VARCHAR(2),          -- Target/Destination warehouse
    modified BOOLEAN,           -- Record modified flag
    rcvdtrn BOOLEAN,            -- Received transaction flag
    custno VARCHAR(19),         -- Customer/Entity reference (if applicable)
    usrid VARCHAR(10),          -- User ID
    brsupp VARCHAR(19),         -- Branch supplier link
    tobrno VARCHAR(2),          -- Target/Destination branch
    brxref NUMERIC(6,0),        -- Branch cross-reference ID
    glref NUMERIC(6,0),         -- Corresponding General Ledger reference ID
    isbrtrx BOOLEAN,            -- Flag indicating inter-branch transaction
    asmtype NUMERIC(1,0),       -- Assembly/Manufacturing type flag
    repost BOOLEAN,             -- Repost required flag
    items_rcvd BOOLEAN,         -- Goods receipt confirmation flag
    trx_printed NUMERIC(2,0),   -- Print counter
    fc_whrate DOUBLE PRECISION, -- Foreign currency warehouse-specific rate
    is_numerator BOOLEAN,       -- Currency conversion numerator logic flag
    pricetp VARCHAR(1)          -- Price tier applied
);

-- Table: stdtl
-- Description: Stock Transactions Details (Line items for transfers, adjustments, etc.).
CREATE TABLE bronze.stdtl (
    itemno VARCHAR(16),         -- Item/Product number
    unicode VARCHAR(6),         -- Unit of measure code
    branch VARCHAR(2),          -- Associated branch
    trtype VARCHAR(2),          -- Transaction type (matches header)
    qty DOUBLE PRECISION,       -- Quantity moved/adjusted
    fqty NUMERIC(11,3),         -- Foreign/Secondary quantity
    whno VARCHAR(2),            -- Source warehouse
    binno VARCHAR(6),           -- Source bin location
    lcost DOUBLE PRECISION,     -- Unit cost in local currency
    trdate VARCHAR(8),          -- Transaction date
    ref NUMERIC(6,0),           -- Document reference number (matches header)
    sysdate VARCHAR(8),         -- System entry date
    src VARCHAR(2),             -- Source module
    lprice DOUBLE PRECISION,    -- Value/Price in local currency
    fcost DOUBLE PRECISION,     -- Unit cost in foreign currency
    fprice DOUBLE PRECISION,    -- Value/Price in foreign currency
    expdate VARCHAR(8),         -- Batch expiry date (YYYYMMDD)
    towhno VARCHAR(2),          -- Target/Destination warehouse
    tobinno VARCHAR(6),         -- Target/Destination bin location
    barcode VARCHAR(20),        -- Item barcode
    cmbkey VARCHAR(24),         -- Combined key for item/unit
    discpc NUMERIC(6,2),        -- Discount percentage (if applicable)
    pack VARCHAR(1),            -- Packaging type
    shdpk NUMERIC(8,3),         -- Shadow pack quantity
    shdqty DOUBLE PRECISION,    -- Shadow standard quantity
    folio NUMERIC(7,0),         -- Folio reference
    rplct_post BOOLEAN,         -- Replicated posting flag
    fcost_fcwh DOUBLE PRECISION -- Foreign cost computed at warehouse rate
);

-- Table: stcrtpuinv
-- Description: Stock Link table mapping Goods Receipts to eventual Purchase Invoices.
CREATE TABLE bronze.stcrtpuinv (
    branch VARCHAR(2),          -- Branch identifier
    splycode VARCHAR(19),       -- Supplier link code
    fcy VARCHAR(3),             -- Currency code
    splyinv VARCHAR(20),        -- Supplier's invoice number
    itemno VARCHAR(16),         -- Item/Product number
    unicode VARCHAR(6),         -- Unit of measure code
    dbxyr VARCHAR(2),           -- Database Year identifier
    idate VARCHAR(8),           -- Invoice date
    lastupdt VARCHAR(8),        -- Last update date
    rplct_post BOOLEAN,         -- Replicated post flag
    slcode VARCHAR(2)           -- Associated buyer/salesman code
);

-- ============================================================================
-- 4. Costing, Pricing & Item Metadata
-- ============================================================================

-- Table: stcosttype
-- Description: Historical tracking of item costs (Highest, Lowest, First, Last).
CREATE TABLE bronze.stcosttype (
    branch VARCHAR(2),          -- Associated branch
    itemno VARCHAR(16),         -- Item/Product number
    unicode VARCHAR(6),         -- Unit of measure code
    lastlcost DOUBLE PRECISION, -- Most recent local cost
    highlcost DOUBLE PRECISION, -- All-time high local cost
    lowlcost DOUBLE PRECISION,  -- All-time low local cost
    lstrcvdate VARCHAR(8),      -- Date of last receipt
    lastfcost DOUBLE PRECISION, -- Most recent foreign cost
    frstrcvdate VARCHAR(8),     -- Date of initial/first receipt
    highfcost DOUBLE PRECISION, -- All-time high foreign cost
    lowfcost DOUBLE PRECISION,  -- All-time low foreign cost
    lastrcvd01 VARCHAR(8),      -- Last receipt date (System 01 tracking)
    lastlcost01 DOUBLE PRECISION, -- Last local cost (System 01 tracking)
    frstlcost01 DOUBLE PRECISION, -- First local cost (System 01 tracking)
    pufrstlcost DOUBLE PRECISION, -- Purchase first local cost
    brlastissue VARCHAR(8)      -- Date the branch last issued this item
);

-- Table: stfcyprice
-- Description: Foreign currency pricing tiers for items.
CREATE TABLE bronze.stfcyprice (
    itemno VARCHAR(16),         -- Item/Product number
    unicode VARCHAR(6),         -- Unit of measure code
    fcyprice1 DOUBLE PRECISION, -- Selling Price Tier 1 in FCY
    fcyprice2 DOUBLE PRECISION, -- Selling Price Tier 2 in FCY
    fcyprice3 DOUBLE PRECISION, -- Selling Price Tier 3 in FCY
    fcymnmprice DOUBLE PRECISION-- Absolute minimum allowed selling price in FCY
);

-- Table: stitemrp
-- Description: Item Replacements & Substitutes mapping for stock shortages.
CREATE TABLE bronze.stitemrp (
    itemno VARCHAR(16),         -- Original Item number
    unicode VARCHAR(6),         -- Original Unit of measure
    rplitemno VARCHAR(16),      -- Replacement/Substitute Item number
    rplunicode VARCHAR(6),      -- Replacement/Substitute Unit of measure
    cmbkey VARCHAR(24),         -- Combined key for mapping
    rplorder NUMERIC(2,0),      -- Priority order for substitution (e.g., 1 is first choice)
    lastupdt DATE               -- Last update date
);



-- ============================================================================
-- PostgreSQL Schema Definitions: Bronze Layer (Batch 5 - Final)
-- Description: Item Master, Units of Measure, Warehouses, Suppliers, 
--              System User Security, and Tax configurations.
-- ============================================================================

-- Safely drop existing tables before creation to ensure a clean deployment
DROP TABLE IF EXISTS bronze.stitems;
DROP TABLE IF EXISTS bronze.stitmphoto;
DROP TABLE IF EXISTS bronze.stprice;
DROP TABLE IF EXISTS bronze.streorderQP;
DROP TABLE IF EXISTS bronze.stunits;
DROP TABLE IF EXISTS bronze.stwhous;
DROP TABLE IF EXISTS bronze.supplier;
DROP TABLE IF EXISTS bronze.sysuse;
DROP TABLE IF EXISTS bronze.taxcategory;
DROP TABLE IF EXISTS bronze.taxlog;
DROP TABLE IF EXISTS bronze.taxperiod;

-- ============================================================================
-- 1. Inventory Item Master & Units
-- ============================================================================

-- Table: stitems
-- Description: Core Item Master Data defining products, raw materials, and services.
CREATE TABLE bronze.stitems (
    name VARCHAR(45),           -- Primary item name
    itemno VARCHAR(16),         -- Unique item identifier code
    mgroup VARCHAR(2),          -- Main group code
    sgroup VARCHAR(2),          -- Sub-group 1 code
    category VARCHAR(2),        -- Category code
    fcy VARCHAR(3),             -- Default foreign currency for purchasing
    classkey VARCHAR(12),       -- Classification mapping key
    exdatealw BOOLEAN,          -- Flag: Expiry date tracking required
    noofsbitem INTEGER,         -- Number of sub-items (for kits/assemblies)
    modified BOOLEAN,           -- Record modified flag
    sgroup3 VARCHAR(3),         -- Sub-group 3 code
    sgroup4 VARCHAR(3),         -- Sub-group 4 code
    company VARCHAR(2),         -- Company identifier code
    lname VARCHAR(40),          -- Alternative language item name
    country NUMERIC(3,0),       -- Country of origin ID
    season VARCHAR(1),          -- Seasonality identifier
    splycode VARCHAR(19),       -- Primary supplier code
    splylcact BOOLEAN,          -- Supplier Local Currency active flag
    itemtype VARCHAR(1),        -- Item Type (e.g., Stock, Service, Asset)
    prntasmitm BOOLEAN,         -- Flag: Print assembly items on invoices
    prmdesc VARCHAR(8),         -- Primary description/short code
    scndesc VARCHAR(8),         -- Secondary description/short code
    cmpprcnt BOOLEAN,           -- Compute percentage flag
    dsctype VARCHAR(1),         -- Discount application type
    brand_id NUMERIC(4,0),      -- Brand identifier
    msplycode VARCHAR(6),       -- Manufacturer/Secondary supplier code
    modelno VARCHAR(16),        -- Manufacturer model number
    nosales BOOLEAN,            -- Flag: Block from sales (e.g., internal use only)
    vprice NUMERIC(13,2),       -- Virtual/Reference price
    fix_barcode BOOLEAN,        -- Flag: Barcode cannot be overridden
    taxfree BOOLEAN,            -- Flag: Item is tax-exempt
    taxtype VARCHAR(1),         -- Tax classification type
    raw_material BOOLEAN        -- Flag: Item is a raw material for manufacturing
);

-- Table: stitmphoto
-- Description: Item E-Commerce extensions, multimedia, and advanced attributes.
CREATE TABLE bronze.stitmphoto (
    itemno VARCHAR(16),         -- Item identifier code
    unicode VARCHAR(6),         -- Unit of measure code
    remarks VARCHAR(250),       -- Marketing/Display remarks
    ipicture VARCHAR(80),       -- File path or URL to item image
    ord_qty DOUBLE PRECISION,   -- Default ordering quantity
    mnimumdt VARCHAR(8),        -- Minimum date requirement
    cust_pctg DOUBLE PRECISION, -- Custom duty percentage
    is_double_width BOOLEAN,    -- Flag: Textiles/Fabrics double-width
    is_price_per_length BOOLEAN,-- Flag: Price calculated by length/dimensions
    is_accessory_stk_item BOOLEAN, -- Flag: Item is an accessory to a main product
    dsc_amt1 DOUBLE PRECISION,  -- Fixed discount tier 1
    dsc_amt2 DOUBLE PRECISION,  -- Fixed discount tier 2
    dsc_amt3 DOUBLE PRECISION,  -- Fixed discount tier 3
    usrid VARCHAR(10),          -- System user who created the record
    usrid_lstchg VARCHAR(10),   -- System user who last modified it
    exemption_reason_code VARCHAR(20), -- Official tax exemption reason code
    sell_in_lcl_currncy BOOLEAN,-- Flag: Force sale in local currency
    extra_tax_p NUMERIC(6,2),   -- Additional specific tax percentage
    onlinesales BOOLEAN,        -- Flag: Publish item to e-commerce/web store
    startdate VARCHAR(8),       -- Validity start date (YYYYMMDD)
    enddate VARCHAR(8)          -- Validity end date (YYYYMMDD)
);

-- Table: stunits
-- Description: Item Units of Measure (UOM), Multi-Pack configurations, and Balances.
CREATE TABLE bronze.stunits (
    name VARCHAR(8),            -- Unit name (e.g., PCS, KG, BOX)
    itemno VARCHAR(16),         -- Item identifier code
    unicode VARCHAR(6),         -- Unique unit code
    moved BOOLEAN,              -- Flag: Item has transaction history
    openlcost DOUBLE PRECISION, -- Opening local cost
    lcost DOUBLE PRECISION,     -- Current local cost (Moving Average/FIFO)
    lprice1 NUMERIC(11,2),      -- Selling Price 1 (Local)
    fprice1 NUMERIC(11,2),      -- Selling Price 1 (Foreign)
    maxdisc1 NUMERIC(4,2),      -- Max allowed discount % for Tier 1
    lprice2 NUMERIC(11,2),      -- Selling Price 2 (Local)
    fprice2 NUMERIC(11,2),      -- Selling Price 2 (Foreign)
    maxdisc2 NUMERIC(4,2),      -- Max allowed discount % for Tier 2
    lprice3 NUMERIC(11,2),      -- Selling Price 3 (Local)
    fprice3 NUMERIC(11,2),      -- Selling Price 3 (Foreign)
    maxdisc3 NUMERIC(4,2),      -- Max allowed discount % for Tier 3
    openfcost DOUBLE PRECISION, -- Opening foreign cost
    fcost DOUBLE PRECISION,     -- Current foreign cost
    lrcvdate VARCHAR(8),        -- Last receive date
    lastissue VARCHAR(8),       -- Last issue/sale date
    openbal DOUBLE PRECISION,   -- Opening stock balance quantity
    curbal DOUBLE PRECISION,    -- Current stock balance quantity
    rsvqty DOUBLE PRECISION,    -- Reserved/Allocated stock quantity
    minstk NUMERIC(11,3),       -- Minimum stock alert level
    maxstk NUMERIC(11,3),       -- Maximum stock capacity level
    orderlevel NUMERIC(11,2),   -- Reorder point level
    leadday NUMERIC(3,0),       -- Supplier lead time in days
    Xdecimal BOOLEAN,           -- Flag: Allow fractional quantities
    barcode VARCHAR(20),        -- Primary barcode for this specific unit
    -- Packaging Multiplier Logic
    pack1 VARCHAR(1), pkqty1 NUMERIC(10,3), -- Outer Pack 1 and multiplier
    pack2 VARCHAR(1), pkqty2 NUMERIC(10,3), -- Outer Pack 2 and multiplier
    pack3 VARCHAR(1), pkqty3 NUMERIC(8,3),  -- Outer Pack 3 and multiplier
    company VARCHAR(2),         -- Company identifier
    modified BOOLEAN,           -- Record modified flag
    pack0 VARCHAR(1),           -- Base pack indicator
    packtp VARCHAR(1),          -- Packaging type
    scnname VARCHAR(8),         -- Scanner name/shortcode
    crtdate VARCHAR(8),         -- Creation date
    inactive BOOLEAN,           -- Flag: Unit is inactive/deprecated
    prmcode VARCHAR(3),         -- Primary unit code
    scncode VARCHAR(3),         -- Secondary unit code
    cmbkey VARCHAR(24),         -- Combined key (Item + Unit)
    mnmprice NUMERIC(11,2),     -- Hard floor minimum selling price
    lastupdt VARCHAR(8),        -- Last update date
    modelno VARCHAR(16),        -- Model number override
    splyitemno VARCHAR(25),     -- Supplier's specific item code
    splyinv VARCHAR(10),        -- Supplier invoice link
    invprice DOUBLE PRECISION,  -- Last invoice price
    invqty NUMERIC(10,3),       -- Last invoice quantity
    invpk VARCHAR(1),           -- Last invoice pack type
    pp2 NUMERIC(6,2),           -- Price point/margin ref 2
    pp3 NUMERIC(6,2)            -- Price point/margin ref 3
);

-- Table: streorderQP
-- Description: Reorder rules and quantities.
CREATE TABLE bronze.streorderQP (
    itemno VARCHAR(16),         -- Item identifier code
    unicode VARCHAR(6),         -- Unit of measure code
    reorderQ NUMERIC(12,3),     -- Fixed reorder quantity
    lastupdt VARCHAR(8),        -- Last update date
    reorderD NUMERIC(3,0),      -- Reorder days threshold
    reorderP NUMERIC(6,2)       -- Reorder percentage/point
);

-- Table: stprice
-- Description: Price level naming configurations.
CREATE TABLE bronze.stprice (
    name VARCHAR(15),           -- Price level name (e.g., Retail, Wholesale)
    code VARCHAR(1),            -- Price level code
    disc VARCHAR(8),            -- Discount rule mapping
    lprice VARCHAR(8),          -- Local price mapping
    fprice VARCHAR(8),          -- Foreign price mapping
    minsal NUMERIC(9,2),        -- Minimum sales limit
    maxsal NUMERIC(9,2),        -- Maximum sales limit
    modified BOOLEAN,           -- Record modified flag
    lname VARCHAR(15),          -- Alternative language name
    lastupdt VARCHAR(8)         -- Last update date
);

-- ============================================================================
-- 2. Warehouses & Suppliers
-- ============================================================================

-- Table: stwhous
-- Description: Warehouse Master Data.
CREATE TABLE bronze.stwhous (
    name VARCHAR(30),           -- Warehouse name
    whno VARCHAR(2),            -- Unique warehouse number
    branch VARCHAR(2),          -- Branch mapping
    manager VARCHAR(30),        -- Warehouse manager name
    phone VARCHAR(9),           -- Contact phone number
    address VARCHAR(30),        -- Physical address
    lastupdt VARCHAR(8),        -- Last update date
    srwhs VARCHAR(19),          -- GL Serial linking to stock accounts
    modified BOOLEAN,           -- Record modified flag
    lname VARCHAR(20),          -- Alternative language warehouse name
    fax VARCHAR(20),            -- Contact fax number
    prnt_fsh BOOLEAN,           -- Fiscal print flag
    ac_end_prd VARCHAR(19),     -- GL link for period-end adjustments
    cstcode VARCHAR(4),         -- Cost center code
    no_autosales BOOLEAN,       -- Flag: Prevent automated sales allocation
    sc_code VARCHAR(6),         -- Sales center mapping
    suspended BOOLEAN,          -- Flag: Warehouse is suspended/closed
    binsrlno VARCHAR(6)         -- Auto-generation serial for bins
);

-- Table: supplier
-- Description: Supplier/Vendor Master Data (Comprehensive Accounts Payable profile).
CREATE TABLE bronze.supplier (
    cu_name VARCHAR(50),        -- Supplier/Vendor name
    cu_company VARCHAR(2),      -- Company identifier code
    cu_code VARCHAR(6),         -- Unique supplier code
    cu_class VARCHAR(2),        -- Supplier classification group
    cu_addrs VARCHAR(50),       -- Supplier address
    cu_tel VARCHAR(25),         -- Telephone number
    cu_fax VARCHAR(10),         -- Fax number
    cu_tlx VARCHAR(10),         -- Telex (Legacy)
    cu_email VARCHAR(30),       -- Email address
    cu_cntactp VARCHAR(20),     -- Contact person
    cu_title VARCHAR(20),       -- Title of contact person
    cu_crlmt NUMERIC(14,2),     -- Credit limit granted by supplier
    cu_pymnt NUMERIC(3,0),      -- Payment terms (days)
    cu_status NUMERIC(1,0),     -- Account status (e.g., 1=Active)
    cu_opnbal DOUBLE PRECISION, -- Opening balance (Local Currency)
    cu_curbal DOUBLE PRECISION, -- Current balance (Local Currency)
    cf_fcy VARCHAR(3),          -- Default foreign currency
    cf_opnfcy DOUBLE PRECISION, -- Opening balance (Foreign Currency)
    cf_curfcy DOUBLE PRECISION, -- Current balance (Foreign Currency)
    cu_xrf VARCHAR(6),          -- External cross-reference code
    cu_alwcr BOOLEAN,           -- Flag: Allow credit purchases
    cu_ctlser VARCHAR(19),      -- GL Control serial
    lastupdt VARCHAR(8),        -- Last update date
    cu_lcaloc DOUBLE PRECISION, -- Allocated local currency
    cu_fcaloc DOUBLE PRECISION, -- Allocated foreign currency
    modified BOOLEAN,           -- Record modified flag
    cmncode VARCHAR(8),         -- Commission code
    cu_lname VARCHAR(40),       -- Alternative language supplier name
    cu_city VARCHAR(6),         -- City code
    cu_country NUMERIC(3,0),    -- Country code
    cu_laddrs VARCHAR(50),      -- Alternative language address
    cu_mobile VARCHAR(25),      -- Mobile number
    cu_sendsms BOOLEAN,         -- Flag: Opt-in for SMS
    rowguid VARCHAR(255),       -- Unique row identifier
    whno VARCHAR(2),            -- Default delivery warehouse
    vndr_taxcode VARCHAR(20),   -- Vendor Tax/VAT identification number
    taxFree BOOLEAN,            -- Flag: Vendor is tax-exempt
    cu_kind VARCHAR(1),         -- Vendor kind classification
    section VARCHAR(6),         -- Division/Section mapping
    PriceIncludeVat BOOLEAN,    -- Flag: Supplier prices are VAT inclusive
    cu_type VARCHAR(1),         -- Vendor type
    usrid VARCHAR(10),          -- System user who created the record
    usridchg VARCHAR(10),       -- System user who modified the record
    Added_date VARCHAR(8)       -- Creation date
);

-- ============================================================================
-- 3. System User Security & Permissions
-- ============================================================================

-- Table: sysuse
-- Description: Extensive User Access Control table defining granular module permissions.
CREATE TABLE bronze.sysuse (
    -- Identity & Authentication
    username VARCHAR(10),       -- Unique login username
    password VARCHAR(100),      -- Hashed user password
    fullname VARCHAR(30),       -- User's full name
    emp_code VARCHAR(10),       -- Associated HR employee code
    grp VARCHAR(255),           -- User group/role assignment
    company VARCHAR(2),         -- Default company access
    
    -- Global Restrictions
    suspend BOOLEAN,            -- Flag: Account is suspended
    uchgpas BOOLEAN,            -- Flag: User must change password
    e_password VARCHAR(255),    -- E-signature or secondary password
    
    -- UI & Navigation Profile
    formkey VARCHAR(255),       -- Authorized form keys
    formsel VARCHAR(255),       -- Authorized form selections
    formname VARCHAR(255),      -- Landing/Default form name
    uslatin BOOLEAN,            -- Flag: Use Latin/English UI layout
    
    -- Data Visibility (Pricing & Costs)
    showcost BOOLEAN,           -- Permission: View item cost
    undrcost BOOLEAN,           -- Permission: Sell below cost
    undrmin BOOLEAN,            -- Permission: Sell below minimum stock
    belowbal BOOLEAN,           -- Permission: Sell into negative stock
    showitmcst BOOLEAN,         -- Permission: Show item cost in grids
    usshowprofit BOOLEAN,       -- Permission: View profit margins
    nopriceblwcost BOOLEAN,     -- Restriction: Block price below cost
    Noslsblwcst BOOLEAN,        -- Restriction: Block sales below cost
    
    -- Operational Access Rights
    acssdisc BOOLEAN,           -- Permission: Apply discounts
    chgprice BOOLEAN,           -- Permission: Change prices
    acssfqty BOOLEAN,           -- Permission: Access foreign quantity fields
    usalwchgprs BOOLEAN,        -- Permission: Always allow price change
    alwchg_slrtn_price BOOLEAN, -- Permission: Change price on sales return
    
    -- Granular Module Permissions (Sales & Purchasing)
    usslcsh BOOLEAN,            -- Access: Cash Sales
    usslcrd BOOLEAN,            -- Access: Credit Sales
    usslrcsh BOOLEAN,           -- Access: Return Cash Sales
    usslrcrd BOOLEAN,           -- Access: Return Credit Sales
    uspucsh BOOLEAN,            -- Access: Cash Purchases
    uspucrd BOOLEAN,            -- Access: Credit Purchases
    uspurcsh BOOLEAN,           -- Access: Return Cash Purchases
    uspurcrd BOOLEAN,           -- Access: Return Credit Purchases
    
    -- General Ledger & Stock Transactions
    usjv BOOLEAN,               -- Access: Journal Vouchers
    usrcv BOOLEAN,              -- Access: Stock Receipts
    usiss BOOLEAN,              -- Access: Stock Issues
    uschqrcv BOOLEAN,           -- Access: Cheque Receipts
    uschqiss BOOLEAN,           -- Access: Cheque Issues
    ustrnsin BOOLEAN,           -- Access: Stock Transfer In
    ustrnsout BOOLEAN,          -- Access: Stock Transfer Out
    usbnkin BOOLEAN,            -- Access: Bank Deposits
    uscredit BOOLEAN,           -- Access: Credit Notes
    usdebit BOOLEAN,            -- Access: Debit Notes
    ussuspend BOOLEAN,          -- Access: Suspend Transactions
    ushide_jv BOOLEAN,          -- Access: View hidden JVs
    
    -- System Actions & Edits
    editothers BOOLEAN,         -- Permission: Edit transactions created by others
    dsplyothers BOOLEAN,        -- Permission: Display transactions created by others
    dsplyothersQH BOOLEAN,      -- Permission: Display quotes created by others
    hideqhinfo BOOLEAN,         -- Restriction: Hide quote info
    chgperiod BOOLEAN,          -- Permission: Change financial periods
    chgtdate BOOLEAN,           -- Permission: Backdate/Forward-date transactions
    noexratechg BOOLEAN,        -- Restriction: Cannot change exchange rates
    
    -- Master Data Security & Limits
    maxdsc NUMERIC(4,2),        -- Maximum allowable discount percentage
    maxfqty NUMERIC(6,2),       -- Maximum allowable foreign quantity entry
    currate NUMERIC(6,3),       -- Default assigned currency rate override
    actallow VARCHAR(255),      -- CSV list of allowed GL accounts
    openallow BOOLEAN,          -- Access: Opening balances
    cstallow VARCHAR(255),      -- CSV list of allowed cost centers
    usrbrn VARCHAR(255),        -- CSV list of allowed branch codes
    uspright VARCHAR(255),      -- Specific rights matrix
    uswhalw VARCHAR(255),       -- CSV list of allowed warehouses
    uscntralw VARCHAR(255),     -- CSV list of allowed sales centers
    usdptalw VARCHAR(255),      -- CSV list of allowed departments
    ussctnalw VARCHAR(255),     -- CSV list of allowed sections
    
    -- Mobile, POS, & Hardware Integrations
    posuser BOOLEAN,            -- Flag: User operates POS interface
    msuser BOOLEAN,             -- Flag: Mobile Sales user
    mobileuser BOOLEAN,         -- Flag: Mobile app access
    mobilNo VARCHAR(30),        -- User's registered mobile number
    usmagnetic BOOLEAN,         -- Flag: Uses magnetic card login
    sendsms BOOLEAN,            -- Permission: Send SMS to clients
    passwordPDA VARCHAR(255),   -- Password for PDA/Scanner devices
    usfpalw BOOLEAN,            -- Access: Fingerprint biometric allowed
    usfpimage VARCHAR(255),     -- Fingerprint biometric template 1
    usfpimage2 VARCHAR(255),    -- Fingerprint biometric template 2
    
    -- Approvals & Validations
    confirmPurchase BOOLEAN,    -- Permission: Confirm/Approve purchases
    confirmbr BOOLEAN,          -- Permission: Confirm branch requests
    confirmtrnsfr BOOLEAN,      -- Permission: Confirm stock transfers
    mgmtcnfrm BOOLEAN,          -- Flag: Requires management confirmation
    noovrdrft BOOLEAN,          -- Restriction: Block overdraft transactions
    onlyactrmt BOOLEAN,         -- Restriction: Only remote active access
    OTP INTEGER,                -- OTP token configuration
    
    -- Print Controls
    alwprntrpt BOOLEAN,         -- Permission: Print reports
    printinv BOOLEAN,           -- Permission: Print invoices
    printtrx BOOLEAN,           -- Permission: Print transactions
    printbarcode BOOLEAN,       -- Permission: Print barcodes
    inv_form_no NUMERIC(2,0),   -- User's default invoice form layout
    max_inv_printed NUMERIC(2,0), -- Max times user can reprint an invoice
    max_fsh_printed NUMERIC(2,0), -- Max times user can print fiscal receipt
    
    -- Advanced & Contract Modules
    web_rights VARCHAR(254),    -- JSON/CSV defining web portal rights
    NorgstrNoSl BOOLEAN,        -- Restriction: No sales without register
    AlwChangeVAT BOOLEAN,       -- Permission: Manually change VAT rate
    blkassmbld BOOLEAN,         -- Flag: Block assembled items
    smartsearch BOOLEAN,        -- Flag: Enable smart/fuzzy search in UI
    e_invrdy BOOLEAN,           -- Flag: E-Invoice ready indicator
    binno VARCHAR(5000),        -- CSV list of allowed warehouse bins
    is_infosoft_equvlnt BOOLEAN,-- Flag: Legacy system equivalent profile
    srvs_chgprice BOOLEAN,      -- Permission: Change service prices
    srvs_acssdisc BOOLEAN,      -- Permission: Access service discounts
    srvs_maxdsc NUMERIC(5,2),   -- Maximum discount for services
    chg_rent_fcy BOOLEAN,       -- Permission: Change rental foreign currency
    opn_closed_ctrct BOOLEAN,   -- Permission: Open closed contracts
    alwslfrmslnobal BOOLEAN,    -- Permission: Allow sales from zero balance
    alwsend_doc BOOLEAN,        -- Permission: Send documents via EDI/Email
    noadd_crdt_clnt BOOLEAN,    -- Restriction: Cannot add credit clients
    
    -- Document Archiving Module
    archv_upload BOOLEAN,       -- Permission: Upload to archive
    archv_download BOOLEAN,     -- Permission: Download from archive
    archv_open BOOLEAN,         -- Permission: Open archive files
    archv_delete BOOLEAN,       -- Permission: Delete from archive
    
    -- Messaging & Security
    alw2usewtsapp BOOLEAN,      -- Permission: Use WhatsApp integration
    alw2chgwtsmbl BOOLEAN,      -- Permission: Change WhatsApp mobile number
    check_in_after_check_out BOOLEAN, -- HR: Allow check-in after check-out
    ok_chng_client_ban_security BOOLEAN, -- Permission: Edit client security bans
    ok_show_client_ban_security BOOLEAN, -- Permission: View client security bans
    ok_contract_check_out BOOLEAN, -- Permission: Perform contract checkout
    ok_contract_closing BOOLEAN,   -- Permission: Perform contract closing
    
    -- Legacy fields
    useprice1 BOOLEAN,          -- Specific permission for Price Tier 1
    useprice2 BOOLEAN,          -- Specific permission for Price Tier 2
    useprice3 BOOLEAN,          -- Specific permission for Price Tier 3
    shwacprtct BOOLEAN,         -- Specific permission for protected accounts
    onlinepost BOOLEAN,         -- Flag: Post transactions online/real-time
    usslprofit BOOLEAN,         -- specific permission for sales profit view
    uschdlcshinv BOOLEAN,       -- specific permission for scheduled cash invoice
    uschdlcshrcv BOOLEAN,       -- specific permission for scheduled cash receipt
    uschdlchqrcv BOOLEAN,       -- specific permission for scheduled cheque receipt
    goblwmnmp BOOLEAN,          -- specific permission for go below minimum price
    usissrqst BOOLEAN,          -- specific permission for issue request
    usstiss BOOLEAN,            -- specific permission for stock issue
    usstrcv BOOLEAN             -- specific permission for stock receipt
);

-- ============================================================================
-- 4. Tax Configuration & Auditing
-- ============================================================================

-- Table: taxcategory
-- Description: Definitions for VAT/Tax categories.
CREATE TABLE bronze.taxcategory (
    taxcatID NUMERIC(3,0),      -- Unique tax category ID
    taxcat_name VARCHAR(40),    -- Tax name (e.g., Standard VAT 15%)
    taxcat_lname VARCHAR(40),   -- Alternative language tax name
    cat_protected BOOLEAN,      -- Flag: Category is protected from editing
    lastupdt VARCHAR(8),        -- Last update date
    sysname VARCHAR(2),         -- System mapping name
    In_out_tax NUMERIC(1,0),    -- Indicator: 1 for Input Tax (Purchases), 0 for Output Tax (Sales)
    txdsc_allowed BOOLEAN       -- Flag: Are discounts calculated pre-tax or post-tax?
);

-- Table: taxperiod
-- Description: Financial tax periods mapping for regulatory reporting.
CREATE TABLE bronze.taxperiod (
    taxprdcalcomp VARCHAR(2),   -- Company code linked to the calculation
    taxprdyrcode VARCHAR(4),    -- Tax Year (e.g., 2026)
    taxprdcode INTEGER,         -- Period Code (e.g., 1 for Q1 or Jan)
    taxprdname VARCHAR(50),     -- Period Name
    taxprdlname VARCHAR(50),    -- Alternative language period name
    taxprdstart VARCHAR(8),     -- Period Start Date (YYYYMMDD)
    taxprdend VARCHAR(8),       -- Period End Date (YYYYMMDD)
    crtdate TIMESTAMP,          -- Record creation timestamp
    lastupdt VARCHAR(8),        -- Last update date
    lastmodifed TIMESTAMP,      -- Last modified timestamp
    Taxtype VARCHAR(3),         -- Tax Type classification
    lastusrupdt VARCHAR(10),    -- System user who last updated the period
    Jv_Vat_Percent NUMERIC(5,2) -- The prevailing VAT percentage for this period
);

-- Table: taxlog
-- Description: Loosely structured audit log for tracking tax and rule changes.
CREATE TABLE bronze.taxlog (
    fld1 VARCHAR(255),          -- Flexible log field 1 (e.g., Transaction ID)
    fld2 VARCHAR(255),          -- Flexible log field 2 (e.g., Old Tax Value)
    fld3 VARCHAR(255),          -- Flexible log field 3 (e.g., New Tax Value)
    fld4 VARCHAR(255),          -- Flexible log field 4 (e.g., User ID)
    fld5 VARCHAR(255),          -- Flexible log field 5 (e.g., Timestamp)
    fld6 VARCHAR(255),          -- Flexible log field 6
    fld7 VARCHAR(255),          -- Flexible log field 7
    fld8 VARCHAR(255),          -- Flexible log field 8
    fld9 VARCHAR(255)           -- Flexible log field 9
);