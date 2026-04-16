-- 1)
select
	CASE
		 WHEN e.employee_id IS NOT NULL AND t.ticket_id IS NOT NULL THEN 'Active Agent'
		 WHEN e.employee_id IS NULL THEN 'Ticket - Invali AGENT'
		 ELSE 'Employee - No Tickets'
	END as emp_classification,
	count(DISTINCT e.employee_id) as total_employee,
	count(DISTINCT t.ticket_id) as total_tickets
from stores.employees e
FULL OUTER JOIN support.tickets t ON e.employee_id = t.agent_id
GROUP BY CASE
		 WHEN e.employee_id IS NOT NULL AND t.ticket_id IS NOT NULL THEN 'Active Agent'
		 WHEN e.employee_id IS NULL THEN 'Ticket - Invali AGENT'
		 ELSE 'Employee - No Tickets'
	END

-- 2)
select 
	CASE
		WHEN c.customer_id IS NOT NULL AND m.customer_id IS NOT NULL THEN 'BOTH'
		WHEN c.customer_id IS NULL THEN 'MEMBER ONLY'
		ELSE 'CUSTOMER ONLY'
	END as split_status,
	count(*) as customer_count
from customers.customers c
FULL OUTER JOIN loyalty.members m USING(customer_id) 
GROUP BY 
	CASE
		WHEN c.customer_id IS NOT NULL AND m.customer_id IS NOT NULL THEN 'BOTH'
		WHEN c.customer_id IS NULL THEN 'MEMBER ONLY'
		ELSE 'CUSTOMER ONLY'
	END

-- 3)
select 
	CASE
		WHEN o.order_id IS NOT NULL AND s.shipment_id IS NOT NULL THEN 'Shipped'
		WHEN o.order_id IS NOT NULL THEN 'Not Shipped'
		ELSE 'Data Error'
	END as order_status,
	count(distinct order_id) as total_orders
from sales.orders o
FULL OUTER JOIN sales.shipments s USING(order_id)
GROUP BY 
	CASE
		WHEN o.order_id IS NOT NULL AND s.shipment_id IS NOT NULL THEN 'Shipped'
		WHEN o.order_id IS NOT NULL THEN 'Not Shipped'
		ELSE 'Data Error'
	END

-- 4)
select 
	p.product_id, 
	p.product_name,
	CASE 
		WHEN p.product_id IS NOT NULL AND r.review_id IS NULL THEN 'No reviews'
		WHEN p.product_id IS NULL THEN 'Invalid - product_id'
	END as review_info
from products.products p
FULL OUTER JOIN customers.reviews r USING(product_id)
WHERE p.product_id IS NULL OR r.review_id IS NULL
GROUP BY p.product_id, p.product_name, 
	CASE 
		WHEN p.product_id IS NOT NULL AND r.review_id IS NULL THEN 'No reviews'
		WHEN p.product_id IS NULL THEN 'Invalid - product_id'
	END
ORDER BY p.product_id

-- 5)
	-- Method 1 (every order has multiple entries)
select o.order_id, c.first_name, p.product_name, oi.quantity, oi.net_amount, s.store_name, coalesce(pay.payment_mode, 'Not Paid') as payment_mode  from sales.orders o
	LEFT JOIN customers.customers c ON c.customer_id = o.cust_id
	LEFT JOIN sales.order_items oi USING(order_id)
	LEFT JOIN products.products p ON oi.prod_id = p.product_id 
	LEFT JOIN stores.stores s USING(store_id)
	LEFT JOIN sales.payments pay using(order_id)
ORDER BY o.order_id

	-- Method 2 (every order as single entry [product names are aggregated and listed using STRING_AGG])
select o.order_id, c.first_name, ord_prod.product_name, ord_prod.total_quantity, o.net_total, s.store_name, coalesce(pay.payment_mode, 'Not Paid') as payment_mode from sales.orders o
	LEFT JOIN customers.customers c ON c.customer_id = o.cust_id
	LEFT JOIN (
		select 
			order_id, count(quantity) as total_quantity, 
			STRING_AGG(p.product_name, ', ') as product_name 
		from sales.order_items oi
		LEFT JOIN products.products p ON p.product_id = oi.prod_id
		GROUP BY order_id
	) ord_prod USING(order_id)
	LEFT JOIN stores.stores s USING(store_id)
	LEFT JOIN sales.payments pay using(order_id)
