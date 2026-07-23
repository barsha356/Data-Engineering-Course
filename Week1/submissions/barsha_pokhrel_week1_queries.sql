CREATE DATABASE rides_practice;
-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?
-- 1. How many total rides are there in the dataset?
SELECT COUNT(*) AS total_rides FROM rides;

-- Query 2
--List all unique pickup cities, sorted alphabetically.

SELECT DISTINCT pickup_city FROM rides ORDER BY pickup_city ASC;


--Query 3
--Show all rides where the fare was above 500, ordered by fare descending.

SELECT * FROM rides WHERE fare_amount > 500 ORDER BY fare_amount DESC;


--Query 4
--How many rides have a NULL rating?
SELECT COUNT(*)  FROM rides WHERE rating IS NULL;


--Queru 5
--Show the 10 most recent completed rides
SELECT * from rides WHERE ride_status = 'completed' ORDER BY requested_at DESC LIMIT 10;

--Query 6
--Count how many rides exist for each ride_status.
SELECT ride_status, COUNT(*) AS ride_count FROM rides GROUP BY ride_status;
 --answer = completed= 2862, cancelled = 1408 ,  no_show=730

--Query 7
--What is the total fare collected across completed rides only?





--Query 8
--Find rides where pickup_city and dropoff_city are the same.
SELECT * FROM rides WHERE pickup_city =dropoff_city;
SELECT count(*) FROM rides WHERE pickup_city =dropoff_city;
--answer 192