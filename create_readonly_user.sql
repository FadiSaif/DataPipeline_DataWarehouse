-- =============================================================================
-- CREATE READ-ONLY USER FOR GOLD SCHEMA
-- =============================================================================
-- Purpose:
--   Creates a dedicated read-only database user 'gold_analyst' with SELECT
--   permissions strictly on the 'gold' star-schema tables.
--   Access to 'bronze', 'silver', and 'public' is explicitly revoked/restricted.
-- =============================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'gold_analyst') THEN
        CREATE ROLE gold_analyst WITH LOGIN PASSWORD 'gold_analyst_2026';
    ELSE
        ALTER ROLE gold_analyst WITH LOGIN PASSWORD 'gold_analyst_2026';
    END IF;
END
$$;

-- 1. Database Connection Privilege
GRANT CONNECT ON DATABASE "sales_DataWarehouse" TO gold_analyst;

-- 2. Gold Schema Usage & Table Access
GRANT USAGE ON SCHEMA gold TO gold_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA gold TO gold_analyst;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA gold TO gold_analyst;

-- Automatically grant SELECT on any future tables/views added to gold
ALTER DEFAULT PRIVILEGES IN SCHEMA gold 
    GRANT SELECT ON TABLES TO gold_analyst;

-- 3. Security Boundary: Explicitly deny access to staging/transform layers
REVOKE ALL ON SCHEMA bronze FROM gold_analyst;
REVOKE ALL ON SCHEMA silver FROM gold_analyst;

