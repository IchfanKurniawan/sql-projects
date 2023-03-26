-- -------------------------------------------------------------------------------------------------------------------------
-- Analysis for:
-- 		1. digital marketing drive sources overall & trend per sources (metric: session, num_order, cvr)
-- 		2. brand vs nonbrand campaign overall and trend (metric: session, num_order, cvr)
-- 		3. device type overall and trend (metric: session, num_order, cvr)
-- 		4. user visit channel trend (metric: session)

use mavenfuzzyfactory;
-- -------------------------------------------------------------------------------------------------------------------------



-- 1. digital marketing drive sources overall & trend per sources (metric: session, num_order, cvr)
-- main source are gsearch and others (null)
select 
	extract(year_month from s.created_at) as year_mon,
    count(s.website_session_id) as tot_sess
    , round((count(s.website_session_id) - 
    lag(count(s.website_session_id), 1) over(order by extract(year_month from s.created_at)
		rows between 1 preceding and current row)) /
	lag(count(s.website_session_id), 1) over(order by extract(year_month from s.created_at)
		rows between 1 preceding and current row) *100.0, 2) as '%chg_tot_sess'
    , round(count(distinct case when utm_source = 'gsearch' then s.website_session_id else null end) /
		count(s.website_session_id) *100.0,2) as '%gsearch_sess'
	, round(count(distinct case when utm_source = 'bsearch' then s.website_session_id else null end) /
		count(s.website_session_id) *100.0,2) as '%bsearch_sess'
    , round(count(distinct case when utm_source = 'socialbook' then s.website_session_id else null end) /
		count(s.website_session_id) *100.0,2) as '%social_sess'
	, round(count(distinct case when utm_source is null then s.website_session_id else null end) /
		count(s.website_session_id) *100.0,2) as '%others_sess'
    
    
    , count(order_id) as tot_order
	, round((count(order_id) - 
		lag(count(order_id), 1) over(order by extract(year_month from s.created_at)
			rows between 1 preceding and current row)) /
		lag(count(order_id), 1) over(order by extract(year_month from s.created_at)
			rows between 1 preceding and current row) *100.0, 2) as '%chg_tot_order'
    , round(count(distinct case when utm_source = 'gsearch' then order_id else null end) /
		count(order_id) *100.0, 2) as '%gsearch_order'
	, round(count(distinct case when utm_source = 'bsearch' then order_id else null end) /
		count(order_id) *100.0, 2) as '%bsearch_order'
	, round(count(distinct case when utm_source = 'socialbook' then order_id else null end) /
		count(order_id) *100.0, 2) as '%social_order'
	, round(count(distinct case when utm_source is null then order_id else null end) /
		count(order_id) *100.0, 2) as '%others_order'
        
        
	, round(count(order_id)/count(s.website_session_id)*100.0,2) as avg_cvr
	, round((count(order_id)/count(s.website_session_id) - 
		lag(count(order_id)/count(s.website_session_id), 1) over(order by extract(year_month from s.created_at)
			rows between 1 preceding and current row)) /
		lag(count(order_id)/count(s.website_session_id), 1) over(order by extract(year_month from s.created_at)
			rows between 1 preceding and current row) *100.0, 2) as '%chg_avg_cvr'
    , round(count(distinct case when utm_source = 'gsearch' then order_id else null end) /
		count(distinct case when utm_source = 'gsearch' then s.website_session_id else null end) *100.0, 2) as gsearch_cvr
	, round(count(distinct case when utm_source = 'bsearch' then order_id else null end) /
		count(distinct case when utm_source = 'bsearch' then s.website_session_id else null end) *100.0, 2) as bsearch_cvr
	, round(count(distinct case when utm_source = 'socialbook' then order_id else null end) /
		count(distinct case when utm_source = 'socialbook' then s.website_session_id else null end) *100.0, 2) as social_cvr
	, round(count(distinct case when utm_source is null then order_id else null end) /
		count(distinct case when utm_source is null then s.website_session_id else null end) *100.0, 2) as others_cvr

from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
group by 1
order by 1
;




