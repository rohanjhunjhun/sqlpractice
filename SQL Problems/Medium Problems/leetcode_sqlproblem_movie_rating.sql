-- Problem:1341 Movie Rating
-- Link: https://leetcode.com/problems/movie-rating/
-- Difficulty: Medium
-- Concepts: Aggregations, Filtering, Joins, Subqueries, CTEs
/* Approach:
    Use two subqueries to find the user with the highest number of ratings and the movie with the highest average rating in February 2020.
    Use ORDER BY and LIMIT to get the top user and top movie based on the specified criteria.
    Use LEFT JOINs to lookup names from Users and Movies tables.
    Combine the results using UNION ALL to return them in a single result set.
*/

(select name as results from Users 
left join 
(select user_id,count(*) as c1 from MovieRating group by user_id) as ct1 
on Users.user_id=ct1.user_id 
ORDER BY c1 DESC,name ASC LIMIT 1)

UNION ALL 

(select title as results from Movies 
left join 
(select movie_id,AVG(rating) as c2 from MovieRating where MONTH(created_at)=2 and YEAR(created_at)=2020 group by movie_id ) as ct2 
on Movies.movie_id=ct2.movie_id  
ORDER BY c2 DESC,title ASC LIMIT 1)
