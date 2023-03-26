-- -------------------------------------------------------------------------------------------------------------------------
-- Analysis for:
-- 		1. sales, number order, number user trend (stat: sum/total, avg, %chg) (dim: per_user, per_day)
-- 		2. products sales overall, product sales trend, market share of products (stat: sum/total, %chg)
-- 		3. refund_trend, refund_per_product, refund_amount_trend
-- 		4. check for seasonality (metric: monthly_revenue, day_type_revenue, weektype_revenue)
-- 		5. user funnel (metric: session)

use mavenfuzzyfactory;
-- -------------------------------------------------------------------------------------------------------------------------


-- 1. sales, number order, number user trend (stat: sum/total, avg, %chg) (dim: per_user, per_day)
select 
	extract(year_month from created_at) as year_month_
    , sum(price_usd) as sales
    , round((sum(price_usd) - 
		lag(sum(price_usd), 1) over(order by extract(year_month from created_at) rows between 1 preceding and current row)) / 
		lag(sum(price_usd), 1) over(order by extract(year_month from created_at) rows between 1 preceding and current row) * 
		100.0, 2) as prct_sales_chg
    
    , round((sum(price_usd) - sum(cogs_usd)) / sum(price_usd) *100.0,2) as prct_profit_over_sales
    
    , count(distinct order_id) as num_order
    , round((count(distinct order_id) - 
		lag(count(distinct order_id), 1) over(order by extract(year_month from created_at) rows between 1 preceding and current row)) /
		lag(count(distinct order_id), 1) over(order by extract(year_month from created_at) rows between 1 preceding and current row) * 
        100.0, 2) as prct_order_chg
    
    , count(user_id) as num_unique_user
	, round((count(distinct user_id) - 
		lag(count(distinct user_id), 1) over(order by extract(year_month from created_at) rows between 1 preceding and current row)) /
		lag(count(distinct user_id), 1) over(order by extract(year_month from created_at) rows between 1 preceding and current row) *
		100.0, 2) as prct_unique_user_chg

    , round(sum(price_usd)/count(distinct user_id),2) as sales_per_user
    , round(sum(price_usd)/count(distinct order_id), 2) as sales_per_order
    , round(count(distinct order_id)/count(distinct user_id),2) as num_order_per_user
    
--     , max(day(created_at)) - min(day(created_at)) as num_day 
    , round(1.0*sum(price_usd)/(max(day(created_at)) - min(day(created_at))),2) as sales_per_day
    , round(1.0*count(distinct order_id)/(max(day(created_at)) - min(day(created_at))),0) as num_order_per_day
    , round(1.0*count(distinct user_id)/(max(day(created_at)) - min(day(created_at))),0) as num_unique_user_per_day
from orders
where extract(year_month from created_at) != 201503
group by 1
order by 1 asc;



-- sales each year separated by new or existing customer

select 
	extract(year from created_at) as year
    , sum(price_usd) as sales
from orders
where extract(year from created_at) != 2015
group by 1
order by 1 asc;




-- -------------------------------------------------------------------------------------------------------------------------
-- 2. products sales overall, product sales trend, market share of products (stat: sum/total, %chg)
select
	product_id
    , min(created_at) as first_date
from order_items
group by 1
;


select
	sum(price_usd) as total_sales
    , round(sum(case when i.product_id = 1 then price_usd else null end)/sum(price_usd) * 100.0, 2) as 'prct_The Original Mr. Fuzzy'
    , round(sum(case when i.product_id = 2 then price_usd else null end)/sum(price_usd) * 100.0, 2) as 'prct_The Forever Love Bear'
    , round(sum(case when i.product_id = 3 then price_usd else null end)/sum(price_usd) * 100.0, 2) as 'prct_The Birthday Sugar Panda'
    , round(sum(case when i.product_id = 4 then price_usd else null end)/sum(price_usd) * 100.0, 2) as 'prct_The Hudson River Mini bear'
from order_items i
join products p on i.product_id = p.product_id;

