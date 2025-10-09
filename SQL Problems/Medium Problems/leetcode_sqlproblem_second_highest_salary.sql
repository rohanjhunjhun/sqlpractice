-- Problem:176 Second Highest Salary
-- Link: https://leetcode.com/problems/second-highest-salary/
-- Difficulty: Medium
-- Concepts: Aggregations, Subqueries, LIMIT, ORDER BY

/* Approach:
    Use DENSE_RANK() to rank salaries in descending order
    Filter where rank =2 to get the second highest salary
    Use SUM to return NULL if there is no second highest salary
*/

select sum(distinct(salary)) as SecondHighestSalary from 
(select *,DENSE_RANK() OVER(ORDER BY salary DESC) as salaryrank from Employee) as tab1 
where salaryrank=2
