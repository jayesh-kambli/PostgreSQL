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


select * from core.dim_brand
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