# 🎓 SQL Curriculum: Batch 24 (RetailMart V2 Edition)

| **Parameter**      | **Details**                                                        |
| :----------------- | :----------------------------------------------------------------- |
| **Duration**       | 6 Weeks \| 29 Sessions                                             |
| **Schedule**       | Week 1 (4 days) + Weeks 2-6 (5 days each)                          |
| **Session Length** | 2 Hours per session                                                |
| **Total Hours**    | **58+ Hours** (Includes extra 2h sessions on Tuesdays from Week 2) |
| **Platform**       | PostgreSQL (latest), pgAdmin 4, VS Code                            |
| **Database**       | **RetailMart V2** (16 Schemas, 47 Tables)                          |

---

## 📅 Week 1: Foundations & Architecture (4 Days)

**Goal**: Strong grip on DDL, Data Types, and the RetailMart Schema.

- **Day 1: Introduction to SQL & Installation**
  - **Topics**: SQL Components (DDL, DML, DCL, TCL), DBMS vs RDBMS, PostgreSQL Architecture.
  - **Lab**: Install PostgreSQL (latest), pgAdmin 4, VS Code, Git.
  - **Setup**: VS Code for project folder management.
  - **Dataset**: Exploration of `RetailMart` schemas (`core`, `sales`, `audit`).

* **Day 2: Basic Queries & DDL Commands**
  - **Topics**: `CREATE DATABASE`, `CREATE SCHEMA`, `CREATE TABLE`. `SELECT version()`.
  - **Lab 1**: Create practice database `accio_<batch_no>` — build schemas and tables from scratch to learn DDL.
  - **Lab 2**: Import RetailMart V2 using `setup_accio_retailmart_raw.sql` (creates all 16 schemas + 47 tables automatically).
  - **Activity**: Explore RetailMart — list all schemas, tables, and row counts.

* **Day 3: PostgreSQL Data Types**
  - **Topics**: `INT`, `SERIAL`, `NUMERIC` (Money), `VARCHAR`, `TEXT`, `TIMESTAMP`.
  - **Advanced**: `JSONB`, `UUID` (used in `audit.trace_id`), `ARRAY`.
  - **Lab**: Selecting correct types for a new `marketing.surveys` table.

