-- Problem: 185. Department Top Three Salaries
-- Link: https://leetcode.com/problems/department-top-three-salaries/description/
-- Difficulty: Hard
-- Concepts: Window Functions, Aggregations, Joins , subqueries

/* Approach:
   Use DENSE_RANK() to rank employees by salary per department, 
   then filter where rank <=3.
*/

select Department,Employee,salary as Salary 
from 
(select e.name as Employee,salary,d.name as Department, 
DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY salary DESC) as deptrank
from Employee as e LEFT JOIN Department as d ON e.departmentId=d.id) as rankedtable 
where deptrank <=3