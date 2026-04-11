-- Test for Header Table
SELECT COUNT(*) AS duplicate_sales_header_pk_count
FROM(
	SELECT company, invtype, ref, invdate, COUNT(*)
	FROM bronze.sales_hd
	GROUP BY 1, 2, 3, 4
	HAVING COUNT(*) > 1
	ORDER BY COUNT(*) DESC
);

-- Test for Detail Table
SELECT COUNT(*) AS duplicate_sales_details_pk_count
FROM(
	SELECT company, invtype, ref, folio, invdate, COUNT(*)
	FROM bronze.sales_dt
	GROUP BY 1, 2, 3, 4, 5
	HAVING COUNT(*) > 1
	ORDER BY COUNT(*) DESC
);

SELECT 
    ref, 
    COUNT(DISTINCT EXTRACT(YEAR FROM invdate::DATE)) AS years_active,
    COUNT(*) AS total_occurrences
FROM bronze.sales_hd
GROUP BY ref
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM invdate::DATE)) > 1
ORDER BY years_active DESC;