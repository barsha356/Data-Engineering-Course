-- week1_queries.sql
-- Week 1 Assignment
-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

SELECT
	COUNT(*)
FROM
	rides r ;
-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

SELECT
	DISTINCT pickup_city
FROM
	rides
ORDER BY
	pickup_city ASC;
--Here alphabetical order is default, 
--"SELECT DISTINCT pickup_city FROM rides ORDER BY pickup_city;" 
--would also have given the same output 
-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.
SELECT
	*
FROM
	rides r
WHERE
	r.fare_amount > 500
ORDER BY
	r.fare_amount DESC ;
    
-- ── Query 4 ───────────────────────────────────────────────────────

-- How many rides have a NULL rating?
-- 2379 rides have a NULL rating

-- What does a NULL rating most likely mean?
-- NULL rating most likely means the ride was not completed or the passenger didnt provide a rating for the ride

SELECT
	COUNT(*)
FROM
	rides
WHERE
	rating IS NULL;


-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).
-- after reading the hint 
SELECT
	*
FROM
	rides
WHERE
	ride_status = 'completed'
ORDER BY
	requested_at DESC
LIMIT 10 ;
-- before reading the hint
SELECT
	*
FROM
	rides
WHERE
	completed_at IS NOT NULL
ORDER BY
	requested_at DESC
LIMIT 10;
-- this is what i thought would also give the same result without reading the hint , 
--because cancel and noshow status both have "null" values at completed_at 
-- but i do understand how the later query is more error prone
-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

SELECT
	ride_status,
	count(*) AS total_rides
FROM
	rides
GROUP BY
	ride_status;
-- i have kept ride_status also in select statement because its necessary to know the count corresponds to which status 
-- i have also temporarily named the count column as total_rides so that the output can be self-explanatory
-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

SELECT
	SUM(fare_amount)
FROM
	rides
WHERE
	ride_status = 'completed';
-- WHERE filters rows before SUM runs, so only completed ride fares are totalled.
-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?

SELECT
	count(*)
FROM
	rides
WHERE
	pickup_city = dropoff_city ;
-- there are 192 of them 
-- yes i do think these likely valid since cities cover large areas,
-- meaning a ride can start and end in the same city.
-- if the pick up and drop points (eg latitude, logitude) were provided and matched the data would be questionable since that would mean 0 distance travelled 
