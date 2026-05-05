-- 1)
CREATE VIEW views.all_ord_details as
select o.order_id, oi.order_item_id, oi.net_amount, p.product_id from sales.orders o
JOIN sales.order_items oi USING(order_id)
JOIN products.products p ON p.product_id = oi.prod_id

select * from views.all_ord_details

DROP VIEW IF EXISTS views.all_ord_details

-- 2)
CREATE VIEW views.raw_order_details as
select * from sales.order_items

CREATE VIEW views.clean_order_details as
select * from views.raw_order_details WHERE net_amount > 50000

CREATE VIEW views.matric_order as 
select order_id, sum(net_amount) from views.clean_order_details
GROUP BY order_id

select * from views.matric_order

-- 3)
COMMENT ON VIEW views.matric_order IS 'This view shows order MATRICS';

SELECT
    n.nspname AS schema_name,
    c.relname AS view_name,
    d.description
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_description d ON d.objoid = c.oid
WHERE c.relkind = 'v'
  AND c.relname = 'matric_order'
  AND n.nspname = 'views';


-- 4)
-- Simple views based on a single table are updatable,
-- whereas views with aggregation (like matric_order) are not updatable in PostgreSQL.

-- 5)
CREATE MATERIALIZED VIEW mv_order_metrics AS
SELECT
    o.order_id,
    SUM(oi.net_amount) AS total_amount
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

EXPLAIN ANALYZE
SELECT
    o.order_id,
    SUM(oi.net_amount)
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

EXPLAIN ANALYZE
SELECT * FROM mv_order_metrics;

-- 6)
CREATE UNIQUE INDEX idx_mv_order_metrics
ON mv_order_metrics(order_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_order_metrics;

SELECT * FROM mv_order_metrics;

-- 7)
CREATE MATERIALIZED VIEW mv_high_value_orders AS
SELECT *
FROM mv_order_metrics
WHERE total_amount > 500;

	-- wrong order (parent must be first)
REFRESH MATERIALIZED VIEW mv_high_value_orders;
REFRESH MATERIALIZED VIEW mv_order_metrics;

	-- correct order
REFRESH MATERIALIZED VIEW mv_order_metrics;
REFRESH MATERIALIZED VIEW mv_high_value_orders;

-- 8)
-- psql -d your_db -c "REFRESH MATERIALIZED VIEW CONCURRENTLY mv_order_metrics;"
-- psql -d your_db -c "REFRESH MATERIALIZED VIEW CONCURRENTLY mv_high_value_orders;"

-- refresh_all.sh

-- crontab -e
-- 0 * * * * /refresh_all.sh