select
	extract(year_month from created_at) as year_month_
	, sum(price_usd) as total_sales
    , round((sum(price_usd) - 
		lag(sum(price_usd), 1) over(order by extract(year_month from created_at) rows between 1 preceding and current row))/
        lag(sum(price_usd), 1) over(order by extract(year_month from created_at) rows between 1 preceding and current row)*
        100.0,2) as prct_chg_total_sales
    , round((sum(price_usd) - sum(cogs_usd)) / 
		sum(price_usd) *100.0,2) as prct_profit_over_sales
        
    , round(sum(case when product_id = 1 then price_usd else null end)/sum(price_usd) * 100.0, 2) as prct_prod_1
	, round(sum(case when product_id = 1 then price_usd else null end), 2) as sales_prod_1
	, round((sum(case when product_id = 1 then price_usd else null end) - 
		lag(sum(case when product_id = 1 then price_usd else null end), 1) over(order by extract(year_month from created_at)
		rows between 1 preceding and current row)) /
		sum(case when product_id = 1 then price_usd else null end) *100.0, 2) as prct_chg_sales_prod_1

    , round(sum(case when product_id = 2 then price_usd else null end)/sum(price_usd) * 100.0, 2) as prct_prod_2
    , round(sum(case when product_id = 2 then price_usd else null end), 2) as sales_prod_2
	, round((sum(case when product_id = 2 then price_usd else null end) - 
		lag(sum(case when product_id = 2 then price_usd else null end), 1) over(order by extract(year_month from created_at)
		rows between 1 preceding and current row)) /
		sum(case when product_id = 2 then price_usd else null end) *100.0, 2) as prct_chg_sales_prod_2

    , round(sum(case when product_id = 3 then price_usd else null end)/sum(price_usd) * 100.0, 2) as prct_prod_3
    , round(sum(case when product_id = 3 then price_usd else null end), 2) as sales_prod_3
	, round((sum(case when product_id = 3 then price_usd else null end) - 
		lag(sum(case when product_id = 3 then price_usd else null end), 1) over(order by extract(year_month from created_at)
		rows between 1 preceding and current row)) /
		sum(case when product_id = 3 then price_usd else null end) *100.0, 2) as prct_chg_sales_prod_3

    , round(sum(case when product_id = 4 then price_usd else null end)/sum(price_usd) * 100.0, 2) as prct_prod_4
    , round(sum(case when product_id = 4 then price_usd else null end), 2) as sales_prod_4
	, round((sum(case when product_id = 4 then price_usd else null end) - 
		lag(sum(case when product_id = 4 then price_usd else null end), 1) over(order by extract(year_month from created_at)
		rows between 1 preceding and current row)) /
		sum(case when product_id = 4 then price_usd else null end) *100.0, 2) as prct_chg_sales_prod_4

from order_items
where extract(year_month from created_at) < '201503'
group by 1
order by 1 asc;
    


-- -------------------------------------------------------------------------------------------------------------------------
-- 3. refund_trend, refund_per_product, refund_amount_trend

select
	extract(year_month from o.created_at) as year_month_
    , count(distinct o.order_id) as num_order
    , round(count(distinct r.order_id)/count(distinct o.order_id) *100.0,2) as prct_orders_refund
    , round(count(distinct r.order_id)/(max(day(o.created_at)) - min(day(o.created_at))) *100.0,2) as refund_order_per_day
    
    , count(distinct i.order_item_id) as num_order_item
	,round(count(distinct r.order_item_id)/count(distinct i.order_item_id) *100.0,2) as prct_order_items_refund
	,round(count(distinct r.order_item_id)/(max(day(o.created_at)) - min(day(o.created_at))) *100.0,2) as refund_order_item_per_day

    
from order_item_refunds r
right join orders o on o.order_id = r.order_id
left join order_items i on i.order_id = o.order_id
group by 1
;



select
	extract(year_month from o.created_at) as year_month_
	, count(distinct o.order_id) as num_total_order
	, round(count(distinct r.order_id)/count(distinct o.order_id) *100.0,2) as prct_orders_refund
    
	, round(count(case when product_id = 1 then 1 else null end)/
		count(distinct o.order_id) *100.0, 2) as prct_order_prod_1
    , round(count(case when r.order_id is not null and product_id = 1 then 1 else null end) /
		count(case when product_id = 1 then 1 else null end) *100.0,2) as prct_order_refund_prod_1
        
	, round(count(case when product_id = 2 then 1 else null end)/
		count(distinct o.order_id) *100.0, 2) as prct_order_prod_2
    , round(count(case when r.order_id is not null and product_id = 2 then 1 else null end) /
		count(case when product_id = 2 then 1 else null end) *100.0,2) as prct_order_refund_prod_2
        
	, round(count(case when product_id = 3 then 1 else null end)/
		count(distinct o.order_id) *100.0, 2) as prct_order_prod_3
    , round(count(case when r.order_id is not null and product_id = 3 then 1 else null end) /
		count(case when product_id = 3 then 1 else null end) *100.0,2) as prct_order_refund_prod_3
        
	, round(count(case when product_id = 4 then 1 else null end)/
		count(distinct o.order_id) *100.0, 2) as prct_order_prod_4
    , round(count(case when r.order_id is not null and product_id = 4 then 1 else null end) /
		count(case when product_id = 4 then 1 else null end) *100.0,2) as prct_order_refund_prod_4

    
