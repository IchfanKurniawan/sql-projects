-- Shout out to Taufiq (techTFQ) for providing this challenge! (https://www.youtube.com/watch?v=dWHSt0BVlv0&t=425s)

-- Q:Write a query to fetch the record of brand whose amount is increasing every year.
-- brands table columns: Year | Brand | Amount

with table_growth as(
	select 
		*
		, case when 
			(amount - 
			lag(amount, 1) over(partition by Brand order by Year rows between 1 preceding and current row)) /
			lag(amount, 1) over(partition by Brand order by Year rows between 1 preceding and current row) 
		< 0 then 1
        else 0 end as neg_growth_flag
	from brands)
 
 select Brand 
 from table_growth
 group by 1
 having sum(neg_growth_flag) = 0;
 ;