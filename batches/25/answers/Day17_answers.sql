-- 1)
WITH pre_nt as (
	select *,
		LAG(net_total) OVER(PARTITION BY cust_id ORDER BY order_date) as previous_net_total
	from sales.orders
)
select *,
	net_total - previous_net_total as diff
from pre_nt

-- 2)
WITH pre_cc as (
	select *,
		created_date - LAG(created_date) OVER(PARTITION BY agent_id ORDER BY created_date) as diff
	from support.tickets
)
select agent_id, MIN(diff) as gap
from pre_cc
GROUP BY agent_id
ORDER BY gap
LIMIT 1

-- 3)
WITH emp_details as (
	select 
		first_name as current_employee,
		LEAD(first_name) OVER(PARTITION BY store_id ORDER BY joining_date, employee_id) as next_employee, -- used (joining_date, employee_id) because 2 employees can join on same date 
		store_id
	from stores.employees
)

select * from emp_details
WHERE next_employee IS NOT NULL

-- 4)
WITH add_week as (
	select *,
		DATE_TRUNC('week', order_date) as order_week
	from sales.orders 
),
weekly_count as (
	select 
		order_week, 
		count(*) as ord_count 
	from add_week
	GROUP BY order_week
),
pct as (
	select *,
		LAG(ord_count) OVER(ORDER BY order_week) as previous_week_count,
		ROUND((ord_count - LAG(ord_count) OVER(ORDER BY order_week)) * 100.0 / LAG(ord_count) OVER(ORDER BY order_week),2) as pct
	from weekly_count
)
select *,
	CASE
		WHEN ABS(pct) > 10 THEN 'SPIKE'
		ELSE 'NORMAL'
	END
from pct

-- 5)
WITH first_emp as(
	select *,
		FIRST_VALUE(first_name) OVER(PARTITION BY dept_id ORDER BY joining_date) as first_employee
	from stores.employees
)
select dept_id, first_employee from first_emp
ORDER BY dept_id

-- 6)
select *,
	FIRST_VALUE(budget) OVER(ORDER BY start_date) as first_campaign_budget,
	LAST_VALUE(budget) OVER(ORDER BY start_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_campaign_budget
from marketing.campaigns

-- 7)
WITH range_matrics as (
	select *,
		FIRST_VALUE(net_total) OVER(PARTITION BY cust_id ORDER BY net_total) as smallest_amount,
		LAST_VALUE(net_total) OVER(PARTITION BY cust_id ORDER BY net_total ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as largest_amount
	from sales.orders
)
select *,
	largest_amount - smallest_amount as diff
from range_matrics

-- 8)
select *,
	LAST_VALUE(salary) OVER(PARTITION BY dept_id ORDER BY salary DESC)
from stores.employees


select *,
	LAST_VALUE(salary) OVER(PARTITION BY dept_id ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
from stores.employees


-- 9)
select *,
	NTH_VALUE(budget,2) OVER(ORDER BY budget DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as second_largest_value
from marketing.campaigns

-- 10)
WITH tier as (
	select *,
		FIRST_VALUE(salary) OVER w as gold,
		NTH_VALUE(salary, 2) OVER w as silver,
		NTH_VALUE(salary, 3) OVER w as bronze
	from stores.employees
	WINDOW w as (PARTITION BY dept_id ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
)
select 
	DISTINCT dept_id, 
	gold - bronze as diff 
from tier
ORDER BY diff DESC 


-- 11)
WITH add_resolved_time as (
select *,
	resolved_date - created_date as resolved_time
from support.tickets 
)
select *,
	NTH_VALUE(resolved_time, 5) OVER(PARTITION BY category ORDER BY resolved_time ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
from add_resolved_time
-- categpry with less the 5 tickets ans will be null 


-- 12)
WITH revenue_per_store as (
	select 
		store_id,
		SUM(net_total) as store_revenue
	from sales.orders
	GROUP BY store_id
),
podium as (
	select *,
		NTH_VALUE(store_revenue, 1) OVER w as first,
		NTH_VALUE(store_revenue, 2) OVER w as second,
		NTH_VALUE(store_revenue, 3) OVER w as third
	from revenue_per_store
	WINDOW 
		w as (order by store_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
),
calculate_gap as (
	select *, 
		first - store_revenue as gap_from_leader
	from podium
)
select * from calculate_gap

-- CHALLENGE SET A
-- 1)
WITH pre as (
	select *, 
		LAG(net_total) OVER(PARTITION BY cust_id ORDER BY order_date) as previous_ord_net_total
	from sales.orders
)
select *, 
	 net_total - previous_ord_net_total as diff 
from pre
WHERE net_total - previous_ord_net_total IS NOT NULL
ORDER BY diff DESC
-- IMP Mistake: didnt added order by order date in OVER of LAG

-- 2)
WITH month_rev as (
	select 
		DATE_TRUNC('month', order_date) as month, 
		sum(net_total) as month_rev 
	from sales.orders
	GROUP BY DATE_TRUNC('month', order_date)
)

