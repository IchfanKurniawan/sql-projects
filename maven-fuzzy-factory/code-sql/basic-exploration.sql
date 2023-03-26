use mavenfuzzyfactory;

-- 32,313 order_id
select count(distinct order_id)
from orders;

-- 40,025 order_item_id
select count(distinct order_item_id)
from order_items;

select distinct product_id, product_name from products;

-- mainly 1 purchased item per order
select *
from orders
where items_purchased > 1
limit 5;

select *
from order_items
where order_id = 7300;

-- product_id: 1,2,3,4
select distinct product_id
from order_items;

-- primary_product_id: 0, 1
-- mainly 1 (80%)
select distinct primary_product_id
from orders;

select 
	100.0 * count(case when is_primary_item = 1 then 1 else null end) / count(is_primary_item) as prct_primary_item
	, 100.0 * count(case when is_primary_item = 0 then 1 else null end) / count(is_primary_item) as prct_not_primary_item
from order_items;


-- 16 distinct pageview_url
select distinct pageview_url
from website_pageviews;

select pageview_url, count(website_session_id)
from website_pageviews
group by 1
order by 2 desc;


-- mobile, desktop
select distinct device_type
from website_sessions;

-- gsearch, bsearch, socialbook, null
select distinct utm_source
from website_sessions;

-- gsearch(gsearch.com), bsearch(bsearch.com), socialbook(socialbook.com) , null(gsearch.com, bsearch.com, null)
select distinct utm_source, http_referer
from website_sessions;

select distinct http_referer
from website_sessions;

-- 0, 1
-- mainly 0 (83.38%)
select distinct is_repeat_session
from website_sessions;

select 
	100.0 * count(case when is_repeat_session = 1 then 1 else null end) / count(is_repeat_session) as prct_repeat_session
	, 100.0 * count(case when is_repeat_session = 0 then 1 else null end) / count(is_repeat_session) as prct_not_repeat_session
from website_sessions;

-- nonbrand, brand, pilot, desktop_targeted, null
select distinct utm_campaign
from website_sessions
where created_at < '2012-11-27';

-- g_ad_1, g_ad_2, b_ad_1, b_ad_2, sociaal_ad_1, social_ad_2, null
select distinct utm_content
from website_sessions;

-- different pageview names
select distinct pageview_url
from website_pageviews
order by 1;