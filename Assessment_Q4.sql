/**Account tenure was assumed to be the month difference between the sign up date (start date) and the last transaction date per user **/

-- cte Required_field_for_analysis bring in the required fields as well as add the last transaction date per customer
with Required_field_for_analysis as
(
select *
, max(transaction_date) over (partition by customer_id) last_transaction_date  -- compute the last transaction date per customer
from (
select user.id customer_id
,concat( user.first_name ,' ',user.last_name) as name
,user.date_joined
,sav.transaction_date
,sav.transaction_reference
,sav.amount*0.001 profit    -- profit was assumed to be 0.1% of the investment amount
from adashi_staging.users_customuser user,
adashi_staging.savings_savingsaccount sav
where user.id = sav.owner_id
) a
),

-- cte profit_transaction aggregate profit and transaction number per user
 
profit_transaction as
(select customer_id
,name
,date_joined
,last_transaction_date
,count(distinct transaction_reference) total_transactions
,sum(profit) profit
from Required_field_for_analysis
group by 1,2,3,4
),

-- cte estimated_clv compute the estimated_clv for each user including the tenure, total transaction.
 
cte_estimated_clv as
(
select customer_id
,name
,tenure
 ,total_transactions
 ,round( ((total_transactions/tenure)*12*avg_profit_per_transaction),2) estimated_clv  -- estimate the clv using the logic provided in the assessment document.
 from
 (
select customer_id
,name
,timestampdiff(month, date_joined, last_transaction_date) tenure  -- month diff. btw the sign up date(datejoined) and last transaction date to get the tenure.
 ,total_transactions
 , profit/total_transactions as avg_profit_per_transaction  -- compute the avg_profit_per_transaction by dividing the total profit per users by total_transaction by the user
from profit_transaction)
d)
select * from cte_estimated_clv
order by estimated_clv desc;