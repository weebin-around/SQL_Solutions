with cte1 as 
(select *,
row_number() over (partition by season order by qnt desc,prc desc) as rn 
 from 
(select p.category as category,
case 
    when extract(month from s.sale_date) IN (12,1,2) then 'Winter'
    when extract(month from s.sale_date) IN (3,4,5) then 'Spring'
    when extract(month from s.sale_date) IN (6,7,8) then 'Summer'
    when extract(month from s.sale_date) IN (9,10,11) then 'Fall'
end as season,
sum(s.quantity) as qnt,
sum(s.quantity * s.price) as prc
from sales s 
join products p
on s.product_id = p.product_id
group by p.category,season
)t )

select season,category, qnt as total_quantity, prc as total_revenue 
from cte1 
where rn = 1