from order_item_refunds r
right join orders o on o.order_id = r.order_id
left join order_items i on i.order_id = o.order_id
group by 1
;


select
	extract(year_month from o.created_at) as year_month_
	, sum(i.price_usd) as total_sales
    , sum(refund_amount_usd) as total_refund
    , round(sum(refund_amount_usd) / sum(i.price_usd) *100.0, 2) as prct_refund_over_sales
    
    , round(100.0*(sum(refund_amount_usd) / (sum(i.price_usd) - sum(i.cogs_usd)) *100.0 - 
		lag(sum(refund_amount_usd) / (sum(i.price_usd) - sum(i.cogs_usd)) *100.0, 1) 
			over(order by extract(year_month from o.created_at) rows between 1 preceding and current row)) /
		lag(sum(refund_amount_usd) / (sum(i.price_usd) - sum(i.cogs_usd)) *100.0, 1) 
			over(order by extract(year_month from o.created_at) rows between 1 preceding and current row), 2) as prct_chg_refund_over_profit
from order_item_refunds r
right join orders o on o.order_id = r.order_id
left join order_items i on i.order_id = o.order_id
group by 1
;





-- -------------------------------------------------------------------------------------------------------------------------
-- 		4. check for seasonality (metric: monthly_revenue, day_type_revenue, weektype_revenue)

select
	month(created_at) as month_basis
    , avg(price_usd) as sales
from orders
group by 1
order by 1 asc;


select
	day(created_at) as daily_basis
    , avg(price_usd) as sales
from orders
group by 1
order by 1 asc;

select
    dayofweek(created_at) as day_ofweek_basis
    , avg(price_usd) as sales
from orders
group by 1
order by 1;


select
	month(created_at) as mon
    , dayofweek(created_at) as day_ofweek
    , avg(price_usd) as sales
from orders
group by 1, 2
order by 1, 2;


select
	(case when dayofweek(created_at) in (2,3,4,5,6) then 'weekday' else 'weekend' end) as week_type_basis
    , avg(price_usd) as sales
from orders
group by 1
order by 1;


select
	month(created_at)
    , (case when dayofweek(created_at) in (2,3,4,5,6) then 'weekday' else 'weekend' end) as week_type_basis
    , avg(price_usd) as sales
    , count(distinct order_id) as num_order
from orders
group by 1, 2
order by 1, 2;





-- -------------------------------------------------------------------------------------------------------------------------
-- 		5. user funnel (metric: session)

select 
	count(distinct website_session_id) as total_session
    , round(count(distinct case when pageview_url in ('/home', '/lander-1', '/lander-2', '/lander-3', '/lander-4', '/lander-5')
		then website_session_id else null end)/
        count(distinct website_session_id)*100.0,2) as '%landing_page_session'
	, round(count(distinct case when pageview_url in ('/products')
		then website_session_id else null end)/
        count(distinct website_session_id)*100.0,2) as '%products_page_session'
	, round(count(distinct case when pageview_url in ('/the-birthday-sugar-panda', '/the-forever-love-bear', '/the-hudson-river-mini-bear', '/the-original-mr-fuzzy')
		then website_session_id else null end)/
        count(distinct website_session_id)*100.0,2) as '%to_product_page_session'
	, round(count(distinct case when pageview_url in ('/cart')
		then website_session_id else null end)/
        count(distinct website_session_id)*100.0,2) as '%cart_page_session'
	, round(count(distinct case when pageview_url in ('/shipping')
		then website_session_id else null end)/
        count(distinct website_session_id)*100.0,2) as '%ship_page_session'
	, round(count(distinct case when pageview_url in ('/billing', '/billing-2')
		then website_session_id else null end)/
        count(distinct website_session_id)*100.0,2) as '%billing_page_session'
	, round(count(distinct case when pageview_url in ('/thank-you-for-your-order')
		then website_session_id else null end)/
        count(distinct website_session_id)*100.0,2) as '%thanks_page_session'
from website_pageviews;