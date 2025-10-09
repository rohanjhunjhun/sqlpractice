-- Problem: 262. Trips and Users
-- Link: https://leetcode.com/problems/trips-and-users/description/
-- Difficulty: Hard
-- Concepts: Window Functions, Aggregations, Filtering

/* Approach:
   "Cancellation Rate" = (Number of cancelled trips/ Total number of trips) for each day
   Join Trips table with Users table twice to get the client and driver information
   Filter out the banned users and the dates outside the range 2013-10-01 to 2013-10-03
*/

-- Write your SQL query below

# Write your MySQL query statement below
select request_at as Day,
(ROUND(COUNT(CASE 
    WHEN Trips.status IN ("cancelled_by_driver","cancelled_by_client") THEN 1 
    ELSE NULL 
    END)/COUNT(*),2)) as "Cancellation Rate" 
    from Trips 
    LEFT JOIN Users as Clients ON Trips.client_id =Clients.users_id 
    LEFT JOIN Users as Drivers ON Trips.driver_id=Drivers.users_id 
    where Clients.banned = "No" and Drivers.banned="No" and request_at BETWEEN "2013-10-01" and "2013-10-03" GROUP BY request_at