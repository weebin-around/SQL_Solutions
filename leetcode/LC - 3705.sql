with cte1 as 
(select 
customer_id,
count(order_timestamp) as order_total,
round(avg(order_rating),2) as avg_rating,
count(order_rating) as rated
from restaurant_orders
group by customer_id
),
cte2 as 
(select 
customer_id,
count(order_timestamp) as total_order_peak_hrs
from restaurant_orders
where extract(hour from order_timestamp) IN (11,12,13)
or extract(hour from order_timestamp) IN (18,19,20)
group by customer_id
)

select cte2.customer_id,
cte1.order_total as total_orders,
round((cte2.total_order_peak_hrs::numeric*100.0/ cte1.order_total),0) as peak_hour_percentage,
 cte1.avg_rating as average_rating
from cte2 
join cte1 on 
cte2.customer_id = cte1.customer_id
where cte1.avg_rating >= 4.00 
and 
round((cte2.total_order_peak_hrs::numeric*100.0/ cte1.order_total),0) >= 60
and 
cte1.order_total >=3
and round((cte1.rated::numeric*100.0/cte1.order_total),2) >= 50.00
order by cte1.avg_rating desc, cte1.customer_id desc
