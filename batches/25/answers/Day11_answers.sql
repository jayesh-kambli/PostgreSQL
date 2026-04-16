-- 1)
select * from stores.stores s1
	JOIN stores.stores s2 ON s2.region_id = s1.region_id AND s2.store_id < s1.store_id

-- 2)
select 
	e1.first_name || ' ' || e1.last_name as e1_name,
	e1.salary as e1_salary,
	e2.first_name || ' ' || e2.last_name as e2_name,
	e2.salary as e2_salary 
from stores.employees e1
JOIN stores.employees e2 ON e1.store_id = e2.store_id AND e1.employee_id > e2.employee_id
WHERE ABS(e1.salary - e2.salary) <= 5000 

-- 3)
select 
	e1.dept_id, 
	count(*)
from stores.employees e1
JOIN stores.employees e2 ON e1.dept_id = e2.dept_id AND e1.employee_id > e2.employee_id
WHERE ABS(e1.salary - e2.salary) > 100000
GROUP BY e1.dept_id
ORDER BY e1.dept_id

-- new functions
-- select generate_series(1,10,1)
-- select unnest(ARRAY[1,2,3])

-- 4)
select t.tier_id, t.tier_name, mp.marketing_platform
from loyalty.tiers t
CROSS JOIN (
select UNNEST(ARRAY['Email','Website','Instagram','Facebook']) as marketing_platform
	) mp

-- 5)
-- cross join doesnt produces null records so its simply not possible with cross join + where
-- possible with cross join + group by + having + count + case

-- stores per region (just add having to filter out the region with 0 stores)
SELECT r.region_id, r.region_name,
	COUNT(CASE WHEN r.region_id = s.region_id THEN 1 END) as total_stores
FROM core.dim_region r
CROSS JOIN stores.stores s
GROUP BY r.region_id,  r.region_name
ORDER BY r.region_id;

-- 6)
select s.store_id, s.store_name, q.quarter from stores.stores s
	CROSS JOIN (
		select UNNEST(ARRAY['q1','q2','q3','q4']) as quarter
	) q
