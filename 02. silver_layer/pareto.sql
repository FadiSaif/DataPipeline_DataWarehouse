WITH RankedProfit AS (
    SELECT 
        sd.item_code AS item_number,
        si.name AS item_name,
        SUM(((sd.quantity * sd.item_price) - (sd.quantity * sd.item_cost)) * CASE 
            WHEN sd.currency = '01' THEN 0.002421307506053 
            WHEN sd.currency = '02' THEN 3.8 
            ELSE 1 
        END) AS net_profit
    FROM silver.sales_order_detail sd
    INNER JOIN silver.stock_item si 
        ON sd.item_code = si.itemno
    WHERE sd.invoice_date > '20211231'
    GROUP BY sd.item_code, si.name
),
CumulativeProfit AS (
    SELECT 
        item_number,
        item_name,
        net_profit,
        SUM(net_profit) OVER (ORDER BY net_profit DESC) AS running_total_profit,
        SUM(net_profit) OVER () AS total_overall_profit
    FROM RankedProfit
)
SELECT 
    item_number AS "ITEM NUMBER",
    item_name AS "ITEM NAME",
    TO_CHAR(net_profit, 'FM9,999,999.00') AS "NET PROFIT",
    TO_CHAR((running_total_profit / total_overall_profit) * 100, 'FM990.00') || '%' AS "CUMULATIVE PROFIT %",
    CASE 
        WHEN (running_total_profit / total_overall_profit) <= 0.80 THEN 'Class A (Top 80%)'
        WHEN (running_total_profit / total_overall_profit) <= 0.95 THEN 'Class B (Next 15%)'
        ELSE 'Class C (Bottom 5%)'
    END AS "PARETO ABC CLASS"
FROM CumulativeProfit
ORDER BY net_profit DESC;