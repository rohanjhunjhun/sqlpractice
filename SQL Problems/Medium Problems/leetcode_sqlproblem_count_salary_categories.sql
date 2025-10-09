-- Problem:1907 Count Salary Categories
-- Link: https://leetcode.com/problems/count-salary-categories/
-- Difficulty: Medium
-- Concepts: Aggregations, Filtering, CASE WHEN , Subqueries, CTEs

/* Approach:
   Create a CTE to list all three categories
   Use CASE to create conditional evaluation for each category
   Use COUNT to count the number of accounts in each category
   LEFT JOIN the CTE with the aggregated table to ensure all categories are represented, even if count is 0
*/

 WITH category1 (category) AS (
        SELECT 'High Salary'
        UNION ALL
        SELECT 'Low Salary'
        UNION ALL
        SELECT 'Average Salary'
    ) 
select category1.category,COALESCE(category2.accounts_count,0) as accounts_count  from category1 left join

(select count(account_id) as accounts_count,
(CASE 
WHEN income < 20000 THEN "Low Salary" 
WHEN income >= 20000 and income <=50000 THEN "Average Salary"
WHEN income > 50000 THEN "High Salary" 
ELSE NULL 
END) as category
from Accounts 
GROUP BY category) as category2 
on category1.category=category2.category Group by category1.category
