-- 1)
EXPLAIN ANALYZE
select * from customers.customers where customer_id = 42
-- Index scan as customer_id is index (PK)
-- Execution Time: 0.083 ms

EXPLAIN ANALYZE
select * from customers.customers where email like '%gmail%'
-- Sequential scan as email is not index
-- Execution Time: 6.598 ms

-- 2)
EXPLAIN ANALYZE
select * from sales.orders
JOIN sales.order_items USING(order_id)
-- HASH JOIN

-- 3)
-- Correlated Subquery
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    o.order_id,
    o.net_total,
    (
        SELECT s.store_name
        FROM stores.stores s
        WHERE s.store_id = o.store_id
    ) AS store_name
FROM sales.orders o
WHERE o.order_date >= '2025-01-01';
-- as orders table have 150k rows and after filtering 80,669 rows, and subquery is in 'select' part so will execute 80,669 times (80,669 loop itteration)
-- Execution Time: 1159.775 ms

-- Equivalent CTE
EXPLAIN (ANALYZE, BUFFERS)
WITH order_data AS (
    SELECT
        order_id,
        net_total,
        store_id
    FROM sales.orders
    WHERE order_date >= '2025-01-01'
)
SELECT
    o.order_id,
    o.net_total,
    s.store_name
FROM order_data o
JOIN stores.stores s
    ON o.store_id = s.store_id;
-- preparing tables are using hash join (no extra looping)
-- Execution Time: 27.408 ms


-- 4)
EXPLAIN (ANALYZE, BUFFERS)
select * from sales.orders
where order_date > '2025-01-01'
  -- Buffers: shared hit=1488
  -- that means all process is done within memory and no I/O was required (as no share read) 
  -- we have enough ram to compute this

-- 5)
EXPLAIN (ANALYZE, BUFFERS)
select * from sales.orders
-- "Planning Time: 0.058 ms"
-- "Execution Time: 9.569 ms"

EXPLAIN (ANALYZE, BUFFERS)
select order_id from sales.orders
-- "Planning Time: 0.060 ms"
-- "Execution Time: 12.845 ms"

-- The only change is that select * returns the full tuple directly, 
-- while select order_id forces PostgreSQL to extract that single column from every row (extra CPU work called projection). 
-- Since everything is already in memory, this CPU overhead makes the second query slightly slower even though it returns less data.
-- This entire row (101, 5, 250) is one tuple.

-- select * → PostgreSQL can return the tuple almost as-is.
-- select order_id → PostgreSQL still reads the full tuple, but then extracts that one column (projection) and builds a new, smaller result row.

-- 6)
EXPLAIN (ANALYZE, BUFFERS)
select * from stores.employees
where lower(first_name) = 'karan'
-- Execution Time: 0.792 ms

EXPLAIN (ANALYZE, BUFFERS)
select * from stores.employees
where first_name = 'Karan'
-- Execution Time: 0.268 ms

-- 7)
EXPLAIN (ANALYZE, BUFFERS)
select * from customers.customers
where customer_id NOT IN(
	select cust_id from sales.orders
)
-- Execution Time: 61.065 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT * 
FROM customers.customers c
WHERE NOT EXISTS (
    SELECT 1 
    FROM sales.orders o 
    WHERE o.cust_id = c.customer_id
);
-- Execution Time: 49.351 ms

-- 8)
EXPLAIN (ANALYZE, BUFFERS)
select * from sales.orders
where cust_id = 100 OR store_id = 5
-- Execution Time: 10.300 ms

EXPLAIN (ANALYZE, BUFFERS)
select * from sales.orders
where cust_id = 100
UNION ALL 
select * from sales.orders
where store_id = 5
-- Execution Time: 38.412 ms

-- Yes, the plan changes: OR uses a single scan, while UNION ALL splits into two scans and combines results, which is why it’s slower in your case.

-- 9. Sargable Rewrite:
-- Take WHERE DATE_TRUNC('month', order_date) = '2025-03-01' and make it sargable. What date range replaces it?
EXPLAIN (ANALYZE, BUFFERS)
select * from sales.orders
WHERE DATE_TRUNC('month', order_date) = '2025-03-01'


EXPLAIN (ANALYZE, BUFFERS)
select * from sales.orders
WHERE order_date >= '2025-03-01' AND order_date < '2025-04-01'


-- 10. 2. Filter Early:
-- Write a query that gets the top 5 highest-value orders from 2025 with store names. Use the CTE “filter first, join late” pattern.
WITH ranked as (
	select * from sales.orders
	WHERE order_date >= '2025-01-01' AND order_date < '2026-01-01'
	ORDER BY net_total DESC
	LIMIT 5
)

select r.*, s.store_name from ranked r
JOIN stores.stores s USING(store_id)


-- 11. 3. The CTE Optimizer:
-- Rewrite the Day 13 correlated subquery (store name lookup per order) as a CTE + JOIN. Compare EXPLAIN ANALYZE actual times.
EXPLAIN (ANALYZE, BUFFERS)
select *,
(
	select store_name from stores.stores s 
	WHERE s.store_id = o.store_id
)
from sales.orders o
WHERE o.order_date >= '2025-01-01' AND o.order_date < '2026-01-01'
-- Execution Time: 1017.046 ms

EXPLAIN (ANALYZE, BUFFERS)
WITH filtered as (
	select *
	from sales.orders o
	WHERE o.order_date >= '2025-01-01' AND o.order_date < '2026-01-01'
)
select * from filtered
JOIN stores.stores s USING(store_id)
-- Execution Time: 27.530 ms

-- 12. 4. Performance Audit:
-- Take the Day 16 moving average query and run EXPLAIN ANALYZE on it. What scan type does the CTE use? Is the Sort in memory or on disk?
EXPLAIN ANALYZE
WITH clean as (
	select  
		DATE_TRUNC('day', order_date) as date, 
		count(*) as total_orders 
	FROM sales.orders
	GROUP BY DATE_TRUNC('day', order_date)
)
select *,
	ROUND(AVG(total_orders) OVER(ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as avg_7_day
from clean
-- Why Gather is needed (3rd step)
-- You had 2 workers scanning & aggregating in parallel
-- Each worker produces its own partial results
-- PostgreSQL must bring everything together before final aggregation

-- step1: parallel sequal scan on table 
	-- worker A: 1-5
	-- worker B: 6 -10

-- step2: Partial Agg - generate aggregated values (DATE_TRUNC, total_orders)
	-- worker A: gen agg table1
	-- worker B: gen agg table2

-- step3: Gather - gathers all data (dup availble)
	-- worker A: 2025-01-02 - 6
	-- worker B: 2025-01-02 - 2

-- step4: Final Agg - elliminates dupes in step3 by agg
	-- Final: 2025-01-02 - 8

-- step 5: Window agg for moving avg_7_day respecting frame

