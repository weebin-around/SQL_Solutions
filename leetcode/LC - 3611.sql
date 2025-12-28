with week_ext as 
(select employee_id,
duration_hours,
date_trunc('week',meeting_date)::date as week_sel
from meetings
)
,cte_sum_hours as 
(select employee_id,sum(duration_hours),count(distinct week_sel) as count_week
from week_ext 
group by employee_id, week_sel 
having sum(duration_hours) >= 20
),
cte_mt_heavy_weeks as 
(
select employee_id, sum(count_week) as meeting_heavy_weeks
from cte_sum_hours
group by employee_id
having  sum(count_week) >= 2
)

select chw.employee_id, e.employee_name, e.department, chw.meeting_heavy_weeks
from cte_mt_heavy_weeks chw 
join employees e 
on chw.employee_id = e.employee_id
order by  chw.meeting_heavy_weeks desc, e.employee_name asc
