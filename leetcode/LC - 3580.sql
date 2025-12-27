with cte1 as 
(select *,
lead(rating,1) over ( partition by employee_id order by review_date ) as lead1,
lead(rating,2) over ( partition by employee_id order by review_date) as lead2,
lag(rating,1) over ( partition by employee_id order by review_date) as lag1,
lag(rating,2) over ( partition by employee_id order by review_date) as lag2
from performance_reviews
)
,cte2 as 
(select *, 
case 
    when (lead1 - rating > 0 and rating-lag1 > 0 ) then lead1 - lag1 
    when (lead2 - lead1 > 0 and lead1 - rating> 0 ) then lead1 - rating
    when (rating - lag1 > 0 and lag1 - lag2 > 0) then rating - lag2
end as improvement_score 
from cte1
where ((lead1 - rating > 0 and rating-lag1 > 0 ) 
or (lead2 - lead1 > 0 and lead1 - rating> 0 ) 
or (rating - lag1 > 0 and lag1 - lag2 > 0)
) 
)

select employee_id,e.name,improvement_score from
(select employee_id as emp_id,improvement_score,
row_number() over (partition by employee_id order by improvement_score desc) as rn
from cte2
)t
join employees e
on t.emp_id = e.employee_id
where rn = 1
order by improvement_score desc, name

