-- 1)
select o.order_id, o.order_date, p.payment_mode from sales.orders o JOIN sales.payments p ON o.order_id = p.order_id;

-- 2)
select p.product_name, b.brand_name, p.price from products.products p JOIN core.dim_brand b ON p.brand_id = b.brand_id order by price DESC;

-- 3)
select e.first_name || ' ' || e.last_name as name, e.role, s.city from stores.employees e JOIN stores.stores s ON e.store_id = s.store_id WHERE e.role = 'Sales Executive';

-- 4)
select * from sales.orders;
select * from sales.order_items;
select  from products.products;
select p.product_name, oi.net_amount, oi.quantity from sales.orders o 
	JOIN sales.order_items oi ON o.order_id = oi.order_id
	JOIN products.products p ON oi.prod_id = p.product_id
	order by oi.net_amount DESC LIMIT 10;

-- 5)
select s.store_name, count(o.order_id) as total_orders 
	FROM stores.stores s 
	LEFT JOIN sales.orders o ON s.store_id = o.order_id
	GROUP BY s.store_name;

-- 6)
select s.store_name, count(o.order_id) as total_orders 
	FROM stores.stores s 
	LEFT JOIN sales.orders o ON s.store_id = o.order_id
	GROUP BY s.store_name
	HAVING count(o.order_id) IS NULL;

-- 7)
select p.product_id, p.product_name, s.supplier_name 
	FROM products.products p
	LEFT JOIN products.suppliers s ON p.supplier_id = s.supplier_id 

-- 8)
select e.employee_id, e.first_name, COALESCE(count(t.ticket_id),0) as total_tickets_completed from stores.employees e 
	LEFT JOIN support.tickets t ON e.employee_id = t.agent_id
	GROUP BY e.employee_id
	ORDER BY employee_id;

-- 9)
select d.dept_id, d.dept_name, count(e.employee_id) as employee_count from stores.employees e
	RIGHT JOIN core.dim_department d ON e.dept_id = d.dept_id
	GROUP BY d.dept_id
	order by d.dept_id;

select d.dept_id, d.dept_name, count(e.employee_id) as employee_count from core.dim_department d
	LEFT JOIN stores.employees e ON e.dept_id = d.dept_id
	GROUP BY d.dept_id
	order by d.dept_id;

-- 10)
select ec.category_name, coalesce(sum(e.amount)) as total_expenses 
	from finance.expenses e 
	RIGHT JOIN core.dim_expense_category ec ON e.exp_cat_id = ec.exp_cat_id
	GROUP BY ec.category_name;

-- 11)
select d.dept_id, d.dept_name, COALESCE(COUNT(e.employee_id)) 
	from stores.employees e 
	RIGHT JOIN core.dim_department d ON e.dept_id = d.dept_id 
	GROUP BY d.dept_id, d.dept_name 
	HAVING COALESCE(COUNT(e.employee_id)) = 0 
	ORDER BY d.dept_id;

-- 12)
select p.payment_id, p.payment_mode, c.first_name || ' ' || c.last_name as full_name, o.order_date from sales.payments p 
	LEFT JOIN sales.orders o ON o.order_id= p.order_id
	INNER JOIN customers.customers c ON  c.customer_id = o.cust_id
	ORDER BY p.payment_id

-- 13)
select r.review_id, c.first_name, p.product_name, b.brand_name from customers.reviews r
	LEFT JOIN customers.customers c on c.customer_id = r.customer_id
	INNER JOIN products.products p on p.product_id = r.product_id
	INNER JOIN core.dim_brand b ON b.brand_id = p.brand_id;

-- 14)
select s.store_id, s.store_name, r.region_name, r.state, count(e.employee_id) as total_employees, count(o.order_id) as total_orders from stores.stores s
	LEFT JOIN core.dim_region r ON r.region_id = s.region_id
	INNER JOIN stores.employees e ON e.store_id = s.store_id
	INNER JOIN sales.orders o ON o.store_id = s.store_id
	GROUP BY s.store_id, s.store_name, r.region_name, r.state

-- 15)
select p.product_id, p.product_name, cat.category_name, SUM(oi.quantity) as total_qty_sold, SUM(oi.net_amount) as total_revenue from core.dim_category cat
	LEFT JOIN core.dim_brand b ON b.category_id = cat.category_id 
	INNER JOIN products.products p ON p.brand_id = b.brand_id
	LEFT JOIN sales.order_items oi ON oi.prod_id = p.product_id
	GROUP BY p.product_id, p.product_name, cat.category_name

-- 16)
select s.store_name, count(e.employee_id) from stores.stores s
	LEFT JOIN stores.employees e ON s.store_id = e.store_id AND e.role ILIKE '%manager%'
	group by s.store_name
	-- Output: 66 stores

