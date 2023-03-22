-- Shout out to Taufiq (techTFQ) for providing this challenge! (https://www.youtube.com/watch?v=_suB8xV9aPc)

-- Q: We have been given the cumulative sum of distance traveled by a car 
-- and we are required to write a SQL query to calculate 
-- the actual distance traveled by a car for each day. 

-- car_travels table columns: cars | days | cumulative_distance

select
	*
	, cumulative_distance - 
	lag(cumulative_distance, 1, 0) over(
		partition by cars order by days asc
		rows between unbounded preceding and current row)
	as travel_distance
from car_travels;