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
	select o.order_date as date, 'Order' as Type, c.first_name as customer, o.net_total as amount from sales.orders o
		LEFT JOIN customers.customers c ON o.cust_id = c.customer_id
	UNION ALL
	select p.payment_date as date, 'Payment' as Type, c.first_name as customer, p.amount as amount from sales.payments p
		LEFT JOIN sales.orders o USING(order_id)
		LEFT JOIN customers.customers c ON c.customer_id = o.cust_id
	
	UNION ALL
	select r.return_date as date, 'Return' as Type, c.first_name as customer, r.refund_amount as amount  from sales.returns r
		LEFT JOIN products.products p ON p.product_id = r.prod_id
		LEFT JOIN sales.orders o USING(order_id)
		LEFT JOIN customers.customers c ON c.customer_id = o.cust_id
	ORDER BY date
	
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

-- 21)
select 'customer' as source, email from customers.customers
UNION
select 'employee' as source, email from stores.employees

-- 22)
select product_id from products.products
EXCEPT
select prod_id from sales.order_items

-- 23)
select e1.first_name as emp1, e1.salary as sal_emp1, e2.first_name as emp2, e2.salary as sal_emp2 from stores.employees e1
	JOIN stores.employees e2 ON e2.dept_id = e1.dept_id AND e2.employee_id < e1.employee_id 
	WHERE ABS (e1.salary-e2.salary) <=1000

-- 24)
select 
	d.dept_name, 
	roles.role, 
	count(DISTINCT e.employee_id) as emp_count 
from core.dim_department d
CROSS JOIN (select DISTINCT role from stores.employees) roles 
LEFT JOIN stores.employees e ON e.role = roles.role AND d.dept_id = e.dept_id
GROUP BY d.dept_name, roles.role
HAVING count(DISTINCT e.employee_id) = 0

-- 25)
select s.store_id, s.store_name, mon.month, count(DISTINCT o.order_id) as order_count from stores.stores s
CROSS JOIN (
	select generate_series(1, 12, 1) as month
) mon
LEFT JOIN sales.orders o ON o.store_id = s.store_id AND EXTRACT('month' from order_date) = mon.month AND EXTRACT('year' from order_date) = 2025
GROUP BY s.store_id, s.store_name, mon.month
ORDER BY s.store_id, s.store_name, mon.month

-- 26)
select main.month, new_o.total_orders+new_r.total_returns as total_activity from (
	select 
		extract('month' from order_date) as month
	FROM sales.orders 
	WHERE extract('year' from order_date) = 2025
	GROUP BY extract('month' from order_date)
	HAVING count(order_id) > 1000
	
	INTERSECT
	
	select 
		extract('month' from return_date) as month
	FROM sales.returns 
	WHERE extract('year' from return_date) = 2025
	GROUP BY extract('month' from return_date)
	HAVING count(return_id) > 50
) main
LEFT JOIN (
	select extract('month' from order_date) as month, count(distinct order_id) as total_orders from sales.orders WHERE extract('year' from order_date) = 2025 GROUP BY extract('month' from order_date)
) new_o USING(month) 
LEFT JOIN (
	select extract('month' from return_date) as month, count(distinct return_id) as total_returns from sales.returns WHERE extract('year' from return_date) = 2025 GROUP BY extract('month' from return_date)
) new_r USING(month)
ORDER BY total_activity DESC
LIMIT 1

-- 27)
select cust_id from sales.orders
INTERSECT
select customer_id from customers.reviews

-- 28)
select order_date as date, 'Order' as type, net_total as amount from sales.orders
UNION ALL
select payment_date as date, 'Payment' as type, amount from sales.payments
UNION ALL
select shipped_date as date, 'Shipment' as type, 0 as amount from sales.shipments
UNION ALL
select return_date as date, 'Return' as type, refund_amount as amount from sales.returns
ORDER BY date
LIMIT 30

-- 29)
-- cities with stores but not customers - 0
select DISTINCT city from stores.stores
EXCEPT
select DISTINCT city from customers.addresses 

-- cities with customers but no stores - 4 (greater)
select DISTINCT city from customers.addresses 
EXCEPT
select DISTINCT city from stores.stores
-- company needs to setup stores in 
-- "Bengaluru"
-- "Guwahati"
-- "Muzaffarpur"
-- "Warangal"

-- 30)
select e1.store_id,
CASE
	WHEN e1.dept_id = e2.dept_id THEN 'Same Dept'
	WHEN e1.role = e2.role THEN 'Same Role'
	ELSE 'Cross-Functional'
END as classification,
count(*) as pair_count
from stores.employees e1
JOIN stores.employees e2 ON e1.store_id = e2.store_id AND e2.employee_id < e1.employee_id 
GROUP BY e1.store_id,
CASE
	WHEN e1.dept_id = e2.dept_id THEN 'Same Dept'
	WHEN e1.role = e2.role THEN 'Same Role'
	ELSE 'Cross-Functional'
END
ORDER BY store_id

-- 31)
select d.dept_name, all_employees.*, dept_max_sal_diff.max_sal_diff from (
	select 
		emp1.dept_id, 
		emp1.first_name as emp1_name, 
		emp1.salary as em1_salary, 
		emp2.first_name as emp2_name, 
		emp2.salary as em2_salary, 
		ABS(emp1.salary - emp2.salary) as salary_difference	 
	from stores.employees emp1
	JOIN stores.employees emp2 ON emp1.dept_id = emp2.dept_id AND emp1.employee_id < emp2.employee_id) all_employees
JOIN ( 
		select 
			e1.dept_id, 
			MAX(ABS(e1.salary - e2.salary)) as max_sal_diff 
		from stores.employees e1
		JOIN stores.employees e2 ON e1.dept_id = e2.dept_id AND e1.employee_id < e2.employee_id
		GROUP BY e1.dept_id
		ORDER BY dept_id 
) dept_max_sal_diff on all_employees.dept_id = dept_max_sal_diff.dept_id AND all_employees.salary_difference = dept_max_sal_diff.max_sal_diff
LEFT JOIN core.dim_department d ON dept_max_sal_diff.dept_id = d.dept_id
ORDER BY dept_max_sal_diff.dept_id

-- 32)
select c.category_id, c.category_name, m.month, count(ord.order_item_id) as total_items_sold from core.dim_category c
CROSS JOIN (
	select generate_series(1,12,1) as month
	) m
LEFT JOIN (
	select oi.order_item_id, o.order_date, b.category_id from sales.order_items oi
	JOIN sales.orders o USING(order_id)
	JOIN products.products p ON oi.prod_id = p.product_id
	JOIN core.dim_brand b USING(brand_id)
) ord ON ord.category_id = c.category_id AND EXTRACT('Month' from ord.order_date) = m.month
GROUP BY c.category_id, m.month
-- HAVING count(ord.order_item_id) = 0
ORDER BY c.category_id, c.category_name, m.month

-- 33)
	-- a
	select order_date as date, 'Order' as type,  net_total as amount from sales.orders
	UNION ALL
	select payment_date as date, 'Payment' as type, amount as amount from sales.payments
	UNION ALL
	select return_date as date, 'Return' as type,  refund_amount as amount from sales.returns
	ORDER BY date, type;
	-- Here we are getting full timeline reports
	
	-- b
	select order_date as date from sales.orders
	INTERSECT
	select payment_date as date from sales.payments
	INTERSECT
	select return_date as date from sales.returns
	-- these are dates where all 3 activites took place (order, payment, returns)
	
	-- c
	select order_date as date from sales.orders
	EXCEPT
	select return_date as date from sales.returns
	-- here we are getting dates on which only orders where placed but no returns