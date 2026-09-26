# 🚗 Automotive Sales Data Warehouse & ELT Pipeline

A production-grade, enterprise Data Warehouse and ELT (Extract, Load, Transform) data pipeline built on **PostgreSQL** using the **Medallion Architecture (Bronze ➔ Silver ➔ Gold)**. 

The project consolidates and models multi-year automotive spare parts sales data from legacy Microsoft SQL Server ERP systems into a business-ready **Star Schema** with normalized SAR (Saudi Riyal) pricing, advanced vehicle part categorization, customer segmentation, and market basket analytics.

---

## 🏗️ Architecture Overview

```mermaid
flowchart LR
    subgraph Source [Legacy ERP Systems]
        MSSQL[(MS SQL Server\nYearly ERP DBs)]
    end

    subgraph Bronze [Bronze Layer - Raw Storage]
        B[(bronze.*\nRaw Tables)]
    end

    subgraph Silver [Silver Layer - Cleaned & Conformed]
        S[(silver.*\nRenamed Tables\nPK/FK Constraints\nDeduplicated\nEnriched Catalog)]
    end

    subgraph Gold [Gold Layer - Dimensional Model]
        G[(gold.fact_sales\ngold.dim_* Tables\nStar Schema\nSAR Normalized)]
    end

    MSSQL -->|Python / Chunked Ingestion| B
    B -->|SQL ELT & Semantic Renaming| S
    S -->|Product Classification & Dimensional Modeling| G
```

---

## 📑 Medallion Architecture Details

### 🥉 1. Bronze Layer (Raw Ingestion)
* **Purpose**: Ingests raw, unaltered tables from historical SQL Server ERP instances (`dbc01y21` – `dbc02y25`).
* **Technology**: Python (`pyodbc` + `psycopg2` batch streaming) / `pgloader`.
* **Key Scripts**:
  * [`01. bronze_layer/ingest_mssql_to_postgres.py`](01.%20bronze_layer/ingest_mssql_to_postgres.py): Memory-efficient chunked batch streamer.
  * [`01. bronze_layer/bronze_layer_ddl.sql`](01.%20bronze_layer/bronze_layer_ddl.sql): DDL for raw staging tables.

### 🥈 2. Silver Layer (Cleaned, Conformed & Enriched)
* **Purpose**: Applies semantic snake_case naming conventions, resolves duplicates, standardizes data types, enforces native ERP relational constraints, and performs in-place NLP catalog enrichment.
* **Key Features**:
  * Systematic column and table renaming across 54+ entities mapped via [`rename_map.json`](rename_map.json).
  * `DISTINCT ON` deduplication preserving the latest archive snapshots.
  * Native ERP Primary Key and Foreign Key constraints (applied as `NOT VALID` where appropriate to accommodate legacy orphaned rows).
  * **Product Catalog NLP / Text Classification**: Over 22,000 spare parts parsed by Arabic description and OEM part numbering conventions to classify:
    * **Vehicle Make & Model** (`vehicle_make_model`: e.g. *Hyundai Elantra, Sonata, Accent, Tucson, Santa Fe, Kia Soul, Rio, Optima/K5...*)
    * **Origin / Quality** (`origin_quality`: *Genuine OEM, Korean [K], Chinese [C], Other*)
    * **Unified Part Category** (`part_category`: *Control Arm, Brake Pads, Sway Bar Link, Shock Absorbers...* unifying Left/Right and Front/Rear counterparts)
    * **Vehicle System** (`vehicle_system`: *Suspension & Steering, Brake System, Engine & Mechanical, Cooling, Electrical, HVAC, Transmission, Body...*)
* **Key Scripts**:
  * [`02. silver_layer/silver_layer_ddl.sql`](02.%20silver_layer/silver_layer_ddl.sql)
  * [`02. silver_layer/01_rename_and_load_silver.sql`](02.%20silver_layer/01_rename_and_load_silver.sql)
  * [`02. silver_layer/02_native_silver_constraints.sql`](02.%20silver_layer/02_native_silver_constraints.sql)
  * [`02. silver_layer/03_enrich_stock_item.sql`](02.%20silver_layer/03_enrich_stock_item.sql)

### 🥇 3. Gold Layer (Star Schema & Business Analytics)
* **Purpose**: Pure Kimball-style Dimensional Model optimized for BI tools (Power BI, Tableau) and high-performance SQL analytics. Sourced directly from enriched Silver tables with zero hardcoded transformation logic.
* **Currency Normalization**: All prices, costs, and discounts are standardized to **SAR (Saudi Riyal)**:
  $$\text{Price}_{\text{SAR}} = \text{Price} \times \begin{cases} 0.002421307506053 & \text{if Currency} = \text{'01' (YER)} \\ 3.8 & \text{if Currency} = \text{'02' (USD)} \\ 1.0 & \text{if Currency} = \text{'03' (SAR) or Local} \end{cases}$$
