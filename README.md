# DataAnalytics-Assessment
For adashi assessment

EXPLANATION OF MY APPROACH

 -- The solutions provided was written in MYSQL language
 **Q1 -- High-Value Customers with Multiple Products**
The goal of this task was to identify customers who have at least one funded savings plan and at least one funded investment plan, 
and then sort them based on their total deposits, starting from the highest.

Worked from the plans_plan table since it contains both savings and investment plans, with columns like is_regular_savings and is_a_fund.

--Joined the related tables:

I joined plans_plan with savings_savingsaccount using plan_id and owner_id to get the confirmed deposit amounts.

I then joined the users_customuser table to fetch each user’s full name by combining first_name and last_name.

--Created a subquery to aggregate data per user:

I grouped the results by owner_id and full name.

I used CASE WHEN pl.is_a_fund = 0 THEN 0 ELSE 1 END to count the number of investment plans per user. 
This means: if is_a_fund is 0, don't count it; otherwise, count it.

I used CASE WHEN pl.is_regular_savings = 1 THEN 1 ELSE 0 END to count the number of savings plans per user.

I summed up the confirmed_amount to get the total deposits per user.

--Filtered the final result:

In the outer query, I filtered the users to only include those who have:

savings_count >= 1 and

investment_count >= 1

This ensures we only see users who have both product types.

--Sorted by total deposits:

I sorted the final result in descending order using order by total_deposits desc to show the users with the highest total deposits at the top.


**Q2. Question 2: Transaction Frequency Analysis**

The task was to figure out how often each customer transacts each month and then group them into frequency categories: High, Medium, or Low.
Here’s how I did it:

--Joined the Tables:

I worked with both the savings_savingsaccount and users_customuser tables, matching transactions with the correct user using owner_id = user.id.

--Counted Monthly Transactions per Customer:

For each customer, I counted how many unique transactions they made in each month using transaction_reference and grouped it by user and month.

--Calculated Number of Months Each Customer Transacted:

I used a window function count(month) over (partition by id) to know how many months each customer has made transactions.

Summed Total Transactions per Customer:

I summed all the monthly transactions for each customer to get their total transactions.

--Computed Average Transactions per Month:

For each customer, I divided their total number of transactions by the number of months they were active (i.e., had transactions). 
This gave me their average monthly transaction count.

--Categorized Customers Based on Frequency:

I used a CASE WHEN to put each customer into:

High Frequency (10 or more transactions per month),

Medium Frequency (3 to 9),

Low Frequency (2 or fewer).

--Grouped and Aggregated:

Finally, I grouped the customers by frequency category to:

Count how many customers fall in each category,

Calculate the overall average transactions per month for each group.

**Q3: Account Inactivity Alert**
The goal was to find accounts that haven’t had any inflow (deposit) transactions in the last 1 year — whether they are savings or investment accounts.

I broke the task down into clear steps using CTEs (Common Table Expressions), just to make it easier to manage.

--Select Relevant Columns
I pulled the columns I needed from the savings_savingsaccount and plans_plan tables, matching them using both owner_id and plan_id.

--Stack Savings and Investments Together
I used a UNION ALL to stack savings and investment accounts on top of each other, so I could treat them as one set.

I tagged each one as either 'Savings' or 'Investments'.

I filtered to only include rows where is_a_fund = 1 (investments) or is_regular_savings = 1 (savings).

--Get the Last Transaction Date for Each Plan
I used a window function to get the latest transaction date for each plan (max(transaction_date) per plan), and filtered it down to only that most recent transaction.

--Filter Accounts With No Activity in the Last 365 Days
I calculated the difference between today (now()) and the last transaction date.

If that number was greater than 365, I included it in the result.

I also calculated how many days past the 1-year mark it has been (just for extra insight).


**Q4:  Customer Lifetime Value (CLV) Estimation**
The goal here was to estimate how valuable each customer is over time, by looking at how long they’ve been with us and how often they transact.
Steps used:
--Joined the Tables:
I joined users_customuser and savings_savingsaccount using owner_id = user.id.

--Calculated Profit Per Transaction:
Since we’re told each transaction gives us 0.1% profit, I did:

profit = amount * 0.001
This gave me the profit from each transaction.

--Got Last Transaction Date for Each Customer:
To calculate how long a customer has been active, I needed their last transaction date.

I used a window function:
max(transaction_date) over (partition by customer_id)
This gives the most recent transaction date for each customer

--Summarized Per Customer:
For each customer, I calculated:

Their total number of unique transactions

Their total profit (sum of all 0.1% profits)

Their sign-up date

Their last transaction date

I did this by grouping the data by customer.

--Calculated Tenure and Estimated CLV:
Then I moved on to calculate:

Tenure in months:
Using TIMESTAMPDIFF(MONTH, date_joined, last_transaction_date), I calculated how long they’ve been active.

Average profit per transaction:
Total profit divided by total number of transactions, and CLV (Customer Lifetime Value).

--Finally, I selected all the customers with:

customer_id

name

tenure_months

total_transactions

estimated_clv

And I sorted them in descending order of CLV, so the most valuable customers appear at the top.
