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
SELECT 
count(*) AS total_rides
FROM rides 

-- ── Query 2 ───────────────────────────────────────────────────────
--list ALL UNIQUE pickup cities , sorted alphabetically ?
SELECT 
distinct(pickup_city) AS pickup_cities
FROM rides 
ORDER BY pickup_city ASC

-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.
SELECT 
* 
FROM rides 
WHERE fare_amount >500 
ORDER BY fare_amount DESC

-- ── Query 4 ───────────────────────────────────────────────────────
--How many rides have a NULL rating?
--Answer: 2379

--what might that mean?
--It might mean the passenger forget to rate driver, passenger or driver didn't show up, ride was cancelled
--Nearly 47% of total rides have no rating,
--Nearly 8% of completed rides have no rating
--Likely 100% of cancelled ride have no rating

SELECT 
count(*) AS null_rating
FROM rides
WHERE rating IS NULL

				
-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).
SELECT 
ride_id, driver_name, rider_name AS passenger_name, requested_at, completed_at
FROM rides 
WHERE requested_at IS NOT NULL AND ride_status = 'completed'
ORDER BY completed_at DESC
LIMIT 10

-- ── Query 6 ───────────────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)
SELECT 
ride_status, count(*) AS status_count  
FROM rides 
GROUP BY ride_status 

-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?
SELECT 
sum(fare_amount) AS total_fare_collected 
FROM rides 
WHERE ride_status = 'completed' 

-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
SELECT 
ride_id, driver_name ,rider_name AS passenger_name , pickup_city ,dropoff_city, ride_distance_km, fare_amount
FROM rides 
WHERE pickup_city = dropoff_city 

-- How many are there? Add a comment: are these valid records?
--count: 192
--Yes, it is valid. Note that rows with NULL values in either column won't match, since NULL = NULL is not considered true in SQL.
SELECT 
count(*) 
FROM rides 
WHERE pickup_city = dropoff_city 
