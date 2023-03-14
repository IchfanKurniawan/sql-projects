-- -----------------------------------------------------------------------------------------------------
-- Title: User's Third Transaction
-- Link: https://datalemur.com/questions/sql-third-transaction
/* Q: Assume you are given the table below on Uber transactions made by users. 
Write a query to obtain the third transaction of every user. Output the user id, spend and transaction date.
*/

-- transactions table's columns: user_id | spend | transaction_date

with 
  cte_num_trsc as
  (select 
    user_id
  , spend
  , transaction_date
    , row_number() over(partition by user_id 
    order by transaction_date asc) as num_trsc
  from transactions)

select 
  user_id
  , spend
  , transaction_date
from cte_num_trsc
where num_trsc = 3
;



-- -----------------------------------------------------------------------------------------------------
-- Title: Sending vs. Opening Snaps
-- Link: https://datalemur.com/questions/time-spent-snaps
/* Q: Assume you are given the tables below containing information on Snapchat users, their ages, and 
their time spent sending and opening snaps. Write a query to obtain a breakdown of the 
time spent sending vs. opening snaps (as a percentage of total time spent on these activities) for each age group.
Output the age bucket and percentage of sending and opening snaps. Round the percentage to 2 decimal places.
*/

-- activities table's columns: activity_id | user_id | activity_type | time_spent | activity_date
-- age_breakdown table's columns: user_id | age_bucket

with table_time as
  (select
    age_bucket
    , case when activity_type = 'open' then time_spent else 0 end as open_time
    , case when activity_type = 'send' then time_spent else 0 end as send_time
  from age_breakdown a 
  join activities c 
    on a.user_id = c.user_id)
    
select 
  age_bucket
  , round(100.0* sum(send_time) / (sum(open_time) + sum(send_time)), 2) as send_perc
  , round(100.0* sum(open_time) / (sum(open_time) + sum(send_time)), 2) as open_perc
from table_time
group by 1
order by 1;



-- -----------------------------------------------------------------------------------------------------
-- Title: Tweets' Rolling Averages
-- Link: https://datalemur.com/questions/rolling-average-tweets
/* Q: The table below contains information about tweets over a given period of time. 
Calculate the 3-day rolling average of tweets published by each user for each date that a tweet was posted. 
Output the user id, tweet date, and rolling averages rounded to 2 decimal places.
*/

-- tweets table's columns: tweet_id | user_id | tweet_date

select 
  user_id
  , tweet_date
  , round(avg(count(tweet_id)) over(
  partition by user_id 
  order by tweet_date
  rows between 2 preceding and current row), 2) as rolling_avg_3days
from tweets
group by 1, 2
order by 1, 2
;



-- -----------------------------------------------------------------------------------------------------
-- Title: Highest-Grossing Items
-- Link: https://datalemur.com/questions/sql-highest-grossing
/* Q: Assume you are given the table containing information on Amazon customers and 
their spending on products in various categories. Identify the top two highest-grossing products 
within each category in 2022. Output the category, product, and total spend.
*/

-- product_spend table's columns: category | product | user_id | spend | transaction_date
with table_spend as
  (select 
    category
    , product
    , sum(spend) as total_spend
    , rank() over(partition by category 
    order by sum(spend) desc) as ranking
    
  from product_spend
  where transaction_date between '01/01/2022'  and '12/31/2022'
  group by 1, 2)

select 
  category
  , product
  , total_spend
from table_spend
where ranking < 3
order by 1, 3 desc, 2 asc
;




-- -----------------------------------------------------------------------------------------------------
-- Title: Top 5 Artists
-- Link: https://datalemur.com/questions/top-fans-rank
/* Q: Assume there are three Spotify tables containing information about the artists, songs, and 
music charts. Write a query to determine the top 5 artists whose songs appear 
in the Top 10 of the global_song_rank table the highest number of times. 
From now on, we'll refer to this ranking number as "song appearances".
Output the top 5 artist names in ascending order along with their song appearances ranking 
(not the number of song appearances, but the rank of who has the most appearances). 
The order of the rank should take precedence.
*/

-- artists table's columns: artist_id | artist_name
-- songs table's columns: song_id | artist_id
-- global_song_rank columns: day | song_id | rank

with top_appr as
  (select 
    a.artist_name
    , count(g.song_id) as num_appr
    , dense_rank() over(order by count(g.song_id) desc) as artist_rank
  from artists a
  join songs s 
    on a.artist_id = s.artist_id
  join (select * 
      from global_song_rank 
      where rank <=10) g 
    on s.song_id = g.song_id
  group by 1)

select artist_name, artist_rank
from top_appr
where artist_rank <=5
;




-- -----------------------------------------------------------------------------------------------------
-- Title: Signup Activation Rate
-- Link: https://datalemur.com/questions/signup-confirmation-rate
/* Q: New TikTok users sign up with their emails. They confirmed their signup by replying to 
the text confirmation to activate their accounts. Users may receive multiple text messages for 
account confirmation until they have confirmed their new account.
Write a query to find the activation rate of the users. 
*/

-- emails table's columns: email_id | user_id | signup_date
-- texts table's columns: text_id | email_id | signup_action

select
  round(1.0* 
    (select count(distinct email_id) as num_confirm
    from texts
    where signup_action = 'Confirmed')/
    (select count(user_id) as num_total
    from emails), 2) 
  as activation_rate
  
 
 
 -- -----------------------------------------------------------------------------------------------------
-- Title: Frequently Purchased Pairs
-- Link: https://datalemur.com/questions/frequently-purchased-pairs
/* Q: Assume you are given the following tables on Walmart transactions and products. 
Find the number of unique product combinations that are purchased in the same transaction.
*/

