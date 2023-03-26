-- -------------------------------------------------------------------------------------------------------------------------
-- Analysis for pageview experiment
-- 		1. /home vs /lander(s)
-- 			1a. /home vs /lander-1
-- 			1b. /home vs /lander-2
-- 			1c. /home vs /lander-3
-- 			1d. /home vs /lander-4
-- 			1e. /home vs /lander-5
-- 		2. data input for statistical test (t-test 2 independent samples) -> check w/ python library later
-- 			2a. /home vs /lander-1
-- 			2b. /home vs /lander-2
-- 			2c. /home vs /lander-3
-- 			2d. /home vs /lander-4
-- 			2e. /home vs /lander-5
-- 		3. /billing vs /billing-2 (metric: session, order, revenue, cvr)
-- 		4. data input for statistical test (t-test 2 independent samples) for /billing vs /billing-2

use mavenfuzzyfactory;
-- -------------------------------------------------------------------------------------------------------------------------
-- check for range of date for each page
select 
	pageview_url
    , min(s.created_at) as min_date
    , max(s.created_at) as max_date
from website_pageviews v
right join website_sessions s on s.website_session_id = v.website_session_id
group by 1
order by 1
;



-- -------------------------------------------------------------------------------------------------------------------------
-- 1a. experiment /home vs /lander-1 (metrics: daily session, daily order)

with lander_1_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-1')

