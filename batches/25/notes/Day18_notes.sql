EXPLAIN (VERBOSE)
select * from sales.orders where cust_id = 100

EXPLAIN (FORMAT JSON)
select * from sales.orders where cust_id = 100

-- SLOW: Correlated subquery (runs sub-query for EACH row)
-- PostgreSQL performs a sequential scan on the orders table and applies the date filter during the scan. 
-- For every row that satisfies the filter, it executes the correlated subquery. 
-- This subquery performs a full sequential scan on the stores table to find the matching store_id. 
-- Since this happens for each of the ~80k rows, the stores table is scanned over 80k times, 
-- resulting in significant repeated work. This leads to high buffer usage and execution time (~1.16 seconds), 
-- making this approach much slower compared to a join-based strategy.
EXPLAIN ANALYZE
SELECT
    order_id,
    net_total,
    (
        SELECT store_name
        FROM stores.stores
        WHERE store_id = o.store_id
    ) AS store_name
FROM sales.orders o
WHERE order_date >= '2025-01-01';


-- FAST: Equivalent JOIN (single scan of both tables)
-- PostgreSQL uses a hash join here. It first performs a sequential scan on the smaller stores table and builds a hash table in memory based on store_id. 
-- Then it performs a sequential scan on the larger orders table, applying the date filter during the scan itself. For each row in orders, 
-- PostgreSQL computes a hash of store_id and performs a constant-time lookup in the in-memory hash table to find the matching store. 
-- This avoids repeatedly scanning the stores table, making the join efficient. The planning time is very small (~0.18 ms), while execution takes around 26 ms, 
-- mostly due to scanning the larger orders table.
EXPLAIN ANALYZE
SELECT
    o.order_id,
    o.net_total,
    s.store_name
FROM sales.orders o
INNER JOIN stores.stores s
    ON o.store_id = s.store_id
WHERE o.order_date >= '2025-01-01';


-- PostgreSQL scans the orders table and uses a hash aggregate to compute monthly revenue per store. 
-- The result is sorted by month and revenue to support a window function that ranks stores within each month. 
-- Using a run condition, PostgreSQL only computes ranks up to 3, avoiding unnecessary work. 
-- Finally, an incremental sort is applied to efficiently order the results by month and rank, 
-- reusing the existing sort order. The query runs efficiently in about 91 ms, with most cost coming from the initial table scan.
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
WITH monthly_rev AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        store_id,
        SUM(net_total) AS monthly_total
    FROM sales.orders
    GROUP BY 1, 2
),

ranked AS (
    SELECT
        month,
        store_id,
        monthly_total,
        RANK() OVER (
            PARTITION BY month
            ORDER BY monthly_total DESC
        ) AS store_rank
    FROM monthly_rev
)

SELECT *
FROM ranked
WHERE store_rank <= 3
ORDER BY month, store_rank;
-- ⚔️ HashAggregate vs WindowAgg (key difference)
--------------------------------------------------------------------------------------
-- Feature	          HashAggregate	                     WindowAgg
--------------------------------------------------------------------------------------
-- Purpose	          Grouping (SUM, COUNT, etc.)     	 Ranking, running totals
-- Rows output	      Fewer rows (grouped)	             Same number of rows
-- Needs sorting?	  ❌ No	                             ✅ Yes (for ORDER BY)
-- Memory usage	      Hash table	                     Sorted partitions
-- Example	          GROUP BY	                         RANK() OVER()
--------------------------------------------------------------------------------------
-- Both can run in memory, but both can also spill to disk if memory isn’t enough.



-- | Feature             | Nested Loop Join                | Hash Join                            | Merge Join                         |
-- | ------------------- | ------------------------------- | ------------------------------------ | ---------------------------------- |
-- | **How it works**    | For each row → scan other table | Build hash on smaller table → lookup | Sort both → merge sequentially     |
-- | **Best for**        | Small data / indexed joins      | Large, unsorted data                 | Large, sorted data                 |
-- | **Time complexity** | O(N × M)                        | O(N + M)                             | O(N + M) (after sort)              |
-- | **Needs index?**    | ✅ Helps a lot                  | ❌ Not required                     | ❌ Not required (but helps sorting) |
-- | **Needs sorting?**  | ❌ No                           | ❌ No                               | ✅ Yes                              |
-- | **Memory usage**    | Low                             | Medium (hash table)                  | Medium (sorting)                   |
-- | **Disk spill risk** | Low                             | If hash too big                      | If sort too big                    |
