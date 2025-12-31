SELECT EXTRACT(MONTH FROM event_date), COUNT(DISTINCT user_id)
FROM user_actions
WHERE user_id in (select distinct user_id from user_actions where EXTRACT(month from event_date)=6)
and EXTRACT(month from event_date)=7
GROUP BY EXTRACT(MONTH FROM event_date);
