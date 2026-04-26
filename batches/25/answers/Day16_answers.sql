-- 1)
select 
	*,
	ROUND(budget * 100.0 / (sum(budget) OVER()),3) as pct
from marketing.campaigns

-- 2)
select 
	*,
	ROUND(AVG(salary) OVER(partition by store_id),2) as store_avg,
	salary  - ROUND(AVG(salary) OVER(partition by store_id),2) as diff
from stores.employees

-- 3)
select 
	*,
	count(price) OVER(partition by brand_id) as total_prod_in_brand,
	MIN(price) OVER(partition by brand_id) as min_price_in_brand,
	MAX(price) OVER(partition by brand_id) as max_price_in_brand
from products.products

-- 4)
select 
	*,
	round(avg(net_total) OVER(partition by store_id),2) as store_avg,
	CASE
		WHEN net_total > (round(avg(net_total) OVER(partition by store_id),2)*3) THEN 'High Value'
		ELSE ' '
	END
from sales.orders

--5)
WITH final_table as (
	select 
		created_date,
		count(ticket_id) as date_total
	from support.tickets
	GROUP BY created_date
),
cumulative as (
	select *,
		sum(date_total) OVER(ORDER BY created_date) as cumulative_count
	from final_table
)
select *
from cumulative
where cumulative_count > 5000 -- on 2025-01-29 00:00:00

-- 6)
with store_rev as (
	select 
		*,
		sum(net_total) OVER(PARTITION BY store_id ORDER BY order_date,order_id) as cumulative_sum
	from sales.orders
)

select store_id, min(order_date) as first_cross_date from store_rev 
where cumulative_sum>10000000
GROUP BY store_id
ORDER BY first_cross_date
LIMIT 1

-- 7)
WITH daily_count as (
	select 
		DATE_TRUNC('day', view_timestamp) as date, 
		count(view_id) as page_views 
	FROM web_events.page_views
	GROUP BY DATE_TRUNC('day', view_timestamp)
	ORDER BY DATE_TRUNC('day', view_timestamp)
)
select *,
	sum(page_views) OVER(ORDER BY date) as cumulative_sum,
	ROUND(page_views * 100.0/ sum(page_views) OVER(ORDER BY date),2) as pct
from daily_count

-- 8)
WITH clean as (
	select 
		*, 
		EXTRACT('YEAR' from order_date) as year,
		EXTRACT('QUARTER' from order_date) as quarter
	from sales.orders
)

select *,
	sum(net_total) OVER(PARTITION BY year, quarter ORDER BY order_date,order_id) as cumulative_sum
from clean


-- 9)
select *, sum(net_total) OVER() from sales.orders
select *, sum(net_total) OVER(ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) from sales.orders
-- value in both table is same just diff is 2nd table is ordered by date 
-- UNBOUNDED PRECEDING 1st rows of partition
-- UNBOUNDED FOLLOWING last rows of partition 
-- and as we dont have any partition over here so it will take full table
-- Both queries return the same result because, in both cases, the window frame covers the entire table
	
-- 10)
select *, ROUND(avg(budget) OVER(ROWS BETWEEN CURRENT ROW AND 3 FOLLOWING),2) from marketing.campaigns
-- at the end the frame size decreases and avg is calculated of remaining values


