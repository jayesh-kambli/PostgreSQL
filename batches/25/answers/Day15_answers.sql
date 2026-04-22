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
select 
	*,
	sum(net_total) OVER(ORDER BY order_date)
from sales.orders

-- 4)
WITH 
	emp_with_rank as (
		select 
			*,
			ROW_NUMBER() OVER(partition by dept_id ORDER BY joining_date ASC) as emp_with_rank
		from stores.employees
	)
select * from emp_with_rank
where emp_with_rank = 1

-- 5)
SELECT *,
       RANK() OVER (ORDER BY points_balance DESC) AS ranks
FROM loyalty.members
ORDER BY points_balance DESC, join_date ASC
LIMIT 5;

-- 6)
WITH dupe_check as(
	select 
		*,
		ROW_NUMBER() OVER(partition by email) as email_arrival_count
	from customers.customers
)
select * from dupe_check
where email_arrival_count > 1

-- 7)
WITH assign as (
	select 
		*,
		ROW_NUMBER() OVER(ORDER BY order_date DESC) ranks
	from sales.orders
)
select * from assign
WHERE ranks BETWEEN 101 AND 200

-- 8)
WITH ranks as (
	select 
		*,
		DENSE_RANK() OVER(ORDER BY square_ft) as size_tier
	from stores.stores
)
select count(DISTINCT size_tier) from ranks

-- 9)
WITH ranks as (
	select 
	*,
	DENSE_RANK() OVER(ORDER BY order_date DESC) as rank1,
	RANK() OVER(ORDER BY order_date DESC) as rank2
	from sales.orders
)
select * from ranks
where rank1 <> rank2

-- DENSE_RANK() doesn’t
-- RANK() skips numbers

-- 10)
WITH ranks as (
	select 
		*,
		DENSE_RANK() OVER(ORDER BY points_balance DESC) as ranks
	from loyalty.members
)
select count(distinct ranks) from ranks

-- 11)
WITH sal_ranks as (
	select 
		*,
		DENSE_RANK() OVER(ORDER BY salary DESC) as sal_rank
	from stores.employees
)
select 
	first_name,
	salary, 
	dept_id,
	role
from sal_ranks
WHERE sal_rank = 3

-- 12)
WITH rank_prod as (
	select 
		*,
		DENSE_RANK() OVER(ORDER BY price DESC) as prod_rank
		from products.products
)
select * from rank_prod
WHERE prod_rank = 2

-- 13)
WITH cust_ord as (
	select 
		*,
		ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY order_date ASC) as order_running_count
		from sales.orders
)
select 
	c.first_name,
	o.order_id,
	o.order_date,
	o.net_total
from cust_ord o
JOIN customers.customers c ON c.customer_id = o.cust_id 
where order_running_count = 1

-- 14)
WITH 
	STORE_REV as (
		select 
			store_id,
			sum(net_total) as store_revenue
		from sales.orders
		GROUP BY store_id
	),
	REGION_STORES_RANK as (
		select 
			*,
			ROW_NUMBER() OVER(partition by region_id ORDER BY store_revenue DESC) as store_rank
		from STORE_REV
		JOIN stores.stores using(store_id)
	)
select 
	region_id,
	store_id,
	store_revenue,
	store_rank
from REGION_STORES_RANK
WHERE store_rank <= 2

-- 15)
WITH cust_sal_ranks as (
	select 
		*,
		ROW_NUMBER() OVER(partition by dept_id order by salary) as sal_rank
	from stores.employees
)

select * from cust_sal_ranks
where sal_rank <= 3

-- 16)
WITH EMP_TICK as (
	select 
		*,
		ROW_NUMBER() OVER(partition by customer_id ORDER BY created_date DESC) as cust_tick_no
	from support.tickets
)
select 
	customer_id,
	ticket_id,
	created_date,
	subject,
	status,
	cust_tick_no
from EMP_TICK
WHERE cust_tick_no = 1

-- 17)
select 
	*,
	ROUND(avg(salary) OVER(partition by dept_id),2) as dept_avg,
	ROUND(avg(salary) OVER(),2) as comp_avg
from stores.employees

-- 18)
WITH cust_ord_rank as (
 select
 	*,
 	ROW_NUMBER() OVER(partition by cust_id ORDER BY order_date DESC) as order_rank
 from sales.orders
)
select * from cust_ord_rank
where order_rank = 1

-- 19)
with emp_sal_rank as (
	select 
		*,
		DENSE_RANK() OVER(ORDER BY salary DESC) as sal_rank
	from stores.employees
)
select * from emp_sal_rank
where sal_rank = 5
-- not ROW because it will not repeat for ties 
-- DENSE_RANK because it respects ties and does not include gaps like RANK

-- 20)
with emp_rank as (
	select 
		*,
		DENSE_RANK() OVER(partition by dept_id ORDER BY salary DESC) as emp_rank
	from stores.employees
)
select * from emp_rank
where emp_rank <=2

-- 21)
with prod_revenue as (
	select 
		p.product_id,
		b.category_id,
		sum(net_amount) as product_rev
	from products.products p
	JOIN sales.order_items oi ON p.product_id = oi.prod_id
	JOIN core.dim_brand b USING(brand_id)
	GROUP BY p.product_id, b.category_id
),
rankit as (
	select 
		*,
		DENSE_RANK() OVER(partition by category_id ORDER BY product_rev DESC) as prank
	from prod_revenue
)

select * from rankit
where prank <= 3

-- 22)
WITH dupe_check as (
	select 
		*,
		ROW_NUMBER() OVER(partition by first_name, dept_id ORDER BY employee_id) as detection_count
	from stores.employees
)
select * from dupe_check
where detection_count = 1
