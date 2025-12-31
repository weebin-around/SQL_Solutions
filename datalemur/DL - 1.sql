SELECT tweets1 AS tweet_bucket, COUNT(user_id) AS users_num
FROM 
(SELECT user_id, COUNT(user_id) AS tweets1 
FROM tweets 
WHERE EXTRACT(YEAR FROM tweet_date) = 2022
GROUP BY user_id)t 
GROUP BY tweets1;
