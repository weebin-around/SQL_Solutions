with cte_loyal as
(select 
    customer_id, 
    sum(case when transaction_type = 'purchase'  then 1 else 0 end) as pur_txn,
    sum(case when transaction_type = 'refund'  then 1 else 0 end) as ref_txn,
    sum(case when transaction_type = 'purchase' or transaction_type = 'refund' then 1 else 0 end) as tot_trxn,
    min(transaction_date) as min_txn_dt,
    max(transaction_date) as max_txn_dt
from customer_transactions
group by customer_id
)

select customer_id from cte_loyal
where max_txn_dt - min_txn_dt >= 30
and pur_txn >= 3
and round((ref_txn:: numeric/tot_trxn),2) < 0.2
order by customer_id asc
