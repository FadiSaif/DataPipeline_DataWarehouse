# 01. Data Pipeline - Data Warehouse
This repository holds all files and folders to create a data pipeline for transferring data from live SQL Server database to PostgreSQL data warehouse using ELT operation. The choice of ELT instead of ETL is performance-related as continuous transformation on live data before loading can hold the live database back in terms of performance, especially with many simultaneous users reading from and writing to the database.

1. Environment Overview

The architecture involves a Microsoft SQL Server (Source) and a PostgreSQL (Target) instance. To automate the ingestion, we utilize WSL2 (Ubuntu) to run pgloader scripts.
Component	Technology	Role
Source RDBMS	MS SQL Server	Production Sales Data (dbc01y21 – dbc02y25)
Target RDBMS	PostgreSQL 16+	Central Data Warehouse
Orchestration	Bash / pgloader	Automated Batch Migration
Network	WSL2 Bridge	Cross-environment communication
2. Target Database & Medallion Schema Setup

First, initialize the Data Warehouse and establish the Medallion architecture (Bronze, Silver, Gold).
Create the Data Warehouse

Connect to your PostgreSQL instance and execute:
SQL

-- Create the central repository
CREATE DATABASE "sales_DataWarehouse";

Establish Medallion Schemas

The Medallion architecture organizes data by its state of "cleanliness."
SQL

-- Connect to sales_DataWarehouse and run:
CREATE SCHEMA bronze; -- Raw, unaltered data from source
CREATE SCHEMA silver; -- Cleaned, filtered, and joined data
CREATE SCHEMA gold;   -- Aggregated, business-level metrics (Reporting)

3. Source (MSSQL) Configuration

To allow pgloader to extract data, SQL Server must be configured for remote TCP/IP access and SQL Authentication.
Enable TCP/IP & Static Port

    Open SQL Server Configuration Manager.

    Navigate to Protocols for MSSQLSERVER > TCP/IP > Enable.

    Under IP Addresses tab, go to IPAll:

        Clear TCP Dynamic Ports.

        Set TCP Port to 1433.

    Restart the SQL Server Service.

Security & Authentication

Ensure Mixed Mode Authentication is enabled in SSMS.

    Create or enable the sa user.

    Set a strong password.

    Ensure the user has db_datareader permissions on all source databases.

4. Network Bridging (WSL2 to Windows Host)

Since the migration script runs in WSL2, you must punch a hole through the Windows Firewall and identify the host IP.
Identify the Bridge IP

In the WSL terminal, find the host gateway:
Bash

ip route show | grep default | awk '{print $3}'
# Note the result (e.g., 172.24.128.1)

Open Firewall Ports

Run this in PowerShell (Administrator) to allow WSL to reach the databases:
PowerShell

New-NetFirewallRule -DisplayName "Allow DWH Migration" -Direction Inbound -LocalPort 5432, 1433 -Protocol TCP -Action Allow -Profile Any

5. Automated Migration Script

This Bash script loops through multiple yearly databases and appends them into the single PostgreSQL bronze schema.

Filename: migrate_bronze.sh
Bash

#!/bin/bash

# 1. Configuration
DATABASES=("dbc01y21" "dbc02y23" "dbc02y24" "dbc02y25")
HOST_IP="172.24.128.1" # Replace with your gateway IP

MSSQL_USER="sa"
MSSQL_PASS="YourPassword"

PG_USER="postgres"
PG_PASS="YourPassword"
PG_DB="sales_DataWarehouse"

# 2. Execution Loop
for DB in "${DATABASES[@]}"; do
    echo "Ingesting Raw Data: $DB..."

    cat <<EOF > current_load.cfg
LOAD DATABASE
    FROM mssql://$MSSQL_USER:$MSSQL_PASS@$HOST_IP/$DB
    INTO postgresql://$PG_USER:$PG_PASS@$HOST_IP/$PG_DB

WITH data only,
     batch rows = 5000,
     prefetch rows = 5000

ALTER SCHEMA 'dbo' RENAME TO 'bronze';
EOF

    pgloader current_load.cfg
done

# 3. Cleanup
rm current_load.cfg
echo "Bronze Layer Establishment Complete."

6. Verification & Validation

After running the script, verify the data integrity in the Bronze layer.
Row Count Validation

Run this in PostgreSQL to ensure all years have been consolidated:
SQL

SELECT 
    table_schema, 
    table_name, 
    reltuples::bigint AS estimated_row_count
FROM pg_catalog.pg_class c
JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'bronze'
AND c.relkind = 'r'
ORDER BY estimated_row_count DESC;

Connectivity Troubleshooting

If the migration fails, use nc (netcat) to test the pipes:

    Test Postgres: nc -vz 172.24.128.1 5432

    Test MSSQL: nc -vz 172.24.128.1 1433

References & Credible Sources

    PostgreSQL Documentation: CREATE SCHEMA

    Microsoft Learn: Configure SQL Server TCP/IP

    pgloader Documentation: MSSQL Ingestion