select *,
	(month_rev - LAG(month_rev) OVER(ORDER BY month)) * 100.0 / LAG(month_rev) OVER(ORDER BY month) as hike_pct
from month_rev
ORDER BY hike_pct DESC

-- 3)
WITH added_next_emp_joining_date as (
	select *,
		LEAD(joining_date) OVER(PARTITION BY dept_id ORDER BY joining_date) as next_emp_joining_date
	from stores.employees
)
select *,
	next_emp_joining_date - joining_date as hiring_gap
from added_next_emp_joining_date

-- 4)
WITH recent_tic as (
	select *,
		LAG(created_date) OVER(PARTITION BY agent_id ORDER BY created_date) as recent_ticket
	from support.tickets
	where resolved_date is not null
),
time_from_recent_tic as (
	select *, created_date - recent_ticket as time_from_recent_ticket from recent_tic
	where recent_ticket IS NOT NULL
)
select agent_id, 
	AVG(time_from_recent_ticket) as avg_intervel_btw_tic_creation
from time_from_recent_tic
GROUP BY AGENT_ID 
ORDER BY avg_intervel_btw_tic_creation
-- ⚠️ need to be aware about agent level and row level
-- If we need agent level answer than we need to make sure we have use group by 
-- and if row level (each entry) than no need of group by

-- CHALLENGE SET B
-- 5)
WITH add_dept_matric as (
	select *,
		FIRST_VALUE(salary) OVER(PARTITION BY dept_id ORDER BY salary DESC) as dept_hightes_salary,
		FIRST_VALUE(salary) OVER(PARTITION BY dept_id ORDER BY salary ASC) as dept_lowest_salary
	from stores.employees 
)
select *,
	ROUND(((salary - dept_lowest_salary) * 100.0 / (dept_hightes_salary - dept_lowest_salary)),2) as pct_of_range
from add_dept_matric
-- Perentile formula: ((value - min) / (max - min)) * 100.0

-- 6) NOT ABLE TO SOLVE
select *,
	FIRST_VALUE(net_total) OVER(partition by store_id ORDER BY order_date ASC) as first_store_ord_amount,
	FIRST_VALUE(net_total) OVER(partition by store_id ORDER BY order_date DESC) as last_store_ord_amount
from sales.orders 

-- 7)
WITH trend as (
	select *,
		FIRST_VALUE(budget) OVER(ORDER BY start_date ASC) as first_campaign_budget,
		FIRST_VALUE(budget) OVER(ORDER BY start_date DESC) as last_campaign_budget
	from marketing.campaigns 
),
final as (
	select first_campaign_budget, last_campaign_budget from trend
	GROUP BY first_campaign_budget, last_campaign_budget
)
select *,
	CASE
		WHEN first_campaign_budget<last_campaign_budget THEN 'Trend Increasing'
		ELSE 'Trend Decreasing'
	END as budget_trend
from final

-- CHALLENGE SET C
-- 8)
select *,
	FIRST_VALUE(salary) OVER w as gold,
	NTH_VALUE(salary,2) OVER w as silver,
	NTH_VALUE(salary,3) OVER w as bronze
from stores.employees
WINDOW w as (PARTITION BY dept_id ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)

-- 9)
WITH ranked_table as (
	select *,
		NTH_VALUE(net_total, 2) OVER (PARTITION BY store_id ORDER BY net_total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as top2_net_total,
		FIRST_VALUE(net_total) OVER w as top1_net_total,
		FIRST_VALUE(net_total) OVER w - NTH_VALUE(net_total, 2) OVER (PARTITION BY store_id ORDER BY net_total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as diff_from_top1
	from sales.orders
	WINDOW w as (PARTITION BY store_id ORDER BY net_total DESC)
)
select store_id, top2_net_total, top1_net_total, diff_from_top1
from ranked_table
WHERE diff_from_top1 IS NOT NULL
GROUP BY store_id, top2_net_total, top1_net_total, diff_from_top1
ORDER BY store_id

-- 10)
WITH store_rev as (
	select 
		store_id,
		SUM(net_total) as store_rev
	from sales.orders
	GROUP BY store_id -- IMP
)
select *,
	DENSE_RANK() OVER(ORDER BY store_rev DESC) as store_rank,
	FIRST_VALUE(store_rev) OVER w as top1,
	FIRST_VALUE(store_rev) OVER w - store_rev as gap_from_top1,
	NTH_VALUE(store_rev,2) OVER w as top2,
	NTH_VALUE(store_rev,2) OVER w - store_rev as gap_from_top2,
	LAG(store_rev) OVER(ORDER BY store_rev DESC) as prev_store_rev 
from store_rev
WINDOW w as (ORDER BY store_rev DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
-- 2 NTH value was same as 1st why ?? because earlier I didnt grouped stores and because of this it created multiple rows of top 1 entry rows so 2nd row is also the 1st value 


