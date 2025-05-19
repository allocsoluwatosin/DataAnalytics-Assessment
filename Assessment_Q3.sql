/** CTE was used here because it requires a few steps**/
-- grab needed columns from saving and plan tables
with Select_needed_col 
as(
select sav.transaction_date
,pl.is_a_fund
,pl.is_regular_savings
,pl.owner_id
,pl.id
 from adashi_staging.savings_savingsaccount sav,
 adashi_staging.plans_plan pl
 where pl.owner_id = sav.owner_id
 and pl.id = sav.plan_id
 ),

-- stack is_saving and is_regular_savings on each other by pivoting as shown in the cte pivot_is_fund_is_reg_saving below.
 -- The cte only returns users with both savings and investment plan.
 pivot_is_fund_is_reg_saving as
 (
 select * from 
 (
 select owner_id
 ,id
 ,transaction_date
 , 'Savings' type
 , is_a_fund value
 from Select_needed_col
 union all
 select owner_id
 ,id
 ,transaction_date
 , 'Investments' type
 , is_regular_savings value
 from Select_needed_col
 )a where value =1          -- return only users with both savings and investment plan.
 
 ),
 
 --  cte pick_max_transaction_date_per_id only added maximum transaction date and displays only records where
 -- maximum transaction date equals transaction date.
 
 pick_max_transaction_date_per_id as
 (
 select * from 
 (
 select owner_id
 ,id
 ,transaction_date
 ,max(transaction_date) over (partition by owner_id,id) max_date_per_id
 ,type
 from pivot_is_fund_is_reg_saving)b
 where transaction_date =  max_date_per_id    -- return records where max. transaction date equals transaction date.
 ),
 
 -- cte active_customer_in_last_365days displays records with no activities in the past 1 year
 
 active_customer_in_last_365days as
 
 (
 select id plan_id
 ,owner_id
 ,type
 ,date(transaction_date) last_transaction_date
 ,datediff(now(), transaction_date) -365 inactivity_days
 from pick_max_transaction_date_per_id
 
 where datediff(now(), transaction_date) >365
 )
 select * from active_customer_in_last_365days