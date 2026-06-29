-- week1_queries.sql
-- Week 1 Assignment
-- Submit this file with all 8 queries filled in.
-- Label each query clearly. Add a comment if your answer
-- reveals something interesting about the data.
--
-- Grading: correctness + NULL handling + clean formatting
-- Due: before Week 2, Day 1

-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

SELECT  count(*) FROM rides


-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

SELECT pickup_city
FROM rides
GROUP BY pickup_city
ORDER BY pickup_city;


-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.

SELECT * FROM rides
WHERE fare_amount > 500
ORDER BY fare_amount DESC;


-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
-- Answer : 2379
-- Add a comment: what does a NULL rating most likely mean?
-- Null rating most likey mean that the passenger has not rated the ride yet.

 SELECT
 COUNT(*) 
 FROM rides 
 WHERE rating 
 IS NULL;


-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).

SELECT *
FROM rides
WHERE ride_status = 'completed'
ORDER BY requested_at DESC
LIMIT 10;


-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

SELECT ride_status, COUNT(*)
FROM rides
GROUP BY ride_status;


-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

SELECT SUM(fare_amount)
FROM rides
WHERE ride_status = 'completed';


-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
SELECT * FROM rides
WHere pickup_city = dropoff_city;
-- How many are there? Add a comment: are these valid records?

SELECT 
count(*)
FROM rides 
Where pickup_city = dropoff_city
-- Answer : ther are 192 ride, and yes these are valid reccords.

