"""
=============================================================================
 run_pipeline.py -- Medallion Data Pipeline Orchestrator

 Executes the full Bronze -> Silver -> Gold ETL pipeline in dependency order.

 Usage:
   python run_pipeline.py                  # Full pipeline (auto-skip bronze if MSSQL offline)
   python run_pipeline.py --skip-bronze    # Skip bronze DDL + ingest
   python run_pipeline.py --silver-only    # Rebuild silver only (steps 4-7)
   python run_pipeline.py --gold-only      # Rebuild gold only (steps 8-9)
   python run_pipeline.py --dry-run        # Print plan without executing

 Pipeline Steps:
   1. Create schemas (bronze, silver, gold)
   2. Bronze DDL (create/reset bronze tables)
   3. Bronze Ingest (MSSQL → PostgreSQL)
   4. Silver DDL (create silver tables from bronze DDL)
   5. Silver Load & Rename (01_rename_and_load_silver.sql)
   6. Silver Constraints (02_native_silver_constraints.sql)
   7. Silver Enrichment (03_enrich_stock_item.sql)
   8. Gold DDL (create gold star schema)
   9. Gold Load (populate dimensions + fact_sales)
=============================================================================
"""

import argparse
import logging
import os
import sys
import time
from datetime import datetime
from pathlib import Path

# Force UTF-8 output on Windows (avoids cp1252 encoding errors)
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

import psycopg2

# =============================================================================
# Configuration
# =============================================================================
PROJECT_ROOT = Path(__file__).resolve().parent

PG_CONFIG = {
    "host": os.getenv("PG_HOST", "localhost"),
    "port": int(os.getenv("PG_PORT", 5432)),
    "user": os.getenv("PG_USER", "postgres"),
    "password": os.getenv("PG_PASSWORD", "postgres"),
    "dbname": os.getenv("PG_DB", "sales_DataWarehouse"),
}

MSSQL_CONFIG = {
    "host": os.getenv("MSSQL_HOST", "localhost"),
    "user": os.getenv("MSSQL_USER", "sa"),
    "password": os.getenv("MSSQL_PASSWORD", "password"),
}

# SQL file paths relative to PROJECT_ROOT
SQL_FILES = {
    "create_schema":        "create_schema.sql",
    "bronze_ddl":           "01. bronze_layer/bronze_layer_ddl.sql",
    "silver_ddl":           "02. silver_layer/silver_layer_ddl.sql",
    "silver_load":          "01. bronze_layer/bronze_layer_ddl.sql",  # placeholder — see note
    "silver_rename_load":   "02. silver_layer/01_rename_and_load_silver.sql",
    "silver_constraints":   "02. silver_layer/02_native_silver_constraints.sql",
    "silver_enrichment":    "02. silver_layer/03_enrich_stock_item.sql",
    "gold_ddl":             "03. gold_layer/gold_layer_ddl.sql",
    "gold_load":            "03. gold_layer/gold_layer_load.sql",
}

# Bronze ingestion Python module
BRONZE_INGEST_SCRIPT = PROJECT_ROOT / "01. bronze_layer" / "ingest_mssql_to_postgres.py"

# Logs directory
LOGS_DIR = PROJECT_ROOT / "logs"

