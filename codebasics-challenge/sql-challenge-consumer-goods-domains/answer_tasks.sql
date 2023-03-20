-- ----------------------------------------------------------------------------------------------
-- Shout out to codebasics.com for providing this SQL challenge!
-- Link to challenge: https://codebasics.io/challenge/codebasics-resume-project-challenge
-- Challenge in the consumer goods domain

use gdb023;
-- ----------------------------------------------------------------------------------------------



-- ----------------------------------------------------------------------------------------------
-- 1. provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
select distinct market
from dim_customer
where region = 'APAC' and customer = 'Atliq Exclusive'
order by 1 asc;




-- ----------------------------------------------------------------------------------------------
-- 2. what is the percentage of unique product increase in 2021 vs. 2020?
select
	count(distinct case when cost_year = 2020 then product_code else null end) as unique_prod_2020
    , count(distinct case when cost_year = 2021 then product_code else null end) as unique_prod_2021
    , round((count(distinct case when cost_year = 2021 then product_code else null end) - 
		count(distinct case when cost_year = 2020 then product_code else null end)) / 
        count(distinct case when cost_year = 2020 then product_code else null end) *100.0,2) as perct_diff
from fact_manufacturing_cost;




-- ----------------------------------------------------------------------------------------------
-- 3. provide a report with all the unique product counts for each segment and 
-- sort them in descending order of product counts.
select
	segment
    , count(distinct product_code) as num_unique_prod
from dim_product
group by 1
order by 2 desc;




-- ----------------------------------------------------------------------------------------------
-- 4. Which segment had the most increase in unique products in 2021 vs 2020?


select
	segment
	, count(distinct case when cost_year = 2020 then mc.product_code else null end) as unique_prod_2020
	, count(distinct case when cost_year = 2021 then mc.product_code else null end) as unique_prod_2021
	, round((count(distinct case when cost_year = 2021 then mc.product_code else null end) - 
		count(distinct case when cost_year = 2020 then mc.product_code else null end)) / 
        count(distinct case when cost_year = 2020 then mc.product_code else null end) *100.0,2) as perct_diff
from dim_product dp
right join fact_manufacturing_cost mc on dp.product_code = mc.product_code
where cost_year in (2020,2021)
group by 1
order by 4 desc;




-- ----------------------------------------------------------------------------------------------
-- 5. Get the products that have the highest and lowest manufacturing costs

select 
	m.product_code    
    , p.product
    , m.manufacturing_cost
from fact_manufacturing_cost m
join dim_product p on m.product_code = p.product_code
where 
	m.manufacturing_cost = (select max(manufacturing_cost) from fact_manufacturing_cost)
	or m.manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost);




-- ----------------------------------------------------------------------------------------------
-- 6. Generate a report which contains the top 5 customers who received an
-- average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.

select
	i.customer_code
    , avg(pre_invoice_discount_pct) as avg_pre_invoice_discount_pct
from fact_pre_invoice_deductions i
join dim_customer c on i.customer_code = c.customer_code
where fiscal_year = 2021 and c.market = "India"
group by 1
order by 2 desc
limit 5
;



-- ----------------------------------------------------------------------------------------------
-- 7. Get the complete report of the Gross sales amount for the customer “Atliq
-- Exclusive” for each month . This analysis helps to get an idea of low and
-- high-performing months and take strategic decisions

select
	month(date) as month
    ,year(date) as year
    , sum(s.sold_quantity*g.gross_price) as sales
from fact_sales_monthly s
join fact_gross_price g on s.product_code = g.product_code
join dim_customer dc on dc.customer_code = s.customer_code
where customer = 'Atliq Exclusive'
group by 2, 1
order by 2, 1
;




-- ----------------------------------------------------------------------------------------------
-- 8. In which quarter of 2020, got the maximum total_sold_quantity? The final
-- output contains these fields sorted by the total_sold_quantity,

select
	quarter(date) as quarter
    , sum(sold_quantity) as tot_sold_quantity
from fact_sales_monthly
where date between '2020-01-01' and '2020-12-31'
group by 1
order by 2 desc
;




-- ----------------------------------------------------------------------------------------------
-- 9. Which channel helped to bring more gross sales in the fiscal year 2021
-- and the percentage of contribution?
with cte as (
	select
		c.channel
		, sum(s.sold_quantity*g.gross_price) as sales
	from dim_customer c
	join fact_sales_monthly s on c.customer_code = s.customer_code
	join fact_gross_price g on s.product_code = g.product_code
	where s.fiscal_year = 2021
	group by 1),
  
tot_cte as (select sum(sales) as tot_sales from cte)

select 
	channel
    , sales
    , 100*sales/tot_sales as pcnt
from cte cross join tot_cte
;





-- ----------------------------------------------------------------------------------------------
-- 10.Get the Top 3 products in each division that have a high
-- total_sold_quantity in the fiscal_year 2021?

-- select count(distinct division) from dim_product;

select
	p.division
	, s.product_code
	, p.product
	, sum(s.sold_quantity) as total_sold
	, row_number() over(partition by p.division 
		order by sum(s.sold_quantity) desc) as "rank"
from fact_sales_monthly s
join dim_product p on s.product_code = p.product_code
where s.fiscal_year = 2021
group by 1,2,3
order by 5 asc
limit 3 -- there are 3 distinct divisions
;





