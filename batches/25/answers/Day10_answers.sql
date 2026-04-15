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
	 

select * from sales.orders
select * from core.dim_region
select * from products.products
select * from sales.order_items
select * from stores.stores

select * from support.tickets
select * from hr.attendance
select * from core.dim_region
select * from stores.stores

select * from core.dim_brand
select * from core.dim_regions
select * from products.products
select * from sales.order_items

select * from customers.customers
select * from sales.order_items
select * from products.products
select * from stores.stores
select * from sales.payments
select * from stores.employees

select * from sales.orders
select * from sales.shipments
select * from sales.payments
select * from customers.customers
select * from customers.reviews
select * from loyalty.members

select * from products.products
select * from SALES.ORDER_ITEMS