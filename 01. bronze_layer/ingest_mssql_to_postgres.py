import os
import pyodbc
import psycopg2
import csv
import io
import sys

# ==============================================================================
# CONFIGURATION 
# Reads connection parameters from environment variables or uses default placeholders
# ==============================================================================
MSSQL_IP = os.getenv("MSSQL_HOST", "localhost")
MSSQL_USER = os.getenv("MSSQL_USER", "sa")
MSSQL_PASS = os.getenv("MSSQL_PASSWORD", "password")

PG_IP = os.getenv("PG_HOST", "localhost")
PG_USER = os.getenv("PG_USER", "postgres")
PG_PASS = os.getenv("PG_PASSWORD", "postgres")
PG_DB = os.getenv("PG_DB", "sales_DataWarehouse")

# Chunk size for fetching data (prevents Out Of Memory errors)
CHUNK_SIZE = 5000

# ==============================================================================
# SCRIPT START
# ==============================================================================

def get_mssql_connection(db_name="master"):
    """Creates a connection to SQL Server"""
    conn_str = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        f"SERVER={MSSQL_IP};"
        f"DATABASE={db_name};"
        f"UID={MSSQL_USER};"
        f"PWD={MSSQL_PASS};"
        "Encrypt=yes;TrustServerCertificate=yes;"
    )
    conn = pyodbc.connect(conn_str)
    # Tell pyodbc how to decode the wire data from SQL Server:
    # NVARCHAR/NCHAR come as UTF-16LE (wide chars)
    conn.setdecoding(pyodbc.SQL_WCHAR, encoding='utf-16le')
    # VARCHAR/CHAR — we'll be casting these to NVARCHAR in our queries,
    # so they'll also arrive as UTF-16LE, but set cp1256 as fallback
    conn.setdecoding(pyodbc.SQL_CHAR, encoding='cp1256')
    conn.setencoding(encoding='utf-8')
    return conn

def get_pg_connection():
    """Creates a connection to PostgreSQL"""
    return psycopg2.connect(
        host=PG_IP,
        user=PG_USER,
        password=PG_PASS,
        dbname=PG_DB
    )

def build_select_query(cursor, table_name):
    """
    Build a SELECT query that CASTs every VARCHAR/CHAR column to NVARCHAR.
    
    This forces SQL Server to convert Arabic text stored in VARCHAR (cp1256)
    into Unicode (UTF-16) ON THE SERVER SIDE, before the ODBC driver touches it.
    Without this, the ODBC driver performs a lossy codepage conversion that
    replaces Arabic characters with '?' question marks.
    """
    cursor.execute(f"""
        SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = '{table_name}'
        ORDER BY ORDINAL_POSITION
    """)
    columns_meta = cursor.fetchall()
    
    select_parts = []
    col_names = []
    for col_name, data_type, max_len in columns_meta:
        col_names.append(col_name)
        if data_type.lower() in ('varchar', 'char', 'text'):
            # Cast to NVARCHAR to force Unicode conversion on the server
            # Use MAX for text columns or columns with very large / -1 length
            if max_len is None or max_len == -1 or max_len > 4000:
                cast_len = 'MAX'
            else:
                cast_len = str(max_len)
            select_parts.append(f"CAST([{col_name}] AS NVARCHAR({cast_len})) AS [{col_name}]")
        else:
            select_parts.append(f"[{col_name}]")
    
    select_clause = ", ".join(select_parts)
    return f"SELECT {select_clause} FROM dbo.[{table_name}]", col_names

