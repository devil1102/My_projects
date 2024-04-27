--find top 10 highest revenue genreating products

select top 10 product_id, sum(sale_price)as total_sales
from df_orders
group by product_id
order by total_sales desc;


--top 5 highest selling product in each region
with cte as (
select *, ROW_NUMBER() over (partition by region order by total_sales desc) rn
from (
select  region,product_id, sum(sale_price)as total_sales
from df_orders
group by region,product_id
) a)
select region,product_id, total_sales
from cte 
where rn <=5;

--find month over month growth comparision for 2022 and 2023	

with cte as (select YEAR(order_date)order_year, MONTH(order_date)order_month, sum(sale_price) total_sales
from df_orders
group by YEAR(order_date), MONTH(order_date)
)

select order_month,
		sum(case when order_year = '2022' then total_sales else 0 end)sales_2022,
	  sum(case when order_year = '2023' then total_sales else 0 end)sales_2023
from cte
group by order_month;

--for each category which month had the highest sales
select category,order_date,sales
from (
select category, FORMAT(order_date, 'yyyyMM') order_date, sum(sale_price) sales,  DENSE_RANK() over (partition by category order by sum(sale_price) desc) the_rank
from df_orders
group by category, FORMAT(order_date, 'yyyyMM'))a
where the_rank = 1

--which category had the highest growth by profit in 2022 and 2023 by percentage


	with cte as (
	select YEAR(order_date)order_year,sub_category, sum(sale_price) total_sales
	from df_orders
	group by YEAR(order_date), MONTH(order_date),sub_category
	), cte2 as(
	select sub_category,
			sum(case when order_year = '2022' then total_sales else 0 end)sales_2022,
		  sum(case when order_year = '2023' then total_sales else 0 end)sales_2023
	from cte
	group by sub_category)
	select sub_category, sales_2022,sales_2023, growth_by_percent
	from (
	select *, CONCAT((sales_2023-sales_2022)/(sales_2022) *100, '%') growth_by_percent,
	ROW_NUMBER() over(order by (sales_2023-sales_2022)/(sales_2022) *100 desc) as rannk
	from cte2 )ca
	where rannk =1
	
	--which category had the highest growth by profit in 2022 and 2023 in dollars

with cte as (
	select YEAR(order_date)order_year,sub_category, sum(sale_price) total_sales
	from df_orders
	group by YEAR(order_date), MONTH(order_date),sub_category
	), cte2 as(
	select sub_category,
			sum(case when order_year = '2022' then total_sales else 0 end)sales_2022,
		  sum(case when order_year = '2023' then total_sales else 0 end)sales_2023
	from cte
	group by sub_category)
	select top 1 *,concat('$ ', (sales_2023-sales_2022)) growth
	from cte2 
	order by  (sales_2023-sales_2022)  desc