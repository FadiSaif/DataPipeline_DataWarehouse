#!/bin/bash

# Define your MSSQL databases
DATABASES=("dbc01y21" "dbc02y23" "dbc02y24" "dbc02y25")

# Define your connection credentials
MSSQL_IP="<Your-Windows-IP>"
MSSQL_USER="sa"
MSSQL_PASS="password"

PG_IP="<Your-Windows-IP>"
PG_USER="postgres"
PG_PASS="password"
PG_DB="sales_DataWarehouse"

# Loop through each database
for DB in "${DATABASES[@]}"; do
    echo "====================================================="
    echo "Starting migration for: $DB"
    echo "====================================================="

    # Dynamically generate a pgloader configuration file
    cat <<EOF > current_load.cfg
LOAD DATABASE
    FROM mssql://$MSSQL_USER:$MSSQL_PASS@$MSSQL_IP/$DB
    INTO postgresql://$PG_USER:$PG_PASS@$PG_IP/$PG_DB

WITH data only,               -- Strictly insert data, no DDL
     truncate off,            -- DO NOT wipe the tables before loading
     create tables = false,   -- Force pgloader to trust your existing tables
     create indexes = false,  -- Do not try to recreate indexes
     reset sequences = false, -- Do not touch auto-increment counters
     batch rows = 5000,
     prefetch rows = 5000

-- This acts as a routing instruction, telling pgloader to map 
-- the source 'dbo' data to your target 'bronze' schema.
ALTER SCHEMA 'dbo' RENAME TO 'bronze'
;
EOF

    # Run pgloader using the generated config file
    pgloader current_load.cfg

    echo "Finished migrating $DB."
    echo ""
done

# Clean up the temporary config file
rm current_load.cfg
echo "All databases migrated successfully!"