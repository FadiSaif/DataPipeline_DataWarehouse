import json
import os
from pathlib import Path

DIR_PATH = Path(__file__).resolve().parent
PROJECT_ROOT = DIR_PATH.parent

dict_file = PROJECT_ROOT / "rename_map.json"
const_file = DIR_PATH / "extracted_mssql_constraints.json"
out_sql = DIR_PATH / "02_native_silver_constraints.sql"

def get_clean_col_name(orig_table, col_name):
    # Match the logic in build_sql.py exactly
    clean = col_name.lower()
    prefixes = ['hd_', 'dt_', 'sl_', 'cu_', 'cl_', 'bk', 'br', 'pr', 'dp_', 'jd', 'jh', 'sc_']
    for p in prefixes:
        if clean.startswith(p):
            clean = clean[len(p):]
            break
    if clean == 'cucode': clean = 'customer_code'
    elif clean == 'clcode': clean = 'class_code'
    elif clean == 'actcode': clean = 'account_code'
    elif clean == 'ref': clean = 'reference_number'
    elif clean == 'invtype': clean = 'invoice_type'
    elif clean == 'comp' or clean == 'company': clean = 'company_id'
    return clean

with open(dict_file, "r") as f:
    table_remaps = json.load(f)
    
with open(const_file, "r") as f:
    schema = json.load(f)

# Find all silver tables
target_tables = set(table_remaps.keys())

def generate():
    with open(out_sql, "w") as f:
        f.write("-- =========================================================================\n")
        f.write("-- SILVER LAYER NATIVE ERP CONSTRAINTS (Semantic Naming)\n")
        f.write("-- \n")
        f.write("-- PURPOSE: Apply genuine MSSQL-derived constraints onto renamed tables/cols.\n")
        f.write("-- NOTE: Foreign Keys are set to NOT VALID to allow initial legacy load.\n")
        f.write("-- =========================================================================\n\n")
        
        f.write("DO $$\nBEGIN\n\n")
        
        f.write("-- 1. PRIMARY KEYS\n")
        for tbl in schema["primary_keys"]:
            if tbl in target_tables:
                new_tbl = table_remaps[tbl]
                orig_cols = schema["primary_keys"][tbl]
                new_cols = [f'"{get_clean_col_name(tbl, c)}"' for c in orig_cols]
                cols_str = ", ".join(new_cols)
                
                f.write(f"ALTER TABLE silver.{new_tbl} DROP CONSTRAINT IF EXISTS pk_{new_tbl};\n")
                f.write(f"ALTER TABLE silver.{new_tbl} ADD CONSTRAINT pk_{new_tbl} PRIMARY KEY ({cols_str});\n")
                
        f.write("\n-- 2. FOREIGN KEYS (NOT VALID to allow legacy orphaned data)\n")
        for ptbl, fks in schema["foreign_keys"].items():
            if ptbl in target_tables:
                new_ptbl = table_remaps[ptbl]
                for fk in fks:
                    rtbl = fk["ref_table"]
                    if rtbl in target_tables:
                        new_rtbl = table_remaps[rtbl]
                        
                        orig_pcols = fk["cols"]
                        orig_rcols = fk["ref_cols"]
                        
                        new_pcols = [f'"{get_clean_col_name(ptbl, c)}"' for c in orig_pcols]
                        new_rcols = [f'"{get_clean_col_name(rtbl, c)}"' for c in orig_rcols]
                        
                        pcols_str = ", ".join(new_pcols)
                        rcols_str = ", ".join(new_rcols)
                        
                        new_fk_name = f"fk_{new_ptbl}_{new_rtbl}_{fk['name'].lower()[-5:]}"
                        
                        f.write(f"ALTER TABLE silver.{new_ptbl} DROP CONSTRAINT IF EXISTS {new_fk_name};\n")
                        f.write(f"ALTER TABLE silver.{new_ptbl} ADD CONSTRAINT {new_fk_name} \n")
                        f.write(f"    FOREIGN KEY ({pcols_str}) REFERENCES silver.{new_rtbl} ({rcols_str}) NOT VALID;\n")
                        
        f.write("\nEND $$;\n")

generate()
print("Generated native constraint script.")

