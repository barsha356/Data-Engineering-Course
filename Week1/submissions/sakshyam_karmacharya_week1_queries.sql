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

SELECT COUNT(*) AS total_rides
FROM rides;





-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

SELECT DISTINCT pickup_city 
FROM rides 
ORDER BY pickup_city ASC;






-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.

SELECT * 
FROM rides 
WHERE fare_amount > 500 
ORDER BY fare_amount DESC;





-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
-- Add a comment: what does a NULL rating most likely mean?

SELECT COUNT(*) AS unrated_rides 
FROM rides
WHERE rating IS NULL ; 

-- Observation: About 47.58% of rides have a NULL rating.
-- Likely Passengers cancelled or didn't show up, so no rating was given.





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

SELECT ride_status, COUNT(*) AS ride_count
FROM rides
GROUP BY ride_status;





-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

SELECT SUM(fare_amount) AS total_fare_collected
FROM rides
WHERE ride_status = 'completed';

-- total fare collected 14,30,112.40






-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?

SELECT *
FROM rides
WHERE pickup_city = dropoff_city;

-- There are about 192 rides where pickup_city and dropoff_city are the same.
-- Yes these could be valid records, as the location might be different within the same city,
-- I also observed that there are about 92 rides where the pickup and dropoff locations
-- are the same, which were cancelled or no show, so these could be invalid records.
-- below is the query to find those records:

/*
SELECT Count (*)
FROM rides
WHERE pickup_city = dropoff_city
AND ride_status IN ('cancelled', 'no_show');
*/