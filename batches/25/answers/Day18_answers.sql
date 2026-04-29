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





