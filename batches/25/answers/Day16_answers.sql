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
)

select *,
	sum(date_total) OVER(ORDER BY created_date) as cumulative_count
from final_table

-- 6)








select * FROM web_events.page_views
select * FROM support.tickets
select * FROM web_events.page_views
select * FROM web_events.page_views
select * FROM web_events.page_views