# =============================================================================
# Logging Setup
# =============================================================================
def setup_logging():
    """Configure dual logging: console + timestamped log file."""
    LOGS_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = LOGS_DIR / f"pipeline_run_{timestamp}.log"

    formatter = logging.Formatter(
        "%(asctime)s  [%(levelname)-7s]  %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)

    # File handler
    file_handler = logging.FileHandler(log_file, encoding="utf-8")
    file_handler.setFormatter(formatter)

    logger = logging.getLogger("pipeline")
    logger.setLevel(logging.DEBUG)
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

    return logger, log_file


# =============================================================================
# Database Helpers
# =============================================================================
def get_pg_connection(autocommit=False):
    """Create a PostgreSQL connection."""
    conn = psycopg2.connect(**PG_CONFIG)
    if autocommit:
        conn.autocommit = True
    return conn


def execute_sql_file(conn, sql_path, logger):
    """Execute a SQL file within a transaction. Returns affected row count."""
    full_path = PROJECT_ROOT / sql_path
    if not full_path.exists():
        raise FileNotFoundError(f"SQL file not found: {full_path}")

    with open(full_path, "r", encoding="utf-8") as f:
        sql = f.read()

    cursor = conn.cursor()
    try:
        cursor.execute(sql)
        conn.commit()
        row_count = cursor.rowcount if cursor.rowcount >= 0 else 0
        logger.info(f"  Executed: {sql_path} ({row_count} rows affected)")
        return row_count
    except Exception as e:
        conn.rollback()
        raise RuntimeError(f"SQL execution failed for {sql_path}: {e}") from e
    finally:
        cursor.close()


def get_row_count(conn, schema, table):
    """Get row count for a table."""
    cursor = conn.cursor()
    try:
        cursor.execute(f"SELECT COUNT(*) FROM {schema}.{table}")
        return cursor.fetchone()[0]
    except Exception:
        return -1
    finally:
        cursor.close()


def check_null_count(conn, schema, table, column):
    """Count NULL values in a column."""
    cursor = conn.cursor()
    try:
        cursor.execute(f"SELECT COUNT(*) FROM {schema}.{table} WHERE {column} IS NULL")
        return cursor.fetchone()[0]
    except Exception:
        return -1
    finally:
        cursor.close()


def check_orphan_count(conn, fact_table, fact_fk, dim_table, dim_pk):
    """Count orphaned rows in a fact table (FK with no matching PK in dimension)."""
    cursor = conn.cursor()
    try:
        cursor.execute(f"""
            SELECT COUNT(*)
            FROM {fact_table} f
            LEFT JOIN {dim_table} d ON f.{fact_fk} = d.{dim_pk}
            WHERE d.{dim_pk} IS NULL
        """)
        return cursor.fetchone()[0]
    except Exception:
        return -1
    finally:
        cursor.close()


# =============================================================================
# MSSQL Connectivity Check
# =============================================================================
def check_mssql_available(logger):
    """Check if MSSQL server is reachable. Returns True/False."""
    try:
        import socket
        sock = socket.create_connection(
            (MSSQL_CONFIG["host"], 1433), timeout=5
        )
        sock.close()
        logger.info(f"  MSSQL server at {MSSQL_CONFIG['host']}:1433 is reachable")
        return True
    except (OSError, TimeoutError):
        logger.warning(f"  MSSQL server at {MSSQL_CONFIG['host']}:1433 is NOT reachable")
        return False


# =============================================================================
# Bronze Ingestion (calls external script)
# =============================================================================
def run_bronze_ingest(logger):
    """Run the bronze ingestion script (MSSQL → PostgreSQL)."""
    import subprocess
    result = subprocess.run(
        [sys.executable, str(BRONZE_INGEST_SCRIPT)],
        capture_output=True, text=True, cwd=str(PROJECT_ROOT)
    )
    if result.returncode != 0:
        logger.error(f"  Bronze ingest failed:\n{result.stderr}")
        raise RuntimeError("Bronze ingestion failed")
    logger.info(f"  Bronze ingest completed successfully")
    if result.stdout:
        for line in result.stdout.strip().split("\n")[-5:]:
            logger.info(f"    {line}")


# =============================================================================
# Pipeline Steps
# =============================================================================
def step_create_schemas(conn, logger):
    """Step 1: Create bronze, silver, gold schemas."""
    execute_sql_file(conn, SQL_FILES["create_schema"], logger)


def step_bronze_ddl(conn, logger):
    """Step 2: Create/reset bronze tables."""
    execute_sql_file(conn, SQL_FILES["bronze_ddl"], logger)


def step_bronze_ingest(logger):
    """Step 3: MSSQL → PostgreSQL bronze ingestion."""
    if not check_mssql_available(logger):
        logger.warning("  MSSQL server offline — SKIPPING bronze ingestion")
        return False
    try:
        import pyodbc  # noqa: F401 — verify pyodbc is available
    except ImportError:
        logger.warning("  pyodbc not installed — SKIPPING bronze ingestion")
        return False
    run_bronze_ingest(logger)
    return True


def step_silver_ddl(conn, logger):
    """Step 4: Create silver tables (same structure as bronze)."""
    cursor = conn.cursor()
    cursor.execute("DROP SCHEMA IF EXISTS silver CASCADE; CREATE SCHEMA silver;")
    conn.commit()
    cursor.close()
    execute_sql_file(conn, SQL_FILES["silver_ddl"], logger)


def step_silver_load(conn, logger):
    """Step 5: Load + rename silver tables from bronze."""
    execute_sql_file(conn, SQL_FILES["silver_rename_load"], logger)


def step_silver_constraints(conn, logger):
    """Step 6: Apply primary keys and foreign keys."""
    execute_sql_file(conn, SQL_FILES["silver_constraints"], logger)


def step_silver_enrichment(conn, logger):
    """Step 7: Enrich silver.stock_item with classification columns."""
    execute_sql_file(conn, SQL_FILES["silver_enrichment"], logger)


def step_gold_ddl(conn, logger):
    """Step 8: Create gold star schema tables."""
    execute_sql_file(conn, SQL_FILES["gold_ddl"], logger)


def step_gold_load(conn, logger):
    """Step 9: Populate gold dimensions and fact table."""
    execute_sql_file(conn, SQL_FILES["gold_load"], logger)


# =============================================================================
# Verification
# =============================================================================
def run_verification(conn, logger):
    """Post-pipeline verification checks."""
    logger.info("")
    logger.info("=" * 70)
    logger.info("VERIFICATION CHECKS")
    logger.info("=" * 70)

    checks_passed = 0
    checks_failed = 0

    def check(description, actual, expected, comparator="=="):
        nonlocal checks_passed, checks_failed
        if comparator == "==":
            passed = actual == expected
        elif comparator == ">=":
            passed = actual >= expected
        else:
            passed = actual == expected

        status = "[PASS]" if passed else "[FAIL]"
        logger.info(f"  {status:6s}  {description}: {actual} (expected {comparator} {expected})")
        if passed:
            checks_passed += 1
        else:
            checks_failed += 1

    # Silver layer checks
    si_count = get_row_count(conn, "silver", "stock_item")
    check("silver.stock_item row count", si_count, 22282)

    null_vmm = check_null_count(conn, "silver", "stock_item", "vehicle_make_model")
    check("silver.stock_item vehicle_make_model NULLs", null_vmm, 0)

    null_oq = check_null_count(conn, "silver", "stock_item", "origin_quality")
    check("silver.stock_item origin_quality NULLs", null_oq, 0)

    null_pc = check_null_count(conn, "silver", "stock_item", "part_category")
    check("silver.stock_item part_category NULLs", null_pc, 0)

    null_vs = check_null_count(conn, "silver", "stock_item", "vehicle_system")
    check("silver.stock_item vehicle_system NULLs", null_vs, 0)

    # Gold layer checks
    dp_count = get_row_count(conn, "gold", "dim_product")
    check("gold.dim_product row count", dp_count, si_count)

    dd_count = get_row_count(conn, "gold", "dim_date")
    check("gold.dim_date row count", dd_count, 2922)

    dc_count = get_row_count(conn, "gold", "dim_customer")
    check("gold.dim_customer row count", dc_count, 0, ">=")

    dso_count = get_row_count(conn, "gold", "dim_sales_order")
    check("gold.dim_sales_order row count", dso_count, 0, ">=")

    fs_count = get_row_count(conn, "gold", "fact_sales")
    check("gold.fact_sales row count", fs_count, 18028)

    # Referential integrity
    orphan_product = check_orphan_count(
        conn, "gold.fact_sales", "product_key", "gold.dim_product", "product_key"
    )
    check("Orphaned fact_sales → dim_product", orphan_product, 0)

    orphan_customer = check_orphan_count(
        conn, "gold.fact_sales", "customer_key", "gold.dim_customer", "customer_key"
    )
    check("Orphaned fact_sales → dim_customer", orphan_customer, 0)

    orphan_currency = check_orphan_count(
        conn, "gold.fact_sales", "currency_key", "gold.dim_currency", "currency_key"
    )
    check("Orphaned fact_sales → dim_currency", orphan_currency, 0)

    orphan_order = check_orphan_count(
        conn, "gold.fact_sales", "sales_order_key", "gold.dim_sales_order", "sales_order_key"
    )
    check("Orphaned fact_sales → dim_sales_order", orphan_order, 0)

    logger.info("")
    logger.info(f"  Results: {checks_passed} passed, {checks_failed} failed")
    return checks_failed == 0


# =============================================================================
# Main Pipeline Execution
# =============================================================================
def main():
    parser = argparse.ArgumentParser(
        description="Medallion Data Pipeline Orchestrator — Bronze → Silver → Gold"
    )
    parser.add_argument(
        "--skip-bronze", action="store_true",
        help="Skip bronze DDL and ingestion (steps 2-3)"
    )
    parser.add_argument(
        "--silver-only", action="store_true",
        help="Run silver layer only (steps 4-7)"
    )
    parser.add_argument(
        "--gold-only", action="store_true",
        help="Run gold layer only (steps 8-9)"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Print the execution plan without running"
    )
    args = parser.parse_args()

    logger, log_file = setup_logging()

    # -------------------------------------------------------------------------
    # Define all pipeline steps
    # -------------------------------------------------------------------------
    all_steps = [
        {"num": 1, "name": "Create Schemas",        "layer": "infra",  "fn": "step_create_schemas",    "uses_conn": True},
        {"num": 2, "name": "Bronze DDL",             "layer": "bronze", "fn": "step_bronze_ddl",        "uses_conn": True},
        {"num": 3, "name": "Bronze Ingest (MSSQL)",  "layer": "bronze", "fn": "step_bronze_ingest",     "uses_conn": False},
        {"num": 4, "name": "Silver DDL",             "layer": "silver", "fn": "step_silver_ddl",        "uses_conn": True},
        {"num": 5, "name": "Silver Load & Rename",   "layer": "silver", "fn": "step_silver_load",       "uses_conn": True},
        {"num": 6, "name": "Silver Constraints",     "layer": "silver", "fn": "step_silver_constraints", "uses_conn": True},
        {"num": 7, "name": "Silver Enrichment",      "layer": "silver", "fn": "step_silver_enrichment",  "uses_conn": True},
        {"num": 8, "name": "Gold DDL",               "layer": "gold",   "fn": "step_gold_ddl",          "uses_conn": True},
        {"num": 9, "name": "Gold Load",              "layer": "gold",   "fn": "step_gold_load",         "uses_conn": True},
    ]

    # -------------------------------------------------------------------------
    # Determine which steps to run based on CLI flags
    # -------------------------------------------------------------------------
    if args.gold_only:
        steps = [s for s in all_steps if s["layer"] == "gold"]
    elif args.silver_only:
        steps = [s for s in all_steps if s["layer"] == "silver"]
    elif args.skip_bronze:
        steps = [s for s in all_steps if s["layer"] != "bronze"]
    else:
        steps = all_steps

    # -------------------------------------------------------------------------
    # Print plan header
    # -------------------------------------------------------------------------
    logger.info("=" * 70)
    logger.info("  MEDALLION DATA PIPELINE ORCHESTRATOR")
    logger.info(f"  Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    logger.info(f"  Log file: {log_file}")
    logger.info(f"  Database: {PG_CONFIG['dbname']} @ {PG_CONFIG['host']}:{PG_CONFIG['port']}")
    logger.info("=" * 70)
    logger.info("")

    if args.dry_run:
        logger.info("DRY RUN -- Execution plan:")
        for s in steps:
            logger.info(f"  Step {s['num']}: {s['name']}")
        logger.info("")
        logger.info("No changes were made. Remove --dry-run to execute.")
        return

    # -------------------------------------------------------------------------
    # Execute pipeline
    # -------------------------------------------------------------------------
    pipeline_start = time.time()
    step_timings = []
    conn = None

    try:
        conn = get_pg_connection()
        logger.info(f"Connected to PostgreSQL: {PG_CONFIG['dbname']}")
        logger.info("")

        for step in steps:
            step_start = time.time()
            logger.info(f"{'=' * 70}")
            logger.info(f"Step {step['num']}: {step['name']}")
            logger.info(f"{'=' * 70}")

            fn = globals()[step["fn"]]

            try:
                if step["uses_conn"]:
                    fn(conn, logger)
                else:
                    fn(logger)

                elapsed = time.time() - step_start
                step_timings.append((step["name"], elapsed, "OK"))
                logger.info(f"  Completed in {elapsed:.1f}s")
                logger.info("")

            except Exception as e:
                elapsed = time.time() - step_start
                step_timings.append((step["name"], elapsed, "FAILED"))
                logger.error(f"  FAILED after {elapsed:.1f}s: {e}")
                logger.error("")
                logger.error("Pipeline ABORTED due to error above.")
                sys.exit(1)

        # Run verification
        logger.info("")
        all_passed = run_verification(conn, logger)

        # Print summary
        total_elapsed = time.time() - pipeline_start
        logger.info("")
        logger.info("=" * 70)
        logger.info("  PIPELINE EXECUTION SUMMARY")
        logger.info("=" * 70)
        for name, elapsed, status in step_timings:
            logger.info(f"  {status:>6s}  {name:<30s}  {elapsed:>7.1f}s")
        logger.info(f"{'=' * 70}")
        logger.info(f"  Total elapsed: {total_elapsed:.1f}s")
        logger.info(f"  Verification:  {'ALL PASSED' if all_passed else 'SOME CHECKS FAILED'}")
        logger.info("=" * 70)

        if not all_passed:
            sys.exit(1)

    except psycopg2.Error as e:
        logger.error(f"Database connection error: {e}")
        sys.exit(1)
    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    main()
