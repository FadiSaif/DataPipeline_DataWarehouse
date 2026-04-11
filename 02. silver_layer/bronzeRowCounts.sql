DO $$ 
DECLARE 
    r RECORD;
    row_count BIGINT;
BEGIN
    -- Create a temporary table to store results
    CREATE TEMP TABLE IF NOT EXISTS bronze_counts (
        table_name TEXT,
        exact_row_count BIGINT
    ) ON COMMIT DROP;

    -- Loop through all tables in the 'bronze' schema
    FOR r IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'bronze' 
          AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('SELECT count(*) FROM bronze.%I', r.table_name) INTO row_count;
        INSERT INTO bronze_counts (table_name, exact_row_count) VALUES (r.table_name, row_count);
    END LOOP;
END $$;

-- View the results
SELECT * FROM bronze_counts ORDER BY exact_row_count DESC;