select s.store_name, count(e.employee_id) from stores.stores s
	LEFT JOIN stores.employees e ON s.store_id = e.store_id
	WHERE e.role ILIKE '%manager%'
	group by s.store_name
	-- Output: 65 stores (45th missing)

-- 17)
select * from sales.returns r
	LEFT JOIN sales.orders o ON o.order_id = r.order_id AND r.return_date > o.order_date;

-- 18)
select c.customer_id, c.first_name, count(payment_id) from customers.customers c
	LEFT JOIN sales.orders o ON c.customer_id = o.cust_id
	LEFT JOIN sales.payments p ON p.order_id = o.order_id AND ((c.registration_date - p.payment_date) <= 7)
	GROUP BY c.customer_id, c.first_name
	ORDER BY customer_id;

-- 19)
select o.order_id, c.first_name, o.order_date, o.net_total from sales.orders o 
	JOIN customers.customers c ON o.cust_id = c.customer_id  
	ORDER BY o.order_date DESC
	LIMIT 20;
	
-- 20)
select e.employee_id, e.first_name, e.role, d.dept_name from stores.employees e
	LEFT JOIN core.dim_department d USING(dept_id)
	ORDER BY d.dept_name;

-- 21)
select o.order_id, o.order_date, p.payment_mode, p.amount from sales.orders o 
	LEFT JOIN sales.payments p ON o.order_id = p.order_id;

-- 22)
select p.product_name, p.price, s.supplier_name, s.city from products.products p
	LEFT JOIN products.suppliers s ON p.supplier_id = s.supplier_id;

-- 23)
select c.customer_id, c.first_name, count(o.order_id) as total_orders, SUM(o.net_total) as total_order_spent, ROUND(AVG(o.net_total),2) as avg_order_value from customers.customers c
	LEFT JOIN sales.orders o ON c.customer_id = o.cust_id
	GROUP BY c.customer_id
	ORDER BY total_order_spent DESC;

SELECT 
    CUST_ID,
    COUNT(*) AS ORDER_COUNT,
    SUM(NET_TOTAL) AS TOTAL_ORDER_VALUE
FROM SALES.ORDERS
GROUP BY CUST_ID;

-- 24)
select d.dept_id, d.dept_name, count(DISTINCT e.employee_id) as total_employee, avg(e.salary) as avg_salary, sum(salary) as total_salary from core.dim_department d
	LEFT JOIN stores.employees e ON e.dept_id = d.dept_id
	GROUP BY d.dept_id
	ORDER BY d.dept_id;

-- 25)
select p.product_id, p.product_name, b.brand_name, sum(oi.quantity) as total_quantity_sold, sum(oi.net_amount) from products.products p 
	LEFT JOIN sales.order_items oi ON p.product_id = oi.prod_id
	LEFT JOIN core.dim_brand b ON b.brand_id = p.brand_id
	GROUP BY p.product_id, p.product_name, b.brand_name
	ORDER BY p.product_id;

-- 26)
select s.store_id, s.store_name, s.city, count(ticket_id) as total_tickets from stores.stores s 
	LEFT JOIN stores.employees e USING(store_id)
	INNER JOIN support.tickets t ON t.agent_id = e.employee_id
	GROUP BY s.store_id, s.store_name, s.city
	ORDER BY store_id;

-- 27)
select o.order_id, c.first_name, p.product_name, oi.quantity, oi.unit_price from sales.orders o
	LEFT JOIN customers.customers c ON c.customer_id = o.cust_id
	LEFT JOIN sales.order_items oi USING(order_id)
	LEFT JOIN products.products p ON p.product_id = oi.prod_id
	WHERE o.order_status = 'Shipped'
	ORDER BY order_id;
	-- the data is order iteam wise not order wise, as taking average of unite price dosent makes any sense ( 1 order has multiple order items so 1 order has multiple unite price )

-- 28)
select s.store_id, s.store_name, reg.region_name, count(DISTINCT e.employee_id) as employee_count, count(o.order_id) as orders_count, SUM(o.net_total) as total_revenue 
	FROM stores.stores s
	LEFT JOIN core.dim_region reg USING(region_id)
	LEFT JOIN stores.employees e USING(store_id)
	LEFT JOIN sales.orders o USING(store_id)
	GROUP BY s.store_id, s.store_name, reg.region_name
	HAVING count(o.order_id) > 100;

-- 29)
select c.customer_id, c.first_name, c.email, c.registration_date  from customers.customers c
	LEFT JOIN sales.orders o ON o.cust_id = c.customer_id
	WHERE o.order_id IS NULL
	ORDER BY customer_id;

-- 30)
select p.product_name, p.price, sup.supplier_name from products.products p
	LEFT JOIN sales.order_items oi ON oi.prod_id = p.product_id
	LEFT JOIN products.suppliers sup USING(supplier_id)
	WHERE oi.order_id IS NULL;

