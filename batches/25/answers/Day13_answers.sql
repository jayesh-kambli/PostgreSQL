-- 1) 
select 
	order_id, 
	store_id,
	net_total,
	(
		 select 
		 	avg(net_total) 
		 from sales.orders 
		 where store_id = o.store_id
	) as store_average
from sales.orders o
WHERE net_total > (
		 select 
		 	avg(net_total) 
		 from sales.orders 
		 where store_id = o.store_id
	)
-- not executed (takes long time) 

-- 2)
select 
	*
from products.products p
WHERE p.price = (
		select 
		max(price)
		from products.products p2 
		WHERE p2.brand_id = p.brand_id 
	)

-- 3)
select 
	c.first_name,
	c.email,
	(
		select 
			count(order_id) 
		from sales.orders o 
		WHERE o.cust_id = c.customer_id 
	) as total_orders
from customers.customers c
-- not executed (takes long time) 

-- 4)
select * from sales.orders o
WHERE o.gross_total > (
	select
		avg(o2.gross_total) 
	from sales.orders o2
	where o.store_id = o2.store_id
)

-- 5)
select * from products.products p
WHERE NOT EXISTS(
	select 1 from sales.returns r WHERE p.product_id = r.prod_id
)

-- Q6-Q10 Missing

-- 11) 
WITH 
	top_products as (
		select 
			product_name,
			price
		from products.products 
		ORDER BY price DESC 
		LIMIT 10
	)
select * from top_products

-- 12)

WITH
	order_count as (
		select 
			cust_id,
			count(order_id) as ord_count
			from sales.orders
			GROUP BY cust_id
	),
	
	average_order as (
		select ROUND(avg(ord_count),2) as avg_order_count from order_count
	)

select *
from order_count oc
	where oc.ord_count > (
		select avg_order_count from average_order
	)

-- 13)
WITH 
	clean_total as (
		select sum(net_total) as orders_revenue from sales.orders
	)
select * from clean_total


-- 14)
WITH
	customer_spending as (
		select 
			cust_id,
			sum(net_total) as customer_spend	
		from sales.orders
		GROUP BY cust_id
	),
	customer_review as (
		select 
			customer_id,
			count(review_id) as total_reviews_given
		from customers.reviews
		GROUP BY customer_id
		
	),
	customer_return as (
		select 
			cust_id,
			count(return_id) as total_returns
		from sales.returns
			JOIN sales.orders USING(order_id)
		GROUP BY cust_id
	)

select 
	c.customer_id,
	COALESCE(s.customer_spend,0),
	COALESCE(rev.total_reviews_given,0),
	COALESCE(r.total_returns,0)
from customers.customers c
LEFT JOIN customer_spending s ON s.cust_id = c.customer_id
LEFT JOIN customer_review rev ON rev.customer_id = c.customer_id
LEFT JOIN customer_return r ON r.cust_id = c.customer_id

-- 15)
select * from sales.orders

WITH 
	last_year_orders as (
		select * from sales.orders
		where extract('year' from order_date) = extract('year' from current_date) - 1 
	),
	get_average as (
		select 
			store_id, 
			avg(net_total) as store_average 
		from last_year_orders
		GROUP BY store_id
	),
	final_result as (
		select 
			* 
		from last_year_orders o
		JOIN get_average g_avg USING(store_id)
		where o.net_total > g_avg.store_average
	)

select * from final_result












