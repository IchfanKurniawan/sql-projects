-- -------------------------------------------------------------------------------------------------------------------------
-- Analysis for:
-- 		1. RFM analysis 
-- 		2. User Retention (for 2013 & 2014)


use mavenfuzzyfactory;
-- -------------------------------------------------------------------------------------------------------------------------


-- -------------------------------------------------------------------------------------------------------------------------
-- 		1. RFM analysis 

select 
	max(date(created_at))
from orders; -- '2015-03-20'

with table_rfm_value as(
	select
		user_id
		, datediff('2015-03-20',
			max(date(created_at)) over(partition by user_id order by date(created_at))) as recency
		, count(distinct order_id) as frequency
		, sum(price_usd - cogs_usd) as monetary
	from orders
	group by 1 order by 1)

-- the frequency in range 1-3    
-- select min(frequency), max(frequency)
-- from table_rfm_value
-- variable R & M are more important than the F

, table_RFM as(
	select
		ntile(5) over(order by recency desc) as R
		, frequency as F
		, ntile(5) over(order by monetary asc) as M
	from table_rfm_value)
    
select
	*
    , case when R = 5 and M in (4,5) then 'champion' 
		when R in (4,5) and M in (2,3) then 'potential_loyalist'
        when R in (3,4) and M in (4,5) then 'loyal_customer'
        when R = 3 and M in (1,2) then 'about_to_sleep'
        when R in (1,2) and M in (1,2) then 'hibernating'
        when R in (1,2) and M in (3,4) then 'at risk'
        when R in (1,2) and M = 5 then 'cant_lose_them'
        when R = 3 and M = 3 then 'need_attention'
        when R = 4 and M = 1 then 'promising'
        when R = 5 and M = 1 then 'new_customer'
        end as segment
from table_RFM
;




-- -------------------------------------------------------------------------------------------------------------------------
-- 		2. User Retention (for 2013 & 2014)

-- for each customer, find the first month of purchase
with first_buy as(
	select 
		user_id
		, min(month(created_at)) over(partition by user_id order by created_at) as first_mon
	from orders
	where created_at between '2014-01-01' and '2014-12-31'
	group by 1)

-- for all purchase records, find the inteval from the first month of user
, next_buy as(
	select
		o.user_id
		, month(created_at) - first_mon as buy_interval
	from orders o
	join first_buy f on o.user_id = f.user_id
	where created_at between '2014-01-01' and '2014-12-31')
 
 -- the count of user id in the first_month
, init_user_count as(
	select
		first_mon
		, count(distinct user_id) as init_user_buy
	from first_buy
	group by 1)

-- grouping count of user id per first month & buy interval 
 , customer_churn as (
	select
		first_mon
		, buy_interval
		, count(distinct fb.user_id) as count_cust
	from first_buy fb
	join next_buy nb on fb.user_id = nb.user_id
	group by 1, 2)

-- customer churn in %
select
	cc.first_mon
	, cc.buy_interval+1 as month_buy
	, cc.count_cust
	, round(100.0*cc.count_cust/iuc.init_user_buy,2) as 'cust_churn_prct'
from customer_churn cc
join init_user_count iuc on cc.first_mon = iuc.first_mon
;





-- -------------------------------------------------------------------------------------------------------------------------
-- 		2. User Retention (yearly basis)

-- for each customer, find the first month of purchase
with first_buy as(
	select 
		user_id
		, min(year(created_at)) over(partition by user_id order by created_at) as first_year
	from orders
	where created_at between '2012-01-01' and '2014-12-31'
	group by 1)

-- for all purchase records, find the inteval from the first year of user
, next_buy as(
	select
		o.user_id
		, year(created_at) - first_year as buy_interval
	from orders o
	join first_buy f on o.user_id = f.user_id
	where created_at between '2012-01-01' and '2014-12-31')
 
 -- the count of user id in the first_year
, init_user_count as(
	select
		first_year
		, count(distinct user_id) as init_user_buy
	from first_buy
	group by 1)

-- grouping count of user id per first month & buy interval 
 , customer_churn as (
	select
		first_year
		, buy_interval
		, count(distinct fb.user_id) as count_cust
	from first_buy fb
	join next_buy nb on fb.user_id = nb.user_id
	group by 1, 2)

-- customer churn in %
select
	cc.first_year
	, cc.buy_interval+1 as year_buy
	, cc.count_cust
	, round(100.0*cc.count_cust/iuc.init_user_buy,2) as 'cust_churn_prct'
from customer_churn cc
join init_user_count iuc on cc.first_year = iuc.first_year
;