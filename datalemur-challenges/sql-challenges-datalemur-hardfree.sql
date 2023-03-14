-- Title: Y-on-Y Growth Rate
-- Link: https://datalemur.com/questions/yoy-growth-rate
/* Q: Assume you are given the table below containing information on user transactions for particular products. 
Write a query to obtain the year-on-year growth rate for the total spend of each product for each year.
Output the year (in ascending order) partitioned by product id, current year's spend, previous year's spend and 
year-on-year growth rate (percentage rounded to 2 decimal places)
*/

-- user_transactions table's columns: transaction_id | product_id | spend | transaction_date

with table_spend as
  (select 
    extract(year from transaction_date) as yr
    , product_id
    , sum(spend) as curr_year_spend
    , lag(sum(spend)) over(
      partition by product_id 
      order by extract(year from transaction_date)) as prev_year_spend
  from user_transactions
  group by 1, 2)
  
select 
  *
  , round(100.0*(curr_year_spend - prev_year_spend) / 
  prev_year_spend, 2) as yoy_rate
from table_spend;



-- -----------------------------------------------------------------------------------------------------
-- Title: Active User Retention
-- Link: https://datalemur.com/questions/user-retention
/* Q: Assume you have the table below containing information on Facebook user actions. 
Write a query to obtain the active user retention in July 2022. Output the month (in numerical format 1, 2, 3) 
and the number of monthly active users (MAUs).
*/

-- user_actions table's columns: user_id | event_id | event_type | event_date

with table_user as
  (select 
    case when extract(month from event_date) = 6 then user_id else null end as last_mon
    , case when extract(month from event_date) = 7 then user_id else null end as curr_mon
  from user_actions)
  
select 
  7 as mon
  ,count(distinct t1.last_mon::char || t2.curr_mon::char)
from table_user t1
join table_user t2
  on t1.last_mon = t2.curr_mon
;



