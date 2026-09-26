import json
import os
from pathlib import Path

# ============================================================================
# This script generates the Silver Layer ETL SQL script.
# Instead of parsing the DDL file (which has DROP TABLE lines that confuse
# the parser), we query PostgreSQL's information_schema directly to get
# the true column lists from the bronze tables.
# ============================================================================

table_remaps = {
    "apclass": "ap_classification",
    "aphdr": "ap_invoice_header",
    "apdtl": "ap_invoice_detail",
    "arhdr": "ar_invoice_header",
    "ardtl": "ar_invoice_detail",
    "bkbank": "bank",
    "bkacct": "bank_account",
    "brselected": "branch_selection",
    "classfil": "classification_file",
    "customer": "customer",
    "delchghdr": "delivery_charge_header",
    "delchgdtl": "delivery_charge_detail",
    "glchart": "gl_chart_of_accounts",
    "glcurr": "gl_currency",
    "glfcimage_rate": "gl_exchange_rate",
    "gljrhdr": "gl_journal_header",
    "gljrdtl": "gl_journal_detail",
    "glsction": "gl_section",
    "orcountry": "country",
    "orpacking": "packing_type",
    "pricehst": "price_history",
    "pudept": "purchase_department",
    "puhdr": "purchase_order_header",
    "pudtl": "purchase_order_detail",
    "salecntr": "sales_center",
    "sales_hd": "sales_order_header",
    "sales_dt": "sales_order_detail",
    "sales_qh": "sales_quotation_header",
    "sales_qd": "sales_quotation_detail",
    "salesmen": "sales_representative",
    "slinvexp": "sales_invoice_expense",
    "starea": "stock_area",
    "stbranch": "stock_branch",
    "stbins": "stock_bin",
    "stclass": "stock_classification",
    "stcosttype": "stock_cost_type",
    "stcrtpuinv": "stock_purchase_invoice",
    "stdtl": "stock_transaction_detail",
    "stfcyprice": "stock_foreign_currency_price",
    "sthdr": "stock_transaction_header",
    "stitemrp": "stock_item_replacement",
    "stitems": "stock_item",
    "stitmphoto": "stock_item_photo",
    "stprice": "stock_price",
    "streorderqp": "stock_reorder_level",
    "stunits": "stock_unit_of_measure",
    "stwhous": "warehouse",
    "supplier": "supplier",
    "sysuse": "sys_user",
    "taxcategory": "tax_category",
    "taxperiod": "tax_period",
    "taxlog": "tax_log"
}

DIR_PATH = Path(__file__).resolve().parent
PROJECT_ROOT = DIR_PATH.parent

out_sql = DIR_PATH / "01_rename_and_load_silver.sql"

