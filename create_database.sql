/*
====================================================
CREATE DATABASE
====================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. All data in 
	the existing database will be permanently deleted. Proceed with caution and ensure you have 
	proper backups before running the script.

	Make sure to highlight-run the Drop Database line first in postgreSQL in order for the script
	to run as intended.
*/

-- Step 1: Drop and create the database
DROP DATABASE IF EXISTS "sales_DataWarehouse" WITH (FORCE); 
GO

CREATE DATABASE "sales_DataWarehouse"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

