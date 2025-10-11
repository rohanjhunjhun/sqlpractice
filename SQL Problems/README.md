# sqlpractice
# 🧠 LeetCode SQL Solutions

This repository contains my solutions to LeetCode SQL problems — each one documented with reasoning, approach, and key concepts.  
---

## 🗂️ Folder Structure

- `problems/` → Individual LeetCode problems with SQL queries and explanations.
---

## 🧩 Problem Format

Each file follows below structure:

```sql
-- Problem: 184. Department Highest Salary
-- Link: https://leetcode.com/problems/department-highest-salary/
-- Difficulty: Medium
-- Concepts: Window Functions, Aggregations, Joins

/* Approach:
   Use DENSE_RANK() to rank employees by salary per department, 
   then filter where rank = 1.
*/

SELECT Department, Employee, Salary
FROM (
  SELECT d.name AS Department,
         e.name AS Employee,
         e.salary AS Salary,
         DENSE_RANK() OVER(PARTITION BY d.name ORDER BY e.salary DESC) AS rnk
  FROM Employee e
  JOIN Department d ON e.departmentId = d.id
) ranked
WHERE rnk = 1;