-- 'Crazy hard' starts here and as I started solvoing this after day 10 I initially found it challenging to decide when to use subqueries versus direct aggregation (so tried solving with both methods where required)
-- 31)
	-- Method 1 (complicated myself)
select * from core.dim_region r
	LEFT JOIN (
		select region_id, count(store_id) as total_stores FROM stores.stores 
			GROUP BY region_id) s 
			USING(region_id)
	LEFT JOIN (
		select r.region_id, count(e.employee_id) as employee_count from stores.employees e 
			LEFT JOIN stores.stores s USING(store_id)
			LEFT JOIN core.dim_region r USING(region_id)
			GROUP BY r.region_id
	) e USING(region_id)
	LEFT JOIN (
		select r.region_id, count(o.order_id) as total_orders, SUM(net_total) as total_revenue, ROUND(AVG(net_total),2) as avg_order_value from stores.stores s
			LEFT JOIN core.dim_region r USING(region_id)
			LEFT JOIN sales.orders o USING(store_id)
			GROUP BY r.region_id
	) o USING(region_id)
GROUP BY r.region_id, s.total_stores, e.employee_count, o.total_orders, o.total_revenue, o.avg_order_value
HAVING o.total_orders > 50

	
	-- Method 2
select r.region_id, r.region_name, r.state, count(DISTINCT s.store_id) as total_stores, count(DISTINCT e.employee_id) as total_employees, count(DISTINCT o.order_id) as total_orders, so.total_revenue, so.avg_order_value from core.dim_region r
	LEFT JOIN stores.stores s USING(region_id)
	LEFT JOIN stores.employees e USING(store_id)
	LEFT JOIN sales.orders o USING(store_id)
	LEFT JOIN (
		select r.region_id, sum(o.net_total) as total_revenue, ROUND(avg(o.net_total),2) as avg_order_value from sales.orders o
			LEFT JOIN stores.stores USING(store_id)
			LEFT JOIN core.dim_region r USING(region_id)
		GROUP BY r.region_id
	) so USING(region_id)
GROUP BY r.region_id, r.region_name, r.state, so.total_revenue, so.avg_order_value
HAVING count(DISTINCT o.order_id) > 50;

-- 32)
select c.customer_id, 
		c.first_name, 
		count(o.order_id) as total_orders, 
		sum(o.net_total) as total_spent, 
		ROUND(avg(o.net_total),2) as avg_order_value, 
		coalesce(current_date - MAX(order_date),0) as days_since_last_order,
		CASE 
			WHEN COUNT(o.order_id) = 0 OR (CURRENT_DATE - MAX(o.order_date)) > 90  then 'Inactive'
			WHEN COUNT(o.order_id) <= 3 THEN 'New'
			WHEN COUNT(o.order_id) >= 10 AND SUM(o.net_total) >= 10000 AND (CURRENT_DATE - MAX(o.order_date)) <= 30 THEN 'VIP'
			ELSE 'Regular'
		END as customer_tier
	from customers.customers c
	LEFT JOIN sales.orders o ON o.cust_id = c.customer_id
GROUP BY c.customer_id, c.first_name
ORDER BY c.customer_id;

-- 33)
	-- Method 1 (complicated myself)
select o.order_id, c.first_name, s.store_name, r.region_name, oi.item_count, o.net_total, COALESCE(p.payment_mode, 'Not Paid'), COALESCE(ship.status, 'Not shipped') as shipment_status from sales.orders o
	LEFT JOIN customers.customers c ON c.customer_id = o.cust_id
	LEFT JOIN stores.stores s USING(store_id)
	LEFT JOIN core.dim_region r USING (region_id)
	LEFT JOIN (
		select order_id, count(order_id) as item_count from sales.order_items GROUP BY order_id
	) oi USING (order_id)
	LEFT JOIN sales.payments p USING(order_id)
	LEFT JOIN sales.shipments ship USING(order_id)
ORDER BY order_id

	-- Method 2
select o.order_id, c.first_name, s.store_name, r.region_name, COUNT(oi.order_id) as item_count, o.net_total, COALESCE(p.payment_mode, 'Not Paid'), COALESCE(ship.status, 'Not shipped') as shipment_status from sales.orders o
	LEFT JOIN customers.customers c ON c.customer_id = o.cust_id
	LEFT JOIN stores.stores s USING(store_id)
	LEFT JOIN core.dim_region r USING (region_id)
	LEFT JOIN sales.order_items oi USING (order_id)
	LEFT JOIN sales.payments p USING(order_id)
	LEFT JOIN sales.shipments ship USING(order_id)
GROUP BY o.order_id, c.first_name, s.store_name, r.region_name, o.net_total, p.payment_mode, ship.status
ORDER BY order_id
	
