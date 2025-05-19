
select frequency_category
,count(distinct id) as customer_count
,sum(trans_number)/sum(month_num) as avg_transactions_per_month
from (

select
case when trans_number>=10 then 
'High Frequency'
when trans_number >=3 and trans_number<=9 then 
'Medium Frequency'
when trans_number <=2 then 
'Low Frequency' end Frequency_Category
,id
,sum(trans_number) trans_number
,max(month_num) month_num


from(
select *, 
count(month) over (partition by id) month_num
from (
select  user.id
,month(sav.transaction_date) month
,count(distinct sav.transaction_reference) trans_number
from 
adashi_staging.savings_savingsaccount sav,
adashi_staging.users_customuser user
where sav.owner_id = user.id
group by 1,2
 ) a
 )b
 group by 1,2
 )c
 group by 1