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

-- 10)
select o.cust_id, sum(net_total) as total_spend, median.total_spend from sales.orders o
CROSS JOIN (
	select sum(net_total) as total_spend from sales.orders
	GROUP BY cust_id
	ORDER BY total_spend
	OFFSET(
			select count(distinct cust_id)/2 from sales.orders
		) LIMIT 1
	) median
GROUP BY o.cust_id, median.total_spend
HAVING sum(net_total) > median.total_spend

-- 11)
select c.category_name, p.product_count, o.total_revenue, p.avg_product_price from (
	select b.category_id, count(distinct product_id) as product_count, round(avg(price),2) as avg_product_price from products.products
	LEFT JOIN core.dim_brand b USING(brand_id)
	GROUP BY b.category_id
) p
LEFT JOIN (
	select 
		b.category_id, 
		sum(net_amount) as total_revenue 
	from sales.order_items oi
	LEFT JOIN products.products p ON p.product_id = oi.prod_id
	LEFT JOIN core.dim_brand b USING(brand_id)
	GROUP BY b.category_id
) o USING(category_id)
LEFT JOIN core.dim_category c USING(category_id)

-- 12)
select 
	store_id,
	s.total_store_revenue,
	c.company_revenue,
	ROUND((s.total_store_revenue * 100.0) / c.company_revenue,2) as store_revenue_pct
from (
	select store_id, sum(net_total) as total_store_revenue from sales.orders
	GROUP BY store_id ) s
CROSS JOIN (
	select sum(net_total) as company_revenue from sales.orders
	) c
ORDER BY s.store_id

-- 13)
select * from products.products p
CROSS JOIN (
	select avg(price) as avg_product_price from products.products
) avg
WHERE p.price > avg.avg_product_price

-- 14)
select * from stores.employees
CROSS JOIN (
	select max(salary)as max_salary from stores.employees
)

-- 15)
select 
	store_id, 
	sum(net_total) as delivered_ord_revenue
from sales.orders o
JOIN sales.shipments s USING(order_id)
WHERE s.status = 'Delivered'
GROUP BY store_id
HAVING sum(net_total) > (
	select 
		avg(delivered_ord_revenue) from
	(
		select store_id, sum(net_total) as delivered_ord_revenue from sales.orders o
		JOIN sales.shipments s USING(order_id)
		WHERE s.status = 'Delivered'
		GROUP BY store_id
	) r
)

-- 16)
select order_id, net_total, revenue.company_revenue, ROUND((net_total * 100.0) / revenue.company_revenue,5) as revenue_pct from sales.orders
CROSS JOIN (
	select sum(net_total) as company_revenue from sales.orders
) revenue

-- 17)
select * from customers.customers
WHERE customer_id IN (
	select cust_id 
	from sales.orders 
	WHERE cust_id IS NOT NULL
) AND customer_id NOT IN (
	select customer_id 
	from customers.reviews 
	WHERE customer_id IS NOT NULL
)

-- 18)
select * from stores.employees 
WHERE store_id IN(
	select store_id from stores.employees e
	JOIN support.tickets t ON e.employee_id = t.agent_id
		WHERE priority = 'Critical'
)

-- 19)
select * from products.products
where product_id IN (
	select prod_id from sales.order_items
) AND product_id NOT IN (
	select prod_id from sales.returns where prod_id IS NOT NULL
)

-- 20)
select DISTINCT payment_mode from (	
	select * from loyalty.members
	WHERE tier_id = 4
) l JOIN customers.customers c USING(customer_id)
JOIN sales.orders o ON o.cust_id = c.customer_id
JOIN sales.payments p USING(order_id)

-- 21)
select count(*) total_emp, string_agg(distinct role, ', ') as roles from stores.employees e
where salary > ALL (
 	select salary from stores.employees where dept_id = 5
)