def get_columns_from_pg():
    """Query PostgreSQL directly to get actual column lists from bronze tables."""
    import psycopg2
    conn = psycopg2.connect(
        host=os.getenv("PG_HOST", "localhost"),
        user=os.getenv("PG_USER", "postgres"),
        password=os.getenv("PG_PASSWORD", "postgres"),
        dbname=os.getenv("PG_DB", "sales_DataWarehouse")
    )
    cursor = conn.cursor()
    
    schema_data = {}
    for tbl in table_remaps.keys():
        cursor.execute("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_schema = 'bronze' AND table_name = %s
            ORDER BY ordinal_position
        """, (tbl,))
        cols = [row[0] for row in cursor.fetchall()]
        schema_data[tbl] = cols
        
    conn.close()
    return schema_data

def get_clean_col_name(orig_table, col_name):
    # Very basic heuristics. 
    clean = col_name.lower()
    
    # Remove common prefixes like hd_, dt_, sl_, cu_, cl_, etc.
    prefixes = ['hd_', 'dt_', 'sl_', 'cu_', 'cl_', 'bk', 'br', 'pr', 'dp_', 'jd', 'jh', 'sc_']
    for p in prefixes:
        if clean.startswith(p):
            clean = clean[len(p):]
            break
            
    # Some overrides
    if clean == 'cucode': clean = 'customer_code'
    elif clean == 'clcode': clean = 'class_code'
    elif clean == 'actcode': clean = 'account_code'
    elif clean == 'ref': clean = 'reference_number'
    elif clean == 'invtype': clean = 'invoice_type'
    elif clean == 'comp' or clean == 'company': clean = 'company_id'
        
    return clean

def generate_script():
    schema_data = get_columns_from_pg()
    
    # 1. Output a shared rename map for constraints script
    with open(PROJECT_ROOT / 'rename_map.json', 'w') as f:
        json.dump(table_remaps, f, indent=4)

    with open(out_sql, 'w', encoding='utf-8') as f:
        f.write("-- =========================================================================\n")
        f.write("-- SILVER LAYER STRUCTURAL TRANSFORMATION & DATA LOAD SCRIPT\n")
        f.write("-- \n")
        f.write("-- PURPOSE:\n")
        f.write("--   1. Rename all 52 legacy tables to modern, contextual ERP naming.\n")
        f.write("--   2. Rename ALL columns from legacy codes (cu_name) to clean names (name).\n")
        f.write("--   3. Execute a full data load using PK-based deduplication.\n")
        f.write("-- =========================================================================\n\n")
        f.write("DO $$\nBEGIN\n\n")
        
        # ---------------------------------------------------------------
        # PHASE 1: RENAME TABLES AND COLUMNS
        # ---------------------------------------------------------------
        f.write("-- -------------------------------------------------------------------------\n")
        f.write("-- PHASE 1: RENAME TABLES AND COLUMNS\n")
        f.write("-- -------------------------------------------------------------------------\n\n")
        for orig, new_table in table_remaps.items():
            if orig != new_table:
                f.write(f"ALTER TABLE IF EXISTS silver.{orig} RENAME TO {new_table};\n")
            
            # Now rename columns for this table
            cols = schema_data.get(orig, [])
            for col in cols:
                new_col = get_clean_col_name(orig, col)
                if new_col != col.lower():
                    # Handle reserved keywords (e.g., 'location', 'section')
                    # Actually Postgres is usually fine with them if quoted, but psql might be better.
                    f.write(f"ALTER TABLE IF EXISTS silver.{new_table} RENAME COLUMN \"{col}\" TO \"{new_col}\";\n")

        # ---------------------------------------------------------------
        # PHASE 2: FULL DATA LOAD FROM BRONZE (DEDUPLICATED)
        # ---------------------------------------------------------------
        const_file = DIR_PATH / "extracted_mssql_constraints.json"
        with open(const_file, "r") as cf:
            native_schema = json.load(cf)
        native_pks = native_schema.get("primary_keys", {})
        
        f.write("\n\n-- -------------------------------------------------------------------------\n")
        f.write("-- PHASE 2: FULL DATA LOAD FROM BRONZE TO SILVER\n")
        f.write("-- \n")
        f.write("-- We load data using 'SELECT DISTINCT ON (pk_cols)' to ensure the \n")
        f.write("-- data integrity of logically unique rows across all 4 databases.\n")
        f.write("-- -------------------------------------------------------------------------\n\n")
        
        for orig, new_name in table_remaps.items():
            f.write(f"-- Load: bronze.{orig} -> silver.{new_name}\n")
            f.write(f"TRUNCATE TABLE silver.{new_name} CASCADE;\n\n")
            
            # Get actual columns, but EXCLUDE our internal tracking column for the Silver target
            all_raw_cols = schema_data.get(orig, [])
            raw_cols = [c for c in all_raw_cols if c != '_source_archive']
            new_cols = [get_clean_col_name(orig, c) for c in raw_cols]
            pk_cols = native_pks.get(orig, [])
            
            if raw_cols and pk_cols:
                cols_str = ", ".join([f'"{c}"' for c in new_cols])
                raw_cols_str = ", ".join([f'"{c}"' for c in raw_cols])
                pk_str = ", ".join([f'"{c}"' for c in pk_cols])
                
                # Deduplication Strategy: Latest Year Wins!
                # We sort by primary key then _source_archive DESC to pick the 2024 version
                f.write(f"INSERT INTO silver.{new_name} ({cols_str})\n")
                f.write(f"SELECT DISTINCT ON ({pk_str}) {raw_cols_str}\n")
                f.write(f"FROM bronze.{orig} \n")
                f.write(f"ORDER BY {pk_str}, _source_archive DESC;\n\n")
            elif raw_cols:
                cols_str = ", ".join([f'"{c}"' for c in new_cols])
                raw_cols_str = ", ".join([f'"{c}"' for c in raw_cols])
                f.write(f"INSERT INTO silver.{new_name} ({cols_str})\n")
                f.write(f"SELECT DISTINCT {raw_cols_str} FROM bronze.{orig};\n\n")

        f.write("END $$;\n")


# Run it
generate_script()
print("Generated SQL script completed!")


