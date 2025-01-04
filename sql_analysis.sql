--find top 10 highest reveue generating products 
select product_id, round(sum(sale_price*quantity),2) as revenue_generated
from df_orders
group by product_id
order by revenue_generated desc
limit 10

--find top 5 highest selling products in each region
with cte as
(select product_id, region,
round(sum(sale_price*quantity),2) as revenue_generated
from df_orders
group by product_id, region
)
select * from(
select *, row_number() over (partition by region order by revenue_generated
desc)
as rn from cte
)x  where rn<=5

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
 select year(order_date) as order_year,monthname(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),monthname(order_date)
)
select order_month,
sum(case when order_year=2022 then round(coalesce(sales,0),2) end) as 2022_sales,
sum(case when order_year=2023 then round(coalesce(sales,0),2) end) as 2023_sales
from cte
group by order_month
order by order_month

--for each category which month had highest sales 
with cte as
(SELECT DATE_FORMAT(order_date, "%Y-%M") as month_year,
category,
round(sum(sale_price*quantity),2) as sales
from df_orders
group by month_year, category
)
select * from
(
select *,
rank() over(partition by category order by sales desc)
as rn
from cte
) X
where rn=1

--which sub category had highest growth by profit in 2023 compare to 2022
with cte as
(select 
sub_category,
sum(case when year(order_date)=2022 then profit else 0 end) as 2022_profit,
sum(case when year(order_date)=2023 then profit else 0 end) as 2023_profit
from df_orders
group by sub_category
)
select sub_category, (2023_profit - 2022_profit) as growth
from cte
order by growth desc
limit 1