def main():
    print("Starting Migration Script...")
    
    # 1. Connect to Postgres to get the target tables in the 'bronze' schema
    try:
        pg_conn = get_pg_connection()
        pg_cursor = pg_conn.cursor()
    except Exception as e:
        print(f"Failed to connect to PostgreSQL: {e}")
        sys.exit(1)

    pg_cursor.execute("SELECT tablename FROM pg_tables WHERE schemaname = 'bronze'")
    target_tables = [row[0] for row in pg_cursor.fetchall()]
    print(f"Found {len(target_tables)} tables in PostgreSQL bronze schema to migrate.")

    # 2. Connect to MSSQL Master to dynamically find databases
    try:
        mssql_master_conn = get_mssql_connection("master")
        mssql_master_cursor = mssql_master_conn.cursor()
    except Exception as e:
        print(f"Failed to connect to MSSQL Server: {e}")
        sys.exit(1)

    # Dynamic Discovery: matches 'dbc01y21', 'dbc02y24', 'dbc02y26' etc.
    mssql_master_cursor.execute("SELECT name FROM sys.databases WHERE name LIKE 'dbc[0-9][0-9]y[0-9][0-9]'")
    databases = [row[0] for row in mssql_master_cursor.fetchall()]
    mssql_master_conn.close()

    if not databases:
        print("No databases found matching the 'dbc__y__' pattern!")
        sys.exit(1)

    print(f"Discovered {len(databases)} target MSSQL Databases: {', '.join(databases)}\n")

    # 3. Loop over each dynamically found database
    for db in databases:
        print(f"=====================================================")
        print(f"Starting pipeline for database: {db}")
        print(f"=====================================================")
        
        try:
            mssql_conn = get_mssql_connection(db)
            mssql_cursor = mssql_conn.cursor()
        except Exception as e:
            print(f"Skipping {db} due to connection error: {e}")
            continue

        for table in target_tables:
            # Check if table exists in MSSQL
            mssql_cursor.execute(f"SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = '{table}'")
            if mssql_cursor.fetchone()[0] == 0:
                print(f"  [SKIP] Table '{table}' not found in {db}.dbo")
                continue
            
            print(f"  [PROCESS] Migrating {db}.dbo.{table} -> bronze.{table}...")
            
            # Ensure _source_archive column exists in Bronze
            pg_cursor.execute(f"ALTER TABLE bronze.{table} ADD COLUMN IF NOT EXISTS _source_archive VARCHAR(20)")
            pg_conn.commit()
            
            # -------------------------------------------------------------
            # INCREMENTAL LOAD LOGIC (Future Hook)
            # -------------------------------------------------------------
            # For future incremental loads, query the MAX() date or ID from
            # Postgres and append a WHERE clause to the query below.
            # Example: qry += f" WHERE updated_at > '{last_sync}'"
            # -------------------------------------------------------------
            
            # Build a SELECT that CASTs VARCHAR/CHAR -> NVARCHAR for Arabic
            try:
                qry, col_names = build_select_query(mssql_cursor, table)
            except Exception as e:
                print(f"    Error building query for {table}: {e}")
                continue
            
            try:
                mssql_cursor.execute(qry)
            except pyodbc.Error as e:
                print(f"    Error reading table {table}: {e}")
                continue
            
            while True:
                rows = mssql_cursor.fetchmany(CHUNK_SIZE)
                if not rows:
                    break
                
                # Convert rows to an in-memory CSV for high-speed COPY loading
                csv_buffer = io.StringIO()
                writer = csv.writer(csv_buffer, delimiter='\t', quoting=csv.QUOTE_MINIMAL)
                
                for row in rows:
                    cleaned_row = []
                    for item in row:
                        if item is None:
                            cleaned_row.append(r'\N')  # PostgreSQL NULL in COPY
                        elif isinstance(item, str):
                            # Strip null bytes (0x00) that break PostgreSQL UTF-8
                            # Also remove tabs/newlines to prevent delimiter corruption
                            clean = item.replace('\x00', '')
                            clean = clean.replace('\t', ' ').replace('\n', ' ').replace('\r', '')
                            cleaned_row.append(clean)
                        elif isinstance(item, bytes):
                            # Decode rogue bytes, strip nulls
                            decoded = item.decode('utf-8', 'replace').replace('\x00', '')
                            cleaned_row.append(decoded)
                        else:
                            cleaned_row.append(str(item))
                    
                    # Add our source database archive tag to the end of the row
                    cleaned_row.append(db)
                    writer.writerow(cleaned_row)
                
                csv_buffer.seek(0)
                
                # Bulk COPY into Postgres (including our custom source tracking column)
                columns_str = f"({', '.join(col_names)}, _source_archive)"
                copy_query = f"COPY bronze.{table} {columns_str} FROM STDIN WITH NULL AS '\\N' DELIMITER '\t' CSV"
                try:
                    pg_cursor.copy_expert(copy_query, csv_buffer)
                    pg_conn.commit()
                except psycopg2.Error as e:
                    print(f"    PostgreSQL Error while copying {table}: {e}")
                    pg_conn.rollback()

        mssql_conn.close()
        print(f"Finished pipeline for {db}.\n")

    pg_cursor.close()
    pg_conn.close()
    print("All dynamic databases migrated successfully!")

if __name__ == "__main__":
    main()