-- -------------------------------------------------------------------------------------------------------------------------
-- 2. brand vs nonbrand campaign overall and trend of gsearch & others (metric: session, num_order, cvr)
-- majority campaign nonbrand
select
	extract(year_month from s.created_at) as year_mon,
    count(s.website_session_id) as tot_sess
	, round(count(distinct case when utm_campaign = 'brand' then s.website_session_id else null end) /
		count(s.website_session_id) *100.0,2) as '%brand_sess'
	, round(count(distinct case when utm_campaign = 'nonbrand' then s.website_session_id else null end) /
		count(s.website_session_id) *100.0,2) as '%nonbrand_sess'

	, count(order_id) as tot_order
	, round(count(distinct case when utm_campaign = 'brand' then order_id else null end) /
		count(order_id) *100.0, 2) as '%brand_order'
	, round(count(distinct case when utm_campaign = 'nonbrand' then order_id else null end) /
		count(order_id) *100.0, 2) as '%nonbrand_order'

	, round(count(order_id)/count(s.website_session_id)*100.0,2) as avg_cvr
	, round(count(distinct case when utm_campaign = 'brand' then order_id else null end) /
		count(distinct case when utm_campaign = 'brand' then s.website_session_id else null end) *100.0, 2) as brand_cvr
    , round(count(distinct case when utm_campaign = 'nonbrand' then order_id else null end) /
		count(distinct case when utm_campaign = 'nonbrand' then s.website_session_id else null end) *100.0, 2) as nonbrand_cvr

from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
where utm_source is null or utm_source = 'gsearch'
group by 1
order by 1
;




-- -------------------------------------------------------------------------------------------------------------------------
-- 3. device type overall and trend of gsearch/others source & nonbrand campaign (metric: session, num_order, cvr)
-- majority desktop device type
select
	extract(year_month from s.created_at) as year_mon,
    count(s.website_session_id) as tot_sess
	, round(count(distinct case when device_type = 'mobile' then s.website_session_id else null end) /
		count(s.website_session_id) *100.0,2) as '%mobile_sess'
	, round(count(distinct case when device_type = 'desktop' then s.website_session_id else null end) /
		count(s.website_session_id) *100.0,2) as '%desktop_sess'

	, count(order_id) as tot_order
	, round(count(distinct case when device_type = 'mobile' then order_id else null end) /
		count(order_id) *100.0, 2) as '%mobile_order'
	, round(count(distinct case when device_type = 'desktop' then order_id else null end) /
		count(order_id) *100.0, 2) as '%desktop_order'

	, round(count(order_id)/count(s.website_session_id)*100.0,2) as avg_cvr
	, round(count(distinct case when device_type = 'mobile' then order_id else null end) /
		count(distinct case when device_type = 'mobile' then s.website_session_id else null end) *100.0, 2) as mobile_cvr
    , round(count(distinct case when device_type = 'desktop' then order_id else null end) /
		count(distinct case when device_type = 'desktop' then s.website_session_id else null end) *100.0, 2) as desktop_cvr

from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
where (utm_source is null or utm_source = 'gsearch')
	and (utm_campaign = 'nonbrand')
group by 1
order by 1
;




-- -------------------------------------------------------------------------------------------------------------------------
-- 4. user visit channel trend (metric: session)
-- mainly coming from paid channel (gsearch, bsearch), but the others have steady increase trend
select
	extract(year_month from s.created_at) as year_mon,
    count(s.website_session_id) as tot_sess
	, round(count(distinct case when utm_source is null and http_referer is null then s.website_session_id else null end)/
		count(s.website_session_id)*100.0, 2) as '%direct_type_sess'
	, round(count(distinct case when utm_source = 'gsearch' and http_referer is not null then s.website_session_id else null end)/
		count(s.website_session_id)*100.0, 2) as '%gsearch_paid_sess'
	, round(count(distinct case when utm_source = 'bsearch' and http_referer is not null then s.website_session_id else null end)/
		count(s.website_session_id)*100.0,2) as '%bsearch_paid_sess'
	, round(count(distinct case when utm_source is null and http_referer is not null then s.website_session_id else null end)/
		count(s.website_session_id)*100.0,2) as '%organic_search_sess'
from website_sessions s
left join orders o on o.website_session_id = s.website_session_id
group by 1
order by 1
;