-- 22)
select * from core.dim_category
JOIN ( -- product count and avg prod price
	select 
		category_id, 
		count(*) as product_count, 
		round(avg(price),2) as avg_product_price 
	from products.products
	JOIN core.dim_brand USING(brand_id)
	GROUP BY category_id
) using(category_id)
JOIN ( -- total revenue category wise 
	select 
		b.category_id, 
		sum(net_amount) as revenue 
	from sales.order_items oi
	JOIN products.products p ON p.product_id = oi.prod_id
	JOIN core.dim_brand b USING(brand_id)
	GROUP BY b.category_id
) using(category_id)
JOIN ( -- top performing product A->B Step
	-- A) all product revenue with its category 
	select t1.category_id, t1.product_id as best_product from ( 
		select 
			p.product_id, 
			b.category_id, 
			sum(net_amount) as product_revenue 
		from sales.order_items oi
		JOIN products.products p ON p.product_id = oi.prod_id
		JOIN core.dim_brand b USING(brand_id)
		GROUP BY p.product_id, b.category_id
		ORDER BY b.category_id ASC, product_revenue DESC
	) t1
	JOIN (
	-- B) Max product price, category wise (by grouping category in same sub-que	ry)
		select 
			category_id, 
			max(product_revenue) as max_revenue 
			from ( 
				select p.product_id, b.category_id, sum(net_amount) as product_revenue from sales.order_items oi
				JOIN products.products p ON p.product_id = oi.prod_id
				JOIN core.dim_brand b USING(brand_id)
				GROUP BY p.product_id, b.category_id
				ORDER BY b.category_id ASC, product_revenue DESC
			)	 
		GROUP by category_id
	) t2 ON t1.category_id = t2.category_id AND t1.product_revenue=t2.max_revenue --IMP: match product price & category in both tables
) using(category_id)

-- 23)
select 
	DATE_TRUNC('month', order_date) as month, 
	SUM(net_total) as revenue 
from sales.orders
WHERE EXTRACT('year' from order_date) = 2025 --EXTRACT('year' from current_date)
GROUP BY DATE_TRUNC('month', order_date)
HAVING SUM(net_total) > ALL(
	select 
		SUM(net_total) as revenue
	from sales.orders
	WHERE EXTRACT('year' from order_date) = 2024 --EXTRACT('year' from current_date) - 1
	GROUP BY DATE_TRUNC('month', order_date)
)

-- 24)
select 
	cust_id, 
	count(order_id) as order_count,
	sum(net_total) as total_spend, 
	round(avg(net_total),2) as avg_order_value, 
	current_date-min(order_date) as daye_since_first_ord,
	current_date-max(order_date) as daye_since_last_ord,
	CASE
		WHEN avg(net_total) > (select avg(net_total) from sales.orders) THEN 'High Value'
		WHEN count(order_id) > 3 THEN 'Growth'
		ELSE 'At Risk'
	END as classification
	from sales.orders
group by cust_id

--25)
select 
	employee_id, 
	first_name, 
	salary,
	dept.dept_avg,
	comp.company_avg,
	CASE
		WHEN salary>dept.dept_avg AND salary>comp.company_avg THEN 'Above Both'
		WHEN salary>dept.dept_avg AND salary<comp.company_avg THEN 'Above Department Average only'
		WHEN salary<dept.dept_avg AND salary>comp.company_avg THEN 'Above Company Average only'
		ELSE 'Below Both'
	END as salary_classsification
from stores.employees
JOIN (
	select 
		dept_id, 
		ROUND(avg(salary),2) as dept_avg
	from stores.employees
	GROUP BY dept_id
) dept USING(dept_id)
CROSS JOIN( 
	select ROUND(avg(salary),2) as company_avg from stores.employees
) comp

-- 26)
select 
	emp.store_id,
	emp.avg_emp_salary,
	comp.comp_avg_emp_salary,
	ABS(emp.avg_emp_salary - comp.comp_avg_emp_salary) as avg_salary_diff,
	store.total_revenue,
	store2.avg_store_revenue,
	ABS(store.total_revenue - store2.avg_store_revenue) as avg_revenue_diff
