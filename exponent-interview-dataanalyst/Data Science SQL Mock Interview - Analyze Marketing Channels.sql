-- Challlenge from Exponent Youtube Channel
-- "Data Science SQL Mock Interview - Analyze Marketing Channels"
-- link to the video: https://www.youtube.com/watch?v=lnhuCj0EfPI

/*
Our goal is to targeting high-value customers.
We have 4 different marketing channels which are most effective?

There are 2 tables:

- attribution table
	- session_id, str
	- marketing_channel, str
	- purchase_value, float

- user_sessions table
	- session_id, str
	- ad_click_timestamp, datetime
	- user_id, str

*/


-- Question 1: What is the avg purchase value per marketing_channel?
SELECT
	marketing_channel
	, avg(purchase_value) as purchase_value
FROM attribution
GROUP BY 1
ORDER BY 2 DESC;


-- Question 2: What % of link clicks convert to a purchase for each marketing_channel?
	-- Formula: number click converted to purchase per all number click
SELECT
	marketing_channel
	, ROUND(COUNT(CASE WHEN purchase_value > 0 THEN 1 END) * 100.0
	/ COUNT(purchase_value), 2) AS prct_click_to_purchase
FROM attribution
GROUP BY 1
ORDER BY 2 DESC;

-- Question 3: What is the customer life time value for each user?
SELECT
	u.user_id
	, SUM(purchase_value) as CLTV
FROM user_sessions u
JOIN attribution a ON u.session_id = a.session_id
GROUP BY 1
ORDER BY 2 DESC;

-- Question 4: Find the highest value customers!
	-- highest value customers = CLTV more than 1000
SELECT
	u.user_id
	, SUM(purchase_value) as CLTV
FROM user_sessions u
JOIN attribution a ON u.session_id = a.session_id
GROUP BY 1
HAVING SUM(purchase_value) > 1000
ORDER BY 2 DESC;

-- Question 5: For all the highest value customers, what the marketing_channel they first
-- encountered the products?
WITH CTE_HV_customers AS(
	SELECT
		u.user_id
	FROM user_sessions u
	JOIN attribution a ON u.session_id = a.session_id
	GROUP BY 1
	HAVING SUM(purchase_value) > 1000)

SELECT
	h.user_id
	, a.marketing_channel
	, MIN(u.ad_click_timestamp) AS first_encounter
FROM attribution a
JOIN user_sessions u ON a.user_sessions = u.user_sessions
JOIN CTE_HV_customers h ON h.user_id = u.user_id
GROUP BY 1, 2
ORDER BY 1
;


-- Question 6: For all the highest value customers, what % of high value customers came
-- from which marketing_channel originally?
WITH 
CTE_HV_customers AS(
	SELECT
		u.user_id
	FROM user_sessions u
	JOIN attribution a ON u.session_id = a.session_id
	GROUP BY 1
	HAVING SUM(purchase_value) > 1000)

CTE_first_encounter AS(
	SELECT
		h.user_id
		, a.marketing_channel
		, MIN(u.ad_click_timestamp) AS first_encounter
	FROM attribution a
	JOIN user_sessions u ON a.user_sessions = u.user_sessions
	JOIN CTE_HV_customers h ON h.user_id = u.user_id
	GROUP BY 1, 2)

CTE_total_marketing_channel AS(
	SELECT COUNT(marketing_channel) AS total_marketing_channel
	FROM CTE_first_encounter)

SELECT
	marketing_channel
	, ROUND(COUNT(marketing_channel)*100.0 / total_marketing_channel,2) AS prct_HV_marketing_channel
FROM CTE_first_encounter f
JOIN CTE_total_marketing_channel t ON 1 = 1
GROUP BY 1
ORDER BY 2 DESC
;
