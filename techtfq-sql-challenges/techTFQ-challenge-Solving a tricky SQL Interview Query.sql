-- Shout out to Taufiq (techTFQ) for providing this challenge! (https://www.youtube.com/watch?v=6UAU79FNBjQ)

-- Columns per table
  -- account_balance: account_no | transaction_date | debit_credit | transaction_amount

-- Q: Write a query to return the account no & transaction date when the account balance reached 1000.
-- Include only those accounts whose balance currently is >= 1000

-- ---------------------------------------------------------------------------------------------------------------
with table_signed as(
	select
		*
		,case when debit_credit = 'debit' then transaction_amount*-1 
			else transaction_amount end as deb_cre_signed
	from account_balance)

, table_cum_bal as
	(select
		account_no
		, transaction_date
		, sum(deb_cre_signed) over(partition by account_no order by transaction_date asc) as cum_balance
	from table_signed
	where account_no in 
		(select account_no 
		from table_signed
		group by 1
		having sum(deb_cre_signed) >=1000))
        
select
	account_no
    , min(transaction_date) as first_date_1000
from table_cum_bal
where cum_balance>=1000
group by 1 ;