# 🧠 Recursive CTE in SQL — Intermediate Level

---

## 📌 What changes from Beginner → Intermediate?

Before:
👉 We generated numbers

Now:
👉 We use **real tables + relationships**

But concept is SAME:

> start → repeat → stop

---

# 🔥 Example 1: Orders → Order Items

---

## 🎯 Intent

We want to:

👉 Start from **orders**
👉 Then get **items of each order**

This is like:

> “For each order, find its items”

---

## 🟦 SQL

```sql id="i1"
WITH RECURSIVE order_flow AS (

  -- 1️⃣ Start from orders
  SELECT 
    order_id,
    order_id AS ref_id,
    1 AS level
  FROM sales.orders

  UNION ALL

  -- 2️⃣ Move to order items
  SELECT 
    of.order_id,
    oi.prod_id,
    of.level + 1
  FROM order_flow of
  JOIN sales.order_items oi
    ON of.ref_id = oi.order_id
  WHERE of.level = 1

)
SELECT * FROM order_flow;
```

---

## ⚙️ Step-by-Step Execution

### Step 1 (Start)

```text id="i2"
order_id | ref_id | level
101      | 101    | 1
102      | 102    | 1
```

---

### Step 2 (Repeat)

For each order → find items:

```text id="i3"
order_id | ref_id | level
101      | 201    | 2
101      | 202    | 2
102      | 203    | 2
```

---

### Step 3 (Stop)

👉 Because:

```sql id="i4"
WHERE of.level = 1
```

---

## 🟨 JavaScript Thinking

```js id="i5"
for (let order of orders) {
  let items = getItems(order.id);
}
```

---

## 🧠 Important Learning

👉 This is NOT infinite loop
👉 We controlled recursion using `level`

---

# 🔥 Example 2: Customer → Orders

---

## 🎯 Intent

👉 For each customer, get their orders

---

## 🟦 SQL

```sql id="i6"
WITH RECURSIVE cust_orders AS (

  -- Start from customers
  SELECT 
    customer_id,
    customer_id AS ref_id,
    1 AS level
  FROM customers.customers

  UNION ALL

  -- Move to orders
  SELECT 
    co.customer_id,
    o.order_id,
    co.level + 1
  FROM cust_orders co
  JOIN sales.orders o
    ON co.ref_id = o.cust_id
  WHERE co.level = 1

)
SELECT * FROM cust_orders;
```

---

## ⚙️ Step-by-Step

### Step 1

```text id="i7"
customer_id | ref_id | level
1           | 1      | 1
```

---

### Step 2

```text id="i8"
customer_id | ref_id | level
1           | 101    | 2
1           | 102    | 2
```

---

### Stop

👉 controlled by `level = 1`

---

## 🟨 JavaScript Thinking

```js id="i9"
for (let customer of customers) {
  let orders = getOrders(customer.id);
}
```

---

# 🧠 Key Understanding

👉 You are using recursion to simulate:

```js
for (...) {
  for (...) {
```

---

# ⚠️ Important Difference

👉 In beginner:

* recursion was needed

👉 Here:

* this could also be done using JOIN

---

## ❗ So why use recursion here?

👉 Answer:
**To understand multi-step flow**

Later:

* 2 steps → 3 steps → 10 steps

---

# ❌ Common Mistakes (Intermediate)

---

## ❌ 1. Thinking recursion is required here

👉 Truth:

```sql id="m1"
JOIN can do this
```

👉 Recursive CTE is overkill for 1-step relation

---

## ❌ 2. Forgetting stop condition

```sql id="m2"
(no WHERE level condition)
```

👉 Result:

* infinite loop
* repeated rows

---

## ❌ 3. Confusing ref_id

👉 Mistake:

```sql id="m3"
JOIN using wrong column
```

👉 Always track:

> “what is current reference?”

---

## ❌ 4. Not tracking level

👉 Without level:

* you don’t know step
* debugging becomes hard

---

# 🤯 Common Misunderstandings

---

## ❓ “Why not just use JOIN?”

👉 Correct — for 1 step, JOIN is enough

👉 Recursive CTE is useful when:

* steps are unknown
* need repeated traversal

---

## ❓ “Is this real recursion?”

👉 Yes — but controlled manually

---

## ❓ “Why use level?”

👉 To:

* stop recursion
* understand depth

---

# 🎯 When to Use (Intermediate Thinking)

Use when:

👉 “Go step by step through relations”

Examples:

* customer → orders → payments
* order → items → products
* multi-step data flow

---

