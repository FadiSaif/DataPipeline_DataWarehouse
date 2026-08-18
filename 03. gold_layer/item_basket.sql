SELECT 
	so.sales_order_key AS "SALES ORDER",
	TO_CHAR(AVG(so.line_item_count), 'FM9,999,999') AS "AVERAGE BASKET COUNT",
	TO_CHAR(AVG(s.line_total_sar), 'FM9,999,999.00') AS "AVERAGE ORDER VALUE"
FROM gold.dim_sales_order so
	INNER JOIN gold.fact_sales s
	ON s.sales_order_key = so.sales_order_key
GROUP BY so.sales_order_key
ORDER BY AVG(so.line_item_count) DESC, AVG(s.line_total_sar) DESC