* **Day 4: Constraints & Keys**
  - **Topics**: `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `DEFAULT`.
  - **Lab**: Verify FK Integrity: `sales.orders(store_id)` -> `stores.stores(store_id)`.
  - **Lab**: Test `CHECK(price > 0)` and Cascading Deletes (`CASCADE`, `RESTRICT`).

---

## 📅 Week 2: Filtering, Logic & Aggregation (5 Days)

**Goal**: Master Data Filtering, Scalar Functions, and Grouping.

- **Day 5: Data Filtering & Sorting**
  - **Topics**: `WHERE`, `AND/OR`, `LIKE/ILIKE`, `BETWEEN`, `IN`, `IS NULL`.
  - **Lab**: "Find `customers` with gmail accounts using `LIKE '%@gmail.com'`."
  - **Lab**: Pagination using `LIMIT` & `OFFSET`.

- **Day 6: Scalar Functions (String & Date)**
  - **String Funcs**: `UPPER`, `LOWER`, `LENGTH`, `SUBSTRING`, `TRIM`, `CONCAT`, `REPLACE`.
  - **Date Funcs**: `NOW()`, `EXTRACT`, `AGE`, `TO_CHAR`, `DATE_TRUNC`.
  - **Lab**: "Format Customer Names (Proper Case) and Calculate Age from DOB."

- **Day 7: Conditional Logic & Derived Columns**
  - **Topics**: `CASE WHEN`, `COALESCE`, `NULLIF`, `CAST`.
  - **Lab**: "Segment Customers: 'VIP' (>10 Orders) vs 'Regular' using `CASE`."
  - **Lab**: Handle missing `return_reason` using `COALESCE`.

- **Day 8: Aggregate Functions & Grouping**
  - **Topics**: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `STRING_AGG`, `ARRAY_AGG`.
  - **Lab**: "Calculate Total Revenue (`gross_total`) per Region."
  - **Lab**: `HAVING` vs `WHERE`: "Find Stores with > ₹1M revenue."

- **Day 9: Joins - Part 1 (Foundations)**
  - **Topics**: `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`.
  - **Lab**: "List Orders with Customer Names" (`orders` + `customers`).
  - **Lab**: "Find Products Never Ordered" (`products` LEFT JOIN `order_items`).

---

## 📅 Week 3: Advanced Joins & Subqueries (5 Days)

**Goal**: Complex Multi-Table Relationships and Query Nesting.

- **Day 10: Joins - Part 2 (Advanced)**
  - **Topics**: `FULL OUTER JOIN`, Multi-table Joins.
  - **Lab**: "Full Supply Chain Trace": `orders` -> `shipments` -> `warehouses`.
  - **Lab**: "Find Unsold Inventory": `inventory` LEFT JOIN `order_items`.

- **Day 11: Self Join, Cross Join & Set Operations**
  - **Topics**: `SELF JOIN` (Hierarchy), `CROSS JOIN`, `UNION`, `INTERSECT`, `EXCEPT`.
  - **Lab**: "Employee-Manager Hierarchy" using `SELF JOIN`.
  - **Lab**: "Combine `audit.application_logs` and `audit.api_requests`" using `UNION`.

- **Day 12: Subqueries - Part 1**
  - **Topics**: Scalar vs Multi-row Subqueries (`IN`, `ANY`, `ALL`).
  - **Lab**: "Find products cheaper than the category average."
  - **Lab**: Subqueries in `SELECT` clause.

- **Day 13: Subqueries - Part 2 & CTEs**
  - **Topics**: Correlated Subqueries, `EXISTS`. **Common Table Expressions (CTEs)**.
  - **Lab**: "Recursive CTE: Generate an Org Chart from `stores.employees`."
  - **Lab**: "Churn Analysis: Find customers inactive for 6 months."

- **Day 14: Practice & Review Session**
  - **Focus**: Complex Join + Subquery challenges combining multiple concepts.
  - **Lab**: "Sales Performance Report: Join 5 tables + Calculate KPIs."

---

## 📅 Week 4: Window Functions & Transactions (5 Days)

**Goal**: Advanced Analytics and Transaction Management.

- **Day 15: Window Functions - Part 1 (Ranking)**
  - **Topics**: `OVER()`, `PARTITION BY`, `ROW_NUMBER`, `RANK`, `DENSE_RANK`.
  - **Lab**: "Rank top 3 highest paid employees **per department**."

- **Day 16: Window Functions - Part 2 (Aggregation)**
  - **Topics**: `SUM() OVER`, `AVG() OVER`, Running Totals, Moving Averages.
  - **Lab**: "Calculate Cumulative Revenue by Month."

* **Day 17: Window Functions - Part 3 (Value Access)**
  - **Topics**: `LEAD`, `LAG`, `FIRST_VALUE`, `LAST_VALUE`, `NTH_VALUE`.
  - **Lab**: "Calculate Month-over-Month Revenue Growth %."
  - **Lab**: "Analyze Session Duration from `web_events` using Lead/Lag."

* **Day 18: Query Performance Basics**
  - **Topics**: Common slow query patterns, Best practices for fast queries.
  - **Topics**: Avoiding `SELECT *`, Using proper WHERE clauses, Limiting results.
  - **Lab**: "Identify and fix slow queries in RetailMart database."

* **Day 19: Indexing Strategies**
  - **Topics**: Index Types (B-Tree, GIN for text search), `CREATE INDEX`.
  - **Lab**: "Create Optimal Indexes for Common Query Patterns."
  - **Lab**: Compare query speed before/after adding indexes.

---

## 📅 Week 5: Transactions & Database Engineering (5 Days)

**Goal**: Transaction Management, Normalization, Views, and Functions.

- **Day 20: Transactions & Error Control**
  - **Topics**: `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`.
  - **Lab**: "Simulate Order Placement": Deduct Inventory -> Insert Order. Rollback if stock low.

- **Day 21: ACID Properties & Transaction Isolation**
  - **Topics**: Atomicity, Consistency, Isolation, Durability.
  - **Concurrency**: Dirty Reads, Phantom Reads, Deadlocks.
  - **Lab**: Demonstrating `READ COMMITTED` vs `SERIALIZABLE` using `finance.expenses`.

- **Day 22: Normalization & Data Modeling**
  - **Topics**: 1NF, 2NF, 3NF, BCNF. Dependency Diagrams.
  - **Lab**: "Audit the RetailMart Schema": Why `addresses` is 3NF but `orders` has derived totals.

- **Day 23: Views & Materialized Views**
  - **Topics**: `CREATE VIEW`, `MATERIALIZED VIEW`, `REFRESH MATERIALIZED VIEW`.
  - **Lab**: "Create `v_executive_dashboard`: Consolidated Sales, Expenses, and HR stats."

- **Day 24: Functions (PL/pgSQL)**

* **Topics**: `CREATE FUNCTION`, Variables, Control Structures (`IF`, `CASE`, `LOOP`).
* **Lab**: "Create `get_customer_ltv(cust_id)` calculating total lifetime spend."

---

## 📅 Week 6: Automation & Capstone Project (5 Days)

**Goal**: Stored Procedures, Security, and End-to-End Project Delivery.

- **Day 25: Stored Procedures & Error Handling**
  - **Topics**: `CREATE PROCEDURE`, `BEGIN...EXCEPTION` blocks, `RAISE` statements.
  - **Lab**: "Create `admin_update_price(pid, price)`: Updates price AND logs to `audit.record_changes`."

* **Day 26: Database Security & User Management**
  - **Topics**: `CREATE USER/ROLE`, `GRANT`, `REVOKE`, Row-Level Security.
  - **Lab**: Create `readonly_analyst` user with access restricted to `analytics_schema`.
  - **Lab**: SQL Injection prevention patterns.

* **Day 27: RetailMart Analytics Project - Part 1 (Foundation & Core Analytics)**
  - **Setup**: Setup `analytics_schema`, Create metadata tables, Add indexes.
  - **Core Modules** (Create Views & Materialized Views):
    - **Sales Analytics**: Monthly trends, MoM/YoY growth, Payment modes, Day-of-week patterns
    - **Customer Analytics**: RFM Segmentation, CLV (Customer Lifetime Value), Cohort Retention
    - **Product Analytics**: Top products, ABC Analysis (Pareto), Category performance
  - **Deliverable**: 15+ views, 6 materialized views, Data quality checks
  - _Reference_: `batches/22/week_06/day_22_23_24/retailmart_analytics/` structure

* **Day 28: RetailMart Analytics Project - Part 2 (Advanced Analytics with V2 Schemas)**
  - **Enhanced Modules** (Leveraging New Schemas):
    - **Store & Finance Analytics**:
      - Store profitability (Revenue from `sales` - Expenses from `finance.expenses`)
      - Vendor payment analysis (`finance.vendor_payments`)
      - Budget vs Actual tracking
    - **Supply Chain & Operations**:
      - Delivery performance (SLA tracking with `logistics.shipments`)
      - Warehouse inventory turnover (`inventory.warehouses`)
      - Return rate analysis by category
    - **Audit & Compliance** (NEW for V2):
      - Application error rate tracking (`audit.application_logs` - ERROR/FATAL levels)
      - API performance (`audit.api_requests` - avg response time, failure rate)
      - Unauthorized data changes (`audit.record_changes` - price updates without approval)
      - Fraud detection patterns (suspicious order patterns)
  - **Automation**: Create `refresh_all_analytics()` stored procedure
  - **Export**: JSON export functions for all modules (using `json_agg`)

* **Day 29: Dashboard Creation & Final Presentation**
  - **Dashboard Build**:
    - **Stack**: HTML5, CSS Grid, Chart.js (responsive design)
    - **Tabs**: Executive Summary, Sales, Customers, Products, Stores, Finance, Audit, Operations
    - **Features**: Auto-refresh, data caching, error handling, dark mode
  - **Data Pipeline**: SQL → `export_all_json.sh` → JSON files → Dashboard
  - **Deploy**: GitHub Pages deployment with CI/CD
  - **Presentation**:
    - Live demo walkthrough (all 8 tabs)
    - Business insights from each module
    - Technical highlights (CTEs, Window Functions, Materialized Views)
    - Code review and Q&A