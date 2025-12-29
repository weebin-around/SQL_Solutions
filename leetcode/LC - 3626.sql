with cte_prod as 
(select *, 
    count(product_name) over (partition by store_id) as cnt_prod,
    row_number() over (partition by store_id order by price desc) as exp_prod,
    row_number() over (partition by store_id order by price asc) as cheap_prod 
from inventory
)
,cte_final as 
(select 
    e.store_id,
    e.product_name as most_exp_product,
    c.product_name as cheapest_product,
    round((c.quantity::numeric/e.quantity::numeric),2) as imbalance 
from
((select *
    from inventory 
    where (store_id,product_name) in (select store_id,product_name from cte_prod where exp_prod = 1 and cnt_prod >= 3)
)e
join 
(
select *
    from inventory 
    where (store_id,product_name) in (select store_id,product_name from cte_prod where cheap_prod = 1 and cnt_prod >=3)
) c
on  
e.store_id = c.store_id
)
where e.quantity < c.quantity
)

select 
    cf.store_id,
    s.store_name,
    s.location,
    cf.most_exp_product,
    cf.cheapest_product,
    cast (cf.imbalance as numeric) as imbalance_ratio
from cte_final cf 
join stores s
on cf.store_id = s.store_id
order by cast (cf.imbalance as numeric) desc,s.store_name asc
