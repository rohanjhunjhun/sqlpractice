-- Problem: 601. Human Traffic of Stadium
-- Link: https://leetcode.com/problems/human-traffic-of-stadium/description
-- Difficulty: Hard
-- Concepts: Window Functions, Case Statements , subqueries , aggregations

/* Approach:
   Use CASE to create a True/False evaluation for dates  with >100 people
   USE SUM on this CASE to get to create 3 conditional evaluation columns to find three consecutive days with >100 people
   FILTER dates where the sum of any of the conditional columns is 3
*/

select id,visit_date,people from 
(select*,
SUM(people100plus) OVER(ORDER BY id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as sum1,
SUM(people100plus) OVER(ORDER BY id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as sum2,
SUM(people100plus) OVER(ORDER BY id ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) as sum3 from 
(select id,visit_date,people,
(CASE 
WHEN people >=100 THEN 1 
ELSE NULL 
END) as people100plus from Stadium) as basedata) as conditions where sum1>2 or sum2>2 or sum3>2