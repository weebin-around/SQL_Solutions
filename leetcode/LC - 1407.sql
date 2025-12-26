with cte1 as 
(select user_id, sum(distance) as trav_dist
from rides 
group by user_id 
) 

select u.name,
case 
    when cte1.trav_dist is null 
    then 0 
    else cte1.trav_dist
end as travelled_distance  
from users u
left join cte1 
on u.id = cte1.user_id 
order by 2 desc,1;