ORDER BY o.order_id

-- 6)
select  b.brand_id, b.brand_name, count(DISTINCT p.product_id) as product_count, ROUND(AVG(p.price), 2) as avg_price, SUM(oi.quantity) as total_quantity_sold, SUM(oi.net_amount) as total_revenue from core.dim_brand b
	LEFT JOIN products.products p USING(brand_id) 
	LEFT JOIN sales.order_items oi ON oi.prod_id = p.product_id
	GROUP BY b.brand_id, b.brand_name
ORDER BY brand_id

-- 7) 
select s.store_name, r.region_name, e.total_employee_count, o.total_orders, o.total_revenue from stores.stores s
	LEFT JOIN core.dim_region r USING(region_id)
	LEFT JOIN (
		select store_id, count(employee_id) as total_employee_count from stores.employees GROUP BY store_id
	) e USING(store_id)
	LEFT JOIN (
		select store_id, count(order_id) as total_orders, SUM(net_total) as total_revenue from sales.orders GROUP BY store_id
	) o USING(store_id)

-- 8)
	-- Products with orders only
	-- Drops products with no sales
	-- Drops orphan order_items (if any)
	select * from products.products p
		INNER JOIN sales.order_items oi ON oi.prod_id = p.product_id;

	-- All products + matching orders
	-- Keeps all products (even if it has no orders)
	-- If no order → oi.* = NULL
	select * from products.products p
		LEFT JOIN sales.order_items oi ON oi.prod_id = p.product_id;

	-- All products (even if it has no orders)
	-- All order_items (even if it has no products)
	-- Non-matching rows → NULLs on either side
	select * from products.products p
		FULL JOIN sales.order_items oi ON oi.prod_id = p.product_id;

-- 9)
select r.region_id, r.region_name, EXTRACT(MONTH from o.order_date), SUM(o.net_total) as revenue from sales.orders o 
	LEFT JOIN stores.stores s USING(store_id)
	LEFT JOIN core.dim_region r USING(region_id)
GROUP BY r.region_id, r.region_name, EXTRACT(MONTH from o.order_date)

-- 10)
	select COUNT(*) as all, count(DISTINCT o.order_id) as orders, count(DISTINCT p.payment_id) as payments from sales.orders o
		LEFT JOIN sales.order_items oi USING(order_id)
		LEFT JOIN sales.payments p USING(order_id)
	-- count(DISTINCT o.order_id) is count of all unique orders
	-- count(DISTINCT p.payment_id) is count of all unique payments made
	-- count(*) is count of combinations of order × items × payments

-- 11)
	select COUNT(o.order_id) as total_orders, COUNT(p.payment_id) as total_payments from sales.orders o
		LEFT JOIN sales.payments p USING(order_id)
	-- total_orders | total_payments
	-- 150000	    | 142450
	-- as we have left join, every order record exists atleast once and we have 150k DISTINCT = COUNT(o.order_id) that means no order is repeating
	-- if no order is repeating, that means we dont have double payment for even single order
	-- total_payments count is less because payment is not done for all orders
	-- no fan-out

-- 12)
	select * from stores.stores s
		LEFT JOIN stores.employees e using(store_id)
		LEFT JOIN hr.attendance ha using(employee_id)
	-- fan out is happening at 'LEFT JOIN hr.attendance ha using(employee_id)'
	-- as one employee can have multiple attendance records
	-- even store are getting multiplied because 1 store can have multiple employees
	-- store x employees x attandance of employee

-- 13)
	-- METHOD 1 (BUGGY)
	select c.customer_id, count(DISTINCT o.order_id) as total_order, sum(o.net_total) as total_spent, count(DISTINCT t.ticket_id) as support_tickets from customers.customers c
		LEFT JOIN sales.orders o ON o.cust_id = c.customer_id
		LEFT JOIN support.tickets t USING(customer_id)
	GROUP BY c.customer_id
	ORDER BY c.customer_id;
	
	-- Method 2 (FIXED)
	select c.customer_id, o.total_orders, o.total_spent, COALESCE(t.support_tickets, 0) as support_tickets from customers.customers c
		LEFT JOIN (
			select cust_id, count(order_id) as total_orders, sum(net_total) as total_spent from sales.orders GROUP BY cust_id
		) o ON o.cust_id = c.customer_id
		LEFT JOIN (
		select customer_id, count(ticket_id) as support_tickets from support.tickets group by customer_id
		) t USING(customer_id)
	ORDER BY c.customer_id;

