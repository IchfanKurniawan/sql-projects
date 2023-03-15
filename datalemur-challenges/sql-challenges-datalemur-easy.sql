-- Title: Data Science Skills 
-- Link: https://datalemur.com/questions/matching-skills
/* Q: Given a table of candidates and their skills, you're tasked with finding the candidates best 
suited for an open Data Science job. You want to find candidates who are proficient in Python, Tableau, and PostgreSQL.
Write a query to list the candidates who possess all of the required skills for the job. 
Sort the output by candidate ID in ascending order.
*/

-- candidates table's columns: candidate_id | skill

select 
  candidate_id
from 
  (select *
  from candidates
  where skill in ('Python', 'Tableau', 'PostgreSQL')) s
group by 1
having count(candidate_id) = 3
order by 1
;



-- -----------------------------------------------------------------------------------------------------
-- Title: Page With No Likes
-- Link:https://datalemur.com/questions/sql-page-with-no-likes
/* Q: Assume you are given the tables below about Facebook pages and page likes. Write a query to return the page 
IDs of all the Facebook pages that don't have any likes. The output should be in ascending order.
*/

-- pages table's columns: page_id | page_name
-- page_likes table's columns: user_id | page_id | liked_date

select 
  page_id
from pages
where 
  page_id not in 
  (select distinct page_id
  from page_likes)
;



-- -----------------------------------------------------------------------------------------------------
-- Title: Unfinished Parts
-- Link: https://datalemur.com/questions/tesla-unfinished-parts
/* Q: Tesla is investigating bottlenecks in their production, and they need your help to extract 
the relevant data. Write a query that determines which parts have begun the assembly process 
but are not yet finished.
*/

-- parts_assembly table's columns: part | finish_date | assembly_step

select distinct part
from parts_assembly
where finish_date is null
;




-- -----------------------------------------------------------------------------------------------------
-- Title: Laptop vs. Mobile Viewership
-- Link: https://datalemur.com/questions/laptop-mobile-viewership
/* Q: Assume that you are given the table below containing information on viewership by device type 
(where the three types are laptop, tablet, and phone). Define “mobile” as the sum of tablet and 
phone viewership numbers. Write a query to compare the viewership on laptops versus mobile devices.
Output the total viewership for laptop and mobile devices in the format of "laptop_views" and "mobile_views".
*/

-- viewership table's columns: user_id | device_type | view_time

select
  sum(laptop) as laptop_views
  , sum(mobile) as mobile_views
from 
  (select 
    case when device_type = 'laptop' 
    then 1 else 0 end as laptop
    , case when device_type = 'phone' or device_type = 'tablet' 
    then 1 else 0 end as mobile
  from viewership) x;




-- -----------------------------------------------------------------------------------------------------
-- Title: Duplicate Job Listings
-- Link: https://datalemur.com/questions/duplicate-job-listings
/* Q: Assume you are given the table below that shows job postings for all companies on the LinkedIn platform. 
Write a query to get the number of companies that have posted duplicate job listings.
*/

-- job_listings table's columns: job_id | company_id | title | description

select
  sum(duplicated) as co_w_duplicate_jobs
from
  (select 
    company_id
    , case when count(job_id) != count(distinct (title || ' ' || description))
    then 1 end as duplicated
  from job_listings
  group by 1) x;




-- -----------------------------------------------------------------------------------------------------
-- Title: Average Post Hiatus (Part 1) 
-- Link: https://datalemur.com/questions/sql-average-post-hiatus-1
/* Q: Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query 
to find the number of days between each user’s first post of the year and last post of the year in the year 2021. 
Output the user and number of the days between each user's first and last post.
*/

-- posts table's columns: user_id |  post_id  | post_date | post_content

select
  user_id
  , extract(day from max(post_date) - min(post_date)) as days_between
from posts
where extract(year from post_date) = 2021
group by 1
having extract(day from max(post_date) - min(post_date)) > 0;




-- -----------------------------------------------------------------------------------------------------
-- Title: Teams Power Users
-- Link: https://datalemur.com/questions/teams-power-users
/* Q: Write a query to find the top 2 power users who sent the most messages on Microsoft Teams in August 2022. 
Display the IDs of these 2 users along with the total number of messages they sent. 
Output the results in descending count of the messages.
*/

-- messages table's columns: message_id	| sender_id | receiver_id | content | sent_date

select 
  sender_id,
  count(sender_id) as message_count
from messages
where sent_date between '08/01/2022' and '08/31/2022'
group by sender_id
order by 2 desc
limit 2
;



