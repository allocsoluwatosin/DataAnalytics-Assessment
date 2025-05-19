/** 
The users table has 1,867 unique user IDs, while the plans_plan table has 1,739, 
which means some users don’t have any plans. Also, the savings table has 873 records,
 showing that not all users with investments have savings.
 So, using an inner join across all three tables makes sense to focus only on users who have data in all of them.
**/

/** currency is in kobo **/
-- this query write out the final output to include owner's id, name, investment count, savings and total deposits
select a.owner_id
,a.name        
,a.investment_count
,a.savings_count
,cast( a.total_deposits as float) total_deposits

from
(
-- this query aggregate investment count, saving and total deposits (in terms of confirmed amount) per owner
select pl.owner_id
,concat( user.first_name ,' ',user.last_name) as name      -- concatenate first name and last name to get user's full name
,sum(case when pl.is_a_fund =0 then 0
else 1 end) investment_count                   -- aggregating investment count per owner_id
,sum(case when pl.is_regular_savings = 1 then 1
else 0 end ) savings_count                     -- aggregating saving count per owner_id
,sum(sav.confirmed_amount) total_deposits      -- summing up confirmed_amount per owner_id as total deposit
from adashi_staging.plans_plan pl
inner join adashi_staging.savings_savingsaccount sav
on pl.id = sav.plan_id
and pl.owner_id = sav.owner_id
inner join adashi_staging.users_customuser user
on pl.owner_id = user.id
group by 1,2
) a

-- this query added the user name as well as limiting the data records to only users with at least one investment and saving plan.
where savings_count>=1 and investment_count>=1      -- display only users with atleast one investment and savings plan
order by total_deposits  desc                       -- display output with total_deposits from highest to lowest