-- 11)
select *,
	MIN(net_total) OVER(ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as min_5_last,
	count(*) OVER(ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as frame_size
from sales.orders

-- 12)
select *,
	sum(net_total) OVER(ORDER BY order_date, order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as default_frame,
	sum(net_total) OVER(ORDER BY order_date, order_id ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as limited_5_frame
from sales.orders

-- 13)
select *,
	round(avg(salary) OVER(ORDER BY employee_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),2) as centered_avg
from stores.employees
-- in first and last row the frame will be limited according to availability and avg will be calculated according to available once 
-- window automatically shrinks at the boundaries

-- 14)
WITH clean as (
	select  
		DATE_TRUNC('day', order_date) as date, 
		count(*) as total_orders 
	FROM sales.orders
	GROUP BY DATE_TRUNC('day', order_date)
)
select *,
	ROUND(AVG(total_orders) OVER(ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as avg_7_day
from clean
-- 3 has lower frame size 
-- 10 has full frame size (7)


-- 15)
WITH clean as (
	select  
		DATE_TRUNC('day', order_date) as date, 
		sum(net_total) as daily_total 
	FROM sales.orders
	GROUP BY DATE_TRUNC('day', order_date)
)
select *,
	ROUND(AVG(daily_total) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as avg_7_day,
	ROUND(AVG(daily_total) OVER(ORDER BY date ROWS BETWEEN 13 PRECEDING AND CURRENT ROW),2) as avg_14_day,
	ROUND(AVG(daily_total) OVER(ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW),2) as avg_30_day
from clean

-- 16)
WITH clean as (
	select  
		DATE_TRUNC('day', order_date) as date, 
		sum(net_total) as daily_total 
	FROM sales.orders
	GROUP BY DATE_TRUNC('day', order_date)
),
avg_cal as (
	select *,
		ROUND(AVG(daily_total) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as avg_7_day
	from clean
)
select *,
 	ROUND(daily_total * 100.0 / avg_7_day,2) as pct,
	CASE
		WHEN daily_total * 100.0 / avg_7_day > 200 THEN 'MEGA SPIKE'
		else 'NORMAL'
	END as spike_status
from avg_cal

-- 17)
WITH clean as (
	select  
		store_id,
		DATE_TRUNC('day', order_date) as date, 
		sum(net_total) as daily_total 
	FROM sales.orders
	GROUP BY store_id, DATE_TRUNC('day', order_date)
),
-- A smooth trend = values change gradually (low fluctuation) STDDEV()
-- A noisy trend = values jump up/down a lot
-- STDDEV - avg value of how values are far from mean
final_table as (
	select *,
		ROUND(avg(daily_total) OVER(PARTITION BY store_id ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as avg_7_day
	from clean
) 
select 
	store_id, 
	STDDEV(avg_7_day) as deviation
from final_table
GROUP BY store_id
ORDER BY deviation
LIMIT 1

-- 18)
WITH clean as (
	select  
		DATE_TRUNC('day', order_date) as date, 
		sum(net_total) as daily_total 
	FROM sales.orders
	GROUP BY DATE_TRUNC('day', order_date)
),
avg_table as (
	select *,
		AVG(daily_total) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as avg_7_day,
		AVG(daily_total) OVER(ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as avg_30_day
	from clean
)

select *,
	CASE
		WHEN avg_7_day > avg_30_day THEN 'BULLISH'
		ELSE 'BEARISH'
	END
from avg_table

-- 19)
WITH filter_table as (
	select * from sales.orders
	WHERE EXTRACT('QUARTER' from order_date) = 4
)
select *,
	sum(net_total) OVER(PARTITION BY store_id) as store_net_total,
	sum(net_total) OVER(PARTITION BY store_id ORDER BY order_date) as cumulative_store_net_total
from filter_table

-- 20)
WITH filter_table as (
	select *,
		sum(net_total) OVER(PARTITION BY store_id) as store_net_total
	from sales.orders
),
pct_table as (
	select *,
		ROUND(net_total * 100.0 / store_net_total,4) as PCT,
		RANK() OVER(PARTITION BY store_id ORDER BY net_total DESC) as ord_rank
	from filter_table
)
select * from pct_table where ord_rank <= 5

-- 21)	
WITH filter_table as (
	select
		DATE_TRUNC('month', order_date) as month,
		sum(net_total) as net_total
	from sales.orders
	GROUP BY DATE_TRUNC('month', order_date)
)
select *,
	sum(net_total) OVER(PARTITION BY EXTRACT(year from month) ORDER BY month)
from filter_table

-- 22)
WITH daily_revenue as (
	select  
		DATE_TRUNC('day', order_date) as date, 
		sum(net_total) as daily_total 
	FROM sales.orders
	GROUP BY DATE_TRUNC('day', order_date)
)
select *,
	avg(daily_total) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as avg_7_day,
	count(daily_total) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as framesize
from daily_revenue

-- 23)
WITH daily_revenue as (
	select  
		DATE_TRUNC('day', order_date) as date, 
		sum(net_total) as daily_total 
	FROM sales.orders
	GROUP BY DATE_TRUNC('day', order_date)
),
seven_day_avg as (
	select *,
		avg(daily_total) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as avg_7_day,
		count(daily_total) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as framesize
	from daily_revenue
)

select *,
	CASE
		WHEN daily_total > 1.5 * avg_7_day THEN 'SPIKE'
		WHEN daily_total < 0.5 * avg_7_day THEN 'DIP'
		ELSE 'NORMAL'
	END
from seven_day_avg
-- IMP correction but not mentioned in questions
-- You already computed framesize 👏 — just use it:
-- WHEN framesize < 7 THEN NULL

-- 24)
WITH clean as (
	select  
		DATE_TRUNC('day', order_date) as date, 
		sum(net_total) as daily_total 
	FROM sales.orders
	GROUP BY DATE_TRUNC('day', order_date)
)
select *,
	SUM(daily_total) OVER(PARTITION BY (EXTRACT(YEAR from date)) ORDER BY date) as running_total_ytd,
	AVG(daily_total) OVER(w ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as avg_7_day,
	AVG(daily_total) OVER(w ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as avg_30_day
from clean
WINDOW 
	w as (ORDER BY date)


