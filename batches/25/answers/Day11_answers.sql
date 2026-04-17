-- 1)
select * from stores.stores s1
	JOIN stores.stores s2 ON s2.region_id = s1.region_id AND s2.store_id < s1.store_id

-- 2)
select 
	e1.first_name || ' ' || e1.last_name as e1_name,
	e1.salary as e1_salary,
	e2.first_name || ' ' || e2.last_name as e2_name,
	e2.salary as e2_salary 
from stores.employees e1
JOIN stores.employees e2 ON e1.store_id = e2.store_id AND e1.employee_id > e2.employee_id
WHERE ABS(e1.salary - e2.salary) <= 5000 

-- 3)
select 
	e1.dept_id, 
	count(*)
from stores.employees e1
JOIN stores.employees e2 ON e1.dept_id = e2.dept_id AND e1.employee_id > e2.employee_id
WHERE ABS(e1.salary - e2.salary) > 100000
GROUP BY e1.dept_id
ORDER BY e1.dept_id

-- new functions
-- select generate_series(1,10,1)
-- select unnest(ARRAY[1,2,3])

-- 4)
select t.tier_id, t.tier_name, mp.marketing_platform
from loyalty.tiers t
CROSS JOIN (
select UNNEST(ARRAY['Email','Website','Instagram','Facebook']) as marketing_platform
	) mp

-- 5)
-- cross join doesnt produces null records so its simply not possible with cross join + where
-- possible with cross join + group by + having + count + case

-- stores per region (just add having to filter out the region with 0 stores)
SELECT r.region_id, r.region_name,
	COUNT(CASE WHEN r.region_id = s.region_id THEN 1 END) as total_stores
FROM core.dim_region r
CROSS JOIN stores.stores s
GROUP BY r.region_id,  r.region_name
ORDER BY r.region_id;

-- 6)
select s.store_id, s.store_name, q.quarter from stores.stores s
	CROSS JOIN (
		select UNNEST(ARRAY['q1','q2','q3','q4']) as quarter
	) q

-- 7)
select city from stores.stores
UNION
select city from customers.addresses

-- 8)
select payment_date, amount from sales.payments
UNION ALL
select return_date, refund_amount from sales.returns

--9)
select count(*) from (
	select email from customers.customers
	UNION
	select email from stores.employees
) 

select count(*) from (
	select email from customers.customers
	UNION ALL
	select email from stores.employees
) 

-- 10)
SELECT role
FROM stores.employees
WHERE dept_id = 1
INTERSECT
SELECT role
FROM stores.employees
WHERE dept_id = 3;

-- 11)
select cust_id from sales.orders
INTERSECT
select customer_id from loyalty.members

-- 12)
select Date_Trunc('Month', order_date) from sales.orders where order_date >= '2025-01-01' AND order_date < '2026-01-01'
INTERSECT
select Date_Trunc('Month', return_date) from sales.returns where return_date >= '2025-01-01' AND return_date < '2026-01-01'

-- 13)
SELECT role
FROM stores.employees
WHERE dept_id = 1
	EXCEPT
SELECT role
FROM stores.employees
WHERE dept_id = 5;

-- 14)
select customer_id from loyalty.members
EXCEPT
select cust_id from sales.orders

-- 15)
	-- city with stores but not customers
	select city from stores.stores
	EXCEPT
	select city from customers.addresses
	
	-- city with customers but no stores 
	select city from customers.addresses
	EXCEPT
	select city from stores.stores
	
-- 16)
	-- All data
	select o.*, c.first_name || ' ' || c.last_name as cust_name from sales.orders o
		LEFT JOIN customers.customers c ON o.cust_id = c.customer_id
	
	select * from sales.payments p
		LEFT JOIN sales.orders o USING(order_id)
	
	select * from sales.returns r
		LEFT JOIN products.products p ON p.product_id = r.prod_id
	
	
	-- Answer
	select o.order_date as date, 'Order' as Type, c.customer_id as customer, o.net_total as amount from sales.orders o
		LEFT JOIN customers.customers c ON o.cust_id = c.customer_id
	UNION ALL
	select p.payment_date as date, 'Payment' as Type, o.cust_id as customer, p.amount as amount from sales.payments p
		LEFT JOIN sales.orders o USING(order_id)
	ORDER BY date,customer
	
	select * from sales.returns r
		LEFT JOIN products.products p ON p.product_id = r.prod_id -- no cust data, should use product name/id instead ?, join new tables returns->orders->customers ?

-- 17)
select brand_id from core.dim_brand
INTERSECT
select p.brand_id from sales.order_items oi
	LEFT JOIN products.products p ON p.product_id = oi.prod_id
EXCEPT
select p.brand_id from sales.returns r
	LEFT JOIN products.products p ON p.product_id = r.prod_id

-- 18)
select 
	DATE_TRUNC('quarter', order_date) as quarter, 
	'Sales' as department, 
	'Order' as metric, 
	count(distinct order_id)as value 
from sales.orders 
GROUP BY DATE_TRUNC('quarter', order_date)
UNION ALL
select 
	DATE_TRUNC('quarter', order_date) as quarter, 
	'Sales' as department, 
	'Revenue' as metric, 
	sum(net_total) as value 
from sales.orders 
GROUP BY DATE_TRUNC('quarter', order_date)
UNION ALL
select 
	DATE_TRUNC('quarter', created_date) as quarter,
	'Support' as department, 
	'Tickets' as metric,
	count(DISTINCT ticket_id) as value 
FROM support.tickets
GROUP BY DATE_TRUNC('quarter', created_date)
UNION ALL
select 
	DATE_TRUNC('quarter', created_date) as quarter,
	'Support' as department, 
	'Resolution Rate' as metric,
	ROUND(COUNT(CASE WHEN status = 'Resolved' THEN 1 end)::numeric / count(DISTINCT ticket_id),2) as value 
FROM support.tickets
GROUP BY DATE_TRUNC('quarter', created_date)
UNION ALL
select 
	DATE_TRUNC('quarter', start_date) as quarter,
	'Marketing' as department, 
	'Campaigns' as metric,
	count(campaign_id) as value  
from marketing.campaigns
 GROUP BY DATE_TRUNC('quarter', start_date)
UNION ALL
select 
	DATE_TRUNC('quarter', spend_date) as quarter,
	'Marketing' as department, 
	'Spend' as metric,
	sum(amount) as value  
from marketing.ads_spend
 GROUP BY DATE_TRUNC('quarter', spend_date)
Order by quarter, department, metric

-- 19)
select s1.city, s1.store_id as store1, s2.store_id as store1 from stores.stores s1
	JOIN stores.stores s2 ON s1.city = s2.city AND s1.store_id < s2.store_id
ORDER by city

-- 20)
select e1.first_name || ' ' || e1.last_name as employee1, e2.first_name || ' ' || e2.last_name as employee2, e1.role, e1.store_id from stores.employees e1
	JOIN stores.employees e2 ON e1.role = e2.role AND e1.store_id =  e2.store_id AND e1.employee_id > e2.employee_id


select * from marketing.campaigns
select * from marketing.ads_spend