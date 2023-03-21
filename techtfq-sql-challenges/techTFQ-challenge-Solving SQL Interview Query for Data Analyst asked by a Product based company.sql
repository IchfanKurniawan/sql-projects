-- Shout out to Taufiq (techTFQ) for providing this challenge! (https://www.youtube.com/watch?v=jS5_hjFgfzA)
-- Q: Display the average billing amount for each customer between 2019 to 2021
	-- assume $0 billing amount if nothing is billed for a particular year of that customer

-- Table's column
  -- billing: customer_id | customer_name | billing_id | billing_creation_date | billed_amount


 -- ------------------------------------------------------------------------------------------------------------------------------------
-- 1. Average billing for each year for each customer in the 2019 to 2021
with cte_table_bill as(
	select
		customer_name,
			round(sum(case when year(billing_creation_date) = 2019 then billed_amount else 0 end) / 
						sum(case when year(billing_creation_date) = 2019 then 1 else 0 end),2) as 'avg_billing_2019'
			,round(sum(case when year(billing_creation_date) = 2020 then billed_amount else 0 end) / 
						sum(case when year(billing_creation_date) = 2020 then 1 else 0 end),2) as 'avg_billing_2020'
			,round(sum(case when year(billing_creation_date) = 2021 then billed_amount else 0 end) / 
						sum(case when year(billing_creation_date) = 2021 then 1 else 0 end),2) as 'avg_billing_2021'
	from billing
	where billing_creation_date between '2019-01-01' and '2021-12-31'
	group by 1
	order by 1)

select
	customer_name
    , if(avg_billing_2019 is null, 0, avg_billing_2019) as 'avg_billing_2019'
    , if(avg_billing_2020 is null, 0, avg_billing_2020) as 'avg_billing_2020'
    , if(avg_billing_2021 is null, 0, avg_billing_2021) as 'avg_billing_2021'
from cte_table_bill
;



-- ------------------------------------------------------------------------------------------------------------------------------------
-- 2. Average billing for each customer in the 2019-2021
select
	customer_name
	, round(
		(sum(case when year(billing_creation_date) = 2019 then billed_amount else 0 end) +
			sum(case when year(billing_creation_date) = 2020 then billed_amount else 0 end) +
			sum(case when year(billing_creation_date) = 2021 then billed_amount else 0 end)) / -- numerator (total values of billing)
			
		(count(case when year(billing_creation_date) = 2019 then billed_amount else null end) +
			count(case when year(billing_creation_date) = 2020 then billed_amount else null end) +
			count(case when year(billing_creation_date) = 2021 then billed_amount else null end)) -- denumerator (n obs)
			,2) as 'avg_billing_2019-2021'
from billing
where billing_creation_date between '2019-01-01' and '2021-12-31'
group by 1
order by 1
;