* **Key Scripts**:
  * [`03. gold_layer/gold_layer_ddl.sql`](03.%20gold_layer/gold_layer_ddl.sql)
  * [`03. gold_layer/gold_layer_load.sql`](03.%20gold_layer/gold_layer_load.sql)

---

## 🌟 Gold Layer Star Schema Design

```mermaid
erDiagram
    fact_sales }o--|| dim_sales_order : "sales_order_key"
    fact_sales }o--|| dim_date : "date_key"
    fact_sales }o--|| dim_product : "product_key"
    fact_sales }o--|| dim_customer : "customer_key"
    fact_sales }o--|| dim_sales_center : "sales_center_key"
    fact_sales }o--|| dim_currency : "currency_key"

    dim_sales_order {
        INT sales_order_key PK
        VARCHAR company_id
        VARCHAR invoice_type
        NUMERIC reference_number
        NUMERIC line_item_count
        VARCHAR salesman_code
        NUMERIC header_discount_pct
        NUMERIC vat_percent
        BOOLEAN is_posted
        BOOLEAN is_released
        BOOLEAN is_cheque
        VARCHAR payment_mode
        INT due_date_key
    }

    dim_date {
        INT date_key PK
        DATE full_date
        SMALLINT year
        SMALLINT quarter
        SMALLINT month
        SMALLINT day
        VARCHAR month_name
        VARCHAR day_name
        BOOLEAN is_weekend
    }

    dim_product {
        INT product_key PK
        VARCHAR item_code
        VARCHAR item_name
        VARCHAR item_name_alt
        VARCHAR vehicle_make_model "Vehicle Model"
        VARCHAR origin_quality "Part Origin"
        VARCHAR part_category "Part Category"
        VARCHAR vehicle_system "Vehicle System"
        VARCHAR item_type
    }

    dim_customer {
        INT customer_key PK
        VARCHAR customer_code
        VARCHAR customer_name
    }

    dim_currency {
        INT currency_key PK
        VARCHAR currency_code
        VARCHAR currency_name
        VARCHAR currency_symbol
        VARCHAR standard_iso_code
        NUMERIC sar_exchange_rate
    }

    dim_sales_center {
        INT sales_center_key PK
        VARCHAR sales_center_code
        VARCHAR company_id
    }

    fact_sales {
        INT fact_sales_key PK
        INT sales_order_key FK
        INT date_key FK
        INT product_key FK
        INT customer_key FK
        INT sales_center_key FK
        INT currency_key FK
        NUMERIC folio
        DOUBLE quantity
        NUMERIC unit_price_sar
        NUMERIC unit_cost_sar
        DOUBLE discount_pct
        NUMERIC discount_amount_sar
        NUMERIC net_price_sar
        NUMERIC line_total_sar
        NUMERIC vat_amount_sar
        DOUBLE returned_quantity
    }
```

---

## 📊 Summary of Entities & Metrics

| Table | Layer | Role / Grain | Row Count | Description |
|---|---|---|---:|---|
| `gold.dim_date` | Gold | Date Dimension | 2,922 | Calendar dates from 2023-01-01 to 2030-12-31 |
| `gold.dim_product` | Gold | Product Dimension | 22,282 | Auto parts with Vehicle Model, Origin, Category & System |
| `gold.dim_customer` | Gold | Customer Dimension | 66 | Customer master records with business keys |
| `gold.dim_currency` | Gold | Currency Dimension | 4 | YER, USD, SAR, RMP with pegged SAR conversion rates |
| `gold.dim_sales_center` | Gold | Branch Dimension | 1 | Sales centers and operating company units |
| `gold.dim_sales_order` | Gold | Invoice Header Dimension | 1,894 | Order metadata, salesman, status, payment mode, basket size |
| `gold.fact_sales` | Gold | Line-Item Fact Table | 18,028 | Sales invoice line items with full SAR normalization |

---

## 📈 Sample Business & Analytics Queries

### 1. Market Basket & Payment Method Analysis
```sql
SELECT 
    dso.payment_mode,
    COUNT(DISTINCT f.sales_order_key)                                                 AS total_orders,
    COUNT(f.fact_sales_key)                                                           AS total_items_sold,
    ROUND((COUNT(f.fact_sales_key)::numeric / COUNT(DISTINCT f.sales_order_key)), 2) AS avg_items_per_basket,
    ROUND((SUM(f.line_total_sar) / COUNT(DISTINCT f.sales_order_key)), 2)             AS avg_basket_value_sar,
    ROUND(SUM(f.line_total_sar), 2)                                                   AS total_revenue_sar
FROM gold.fact_sales f
JOIN gold.dim_sales_order dso ON f.sales_order_key = dso.sales_order_key
GROUP BY dso.payment_mode
ORDER BY total_revenue_sar DESC;
```

