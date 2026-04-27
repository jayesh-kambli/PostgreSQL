# 🎓 SQL Curriculum V4: Batch 24+ (RetailMart V2 Edition)

| **Parameter**      | **Details**                                                                       |
| :----------------- | :-------------------------------------------------------------------------------- |
| **Duration**       | 6 Weeks \| 29 Sessions                                                            |
| **Session Length** | 2h 20m per session                                                                |
| **Total Hours**    | ~67 hours                                                                         |
| **Platform**       | PostgreSQL 18, pgAdmin 4, VS Code                                                 |
| **Database**       | **RetailMart V2** (16 Schemas, 47 Tables)                                         |
| **Philosophy**     | Teach the 80/20. Cut niche topics. Use freed time for deep, repeated practice.    |

---

## 🎯 What changed from V3

V4 keeps the same 29 sessions and the same overall arc. It removes specialty topics that junior data analysts and app developers rarely write, and reinvests the freed minutes into **more practice problems per remaining topic** (minimum 4 per topic, often more).

**Topics removed from V3:**

| Day | Removed | Why |
| :-- | :------ | :-- |
| 3   | `ARRAY` type                                       | App devs use JSONB, not arrays. |
| 6   | `AGE()`                                            | `EXTRACT` / `DATE_TRUNC` / interval math is what people actually write. |
| 8   | `ARRAY_AGG`                                        | `STRING_AGG` covers the listing use case. |
| 11  | `INTERSECT`, `EXCEPT`, `CROSS JOIN`                | Rare in practice; UNION carries the day. |
| 12  | `ANY`, `ALL`                                       | `IN` and `EXISTS` cover the same ground more clearly. |
| 17  | `FIRST_VALUE`, `LAST_VALUE`, `NTH_VALUE`           | Confusing default frames; LAG/LEAD is the 80/20. |
| 19  | GIN indexes / Full-Text Search                     | Specialty. Most jobs use FTS via library wrappers. |
| 19  | Expression indexes (deep dive)                     | Becomes a 5-minute mention only. |
| 21  | `SERIALIZABLE` deep dive                           | "READ COMMITTED is the default; here's why" is enough. |
| 22  | BCNF                                               | 3NF is the practical stopping point. |
| 24  | PL/pgSQL `LOOP`                                    | Real functions are SQL or simple `IF`. |
| 26  | Row-Level Security                                 | Rarely used by junior roles. |

**Day shape (every day):**
- ~40 min — concept teaching (1–3 topics max)
- ~90 min — practice block: **minimum 4 problems per topic**, escalating difficulty
- ~10 min — wrap, recap, preview tomorrow

---

## 📅 Week 1: Foundations & Architecture (4 Days)

**Goal**: Strong grip on DDL, Data Types, and the RetailMart Schema.

### Day 1 — Introduction to SQL & Installation
- **Topics**: SQL components (DDL, DML, DCL, TCL), DBMS vs RDBMS, PostgreSQL architecture.
- **Lab**: Install PostgreSQL 18, pgAdmin 4, VS Code, Git. Connect to local server.
- **Activity**: Tour of RetailMart V2 — list schemas, count rows in `sales.orders`, `customers.customers`, `products.products`.

### Day 2 — Basic Queries & DDL
- **Topics**: `CREATE DATABASE`, `CREATE SCHEMA`, `CREATE TABLE`, `DROP`, `ALTER TABLE`. `SELECT version()`.
- **Lab 1**: Build practice DB `accio_<batch_no>` from scratch — 3 tables, FK between them.
- **Lab 2**: Import RetailMart V2 via `setup_accio_retailmart_raw.sql`.
- **Practice (4)**: Add column to existing table; rename a table; drop a column with FK; recreate a table after `DROP CASCADE`.

### Day 3 — PostgreSQL Data Types
- **Topics**: `INT`, `SERIAL`, `BIGSERIAL`, `NUMERIC` (money), `VARCHAR`, `TEXT`, `TIMESTAMP`, `DATE`, `BOOLEAN`. Brief: `JSONB`, `UUID`.
- **Lab**: Choose correct types when designing a new `marketing.surveys` table.
- **Practice (4)**: Convert `VARCHAR` price column to `NUMERIC`; spot wrong type usages in a sample DDL; query `audit.trace_id` (UUID); read a `JSONB` field with `->` and `->>`.

