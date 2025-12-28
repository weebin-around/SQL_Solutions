with cte_half as 
(select driver_id, 
    case 
    when extract(month from trip_date) IN (1,2,3,4,5,6) then 'first_half'
    when extract(month from trip_date) IN (7,8,9,10,11,12) then 'second_half' 
end as half,
round((distance_km:: numeric/nullif(fuel_consumed,0)),2) as avg_fl_eff
from trips
)
,cte_calc as
(select
    driver_id,
    round((AVG(case when half = 'first_half' then avg_fl_eff else null end)::numeric),2) as first_half_avg,
    round((AVG(case when half = 'second_half' then avg_fl_eff else null end)::numeric),2) as second_half_avg
    from cte_half
group by driver_id
)

select 
cc.driver_id, 
d.driver_name, 
cc.first_half_avg,
cc.second_half_avg,
round((cc.second_half_avg - cc.first_half_avg)::numeric,2) as efficiency_improvement 
from cte_calc cc
join drivers d 
on cc.driver_id = d.driver_id 
where 
(cc.first_half_avg is not null)
and 
(cc.second_half_avg is not null)
order by (cc.second_half_avg - cc.first_half_avg) desc, d.driver_name 