### 2. Top Revenue by Vehicle Make & Model
```sql
SELECT 
    dp.vehicle_make_model AS vehicle_model,
    COUNT(f.fact_sales_key) AS items_sold,
    ROUND(SUM(f.line_total_sar), 2) AS total_revenue_sar,
    ROUND(AVG(f.unit_price_sar), 2) AS avg_unit_price_sar
FROM gold.fact_sales f
JOIN gold.dim_product dp ON f.product_key = dp.product_key
GROUP BY dp.vehicle_make_model
ORDER BY total_revenue_sar DESC
LIMIT 10;
```

### 3. Sales Volume & Margin by Part Origin (Genuine vs. Aftermarket)
```sql
SELECT 
    dp.origin_quality AS origin,
    COUNT(f.fact_sales_key) AS line_items_sold,
    ROUND(SUM(f.line_total_sar), 2) AS total_revenue_sar,
    ROUND(AVG(f.unit_price_sar), 2) AS avg_price_sar
FROM gold.fact_sales f
JOIN gold.dim_product dp ON f.product_key = dp.product_key
GROUP BY dp.origin_quality
ORDER BY total_revenue_sar DESC;
```

---

## 🚀 Unified Pipeline Orchestration

The entire Bronze → Silver → Gold ETL workflow is orchestrated seamlessly with a single Python command with built-in transaction management, timing, and 14 automated verification checks.

### One-Command Execution
```bash
# Run complete end-to-end pipeline (auto-skips bronze if MSSQL is unreachable)
python run_pipeline.py

# Run transformations on existing bronze data (Silver -> Gold)
python run_pipeline.py --skip-bronze

# Rebuild only the Silver layer (DDL, Load, Constraints, Enrichment)
python run_pipeline.py --silver-only

# Rebuild only the Gold Dimensional layer (DDL, Load)
python run_pipeline.py --gold-only

# Inspect execution plan without modifying database
python run_pipeline.py --dry-run
```

### Pipeline Execution Order & Verification
1. **Create Schemas**: Idempotent setup for `bronze`, `silver`, and `gold`.
2. **Bronze DDL**: Staging table definitions.
3. **Bronze Ingest**: Stream legacy SQL Server tables to PostgreSQL (auto-skipped if MSSQL is offline).
4. **Silver DDL**: Clean table structures.
5. **Silver Load & Rename**: `01_rename_and_load_silver.sql` deduplicates raw data and applies snake_case schemas.
6. **Silver Constraints**: `02_native_silver_constraints.sql` enforces Primary and Foreign Keys.
7. **Silver Enrichment**: `03_enrich_stock_item.sql` classifies all 22k+ items with Vehicle Model, Origin, Category, and Vehicle System.
8. **Gold DDL**: `gold_layer_ddl.sql` sets up the Star Schema with foreign keys.
9. **Gold Load**: `gold_layer_load.sql` sources directly from enriched Silver tables, converting all financial metrics to SAR.
10. **Automated Verification**: Runs 14 automated integrity and row-count checks (0 nulls, 0 orphan facts).

---

## 📂 Repository Structure

```
.
├── run_pipeline.py                     # Single-command pipeline orchestrator
├── create_database.sql                 # Database creation
├── create_schema.sql                   # Medallion schemas setup (bronze, silver, gold)
├── rename_map.json                     # Semantic renaming mappings for 54+ tables
├── 01. bronze_layer/
│   ├── bronze_layer_ddl.sql            # Raw staging DDL
│   ├── ingest_mssql_to_postgres.py     # Batch data extractor from SQL Server
│   └── truncate_bronze.sql             # Staging cleanup
├── 02. silver_layer/
│   ├── silver_layer_ddl.sql            # Silver layer DDL
│   ├── 01_rename_and_load_silver.sql   # Silver ELT transform & load script
│   ├── 02_native_silver_constraints.sql# Native ERP PK/FK constraint definitions
│   └── 03_enrich_stock_item.sql        # NLP & regex product classification enrichment
└── 03. gold_layer/
    ├── gold_layer_ddl.sql              # Star Schema DDL (Option 3: Header Dim + Line Fact)
    ├── gold_layer_load.sql             # Automated Gold ELT loader (reads from enriched Silver)
    ├── item_basket.sql                 # Market basket analytics
    └── pareto_analysis.sql             # ABC/Pareto 80/20 sales analysis
```

---

## 📄 License

This project and its pipeline source code are proprietary to **Fadi Saif**. All underlying business data and transaction records are proprietary and confidential to **Hyundai Bin Abdulwali**. See the [LICENSE](LICENSE) file for details.
