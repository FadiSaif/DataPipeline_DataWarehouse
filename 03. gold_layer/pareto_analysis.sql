CREATE OR REPLACE VIEW gold.vw_sales_pareto AS (

WITH RankedProfit AS (
    SELECT 
        p.category,
        SUM(s.quantity * (s.unit_price_sar - s.unit_cost_sar)) AS net_profit
    FROM gold.fact_sales s
    RIGHT JOIN gold.dim_product p 
        ON s.product_key = p.product_key
    WHERE p.category NOT IN ('Unspecified / Placeholder', 'Other Parts & Accessories')
    GROUP BY p.category
),
CumulativeProfit AS (
    SELECT 
        category,
        net_profit,
        SUM(net_profit) OVER (ORDER BY net_profit DESC) AS running_total_profit,
        SUM(net_profit) OVER () AS total_overall_profit
    FROM RankedProfit
)
SELECT 
    category AS "ITEM NAME",
    TO_CHAR(net_profit, 'FM9,999,999.00') AS "NET PROFIT",
	TO_CHAR(running_total_profit, 'FM9,999,999.00') AS "CUMULATIVE PROFIT",
    TO_CHAR((running_total_profit / total_overall_profit) * 100, 'FM990.00') || '%' AS "CUMULATIVE PROFIT %",
    CASE 
        WHEN (running_total_profit / total_overall_profit) <= 0.80 THEN 'Class A (Top 80%)'
        WHEN (running_total_profit / total_overall_profit) <= 0.95 THEN 'Class B (Next 15%)'
        ELSE 'Class C (Bottom 5%)'
    END AS "PARETO ABC CLASS"
FROM CumulativeProfit
ORDER BY net_profit DESC
);