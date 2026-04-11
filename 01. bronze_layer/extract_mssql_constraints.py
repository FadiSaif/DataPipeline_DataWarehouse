import pyodbc
import json

MSSQL_IP = "192.168.1.100"
MSSQL_USER = "sa"
MSSQL_PASS = "123"

def extract_constraints():
    conn_str = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        f"SERVER={MSSQL_IP};"
        f"DATABASE=dbc01y21;"
        f"UID={MSSQL_USER};"
        f"PWD={MSSQL_PASS};"
        "Encrypt=yes;TrustServerCertificate=yes;"
    )
    
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    
    # 1. Primary Keys
    schema_pks = {} # table_name -> [col1, col2]
    pk_query = """
        SELECT 
            t.name AS table_name,
            c.name AS column_name
        FROM sys.indexes i
        INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        INNER JOIN sys.tables t ON i.object_id = t.object_id
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE i.is_primary_key = 1 AND t.is_ms_shipped = 0
        ORDER BY t.name, ic.key_ordinal;
    """
    cursor.execute(pk_query)
    for row in cursor.fetchall():
        tname = row.table_name.lower()
        cname = row.column_name.lower()
        if tname not in schema_pks:
            schema_pks[tname] = []
        schema_pks[tname].append(cname)
        
    # 2. Foreign Keys
    schema_fks = {} # table_name -> list of dicts
    fk_query = """
        SELECT  
            fk.name AS fk_name,
            tp.name AS parent_table,
            cp.name AS parent_column,
            tr.name AS referenced_table,
            cr.name AS referenced_column
        FROM sys.foreign_keys fk
        INNER JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
        INNER JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
        INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
        INNER JOIN sys.columns cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
        INNER JOIN sys.columns cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
        ORDER BY tp.name, fk.name, fkc.constraint_column_id;
    """
    cursor.execute(fk_query)
    
    # Group by fk_name
    temp_fks = {}
    for row in cursor.fetchall():
        fk_name = row.fk_name.lower()
        if fk_name not in temp_fks:
            temp_fks[fk_name] = {
                "parent_table": row.parent_table.lower(),
                "referenced_table": row.referenced_table.lower(),
                "parent_columns": [],
                "referenced_columns": []
            }
        temp_fks[fk_name]["parent_columns"].append(row.parent_column.lower())
        temp_fks[fk_name]["referenced_columns"].append(row.referenced_column.lower())
        
    for fk_name, fk_def in temp_fks.items():
        ptable = fk_def["parent_table"]
        if ptable not in schema_fks:
            schema_fks[ptable] = []
        schema_fks[ptable].append({
            "name": fk_name,
            "ref_table": fk_def["referenced_table"],
            "cols": fk_def["parent_columns"],
            "ref_cols": fk_def["referenced_columns"]
        })
        
    conn.close()
    
    output = {
        "primary_keys": schema_pks,
        "foreign_keys": schema_fks
    }
    
    with open("02. silver_layer/extracted_mssql_constraints.json", "w") as f:
        json.dump(output, f, indent=4)
        
    print("Constraints extracted to JSON.")

if __name__ == "__main__":
    extract_constraints()
