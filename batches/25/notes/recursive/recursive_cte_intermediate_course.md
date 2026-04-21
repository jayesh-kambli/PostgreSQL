# 🟡 RECURSIVE CTE — INTERMEDIATE COURSE (REAL TABLES + LOGIC)

---

# 🎯 GOAL

By the end of this file, you will:

✅ Understand recursion on real tables  
✅ Clearly see how data flows between tables  
✅ Understand WHEN recursion is actually needed  
✅ Avoid overusing recursion  

---

# ⚠️ IMPORTANT SHIFT FROM BEGINNER

Before:
👉 You worked with numbers (1 → 2 → 3)

Now:
👉 You will work with REAL DATA (tables)

This is where most people get confused.

---

# 🧠 CORE IDEA (INTERMEDIATE)

Still SAME:

```
Start → Repeat → Stop
```

BUT:

👉 “Repeat” now involves JOIN

---

# 🔥 QUESTION 1: Get order items for each order (USING JOIN)

---

## ✅ QUERY

```sql
SELECT o.order_id, oi.prod_id
FROM sales.orders o
JOIN sales.order_items oi
  ON o.order_id = oi.order_id;
```

---

## 📤 OUTPUT (Example)

```
order_id | prod_id
101      | 201
101      | 202
102      | 203
```

---

## 🔍 HOW OUTPUT IS GENERATED

Step 1:
Take one row from orders:
```
order_id = 101
```

Step 2:
Find matching rows in order_items:
```
101 → 201
101 → 202
```

Step 3:
Repeat for next order

---

## 🎯 WHEN TO USE

👉 Use JOIN when:
- Only ONE step relation exists

---

# 🚨 IMPORTANT

👉 THIS DOES NOT NEED RECURSION

---

# 🔥 QUESTION 2: Simulate same using recursion (for understanding)

---

## ✅ QUERY

```sql
WITH RECURSIVE flow AS (

  -- Step 1: Start from orders
  SELECT order_id, order_id AS ref_id, 1 AS level
  FROM sales.orders

  UNION ALL

  -- Step 2: Move to items
  SELECT f.order_id, oi.prod_id, f.level + 1
  FROM flow f
  JOIN sales.order_items oi
    ON f.ref_id = oi.order_id
  WHERE f.level = 1

)
SELECT * FROM flow;
```

---

# 🔍 STEP-BY-STEP EXECUTION

---

## 🟢 Step 1 — Anchor

```
order_id | ref_id | level
101      | 101    | 1
102      | 102    | 1
```

---

## 🟡 Step 2 — Recursive

Take row:
```
101
```

Join with items:
```
101 → 201
101 → 202
```

Add:
```
101 | 201 | 2
101 | 202 | 2
```

---

## 🔴 Step 3 — Stop

Condition:
```
WHERE level = 1
```

So recursion runs ONLY once

---

## 📤 FINAL OUTPUT

```
101 | 101 | 1
101 | 201 | 2
101 | 202 | 2
```

---

## 🎯 WHEN TO USE

👉 Honestly:
- NOT needed here
- This is just for learning recursion flow

---

# 🧠 KEY LEARNING

👉 JOIN = direct relation  
👉 RECURSION = repeated relation  

---

# 🔥 QUESTION 3: Customer → Orders

---

## ✅ QUERY

```sql
WITH RECURSIVE cust_flow AS (

  SELECT customer_id, customer_id AS ref_id, 1 AS level
  FROM customers.customers

  UNION ALL

  SELECT c.customer_id, o.order_id, c.level + 1
  FROM cust_flow c
  JOIN sales.orders o
    ON c.ref_id = o.cust_id
  WHERE c.level = 1

)
SELECT * FROM cust_flow;
```

---

# 🔍 EXECUTION

Step 1:
```
customer_id = 1
```

Step 2:
Find orders:
```
1 → 101
1 → 102
```

---

# 🎯 WHEN TO USE

👉 Multi-step understanding  
👉 Data flow visualization  

---

# 🔥 QUESTION 4: Add one more step (Orders → Payments)

---

## ✅ QUERY

```sql
WITH RECURSIVE flow AS (

  SELECT customer_id, customer_id AS ref_id, 'CUST' AS step, 1 AS level
  FROM customers.customers

  UNION ALL

  SELECT f.customer_id, o.order_id, 'ORDER', f.level + 1
  FROM flow f
  JOIN sales.orders o ON f.ref_id = o.cust_id
  WHERE f.step = 'CUST'

  UNION ALL

  SELECT f.customer_id, p.payment_id, 'PAYMENT', f.level + 1
  FROM flow f
  JOIN sales.payments p ON f.ref_id = p.order_id
  WHERE f.step = 'ORDER'

)
SELECT * FROM flow;
```

---

# 🔍 EXECUTION FLOW

```
Customer → Orders → Payments
```

Step-by-step expansion happens

---

# 🎯 WHEN TO USE

👉 Multi-hop traversal  
👉 Data pipelines  

---

# ⚠️ COMMON INTERMEDIATE MISTAKES

---

## ❌ Mistake 1: Using recursion when JOIN works

👉 Most common mistake

---

## ❌ Mistake 2: Wrong join condition

👉 Leads to wrong output

---

## ❌ Mistake 3: No level control

👉 Infinite recursion or repeated rows

---

# 🧠 FINAL MENTAL MODEL

```
JOIN = one step
RECURSION = multiple steps
```

---

# 🎯 SUMMARY

| Concept | Use |
|--------|-----|
| JOIN | direct relation |
| RECURSION | repeated relation |

---

# 🚀 NEXT STEP

👉 Advanced:
- Hierarchy (tree)
- Path finding
- Graph traversal