-- 14)
select 
	CASE
		WHEN e.dept_id IS NOT NULL AND d.dept_id IS NOT NULL THEN 'Matches'
		WHEN e.dept_id IS NOT NULL THEN 'Dept Only'
		ELSE 'Employee Only'
	END as classification,
	count(e.employee_id)
from core.dim_department d
	FULL JOIN stores.employees e ON e.dept_id = d.dept_id
GROUP BY 
	CASE
		WHEN e.dept_id IS NOT NULL AND d.dept_id IS NOT NULL THEN 'Matches'
		WHEN e.dept_id IS NOT NULL THEN 'Dept Only'
		ELSE 'Employee Only'
	END

-- 15)
select 
	p.product_id,
	COALESCE(oi.order_item_id,0) as order_item_id, 
	CASE
		WHEN oi.order_item_id IS NULL THEN 'Product Never Ordered'
		ELSE 'In-Valid product ID'
	END as classification
from products.products p
FULL JOIN sales.order_items oi ON oi.prod_id = p.product_id 
WHERE oi.order_item_id IS NULL or p.product_id IS NULL

-- 16) same as Q2
select 
	CASE
		WHEN c.customer_id IS NOT NULL AND m.customer_id IS NOT NULL THEN 'BOTH'
		WHEN c.customer_id IS NULL THEN 'MEMBER ONLY'
		ELSE 'CUSTOMER ONLY'
	END as split_status,
	count(*) as customer_count
from customers.customers c
FULL OUTER JOIN loyalty.members m USING(customer_id) 
GROUP BY 
	CASE
		WHEN c.customer_id IS NOT NULL AND m.customer_id IS NOT NULL THEN 'BOTH'
		WHEN c.customer_id IS NULL THEN 'MEMBER ONLY'
		ELSE 'CUSTOMER ONLY'
	END

-- 17)
select
	CASE 
		WHEN o.order_id IS NOT NULL AND s.order_id IS NOT NULL THEN 'Shipped Order'
		WHEN o.order_id IS NOT NULL THEN 'Unshipped Order'
		ELSE 'Orphan Order'
	END as classification,
	count(*) as order_count
from sales.orders o
	FULL JOIN sales.shipments s on s.order_id = o.order_id
	GROUP BY CASE 
		WHEN o.order_id IS NOT NULL AND s.order_id IS NOT NULL THEN 'Shipped Order'
		WHEN o.order_id IS NOT NULL THEN 'Unshipped Order'
		ELSE 'Orphan Shipment'
	END

-- 18)
select o.order_id, c.first_name, ord_prod.product_name, ord_prod.total_quantity, o.net_total, s.store_name, coalesce(pay.payment_mode, 'Not Paid') as payment_mode from sales.orders o
	LEFT JOIN customers.customers c ON c.customer_id = o.cust_id
	LEFT JOIN (
		select 
			order_id, count(quantity) as total_quantity, 
			STRING_AGG(p.product_name, ', ') as product_name 
		from sales.order_items oi
		LEFT JOIN products.products p ON p.product_id = oi.prod_id
		GROUP BY order_id
	) ord_prod USING(order_id)
	LEFT JOIN stores.stores s USING(store_id)
	LEFT JOIN sales.payments pay using(order_id)
ORDER BY o.order_id

-- 19)
select r.region_id, r.region_name, s.total_stores, e.total_employees, o.total_orders from core.dim_region r
	LEFT JOIN (
		select region_id, count(store_id) as total_stores from stores.stores GROUP BY region_id
	) s USING(region_id)
	LEFT JOIN (
		select s.region_id, count(e.employee_id) as total_employees from stores.employees e
			LEFT JOIN stores.stores s USING(store_id)
		GROUP BY s.region_id
	) e USING(region_id)
	LEFT JOIN (
		select s.region_id, count(o.order_id) as total_orders from sales.orders o
			LEFT JOIN stores.stores s USING(store_id)
		GROUP BY s.region_id
	) o USING(region_id)

