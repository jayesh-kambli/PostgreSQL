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


select * from sales.orders
select * from sales.shipments
select * from sales.payments
select * from customers.customers
select * from customers.reviews
select * from loyalty.members

select * from products.products
select * from SALES.ORDER_ITEMS