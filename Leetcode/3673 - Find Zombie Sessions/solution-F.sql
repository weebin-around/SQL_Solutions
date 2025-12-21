with cte1 as 
(select * from 
(select *,
first_value(event_timestamp) over (partition by session_id order by event_timestamp) as tm_sess_open,
last_value(event_timestamp) over (partition by session_id order by event_timestamp rows between current row and unbounded following) as tm_sess_close 
from app_events
)t
where EXTRACT(EPOCH FROM (tm_sess_close - tm_sess_open)) / 60 > 30
),
cte2 AS 
(select * from 
(select
session_id, user_id,
sum(case when event_type = 'scroll' then 1 else 0 end) as scroll_event,
sum(case when event_type = 'click' then 1 else 0 end) as click_event,
sum(case when event_type = 'purchase' then 1 else 0 end) as pur_event
from cte1
group by session_id,user_id
)x
where scroll_event >= 5 and 
(click_event::numeric/scroll_event) < 0.20 
and pur_event < 1
)

select 
cte1.session_id,cte1.user_id, extract (epoch from cte1.tm_sess_close - cte1.tm_sess_open)/60 as session_duration_minutes,cte2.scroll_event as scroll_count 
from cte1 
join cte2 
on cte1.session_id = cte2.session_id
where cte1.event_type <> 'purchase'
group by cte1.session_id,cte1.user_id, extract (epoch from cte1.tm_sess_close - cte1.tm_sess_open),cte2.scroll_event
order by cte2.scroll_event desc,
cte1.session_id asc;