-- -----------------------------------------------------------------------------------------------------
-- Title: Cities With Completed Trades
-- Link: https://datalemur.com/questions/completed-trades
/* Q: You are given the tables below containing information on Robinhood trades and users. 
Write a query to list the top three cities that have the most completed trade orders in descending order.
Output the city and number of orders.
*/

-- trades table's columns: order_id | user_id | price | quantity | status | timestamp
-- users table's columns: user_id | city | email | signup_date

select 
  u.city, 
  count(t.order_id) as total_orders 
from trades t 
join users u on t.user_id = u.user_id 
where t.status = 'Completed' 
group by 1
order by 2 desc
limit 3;



-- -----------------------------------------------------------------------------------------------------
-- Title: Average Review Ratings
-- Link: https://datalemur.com/questions/sql-avg-review-ratings
/* Q: Given the reviews table, write a query to get the average stars for each product every month.
The output should include the month in numerical value, product id, and average star rating rounded to 
two decimal places. Sort the output based on month followed by the product id.
*/

-- reviews table's columns: review_id | user_id | submit_date | product_id | stars

select 
  extract(month from submit_date) as month, 
  product_id,
  round(avg(stars),2) as avg_stars

from reviews 
group by 1,2
order by 1,2
;



-- -----------------------------------------------------------------------------------------------------
-- Title: App Click-through Rate
-- Link: https://datalemur.com/questions/click-through-rate
/* Q: Assume you have an events table on app analytics. 
Write a query to get the app’s click-through rate (CTR %) in 2022. 
Output the results in percentages rounded to 2 decimal places.
*/

-- events table's columns: app_id | event_type | timestamp

select 
  app_id
  , round(100.0* sum(click)/sum(impression), 2) as ctr
from
  (select 
    app_id
    , case when event_type = 'impression' then 1 else 0 end as impression
    , case when event_type = 'click' then 1 else 0 end as click
  from events
  where timestamp between '01/01/2022' and '12/31/2022') x
group by 1
order by 1
; 



-- -----------------------------------------------------------------------------------------------------
-- Title: Second Day Confirmation
-- Link: https://datalemur.com/questions/second-day-confirmation
/* Q: New TikTok users sign up with their emails and each user receives a text confirmation 
to activate their account. Assume you are given the below tables about emails and texts.
Write a query to display the ids of the users who did not confirm on the first day of sign-up, 
but confirmed on the second day.
*/

-- emails  table's columns: email_id | user_id | signup_date
-- texts table's columns: text_id | email_id | signup_action | action_date


select
  user_id
from texts t  
left join emails e on t.email_id = e.email_id
where signup_action = 'Confirmed'
  and extract(day from (action_date - signup_date)) = 1 




-- -----------------------------------------------------------------------------------------------------
-- Title: Cards Issued Difference
-- Link: https://datalemur.com/questions/cards-issued-difference
/* Q: Your team at JPMorgan Chase is soon launching a new credit card, and to gain some context, 
you are analyzing how many credit cards were issued each month.
Write a query that outputs the name of each credit card and the difference in issued amount between 
the month with the most cards issued, and the least cards issued. 
Order the results according to the biggest difference.
*/

-- monthly_cards_issued table's columns: issue_month | issue_year | card_name | issued_amount

select 
  card_name
  , max(tot_issue) - min(tot_issue) as difference
from   
  (select 
    card_name
    , issue_month
    , sum(issued_amount) tot_issue
  from monthly_cards_issued
  group by 1, 2) x
group by 1
order by 2 desc
;



-- -----------------------------------------------------------------------------------------------------
-- Title: Compressed Mean
-- Link: https://datalemur.com/questions/alibaba-compressed-mean
/* Q: You are trying to find the mean number of items bought per order on Alibaba, rounded to 1 decimal place.
However, instead of doing analytics on all Alibaba orders, you have access to a summary table, 
which describes how many items were in an order (item_count), and 
the number of orders that had that many items (order_occurrences).
*/

-- items_per_order table's columns: item_count | order_occurrences

select
  round(1.0* sum(item_count*order_occurrences) / 
  sum(order_occurrences), 1) as mean
from items_per_order;




-- -----------------------------------------------------------------------------------------------------
-- Title: Pharmacy Analytics (Part 1)
-- Link: https://datalemur.com/questions/top-profitable-drugs
/* Q: CVS Health is trying to better understand its pharmacy sales, and how well different products are selling. 
Each drug can only be produced by one manufacturer.
Write a query to find the top 3 most profitable drugs sold, and how much profit they made. 
Assume that there are no ties in the profits. Display the result from the highest to the lowest total profit.
*/