from (
	select 
		store_id, 
		ROUND(avg(salary),2) as avg_emp_salary 
	from stores.employees
	GROUP BY store_id
) emp CROSS JOIN (
	select ROUND(avg(salary),2) as comp_avg_emp_salary from stores.employees
) comp
JOIN (
	select 
		store_id, 
		sum(net_total) as total_revenue
	from sales.orders
	GROUP BY store_id
) store using(store_id)
CROSS JOIN (
	select 
	ROUND(avg(t.t_revenue),2) as avg_store_revenue 
	from(
		select 
			store_id, 
			sum(net_total) as t_revenue
		from sales.orders
		GROUP BY store_id
	) t
) store2
ORDER BY avg_salary_diff ASC, avg_revenue_diff ASC

-- 27)
select 
	s.store_id, 
	s.store_name,
	r.region_name, 
	emp.headcount,
	emp.avg_salary, 
	store.revenue, 
	store.order_count,
	ret.total_returned,
	ret.total_returned::numeric/store.order_count as return_rate,
	sup.avg_ticket_resolution_hrs,
	CASE 
        WHEN store.revenue > 100000 AND (ret.total_returned::NUMERIC / NULLIF(store.order_count, 0)) < 0.05 THEN 'Excellent'
        WHEN store.revenue > 50000 OR (ret.total_returned::NUMERIC / NULLIF(store.order_count, 0)) < 0.10 THEN 'Healthy'
        WHEN store.revenue IS NULL THEN 'No Data'
        ELSE 'Needs Attention'
    END AS store_health_score
	from stores.stores s
LEFT JOIN core.dim_region r USING(region_id)
LEFT JOIN (
	select 
		store_id, 
		count(*) as headcount, 
		avg(salary) as avg_salary
	from stores.employees
	GROUP BY store_id
) emp USING(store_id)
LEFT JOIN (
	select 
		store_id,
		count(*) as order_count, 
		sum(net_total) as revenue 
	from sales.orders
	GROUP BY store_id
) store USING(store_id)
LEFT JOIN (
	select 
		store_id, 
		count(*) as total_returned 
	from sales.returns
	JOIN sales.orders USING(order_id)
	GROUP BY store_id
) ret USING(store_id)
LEFT JOIN (
	select 
		e.store_id,
		ROUND(AVG(ROUND(EXTRACT('EPOCH' from resolved_date - created_date)/3600,1)),2) as avg_ticket_resolution_hrs 
	from support.tickets t 
	LEFT JOIN stores.employees e ON e.employee_id = t.agent_id
	GROUP BY store_id
) sup USING(store_id)



SELECT 
    e.first_name,
    e.dept_id,
    e.salary,
    ROUND(AVG(salary) OVER (PARTITION BY dept_id), 2) AS dept_avg_salary,
    CASE 
        WHEN salary > AVG(salary) OVER (PARTITION BY dept_id) THEN 'above'
        WHEN salary < AVG(salary) OVER (PARTITION BY dept_id) THEN 'below'
        ELSE 'Average'
    END AS salary_status
FROM stores.employees e
ORDER BY dept_id, first_name;

SELECT dept_id, MAX(salary) 
FROM stores.employees
GROUP BY dept_id;

ORDER BY salary
OFFSET 1 LIMIT 2;









select * from core.dim_category
select * from customers.customers
select * from sales.orders
select * from sales.payments
select * from payroll.pay_slips
select * from payroll.pay_slips
select * from customers.customers
select * from loyalty.members
select * from sales.payments
select * from stores.employees
select * from products.products
select * from core.dim_brand
select * from core.dim_category
select * from products.products
select * from sales.returns
select * from support.tickets
select * from stores.stores
select * from sales.orders
select * from sales.order_items