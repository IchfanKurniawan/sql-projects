-- Challlenge from Exponent
-- link to: https://www.youtube.com/watch?v=EYxoPVSBKcU


create table if not exists orders(
	order_id int primary key
	, customer_id int
	, order_date timestamp
	, order_amount int
	, department_id int
);

create table if not exists departments(
	department_id primary key
	, department_name varchar(50)
);

create table if not exists customers(
	customer_id int primary key
	, last_name varchar(255)
	, first_name varchar(255)
);


-- --------------------------------------------------------
-- --------------------------------------------------------

-- q: total revenue per deparment in the last 12 months?
-- orders o, departments d
-- deparment_name | total_revenue

select
	d.department_name
	, sum(order_amount) as total_revenue
from orders o 
left join departments d 
	on o.department_id = d.department_id
where order_date <= now() - interval 12 month
group by 1
order by 2 desc;



-- q: # customer from electronics & fashion department in 2022
-- orders o, departments d
-- deparment_name | #_order

select
	d.department_name
	, count(distinct customer_id) as "#_customers"
from orders o 
left join departments d 
	on o.department_id = d.department_id
where d.deparment_name in ("Electronics", "Fashion")
	and year(o.order_date) = 2022
group by 1;



-- q: find the 5 customers who have the most order in the last 5 year
-- orders o, customers c
-- year | customer_id | first_name | last_name | #_order




with last_5_year as( 
	select
		extract(year from order_date)
	from order
	where order_date >= now() - interval 5 year
	)

, num_order_per_customer as(
	select
		extract(year from o.order_date) as year
		, c.customer_id
		, c.first_name
		, c.last_name
		, count(order_id) as '#_order'
		, row_number() over(partition by extract(year from o.order_date)
			order by count(order_id) desc) as rn
		
	from orders o 
	join customers c
		on o.customer_id = c.customer_id
	where year(order_date) in (select * from last_5_year)
	group by 1, 2, 3, 4
	)

select *
from num_order_per_customer
where rn <= 5
order by year asc, rn asc;



-- q: 2nd highest order amount in the fashion dept
-- orders o, department d
-- order_id | order_date | order_amount

with rank_ord_amount_fashion as(
	select
		order_id
		, order_date
		, order_amount
		, rank() over(order by order_amount desc) as rn
	from orders o
	join department d on o.order_id = d.order_id
	where d.department_name = 'Fashion'
	)
	
select
	order_id
	, order_date
	, order_amount
from rank_ord_amount_fashion
where rn = 2;



-- q: the highest department the highest MoM% growth of order amount in Dec 2022
-- orders o, department d
-- department_name | MoM_prct

with cte_dec_order_growth as(
	select
		department_name
		, month(order_date) as mth
		, sum(order_amount) as total_order
		, lag(order_amount, 1) over(partition by department_name
			order by month(order_date)
			rows between 1 preceding and current rows) as prv_total_order
	from orders o
	join department d on o.order_id = d.order_id
	where order_date between '11/01/2022' and '12/31/2022'
	group by 1, 2)

, cte_rank_dept as(
	select
		department_name
		,(100.0*(total_order - prv_total_order)/prv_total_order) as MoM_prct
		, rank() over(order by (100.0*(total_order - prv_total_order)/prv_total_order) desc) as rn
	from cte_dec_order_growth
	where mth = 12)

select deparment_name, MoM_prct
from cte_rank_dept
where rn = 1
;