# 💡 Final Mental Model

```js id="i10"
for (step1) {
  for (step2) {
    for (step3) {
```

Recursive CTE replaces this.

---

# 🧠 One Line Summary

👉 Recursive CTE =
**multi-step JOIN using loop logic**

---

# 🟢 Beginner Level — Query-Based QnA

---

## ❓ Q1: Generate numbers from 1 to 3

👉 Expected:

```
1
2
3
```

### ✅ Query

```sql id="b1"
WITH RECURSIVE nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1
  FROM nums
  WHERE n < 3
)
SELECT * FROM nums;
```

### 🧠 Clears Doubt:

👉 Where does `n + 1` come from?
→ From previous row

---

## ❓ Q2: Generate numbers from 5 to 8

👉 Expected:

```
5
6
7
8
```

### ✅ Query

```sql id="b2"
WITH RECURSIVE nums AS (
  SELECT 5 AS n
  UNION ALL
  SELECT n + 1
  FROM nums
  WHERE n < 8
)
SELECT * FROM nums;
```

### 🧠 Clears Doubt:

👉 Start value can be anything (not only 1)

---

## ❓ Q3: Generate numbers in reverse (5 to 1)

👉 Expected:

```
5
4
3
2
1
```

### ✅ Query

```sql id="b3"
WITH RECURSIVE nums AS (
  SELECT 5 AS n
  UNION ALL
  SELECT n - 1
  FROM nums
  WHERE n > 1
)
SELECT * FROM nums;
```

### 🧠 Clears Doubt:

👉 You can decrease also (`n - 1`)

---

## ❓ Q4: Generate even numbers till 10

👉 Expected:

```
2
4
6
8
10
```

### ✅ Query

```sql id="b4"
WITH RECURSIVE nums AS (
  SELECT 2 AS n
  UNION ALL
  SELECT n + 2
  FROM nums
  WHERE n < 10
)
SELECT * FROM nums;
```

### 🧠 Clears Doubt:

👉 Step size can change (`+2`, not only +1)

---

## ❓ Q5: Stop recursion properly

👉 Task:
Generate numbers but DO NOT include 6

### ✅ Query

```sql id="b5"
WITH RECURSIVE nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1
  FROM nums
  WHERE n < 5
)
SELECT * FROM nums;
```

### 🧠 Clears Doubt:

👉 Condition is checked BEFORE next row
👉 That’s why 6 is not included

---

---

# 🟡 Intermediate Level — Query-Based QnA

---

## ❓ Q1: Get all order items for each order

👉 Tables:

* sales.orders
* sales.order_items

---

### ✅ Query

```sql id="i1"
WITH RECURSIVE order_flow AS (

  SELECT order_id, order_id AS ref_id, 1 AS level
  FROM sales.orders

  UNION ALL

  SELECT of.order_id, oi.prod_id, of.level + 1
  FROM order_flow of
  JOIN sales.order_items oi
    ON of.ref_id = oi.order_id
  WHERE of.level = 1

)
SELECT * FROM order_flow;
```

### 🧠 Clears Doubt:

👉 Why recursion?
→ simulating nested loop

---

## ❓ Q2: Get customer → their orders

---

### ✅ Query

```sql id="i2"
WITH RECURSIVE cust_orders AS (

  SELECT customer_id, customer_id AS ref_id, 1 AS level
  FROM customers.customers

  UNION ALL

  SELECT co.customer_id, o.order_id, co.level + 1
  FROM cust_orders co
  JOIN sales.orders o
    ON co.ref_id = o.cust_id
  WHERE co.level = 1

)
SELECT * FROM cust_orders;
```

### 🧠 Clears Doubt:

👉 How data flows from one table to another

---

## ❓ Q3: Add one more step (Orders → Payments)

---

### ✅ Query

```sql id="i3"
WITH RECURSIVE flow AS (

  SELECT customer_id, customer_id AS ref_id, 'CUSTOMER' AS step, 1 AS level
  FROM customers.customers

  UNION ALL

  SELECT f.customer_id, o.order_id, 'ORDER', f.level + 1
  FROM flow f
  JOIN sales.orders o ON f.ref_id = o.cust_id
  WHERE f.step = 'CUSTOMER'

  UNION ALL

  SELECT f.customer_id, p.payment_id, 'PAYMENT', f.level + 1
  FROM flow f
  JOIN sales.payments p ON f.ref_id = p.order_id
  WHERE f.step = 'ORDER'

)
SELECT * FROM flow;
```

### 🧠 Clears Doubt:

👉 How recursion can move across multiple tables

---

## ❓ Q4: Limit recursion to only 2 steps

---

### ✅ Query

```sql id="i4"
WHERE level < 2
```

(used inside recursive part)

### 🧠 Clears Doubt:

👉 How to control recursion depth

---

## ❓ Q5: What happens if we remove condition?

👉 Task:
Run without WHERE

### 🧠 Expected:

❌ infinite loop / repeated rows

### 🧠 Clears Doubt:

👉 Why stop condition is critical

---

## ❓ Q6: Rewrite using JOIN (no recursion)

---

### ✅ Query

```sql id="i5"
SELECT o.order_id, oi.prod_id
FROM sales.orders o
JOIN sales.order_items oi
  ON o.order_id = oi.order_id;
```

### 🧠 Clears Doubt:

👉 When recursion is NOT needed

---

## ❓ Q7: Add level column manually

---

### ✅ Query

```sql id="i6"
SELECT o.order_id, oi.prod_id, 2 AS level
FROM sales.orders o
JOIN sales.order_items oi
  ON o.order_id = oi.order_id;
```

### 🧠 Clears Doubt:

👉 Difference between static level vs dynamic recursion

---

# 🟡 Intermediate Level — Query-Based QnA

---

## ❓ Q1: Get all order items for each order

👉 Tables:

* sales.orders
* sales.order_items

---

### ✅ Query

```sql id="i1"
WITH RECURSIVE order_flow AS (

  SELECT order_id, order_id AS ref_id, 1 AS level
  FROM sales.orders

  UNION ALL

  SELECT of.order_id, oi.prod_id, of.level + 1
  FROM order_flow of
  JOIN sales.order_items oi
    ON of.ref_id = oi.order_id
  WHERE of.level = 1

)
SELECT * FROM order_flow;
```

### 🧠 Clears Doubt:

👉 Why recursion?
→ simulating nested loop

---

## ❓ Q2: Get customer → their orders

---

### ✅ Query

```sql id="i2"
WITH RECURSIVE cust_orders AS (

  SELECT customer_id, customer_id AS ref_id, 1 AS level
  FROM customers.customers

  UNION ALL

  SELECT co.customer_id, o.order_id, co.level + 1
  FROM cust_orders co
  JOIN sales.orders o
    ON co.ref_id = o.cust_id
  WHERE co.level = 1

)
SELECT * FROM cust_orders;
```

### 🧠 Clears Doubt:

👉 How data flows from one table to another

---

## ❓ Q3: Add one more step (Orders → Payments)

---

### ✅ Query

```sql id="i3"
WITH RECURSIVE flow AS (

  SELECT customer_id, customer_id AS ref_id, 'CUSTOMER' AS step, 1 AS level
  FROM customers.customers

  UNION ALL

  SELECT f.customer_id, o.order_id, 'ORDER', f.level + 1
  FROM flow f
  JOIN sales.orders o ON f.ref_id = o.cust_id
  WHERE f.step = 'CUSTOMER'

  UNION ALL

  SELECT f.customer_id, p.payment_id, 'PAYMENT', f.level + 1
  FROM flow f
  JOIN sales.payments p ON f.ref_id = p.order_id
  WHERE f.step = 'ORDER'

)
SELECT * FROM flow;
```

### 🧠 Clears Doubt:

👉 How recursion can move across multiple tables

---

## ❓ Q4: Limit recursion to only 2 steps

---

### ✅ Query

```sql id="i4"
WHERE level < 2
```

(used inside recursive part)

### 🧠 Clears Doubt:

👉 How to control recursion depth

---

## ❓ Q5: What happens if we remove condition?

👉 Task:
Run without WHERE

### 🧠 Expected:

❌ infinite loop / repeated rows

### 🧠 Clears Doubt:

👉 Why stop condition is critical

---

## ❓ Q6: Rewrite using JOIN (no recursion)

---

### ✅ Query

```sql id="i5"
SELECT o.order_id, oi.prod_id
FROM sales.orders o
JOIN sales.order_items oi
  ON o.order_id = oi.order_id;
```

### 🧠 Clears Doubt:

👉 When recursion is NOT needed

---

## ❓ Q7: Add level column manually

---

### ✅ Query

```sql id="i6"
SELECT o.order_id, oi.prod_id, 2 AS level
FROM sales.orders o
JOIN sales.order_items oi
  ON o.order_id = oi.order_id;
```

### 🧠 Clears Doubt:

👉 Difference between static level vs dynamic recursion

---
