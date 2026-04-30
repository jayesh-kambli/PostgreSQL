-- 1)Safe Delete: Write a transaction that DELETES all returns from sales.returns for a specific order_id. Verify the DELETE worked, then ROLLBACK to restore the data.
select * from sales.returns
where order_id = 7

BEGIN

delete from sales.returns where order_id = 7

ROLLBACK

-- 2) Price Update: Increase all product prices by 10% inside a transaction. Check the new prices. Then ROLLBACK to keep original prices.
BEGIN
select * from sales.orders
update sales.orders SET net_total = net_total + (net_total*0.1) WHERE order_id = 1
ROLLBACK

-- 3) Multi-Table Insert: Insert a new customer into customers.customers AND their first order into sales.orders in one transaction. ROLLBACK after verifying.
BEGIN;

INSERT INTO customers.customers (customer_id, first_name, email)
VALUES (95678999, 'Test', 'test@example.com');

INSERT INTO sales.orders (order_id, cust_id, order_date, net_total)
VALUES (8845688, 95678999, CURRENT_DATE, 500);

SELECT * FROM customers.customers WHERE customer_id = 95678999;
SELECT * FROM sales.orders WHERE cust_id = 95678999;

ROLLBACK;

-- 4) Two-Step Undo: Inside a transaction, update two different products' prices. 
-- Create a SAVEPOINT after the first update. Then ROLLBACK TO the savepoint. 
-- Verify that only the second update was undone.
	BEGIN;
	
	-- First update
	UPDATE products.products
	SET price = price + 100
	WHERE product_id = 1;
	
	-- Savepoint after first update
	SAVEPOINT sp1;
	
	-- Second update
	UPDATE products.products
	SET price = price + 200
	WHERE product_id = 2;
	
	-- Undo only second update
	ROLLBACK TO sp1;
	
	-- Verify
	SELECT product_id, price
	FROM products.products
	WHERE product_id IN (1, 2);
	
	ROLLBACK;

-- 5) Import 5 Records: Insert 5 expense records, creating a SAVEPOINT before each insert. 
-- Make the 3rd insert fail intentionally. Verify that records 1, 2, 4, and 5 were successfully inserted.
	BEGIN;
	
	-- 1
	SAVEPOINT sp1;
	INSERT INTO stores.expenses (store_expense_id, store_id, expense_type, amount, expense_date)
	VALUES (1, 101, 'Rent', 1000, CURRENT_DATE);
	
	-- 2
	SAVEPOINT sp2;
	INSERT INTO stores.expenses (store_expense_id, store_id, expense_type, amount, expense_date)
	VALUES (2, 101, 'Electricity', 300, CURRENT_DATE);
	
	-- 3 (duplicate PK)
	SAVEPOINT sp3;
	INSERT INTO stores.expenses (store_expense_id, store_id, expense_type, amount, expense_date)
	VALUES (2, 101, 'Water', 150, CURRENT_DATE);
	ROLLBACK TO sp3;
	
	-- 4
	SAVEPOINT sp4;
	INSERT INTO stores.expenses (store_expense_id, store_id, expense_type, amount, expense_date)
	VALUES (4, 101, 'Internet', 200, CURRENT_DATE);
	
	-- 5
	SAVEPOINT sp5;
	INSERT INTO stores.expenses (store_expense_id, store_id, expense_type, amount, expense_date)
	VALUES (5, 101, 'Maintenance', 250, CURRENT_DATE);
	
	-- Verify
	SELECT * FROM stores.expenses
	WHERE store_expense_id IN (1,2,3,4,5)
	ORDER BY store_expense_id;
	
	ROLLBACK;


-- 6) Nested Savepoints: Create 3 nested savepoints (sp1, sp2, sp3). Then ROLLBACK TO sp2.
-- → What happens to sp3?
-- → Can you still use it afterward?
	BEGIN;
	
	-- First savepoint
	SAVEPOINT sp1;
	INSERT INTO stores.expenses (store_expense_id, store_id, expense_type, amount, expense_date)
	VALUES (10, 101, 'Rent', 1000, CURRENT_DATE);
	
	-- Second savepoint
	SAVEPOINT sp2;
	INSERT INTO stores.expenses (store_expense_id, store_id, expense_type, amount, expense_date)
	VALUES (11, 101, 'Electricity', 300, CURRENT_DATE);
	
	-- Third savepoint
	SAVEPOINT sp3;
	INSERT INTO stores.expenses (store_expense_id, store_id, expense_type, amount, expense_date)
	VALUES (12, 101, 'Water', 150, CURRENT_DATE);
	
	-- Rollback to sp2
	ROLLBACK TO sp2;
	
	-- Verify (only sp1 + sp2 data should remain)
	SELECT * FROM stores.expenses
	WHERE store_expense_id IN (10,11,12)
	ORDER BY store_expense_id;
	
	-- Try to use sp3 again (will fail)
	-- ROLLBACK TO sp3;  -- ❌ ERROR: savepoint "sp3" does not exist
	
	ROLLBACK;
