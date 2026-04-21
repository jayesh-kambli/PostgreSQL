-- 1)
select 
	product_name,
	price, 
	brand_id,
	ROUND(avg(price) OVER(partition by brand_id),2) as avg_product_price_per_brand
from products.products

-- 2)
select 
	order_id,
	store_id,
	order_status,
	count(order_id) OVER (partition by store_id, order_status) as combination_count
from sales.orders

-- 3)
-- need to add order_id to getting running total else we will get 1 constant value
select 
	*,
	sum(net_total) OVER(ORDER BY order_date, order_id)
from sales.orders