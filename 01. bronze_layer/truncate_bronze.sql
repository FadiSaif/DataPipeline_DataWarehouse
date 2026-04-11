DO $$ 
DECLARE 
    truncate_stmt text;
BEGIN 
    SELECT 'TRUNCATE TABLE ' || string_agg('bronze.' || quote_ident(tablename), ', ') || ' CASCADE;' 
    INTO truncate_stmt 
    FROM pg_tables 
    WHERE schemaname = 'bronze';
    
    IF truncate_stmt IS NOT NULL THEN 
        EXECUTE truncate_stmt; 
    END IF; 
END $$;