select
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-1' then s.website_session_id else null end) as 'lander_1_sess'
    , round(count(distinct case when pageview_url = '/home' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_sess'
    , round(count(distinct case when pageview_url = '/lander-1' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_1_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-1' then o.order_id else null end) as 'lander_1_order'
    , round(count(distinct case when pageview_url = '/home' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_order'
	, round(count(distinct case when pageview_url = '/lander-1' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_1_order'
        
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-1' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-1' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_1'
    
    , datediff(max(s.created_at ), min(s.created_at)) as 'num_day_test'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-1') and
    s.created_at between (select min_date from lander_1_date) and 
		(select max_date from lander_1_date)
;




-- -------------------------------------------------------------------------------------------------------------------------
-- 1b. experiment /home vs /lander-2 (metrics: daily session, daily order)

with lander_2_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-2')

select
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-2' then s.website_session_id else null end) as 'lander_2_sess'
    , round(count(distinct case when pageview_url = '/home' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_sess'
    , round(count(distinct case when pageview_url = '/lander-2' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_2_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-2' then o.order_id else null end) as 'lander_2_order'
    , round(count(distinct case when pageview_url = '/home' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_order'
	, round(count(distinct case when pageview_url = '/lander-2' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_2_order'
        
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-2' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-2' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_2'
    
    , datediff(max(s.created_at ), min(s.created_at)) as 'num_day_test'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-2') and
    s.created_at between (select min_date from lander_2_date) and 
		(select max_date from lander_2_date)
;





-- -------------------------------------------------------------------------------------------------------------------------
-- 1c. experiment /home vs /lander-3 (metrics: daily session, daily order)

with lander_3_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-3')

select
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-3' then s.website_session_id else null end) as 'lander_3_sess'
    , round(count(distinct case when pageview_url = '/home' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_sess'
    , round(count(distinct case when pageview_url = '/lander-3' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_3_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-3' then o.order_id else null end) as 'lander_3_order'
    , round(count(distinct case when pageview_url = '/home' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_order'
	, round(count(distinct case when pageview_url = '/lander-3' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_3_order'
        
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-3' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-3' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_3'
    
    , datediff(max(s.created_at ), min(s.created_at)) as 'num_day_test'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-3') and
    s.created_at between (select min_date from lander_3_date) and 
		(select max_date from lander_3_date)
;




-- -------------------------------------------------------------------------------------------------------------------------
-- 1d. experiment /home vs /lander-4 (metrics: daily session, daily order)

with lander_4_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-4')

select
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-4' then s.website_session_id else null end) as 'lander_4_sess'
    , round(count(distinct case when pageview_url = '/home' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_sess'
    , round(count(distinct case when pageview_url = '/lander-4' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_4_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-4' then o.order_id else null end) as 'lander_4_order'
    , round(count(distinct case when pageview_url = '/home' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_order'
	, round(count(distinct case when pageview_url = '/lander-4' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_4_order'
        
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-4' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-4' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_4'
    
    , datediff(max(s.created_at ), min(s.created_at)) as 'num_day_test'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-4') and
    s.created_at between (select min_date from lander_4_date) and 
		(select max_date from lander_4_date)
;





-- -------------------------------------------------------------------------------------------------------------------------
-- 1e. experiment /home vs /lander-5 (metrics: daily session, daily order)

with lander_5_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-5')

select
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-5' then s.website_session_id else null end) as 'lander_5_sess'
    , round(count(distinct case when pageview_url = '/home' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_sess'
    , round(count(distinct case when pageview_url = '/lander-5' then s.website_session_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_5_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-5' then o.order_id else null end) as 'lander_5_order'
    , round(count(distinct case when pageview_url = '/home' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_home_order'
	, round(count(distinct case when pageview_url = '/lander-5' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)),2) as 'daily_lander_5_order'
        
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-5' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-5' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_5'
    
    , datediff(max(s.created_at ), min(s.created_at)) as 'num_day_test'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-5') and
    s.created_at between (select min_date from lander_5_date) and 
		(select max_date from lander_5_date)
;






-- -------------------------------------------------------------------------------------------------------------------------
-- 2. data input for statistical test (t-test 2 independent samples)
-- 2a. /home vs /lander-1

with lander_1_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-1')

select
	date(s.created_at) as date
    , 
    count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-1' then s.website_session_id else null end) as 'lander_1_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-1' then o.order_id else null end) as 'lander_1_order'
    
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-1' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-1' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_1'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-1') and
    s.created_at between (select min_date from lander_1_date) and 
		(select max_date from lander_1_date)
group by 1
;





-- -------------------------------------------------------------------------------------------------------------------------
-- 2b. /home vs /lander-2

with lander_2_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-2')

select
	date(s.created_at) as date
    , 
    count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-2' then s.website_session_id else null end) as 'lander_2_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-2' then o.order_id else null end) as 'lander_2_order'
    
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-2' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-2' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_2'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-2') and
    s.created_at between (select min_date from lander_2_date) and 
		(select max_date from lander_2_date)
group by 1
;




-- -------------------------------------------------------------------------------------------------------------------------
-- 2c. /home vs /lander-3

with lander_3_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-3')

select
	date(s.created_at) as date
    , 
    count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-3' then s.website_session_id else null end) as 'lander_3_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-3' then o.order_id else null end) as 'lander_3_order'
    
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-3' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-3' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_3'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-3') and
    s.created_at between (select min_date from lander_3_date) and 
		(select max_date from lander_3_date)
group by 1
;





-- -------------------------------------------------------------------------------------------------------------------------
-- 2d. /home vs /lander-4

with lander_4_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-4')

select
	date(s.created_at) as date
    , 
    count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-4' then s.website_session_id else null end) as 'lander_4_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-4' then o.order_id else null end) as 'lander_4_order'
    
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-4' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-4' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_4'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-4') and
    s.created_at between (select min_date from lander_4_date) and 
		(select max_date from lander_4_date)
group by 1
;





-- -------------------------------------------------------------------------------------------------------------------------
-- 2e. /home vs /lander-5

with lander_5_date as(
	select 
		min(s.created_at) as min_date
		, max(s.created_at) as max_date
	from website_pageviews v
	right join website_sessions s on s.website_session_id = v.website_session_id
    where pageview_url = '/lander-5')

select
	date(s.created_at) as date
    , 
    count(distinct case when pageview_url = '/home' then s.website_session_id else null end) as 'home_sess'
    , count(distinct case when pageview_url = '/lander-5' then s.website_session_id else null end) as 'lander_5_sess'
    
    , count(distinct case when pageview_url = '/home' then o.order_id else null end) as 'home_order'
    , count(distinct case when pageview_url = '/lander-5' then o.order_id else null end) as 'lander_5_order'
    
	, round(count(distinct case when pageview_url = '/home' then o.order_id else null end) /
	count(distinct case when pageview_url = '/home' then s.website_session_id else null end)*100.0,2) as 'cvr_home'
	, round(count(distinct case when pageview_url = '/lander-5' then o.order_id else null end) /
	count(distinct case when pageview_url = '/lander-5' then s.website_session_id else null end)*100.0,2) as 'cvr_lander_5'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/home', '/lander-5') and
    s.created_at between (select min_date from lander_5_date) and 
		(select max_date from lander_5_date)
group by 1
;





-- -------------------------------------------------------------------------------------------------------------------------
-- 3. /billing vs /billing-2 (metric: session, order, revenue, cvr)
-- assume the test experiment happen in this period '2012-09-10' to '2013-01-05' 
-- (based on the /billing-2 page start & based on the /billing page end)

select
	count(distinct case when pageview_url = '/billing' then s.website_session_id else null end) as 'billing_sess'
    , count(distinct case when pageview_url = '/billing-2' then s.website_session_id else null end) as 'billing-2_sess'
    , 1.0* count(distinct case when pageview_url = '/billing' then s.website_session_id else null end)/ 
		datediff(max(s.created_at), min(s.created_at)) as 'billing_daily_sess'
	, 1.0* count(distinct case when pageview_url = '/billing-2' then s.website_session_id else null end)/ 
		datediff(max(s.created_at), min(s.created_at)) as 'billing-2_daily_sess'
    
    , count(distinct case when pageview_url = '/billing' then o.order_id else null end) as 'billing_order'
    , count(distinct case when pageview_url = '/billing-2' then o.order_id else null end) as 'billing-2_order'
    , 1.0*count(distinct case when pageview_url = '/billing' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)) as 'billing_daily_order'
    , 1.0*count(distinct case when pageview_url = '/billing-2' then o.order_id else null end)/
		datediff(max(s.created_at), min(s.created_at)) as 'billing-2_daily_order'
    
	, sum(case when pageview_url = '/billing' then o.price_usd else null end) as 'billing_revenue'
	, sum(case when pageview_url = '/billing-2' then o.price_usd else null end) as 'billing-2_revenue'
    , 1.0*sum(case when pageview_url = '/billing' then o.price_usd else null end)/
		datediff(max(s.created_at), min(s.created_at)) as 'billing_daily_revenue'
    , 1.0*sum(case when pageview_url = '/billing-2' then o.price_usd else null end)/
		datediff(max(s.created_at), min(s.created_at)) as 'billing-2_daily_revenue'
    
    , 100.0* count(distinct case when pageview_url = '/billing' then o.order_id else null end)/
		count(distinct case when pageview_url = '/billing' then s.website_session_id else null end) as 'billing_cvr'
    , 100.0* count(distinct case when pageview_url = '/billing-2' then o.order_id else null end)/
		count(distinct case when pageview_url = '/billing-2' then s.website_session_id else null end) as 'billing-2_cvr'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/billing', '/billing-2') and
    s.created_at between '2012-09-10' and '2013-01-05' 
;





-- -------------------------------------------------------------------------------------------------------------------------
-- 4. data input for statistical test (t-test 2 independent samples) for /billing vs /billing-2
-- assume the test experiment happen in this period '2012-09-10' to '2013-01-05' 
-- (based on the /billing-2 page start & based on the /billing page end)

select
	date(s.created_at) as date_
    , count(distinct case when pageview_url = '/billing' then s.website_session_id else null end) as 'billing_sess'
    , count(distinct case when pageview_url = '/billing-2' then s.website_session_id else null end) as 'billing-2_sess'
    
    , count(distinct case when pageview_url = '/billing' then o.order_id else null end) as 'billing_order'
    , count(distinct case when pageview_url = '/billing-2' then o.order_id else null end) as 'billing-2_order'
    
	, sum(case when pageview_url = '/billing' then o.price_usd else null end) as 'billing_revenue'
	, sum(case when pageview_url = '/billing-2' then o.price_usd else null end) as 'billing-2_revenue'
    
    , 100.0* count(distinct case when pageview_url = '/billing' then o.order_id else null end)/
		count(distinct case when pageview_url = '/billing' then s.website_session_id else null end) as 'billing_cvr'
    , 100.0* count(distinct case when pageview_url = '/billing-2' then o.order_id else null end)/
		count(distinct case when pageview_url = '/billing-2' then s.website_session_id else null end) as 'billing-2_cvr'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
left join website_pageviews v on v.website_session_id = s.website_session_id
where
	pageview_url in ('/billing', '/billing-2') and
    s.created_at between '2012-09-10' and '2013-01-05' 
group by 1
;