-- transactions  table's columns: transaction_id | product_id | user_id | transaction_date
-- products table's columns: product_id | product_name

with table_product_id as(
  select
    t1.product_id
    , t2.product_id as t2_prod_id
    , t1.product_id*t2.product_id as mul
  from transactions t1
  join transactions t2 
  on (t1.transaction_id = t2.transaction_id) 
    and (t1.product_id != t2.product_id)
)

select count(distinct mul) as unique_combination
from table_product_id
;



 -- -----------------------------------------------------------------------------------------------------
-- Title: Supercloud Customer
-- Link: https://datalemur.com/questions/supercloud-customer
/* Q: A Microsoft Azure Supercloud customer is a company which buys at least 1 product from each product category.
Write a query to report the company ID which is a Supercloud customer.
*/

-- customer_contracts table's columns: customer_id | product_id | amount
-- products table's columns: pproduct_id | product_category | product_name

select 
  c.customer_id
from customer_contracts c
left join products p
  on c.product_id = p.product_id
group by 1
having 
  count(distinct p.product_category) = 
  (select count(distinct product_category) 
  from products)
;



 -- -----------------------------------------------------------------------------------------------------
-- Title: Odd and Even Measurements
-- Link: https://datalemur.com/questions/odd-even-measurements
/* Q: Assume you are given the table containing measurement values obtained from a 
Google sensor over several days. Measurements are taken several times within a given day.
Write a query to obtain the sum of the odd-numbered and even-numbered measurements on 
a particular day, in two different columns. Refer to the Example Output below for the output format.
*/

-- measurements  table's columns: measurement_id | measurement_value | measurement_time

with table_measure as  
  (select
    *
    ,row_number() over(partition by date(measurement_time) 
    order by measurement_time asc) as rn
  from measurements
  order by measurement_time),

table_odd_even as(
  select 
    date(measurement_time) as measurement_day
    , case when rn%2 = 1 then (measurement_value) else 0 end as odd
    , case when rn%2 = 0 then (measurement_value) else 0 end as even
  from table_measure)


select 
  measurement_day
  , sum(odd) as odd_sum
  , sum(even) as even_sum
from table_odd_even
group by 1
order by 1
;



 -- -----------------------------------------------------------------------------------------------------
-- Title: Histogram of Users and Purchases
-- Link: https://datalemur.com/questions/histogram-users-purchases
/* Q: Assume you are given the table on Walmart user transactions. Based on a user's most 
recent transaction date, write a query to obtain the users and the number of products bought.
Output the user's most recent transaction date, user ID and the number of products 
sorted by the transaction date in chronological order.
*/

-- user_transactions table's columns: product_id | user_id | spend | transaction_date

with max_purch as
  (select 
    user_id
    , max(transaction_date) as transaction_date
  from user_transactions
  group by 1)

select 
  u.transaction_date
  , u.user_id
  , count(spend) as purchase_count
from user_transactions u
inner join max_purch x
on (u.user_id = x.user_id) and 
  (u.transaction_date = x.transaction_date)
group by 1, 2
order by 1, 2
;



 -- -----------------------------------------------------------------------------------------------------
-- Title: Compressed Mode
-- Link: https://datalemur.com/questions/alibaba-compressed-mode
/* Q: You are trying to find the most common (aka the mode) number of items bought per order on Alibaba.
However, instead of doing analytics on all Alibaba orders, you have access to a summary table, which describes 
how many items were in an order (item_count), and the number of orders that had that many items (order_occurrences).
In case of multiple item counts, display the item_counts in ascending order.
*/

-- items_per_order table's columns: item_count | order_occurrences

select
  item_count as mode
from items_per_order
where order_occurrences = 
  (select max(order_occurrences)
  from items_per_order)
;



-- -----------------------------------------------------------------------------------------------------
-- Title: International Call Percentage
-- Link: https://datalemur.com/questions/international-call-percentage
/* Q: A phone call is considered an international call when the person 
calling is in a different country than the person receiving the call.
What percentage of phone calls are international? Round the result to 1 decimal.
*/

-- monthly_cards_issued table's columns: issue_month | issue_year | card_name | issued_amount

with table_intl as
  (select 
    case when p1.country_id = p2.country_id then 0 else 1 end as intl
  from phone_calls c
  join phone_info p1 on c.caller_id = p1.caller_id
  join phone_info p2 on c.receiver_id = p2.caller_id)

select round(100.0*sum(intl)/count(intl),1)
from table_intl;




 -- -----------------------------------------------------------------------------------------------------
-- Title: Card Launch Success
-- Link: https://datalemur.com/questions/card-launch-success
/* Q: Your team at JPMorgan Chase is soon launching a new credit card. You are asked to estimate 
how many cards you'll issue in the first month. Before you can answer this question, you want to first 
get some perspective on how well new credit card launches typically do in their first month.
Write a query that outputs the name of the credit card, and how many cards were issued in its launch month. 
The launch month is the earliest record in the monthly_cards_issued table for a given card. 
Order the results starting from the biggest issued amount.
*/

-- monthly_cards_issued table's columns: issue_month | issue_year | card_name | issued_amount

with table_launch as
  (select 
    card_name
    , min((issue_month ||'\01\' || issue_year)::date) as launch
  from monthly_cards_issued
  group by 1)
  
select 
  i.card_name
  , i.issued_amount
from monthly_cards_issued i
join table_launch l
  on (i.card_name = l.card_name)
    and ((i.issue_month ||'\01\' || i.issue_year)::date = l.launch)
order by 2 desc
;