-- pharmacy_sales  table's columns: product_id | units_sold | total_sales | cogs | manufacturer | drug

select
  drug
  , sum(total_sales - cogs) as total_profit
from pharmacy_sales 
group by 1
order by 2 desc
limit 3
;



-- -----------------------------------------------------------------------------------------------------
-- Title: Pharmacy Analytics (Part 2)
-- Link: https://datalemur.com/questions/non-profitable-drugs
/* Q: CVS Health is trying to better understand its pharmacy sales, and how well different products are selling. 
Each drug can only be produced by one manufacturer. Write a query to find out which manufacturer is 
associated with the drugs that were not profitable and how much money CVS lost on these drugs. 
Output the manufacturer, number of drugs and total losses. 
Total losses should be in absolute value. Display the results with the highest losses on top.
*/

-- pharmacy_sales  table's columns: product_id | units_sold | total_sales | cogs | manufacturer | drug

select
  manufacturer
  , count(product_id) as drug_count
  , round(-1.0* sum(total_sales - cogs), 2) as total_loss
from pharmacy_sales
where total_sales - cogs < 0
group by 1
order by 3 desc
;



-- -----------------------------------------------------------------------------------------------------
-- Title: Pharmacy Analytics (Part 3) 
-- Link: https://datalemur.com/questions/total-drugs-sales
/* Q: CVS Health is trying to better understand its pharmacy sales, and how well different products are selling. 
Each drug can only be produced by one manufacturer. Write a query to find the total sales of drugs for each manufacturer. 
Round your answer to the closest million, and report your results in descending order of total sales.
Because this data is being directly fed into a dashboard which is being seen by business stakeholders, 
format your result like this: "$36 million".
*/

-- pharmacy_sales  table's columns: product_id | units_sold | total_sales | cogs | manufacturer | drug

select 
  manufacturer
  , '$' ||
  round(sum(total_sales)/1000000.0, 0)::varchar ||
  ' million' as sale
from pharmacy_sales
group by 1
order by sum(total_sales) desc
;



-- -----------------------------------------------------------------------------------------------------
-- Title: Patient Support Analysis (Part 1)
-- Link: https://datalemur.com/questions/frequent-callers
/* Q: UnitedHealth has a program called Advocate4Me, which allows members to call an advocate and 
receive support for their health care needs – whether that's behavioural, clinical, well-being, 
health care financing, benefits, claims or pharmacy help.
Write a query to find how many UHG members made 3 or more calls. 
case_id column uniquely identifies each call made.
*/

-- callers table's columns:policy_holder_id | case_id | call_category | call_received | call_duration_secs | original_order

select count(policy_holder_id) as member_count
from
  (select 
    policy_holder_id
    , count(case_id) as call
  from callers
  group by 1
  having count(case_id) >= 3) x; 




-- -----------------------------------------------------------------------------------------------------
-- Title: Patient Support Analysis (Part 2)
-- Link: https://datalemur.com/questions/uncategorized-calls-percentage
/* Q: UnitedHealth Group has a program called Advocate4Me, which allows members to call an advocate and 
receive support for their health care needs – whether that's behavioural, clinical, 
well-being, health care financing, benefits, claims or pharmacy help.
Calls to the Advocate4Me call centre are categorised, but sometimes they can't fit neatly into a category. 
These uncategorised calls are labelled “n/a”, or are just empty (when a support agent enters nothing into the category field).
Write a query to find the percentage of calls that cannot be categorised. Round your answer to 1 decimal place.
*/

-- callers table's columns:policy_holder_id | case_id | call_category | call_received | call_duration_secs | original_order

select 
  round(100.0 * sum(call_catg) / count(1), 1) as call_percentage
from
  (select
    case when call_category = 'n/a' or call_category is null
    then 1 else 0 end as call_catg
  from callers) x




-- -----------------------------------------------------------------------------------------------------
-- Title: Patient Support Analysis (Part 2)
-- Link: https://datalemur.com/questions/uncategorized-calls-percentage
/* Q: UnitedHealth Group has a program called Advocate4Me, which allows members to call an advocate and 
receive support for their health care needs – whether that's behavioural, clinical, 
well-being, health care financing, benefits, claims or pharmacy help.
Calls to the Advocate4Me call centre are categorised, but sometimes they can't fit neatly into a category. 
These uncategorised calls are labelled “n/a”, or are just empty (when a support agent enters nothing into the category field).
Write a query to find the percentage of calls that cannot be categorised. Round your answer to 1 decimal place.
*/

-- callers table's columns:policy_holder_id | case_id | call_category | call_received | call_duration_secs | original_order

select 