-- 20)
select b.brand_id, b.brand_name, p.product_count, p.avg_product_price, oi.total_revenue from core.dim_brand b
	LEFT JOIN (
		select brand_id, count(product_id) as product_count, round(avg(price),2) as avg_product_price from products.products GROUP BY brand_id
	) p USING(brand_id)
	LEFT JOIN (
		select p.brand_id, sum(oi.net_amount) as total_revenue from sales.order_items oi
			LEFT JOIN products.products p ON p.product_id = oi.prod_id  
		GROUP BY brand_id
	) oi USING(brand_id)
ORDER BY brand_id

-- 21)
-- customer -> orders
select 
	CASE
		WHEN x.customer_id IS NULL THEN 'Orphan'
		ELSE 'Valid'
	END as classification,
	COUNT(*) as total
from customers.customers x 
	RIGHT JOIN sales.orders y ON y.cust_id = x.customer_id
GROUP BY 
	CASE
		WHEN x.customer_id IS NULL THEN 'Orphan'
		ELSE 'Valid'
	END

-- order item -> products
select 
	CASE
		WHEN p.product_id IS NULL THEN 'Orphan'
		ELSE 'VALID'
	END classification,
	COUNT(*) as total
from products.products p
	RIGHT JOIN sales.order_items oi ON oi.prod_id = p.product_id
GROUP BY 
	CASE
		WHEN p.product_id IS NULL THEN 'Orphan'
		ELSE 'VALID'
	END

-- employee -> tickets
select 
	CASE
		WHEN e.employee_id IS NULL THEN 'Orphan'
		ELSE 'Valid'
	END classification,
	COUNT(*) as total
from stores.employees e
	RIGHT JOIN support.tickets t ON t.agent_id = e.employee_id 
GROUP BY 
	CASE
		WHEN e.employee_id IS NULL THEN 'Orphan'
		ELSE 'Valid'
	END

-- order -> shipment
select
	CASE
		WHEN o.order_id IS NULL THEN 'Orphan'
		ELSE 'Valid'
	END classification,
	COUNT(*) as total
from sales.orders o
	 RIGHT JOIN sales.shipments s USING(order_id)
GROUP BY 
	CASE
		WHEN o.order_id IS NULL THEN 'Orphan'
		ELSE 'Valid'
	END

-- 22)
select e.employee_id, e.first_name, d.dept_name, s.store_name, r.region_name, COUNT(t.ticket_id) as total_tickets, COALESCE(TO_CHAR(AVG(AGE(t.resolved_date, t.created_date)), 'DD "days" HH24 "hrs" MI "mins"' ),'No Tickets / Not Resolved') as avg_resolution_time from stores.employees e
	LEFT JOIN core.dim_department d USING(dept_id)
	LEFT JOIN stores.stores s USING(store_id)
	LEFT JOIN core.dim_region r using(region_id)
	LEFT JOIN support.tickets t ON t.agent_id = e.employee_id 
GROUP BY e.employee_id, e.first_name, d.dept_name, s.store_name, r.region_name
ORDER BY e.employee_id

-- 23)
select s.store_id, s.store_name, r.region_name, e.employee_count, o.order_count , o.revenue, coalesce(o.avg_order_value, 0) , o.return_count, o.return_rate from stores.stores s
	LEFT JOIN core.dim_region r USING(region_id)
	LEFT JOIN (
		select store_id, count(employee_id) as employee_count from stores.employees
		GROUP BY store_id
	) e USING(store_id)
	LEFT JOIN (
		select store_id, 
			count(order_id) as order_count,
			sum(net_total) as revenue,
			avg(net_total) as avg_order_value,
			count(case when order_status = 'Returned' then 1 else null end) as return_count, 
			ROUND(count(case when order_status = 'Returned' then 1 else null end)::numeric/count(*),3) as return_rate 
			from sales.orders 
			GROUP BY store_id ) o USING(store_id)
ORDER BY store_id

-- 24)
select 
	extract(month from order_date) as month, 
	count(order_id) as total_order, 
	sum(net_total) as revenue,
	count(DISTINCT cust_id) as unique_customers,
	ROUND(avg(net_total),2) as avg_order_value
