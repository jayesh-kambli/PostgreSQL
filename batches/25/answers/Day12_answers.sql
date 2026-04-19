-- 1)
select p.product_name, p.price, ROUND(avg.avg_price,2) from products.products p
CROSS JOIN (select AVG(price) as avg_price from products.products) as avg
WHERE p.price > avg.avg_price

-- 2)
select 
	store_id, 
	SUM(net_total) as store_revenue,
	cr.comp_rev as company_revenue,
	ROUND(SUM(net_total) * 100.0 /cr.comp_rev,3) as precentage
from stores.stores
JOIN sales.orders USING(store_id)
CROSS JOIN ( select SUM(net_total) as comp_rev from sales.orders ) cr
GROUP BY store_id, cr.comp_rev

-- 3)
select s.ticket_id, s.category, ROUND(EXTRACT('EPOCH' from resolved_date - created_date)/3600,2) as resolution_hours, avg.avg_resolution_hours from support.tickets s
CROSS JOIN (
	select ROUND(AVG(EXTRACT('EPOCH' from resolved_date - created_date)/3600),2) as avg_resolution_hours from support.tickets
) avg
WHERE EXTRACT('EPOCH' from resolved_date - created_date)/3600 > avg.avg_resolution_hours
	-- EPOCH -- total seconds
	-- /3600 divided it by this to get value in hours

-- 4)
select * from stores.stores
WHERE store_id IN (
	select DISTINCT store_id from stores.employees where role = 'Store Manager'
)

-- 5)
select * from products.products
WHERE product_id  NOT IN (
	select prod_id from sales.returns
	WHERE prod_id IS NOT NULL
	)

-- 6)
select * from stores.employees
WHERE dept_id IN (
	select dept_id from stores.employees
	GROUP BY dept_id
	HAVING count(employee_id) > 100
)

-- 7)
select count(*) from sales.orders
WHERE net_total > ANY (
	select amount 
	from sales.payments
	WHERE payment_mode = 'Cash'
)
	

-- 8)
select count(*) from sales.orders
WHERE net_total > ALL (
	select amount 
	from sales.payments
	WHERE payment_mode = 'Gift Card'
)

-- 9)
select role, count(*) as total_emp from stores.employees
WHERE salary < ALL (
	select salary from stores.employees
	WHERE role = 'Regional Manager'
) AND salary > ANY (
	select salary from stores.employees
	WHERE role = 'Cashier'
) GROUP BY role
ORDER BY total_emp DESC
LIMIT 1






select * from sales.payments
select * from stores.employees
select * from products.products
select * from sales.returns
select * from support.tickets
select * from stores.stores
select * from sales.orders