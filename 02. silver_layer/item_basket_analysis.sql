WITH ItemCounts AS (
    -- Calculate the total number of distinct orders each item appears in
    SELECT 
        itemno,
        COUNT(DISTINCT reference_number) AS total_item_orders
    FROM silver.sales_order_detail
    WHERE invdate > '20211231'
    GROUP BY itemno
),
PairCombinations AS (
    -- Join transaction details to find concurrent items in the same order
    SELECT 
        sd1.itemno AS item_a_id,
        si1.name AS item_a_name,
        sd1.qty AS item_a_qty,
        sd2.itemno AS item_b_id,
        si2.name AS item_b_name,
        sd2.qty AS item_b_qty,
        COUNT(DISTINCT sd1.reference_number) AS pairs_order_count
    FROM silver.sales_order_detail sd1
    INNER JOIN silver.sales_order_detail sd2 
        ON sd1.reference_number = sd2.reference_number
        AND sd1.itemno < sd2.itemno -- Prevents self-pairing and mirror duplicates
    INNER JOIN silver.stock_item si1 
        ON sd1.itemno = si1.itemno
    INNER JOIN silver.stock_item si2 
        ON sd2.itemno = si2.itemno
    WHERE sd1.invdate > '20211231'
		AND TRIM(sd1.itemno) != '1'
		AND TRIM(sd2.itemno) != '1'
    GROUP BY 
        sd1.itemno, si1.name, sd1.qty,
        sd2.itemno, si2.name, sd2.qty
)
SELECT 
    pc.item_a_name AS "ITEM A",
    pc.item_a_qty AS "QTY A",
    pc.item_b_name AS "ITEM B",
    pc.item_b_qty AS "QTY B",
    TO_CHAR(pc.pairs_order_count, 'FM9,999,999') AS "ORDERS TOGETHER",
    -- Confidence: Probability that an order containing Item A also contains Item B
    TO_CHAR((pc.pairs_order_count::float / ic.total_item_orders) * 100, 'FM990.00') || '%' AS "CONFIDENCE (A -> B)"
FROM PairCombinations pc
INNER JOIN ItemCounts ic 
    ON pc.item_a_id = ic.itemno
WHERE pc.pairs_order_count > 5 -- Filters out accidental or one-off pairings
ORDER BY pc.pairs_order_count DESC
LIMIT 50;