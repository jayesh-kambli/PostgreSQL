-- 1. Before/After: Create an index on sales.order_items(order_id). Run EXPLAIN ANALYZE on
-- SELECT * FROM sales.order_items WHERE order_id = 1000 before and after.
CREATE INDEX IF NOT EXISTS idx_order_items
ON sales.order_items(order_id)

EXPLAIN ANALYZE
SELECT * FROM sales.order_items WHERE order_id = 1000

DROP INDEX sales.idx_order_items

	-- BEFORE Execution Time: 36.380 ms
	-- AFTER Execution Time: 0.046 ms

-- 2. Composite: Create a composite index on stores.employees(store_id, salary DESC).
-- Test it with a query filtering by store_id and ordering by salary.
CREATE INDEX idx_stores_employees
ON stores.employees(store_id, salary DESC)

DROP INDEX stores.idx_stores_employees

-- Execution Time: 0.229 ms
EXPLAIN ANALYZE
select * from stores.employees WHERE store_id = 10 ORDER BY salary DESC
-- Execution Time: 0.080 ms

-- 3. Check Existing:
-- Run SELECT indexname, indexdef FROM pg_indexes WHERE schemaname = 'sales';
-- — how many indexes already exist?
SELECT indexname, indexdef FROM pg_indexes WHERE schemaname = 'sales'
	-- Primary key creates a B-Tree Index By default

-- 4.Product Search:
-- Create a GIN index on products.products and search for products with 'Pro' or 'Plus' in their name using to_tsvector.
CREATE INDEX IF NOT EXISTS idx_products
ON products.products USING GIN (to_tsvector('english', product_name))

DROP INDEX IF EXISTS products.idx_products

select * from products.products
WHERE to_tsvector('english', product_name) @@ (to_tsquery('english','Pro:*'))

-- 5.Campaign Search:
-- Create a GIN index on marketing.campaigns(campaign_name) and search for campaigns containing 'solution'.
CREATE INDEX IF NOT EXISTS idx_camp
ON marketing.campaigns USING GIN (to_tsvector('english', campaign_name))

DROP INDEX IF EXISTS marketing.idx_camp

select * from marketing.campaigns
WHERE to_tsvector('english', campaign_name) @@ to_tsquery('english', 'solution')

-- 6.Index Audit:
-- Run SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0; to find unused indexes in the database.
SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;

