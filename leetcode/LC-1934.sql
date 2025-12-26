WITH cte1 AS 
(SELECT s.user_id AS uid,
SUM(CASE WHEN c.time_stamp IS NOT NULL AND action = 'confirmed' THEN 1 ELSE 0 END) AS c1,
SUM(CASE WHEN c.time_stamp IS NOT NULL AND action <> 'confirmed' THEN 1 ELSE 0 END) AS c2,
(SUM(CASE WHEN c.time_stamp IS NOT NULL AND action = 'confirmed' THEN 1 ELSE 0 END) +
SUM(CASE WHEN c.time_stamp IS NOT NULL AND action <> 'confirmed' THEN 1 ELSE 0 END) ) AS c3
FROM signups s
LEFT JOIN confirmations c
ON s.user_id = c.user_id 
GROUP BY s.user_id
)

SELECT uid AS user_id,
       ROUND(CAST(c1 AS numeric) / COALESCE(NULLIF(c3, 0), 1), 2) AS confirmation_rate
FROM cte1;