from sales.orders
GROUP BY EXTRACT(month from order_date)
ORDER BY month

-- 25)
select 
		c.customer_id,
		c.first_name,
		c.email,
		coalesce(m.tier_id, 0) tier_id,
		o.total_orders,
		o.total_spend,
		o.avg_order_value,
		o.last_order_date,
		CURRENT_DATE - o.last_order_date as recency,
		coalesce(t.total_tickets, 0) as total_tickets,
		CASE
			WHEN o.total_spend > 100000 AND CURRENT_DATE - o.last_order_date < 10 THEN 'Good'
			WHEN o.total_spend > 50000 THEN 'Average'
			ELSE 'Bad'
		END as health
	from customers.customers c
	LEFT JOIN loyalty.members m USING(customer_id)
	LEFT JOIN (
		select 
			cust_id as customer_id, 
			count(order_id) as total_orders, 
			sum(net_total) as total_spend, 
			ROUND(avg(net_total),2) as avg_order_value, 
			max(order_date) as last_order_date 
		from sales.orders GROUP BY cust_id
	) o USING(customer_id)
	LEFT JOIN (
		select 
			customer_id, 
			COALESCE(count(*), 0)  as total_tickets
		from support.tickets group by customer_id
	) t USING(customer_id)

-- 26)
select 
		s.store_id, 
		s.store_name, 
		r.region_name, 
		s.city, 
		e.employee_count, 
		e.salary_budget, 
		o.order_count, 
		o.revenue, 
		o.unique_customers,
		o.return_rate,
		tic.tickets
	from stores.stores s
	LEFT JOIN core.dim_region r USING(region_id)
	LEFT JOIN (
		select 
			store_id, 
			count(employee_id) as employee_count,
			sum(salary) as salary_budget
		from stores.employees
		GROUP BY store_id
	) e USING(store_id)
	LEFT JOIN (
		select store_id, 
			count(order_id) as order_count,
			count(DISTINCT cust_id) as unique_customers,
			sum(net_total) as revenue,
			avg(net_total) as avg_order_value,
			ROUND(count(case when order_status = 'Returned' then 1 else null end)::numeric/count(*),3) as return_rate 
		from sales.orders 
		GROUP BY store_id 
	) o USING(store_id)
	LEFT JOIN (
		select 	
			e.store_id,
			count(*) as tickets 
		from support.tickets t
		LEFT JOIN stores.employees e ON e.employee_id = t.agent_id
		GROUP BY e.store_id
	) tic USING(store_id)
ORDER BY store_id

-- 27)
	select * from sales.orders o
		INNER JOIN sales.order_items oi USING(order_id)
		INNER JOIN products.products p ON p.product_id = oi.prod_id  
	-- total rows 375202
	-- returns only matching records across all tables
	-- rows exist only where order_id and product_id are valid in all tables
	-- no NULL values in joined columns
	-- skips any unmatched (orphan) records
	-- row count = only valid relationships
	
	select * from sales.orders o
		LEFT JOIN sales.order_items oi USING(order_id)
		LEFT JOIN products.products p ON p.product_id = oi.prod_id
	-- total rows 375202
	-- returns all orders (left table is fully preserved)
	-- if order has no order_items → oi columns = NULL
	-- if order_item has no valid product → product columns = NULL
	-- unmatched rows are NOT removed (only left side guaranteed)
	-- row count = at least number of orders (can increase due to 1:N)
	
	select * from sales.orders o
		FULL JOIN sales.order_items oi USING(order_id)
		FULL JOIN products.products p ON p.product_id = oi.prod_id  
	-- total rows 375806 (more, because there are some preoducs that are never ordered)
	-- returns all records from all tables (orders + order_items + products)
	-- unmatched rows from any table are included with NULLs
	-- helps identify:
	--   - orders without items
	--   - order_items without orders
	--   - order_items with invalid products
	--   - products never ordered
	-- row count = highest (includes all matches + all mismatches)