### Day 4 — Constraints & Keys
- **Topics**: `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `DEFAULT`, `NOT NULL`. `CASCADE` vs `RESTRICT`.
- **Lab**: Verify FK integrity `sales.orders.store_id → stores.stores.store_id`.
- **Practice (4)**: Add a `CHECK(price > 0)`; add composite UNIQUE; add `ON DELETE CASCADE`; intentionally break a FK insert and read the error.

---

## 📅 Week 2: Filtering, Logic & Aggregation (5 Days)

**Goal**: Master filtering, scalar functions, and grouping. Practice-heavy week.

### Day 5 — Filtering & Sorting
- **Topics**: `WHERE`, `AND`/`OR`/`NOT`, `LIKE`/`ILIKE`, `BETWEEN`, `IN`, `IS NULL`, `ORDER BY`, `LIMIT`/`OFFSET`.
- **Practice (6)**: gmail customers via `LIKE`; orders in date range via `BETWEEN`; multi-condition with `OR`/`AND` precedence; pagination (page 3, 20/page); NULL handling on `customers.phone`; top 10 most expensive products.

### Day 6 — Scalar Functions (String & Date)
- **Topics**: `UPPER`, `LOWER`, `LENGTH`, `SUBSTRING`, `TRIM`, `CONCAT`, `REPLACE`, `POSITION`. `NOW()`, `EXTRACT`, `DATE_TRUNC`, `TO_CHAR`, interval arithmetic.
- **Practice (6)**: Proper-case customer names; mask phone numbers; extract domain from email; orders by month using `DATE_TRUNC`; "days since last order" using interval math; format `created_at` as `DD-Mon-YYYY`.

### Day 7 — Conditional Logic & Derived Columns
- **Topics**: `CASE WHEN`, `COALESCE`, `NULLIF`, `CAST` / `::`.
- **Practice (5)**: Segment customers VIP/Regular/New by order count; `COALESCE` missing `return_reason`; bucket order amounts into Small/Med/Large; `NULLIF` to avoid divide-by-zero in margin calc; cast `VARCHAR` date to `DATE` and filter.

### Day 8 — Aggregate Functions & Grouping
- **Topics**: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `STRING_AGG`. `GROUP BY` mechanics, `HAVING` vs `WHERE`.
- **Practice (6)**: Total revenue by region; avg order value per store; stores with >₹1M revenue (`HAVING`); customers with ≥5 orders; product names per category as comma list (`STRING_AGG`); top 10 categories by item count.

### Day 9 — Joins Part 1 (Foundations)
- **Topics**: `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`. Join keys, ambiguity, aliasing.
- **Practice (6)**: Orders with customer names; products never ordered (LEFT JOIN); orders missing shipment record; employees with their store name; categories with their parent category; customer order count including zero-order customers.

---

## 📅 Week 3: Advanced Joins, Subqueries & CTEs (5 Days)

**Goal**: Multi-table reasoning. Practice-heavy week — joins are where most students stumble.

### Day 10 — Joins Part 2 (Advanced)
- **Topics**: `FULL OUTER JOIN`, multi-table joins (4–5 tables), join order intuition.
- **Practice (5)**: Full supply-chain trace `orders → shipments → warehouses → inventory`; unsold inventory; orders + customer + product + store in one row; reconcile two systems via `FULL OUTER JOIN`; rewrite a 3-table inner join three different ways.

### Day 11 — Self Join & UNION
- **Topics**: `SELF JOIN` (hierarchies), `UNION` / `UNION ALL`.
- **Practice (4)**: Employee–manager hierarchy; pairs of products in the same category; union of `audit.application_logs` + `audit.api_requests` into one feed; `UNION` vs `UNION ALL` performance comparison.

### Day 12 — Subqueries Part 1
- **Topics**: Scalar subqueries, multi-row subqueries with `IN`, subqueries in `SELECT` and `FROM`.
- **Practice (5)**: Products cheaper than category average; customers above the global avg spend; subquery in `SELECT` for "orders this month per customer"; rewrite an `IN`-subquery as a JOIN; spot the bug — subquery returning multiple rows where scalar expected.

### Day 13 — Subqueries Part 2 (Correlated, EXISTS) & CTEs
- **Topics**: Correlated subqueries, `EXISTS` / `NOT EXISTS`, basic `WITH` (CTEs), recursive CTEs.
- **Practice (6)**: Customers with at least one return; products never bought via `NOT EXISTS`; CTE-based churn (no order in 6 months); recursive CTE for org chart from `stores.employees`; recursive CTE for category tree; refactor a 3-level nested subquery into chained CTEs.

### Day 14 — Practice & Review (Joins + Subqueries + CTEs)
- **Format**: Pure practice day. No new concepts.
- **Practice (8)**: Sales performance report (5-table join + KPIs); top 3 customers per region; products with declining sales; "category cannibalization" — pairs frequently substituted; refund-rate by category; cohort of customers acquired in Q1; basket analysis (pairs of products bought together); store-vs-store comparison.

---

## 📅 Week 4: Window Functions & Performance (5 Days)

**Goal**: Analytics queries + understanding why queries are slow.

### Day 15 — Window Functions Part 1 (Ranking)
- **Topics**: `OVER()`, `PARTITION BY`, `ORDER BY` inside window. `ROW_NUMBER`, `RANK`, `DENSE_RANK`. Top-N per group pattern.
- **Practice (6)**: Top 3 highest-paid employees per department; rank products within each category by sales; deduplicate `customers` keeping latest record per email; "second highest" salary; rank stores by revenue per region; ROW_NUMBER vs RANK vs DENSE_RANK side-by-side on tied data.

### Day 16 — Window Functions Part 2 (Aggregation, Frames)
- **Topics**: `SUM() OVER`, `AVG() OVER`, running totals, moving averages, window frame syntax (`ROWS BETWEEN ...`).
- **Practice (6)**: Cumulative revenue by month; 7-day moving avg of orders; running total of expenses per department; % of category total per product; rolling 30-day customer count; reset running total at year boundary.

### Day 17 — Window Functions Part 3 (LAG/LEAD)
- **Topics**: `LAG`, `LEAD`. Period-over-period analysis. (FIRST_VALUE / LAST_VALUE / NTH_VALUE deliberately excluded.)
- **Practice (6)**: Month-over-month revenue growth %; gap between consecutive orders per customer; detect price changes in `products` history; first-vs-second order time delta; web session duration from `web_events` using LAG; flag rows where today's value > yesterday's by >20%.

### Day 18 — Query Performance Basics
- **Topics**: `EXPLAIN`, `EXPLAIN ANALYZE`, reading a plan (Seq Scan vs Index Scan vs Bitmap), common slow patterns (`SELECT *`, leading wildcard `LIKE`, function-on-column in `WHERE`).
- **Practice (5)**: Read a plan and identify the bottleneck; rewrite `WHERE UPPER(email) = ...` to be sargable; replace `SELECT *` in a wide-table query; spot the missing `LIMIT`; compare plan before/after rewriting an `OR` as `UNION ALL`.

### Day 19 — Indexing Strategies
- **Topics**: B-Tree indexes, composite indexes (column order matters), partial indexes, `CREATE INDEX CONCURRENTLY`. Brief mention only: expression indexes. (GIN / FTS deliberately excluded.)
- **Practice (5)**: Add a B-Tree index, measure before/after; choose composite column order for a 2-predicate query; partial index for `WHERE status = 'active'`; identify a redundant index; measure write cost of an over-indexed table.

---

## 📅 Week 5: Transactions & Database Engineering (5 Days)

### Day 20 — Transactions & Error Control
- **Topics**: `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`.
- **Lab**: Simulate order placement — deduct inventory, insert order; rollback if stock low.
- **Practice (5)**: Multi-statement debit/credit transfer; rollback to savepoint mid-transaction; nested savepoints; transaction across 2 schemas; observe behavior on error without explicit rollback.

### Day 21 — ACID & Isolation Levels
- **Topics**: Atomicity, Consistency, Isolation, Durability (concept). Isolation problems: dirty read, non-repeatable read, phantom read. PostgreSQL default = `READ COMMITTED`. Brief mention: `REPEATABLE READ`, `SERIALIZABLE` (no deep dive).
- **Practice (4)**: Two-session demo of non-repeatable read; deadlock simulation between two sessions; `SELECT ... FOR UPDATE` lab; identify which anomalies `READ COMMITTED` does and doesn't prevent.

### Day 22 — Normalization & Data Modeling
- **Topics**: 1NF, 2NF, 3NF. Functional dependencies, denormalization tradeoffs. (BCNF deliberately excluded.)
- **Lab**: Audit the RetailMart schema — why `addresses` is 3NF but `orders` keeps a derived `gross_total`.
- **Practice (4)**: Normalize a flat CSV into 3NF; spot the 2NF violation in a given table; design a many-to-many junction table; argue for/against denormalizing a specific RetailMart table.

### Day 23 — Views & Materialized Views
- **Topics**: `CREATE VIEW`, `CREATE MATERIALIZED VIEW`, `REFRESH MATERIALIZED VIEW`, `REFRESH ... CONCURRENTLY`. View vs MV tradeoffs.
- **Lab**: Build `v_executive_dashboard` consolidating sales + expenses + HR.
- **Practice (4)**: View on top of a 4-table join; updatable view limitations; MV with concurrent refresh + unique index requirement; refresh-cost vs query-cost comparison.

### Day 24 — Functions (PL/pgSQL)
- **Topics**: `CREATE FUNCTION`, parameters, return types (scalar, table, setof). Variables, `IF` / `CASE` control flow. (Loops deliberately excluded.)
- **Lab**: `get_customer_ltv(cust_id)` returning total lifetime spend.
- **Practice (4)**: `tier_for_customer(cust_id)` returning 'Bronze'/'Silver'/'Gold'; table-returning function for a parameterized report; immutable vs stable vs volatile classification; calling one function from another.

---

## 📅 Week 6: Security, Procedures & Capstone (5 Days)

### Day 25 — Stored Procedures & Error Handling
- **Topics**: `CREATE PROCEDURE`, `CALL`, `BEGIN ... EXCEPTION ... END`, `RAISE NOTICE` / `RAISE EXCEPTION`. Procedure vs function (transaction control).
- **Lab**: `admin_update_price(pid, price)` — updates price AND logs to `audit.record_changes`, rolls back on validation fail.
- **Practice (4)**: Procedure that processes a refund (multi-step); custom exception with error code; `RAISE NOTICE` for trace logging; procedure that commits mid-execution.

### Day 26 — Database Security & User Management
- **Topics**: `CREATE ROLE` / `CREATE USER`, `GRANT` / `REVOKE` (table, schema, column level), `ALTER DEFAULT PRIVILEGES`. SQL injection and parameterized queries. (Row-Level Security deliberately excluded.)
- **Lab**: Create `readonly_analyst` with access only to `analytics` schema.
- **Practice (4)**: Grant SELECT on subset of columns; revoke and verify; demonstrate SQL injection on a vulnerable string-concat query, then fix with parameter binding; audit who has what on a given table.

### Day 27 — Capstone Part 1: Foundation & Core Analytics
- **Setup**: `analytics_schema`, metadata tables, indexes.
- **Modules** (Views + Materialized Views):
  - **Sales Analytics**: monthly trends, MoM/YoY growth, payment modes, day-of-week patterns.
  - **Customer Analytics**: RFM segmentation, CLV, cohort retention.
  - **Product Analytics**: top products, ABC/Pareto, category performance.
- **Deliverable**: 15+ views, 6 materialized views, data-quality checks.

### Day 28 — Capstone Part 2: Advanced Analytics
- **Modules**:
  - **Store & Finance**: profitability (revenue − expenses), vendor payments, budget vs actual.
  - **Supply Chain**: SLA tracking with `logistics.shipments`, warehouse turnover, return-rate by category.
  - **Audit & Compliance**: error rates from `audit.application_logs`, API performance from `audit.api_requests`, unauthorized changes from `audit.record_changes`, fraud-pattern detection.
- **Automation**: `refresh_all_analytics()` stored procedure.
- **Export**: JSON export functions using `json_agg`.

### Day 29 — Dashboard & Final Presentation
- **Stack**: HTML5, CSS Grid, Chart.js.
- **Tabs**: Executive, Sales, Customers, Products, Stores, Finance, Audit, Operations.
- **Pipeline**: SQL → `export_all_json.sh` → JSON → Dashboard.
- **Deploy**: GitHub Pages.
- **Presentation**: Live demo, business insights per module, technical highlights (CTEs, window functions, MVs), Q&A.

---

## 📊 Practice problem totals (V3 → V4)

| Week | V3 problems | V4 problems |
| :--- | :---------: | :---------: |
| 1    | ~8          | ~12         |
| 2    | ~10         | ~29         |
| 3    | ~12         | ~28         |
| 4    | ~10         | ~28         |
| 5    | ~10         | ~21         |
| 6    | ~6 + capstone | ~12 + capstone |

V4 roughly **doubles** the hands-on problem count without adding sessions. The freed minutes from cut topics convert directly into student keyboard time.
