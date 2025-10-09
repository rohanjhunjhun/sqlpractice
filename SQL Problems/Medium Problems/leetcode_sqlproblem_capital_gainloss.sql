-- Problem: 1393 Capital Gain/Loss
-- Link: https://leetcode.com/problems/capital-gainloss/
-- Difficulty: Medium
-- Concepts: CASE, Aggregations, GROUP BY, SUM

/* Approach:
   Use CASE to calculate the capital gain/loss for each stock.
   Group the results by stock_name.
*/

select stock_name,sum(case 
when operation = "Buy" then price * -1
when operation = "Sell" then price * 1 
else null 
end) as "capital_gain_loss" from Stocks GROUP BY stock_name