-- 28)
	-- customers.customers.customer_id -> sales.orders.cust_id
	select 
		CASE
			WHEN o.cust_id IS NULL THEN 'Orphan Customers (Never Ordered)'
			WHEN c.customer_id IS NULL THEN 'Orphan Order'
			else 'Good Records'
		END as status,
		COUNT(*)
	from customers.customers c
	FULL JOIN sales.orders o ON o.cust_id = c.customer_id
	GROUP BY 
		CASE
			WHEN o.cust_id IS NULL THEN 'Orphan Customers (Never Ordered)'
			WHEN c.customer_id IS NULL THEN 'Orphan Order'
			else 'Good Records'
		END
	
	-- sales.orders.order_id -> sales.order_items.order_id
	select 
		CASE 
			WHEN oi.order_id IS NULL THEN 'Orphan Order'
			WHEN o.order_id IS NULL THEN 'Orphan Order Item'
			else 'Good Records'
		END as status,
		COUNT(*)
	from sales.orders o
	FULL JOIN sales.order_items oi ON oi.order_id = o.order_id
	GROUP BY 
		CASE 
			WHEN oi.order_id IS NULL THEN 'Orphan Order'
			WHEN o.order_id IS NULL THEN 'Orphan Order Item'
			else 'Good Records'
		END
	
	-- products.products.product_id -> sales.order_items.prod_id
	select 
		CASE
			WHEN oi.prod_id IS NULL THEN 'Never Ordered Product' 
			WHEN p.product_id IS NULL THEN 'Orphan Order Item' 
			else 'Good Records'
		END as status,
		COUNT(*)
	from products.products p
	FULL JOIN sales.order_items oi ON oi.prod_id = p.product_id
	GROUP BY
		CASE
			WHEN oi.prod_id IS NULL THEN 'Never Ordered Product' 
			WHEN p.product_id IS NULL THEN 'Orphan Order Item' 
			else 'Good Records'
		END
	
	-- sales.orders.order_id -> sales.payments.order_id
	select 
		CASE
			WHEN p.order_id IS NULL THEN 'No Payments/Pending'
			WHEN o.order_id IS NULL THEN 'Orphan Payments'
			else 'Good Records/Paid'
		END as status,
		COUNT(*)
	from sales.orders o
	FULL JOIN sales.payments p ON p.order_id = o.order_id
	GROUP BY 
		CASE
			WHEN p.order_id IS NULL THEN 'No Payments/Pending'
			WHEN o.order_id IS NULL THEN 'Orphan Payments'
			else 'Good Records/Paid'
		END
	
	-- sales.orders.order_id -> sales.shipments.order_id
	select 
		CASE
			WHEN s.order_id IS NULL THEN 'Not Shipped'
			WHEN o.order_id IS NULL THEN 'Orphan Shipment'
			else 'Delivered/Shipped/Returned'
		END as status,
		COUNT(*)
	from sales.orders o
	FULL JOIN sales.shipments s ON s.order_id = o.order_id
	GROUP BY 
		CASE
			WHEN s.order_id IS NULL THEN 'Not Shipped'
			WHEN o.order_id IS NULL THEN 'Orphan Shipment'
			else 'Delivered/Shipped/Returned'
		END
	
	-- stores.stores.store_id -> sales.orders.store_id
	select 
		CASE
			WHEN o.store_id IS NULL THEN 'Orphan Store / No Orders'
			WHEN s.store_id IS NULL THEN 'Orphan Order'
			else 'Good Records'
		END as status,
		COUNT(*)
	from stores.stores s
	FULL JOIN sales.orders o ON o.store_id = s.store_id
	GROUP BY 
		CASE
			WHEN o.store_id IS NULL THEN 'Orphan Store / No Orders'
			WHEN s.store_id IS NULL THEN 'Orphan Order'
			else 'Good Records'
		END
	
	-- stores.employees.employee_id -> support.tickets.agent_id
	select 
		CASE
			WHEN t.agent_id IS NULL THEN 'Employee with no tickets'
			WHEN e.employee_id IS NULL THEN 'Orphan Ticket'
			else 'Good Records'
		END as status,
		COUNT(*)
	from stores.employees e
	FULL JOIN support.tickets t ON t.agent_id = e.employee_id
	GROUP BY
		CASE
			WHEN t.agent_id IS NULL THEN 'Employee with no tickets'
			WHEN e.employee_id IS NULL THEN 'Orphan Ticket'
			else 'Good Records'
		END
