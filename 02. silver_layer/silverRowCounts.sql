DO $$ 
DECLARE 
    r RECORD;
    row_count BIGINT;
BEGIN
    -- Create a temporary table to store results
    CREATE TEMP TABLE IF NOT EXISTS silver_counts (
        table_name TEXT,
        exact_row_count BIGINT
    ) ON COMMIT DROP;

    -- Loop through all tables in the 'silver' schema
    FOR r IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'silver' 
          AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('SELECT count(*) FROM silver.%I', r.table_name) INTO row_count;
        INSERT INTO silver_counts (table_name, exact_row_count) VALUES (r.table_name, row_count);
    END LOOP;
END $$;

-- View the results
SELECT * FROM silver_counts 
ORDER BY exact_row_count DESC;