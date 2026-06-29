---Week 3 Assignment
-- Q1: Add indexes to the trips table
EXPLAIN ANALYZE
SELECT * FROM trips WHERE driver_id = 3;
--Bitmap Heap Scan on trips  (cost=8.01..79.02 rows=481 width=67) (actual time=0.063..0.227 rows=481.00 loops=1)
--  Recheck Cond: (driver_id = 3)
--  Heap Blocks: exact=64
--  Buffers: shared hit=67
--  ->  Bitmap Index Scan on idx_trips_driver_id  (cost=0.00..7.89 rows=481 width=0) (actual time=0.031..0.031 rows=481.00 loops=1)
--        Index Cond: (driver_id = 3)
--        Index Searches: 1
--        Buffers: shared hit=3
--Planning Time: 0.146 ms
--Execution Time: 0.280 ms

EXPLAIN ANALYZE
SELECT * FROM trips WHERE status = 'cancelled';
--Seq Scan on trips  (cost=0.00..128.47 rows=1430 width=67) (actual time=0.039..0.760 rows=1408.00 loops=1)
--  Filter: ((status)::text = 'cancelled'::text)
--  Rows Removed by Filter: 3593
--  Buffers: shared hit=65
--Planning Time: 0.141 ms
--Execution Time: 0.840 ms

EXPLAIN ANALYZE
SELECT * FROM trips
WHERE driver_id = 3 AND status = 'completed';

--Seq Scan on trips  (cost=0.00..141.17 rows=280 width=67) (actual time=0.026..3.869 rows=284.00 loops=1)
--  Filter: ((driver_id = 3) AND ((status)::text = 'completed'::text))
--  Rows Removed by Filter: 4717
--  Buffers: shared hit=65
--Planning Time: 0.161 ms
--Execution Time: 3.939 ms


-- Index for driver filter
CREATE INDEX IF NOT EXISTS idx_trips_driver_id
ON trips(driver_id);

-- Index for status filter
CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status);

-- Composite index for driver + status 
CREATE INDEX idx_trips_driver_status
ON trips(driver_id, status);


-- Query A before: Seq Scan, execution time = 0.280 ms
-- Query A after:  Index Scan using idx_trips_driver_id, execution time = 0.001 s

-- Query B before: Seq Scan, execution time = 0.840 ms
-- Query B after:  Index Scan using idx_trips_status, execution time = 0.006 s

-- Query C before: Seq Scan, execution time = 3.939 ms
-- Query C after:  Index Scan using idx_trips_driver_status, execution time =  0.017 s


-- Q2: Create completed_trips_view
CREATE OR REPLACE VIEW completed_trips_view AS
SELECT
    t.trip_id,
    d.driver_name,
    p.passenger_name,
    lp.city_name AS pickup_city,
    ld.city_name AS dropoff_city,
    t.fare_amount,
    t.distance_km,
    t.rating,
    t.payment_method_id,
    t.requested_at,
    t.completed_at
FROM trips t
JOIN drivers d ON t.driver_id = d.driver_id
JOIN passengers p ON t.passenger_id = p.passenger_id
JOIN locations lp ON t.pickup_location_id = lp.location_id
JOIN locations ld ON t.dropoff_location_id = ld.location_id
WHERE t.status = 'completed';
---Execution time : 0.019

SELECT * FROM completed_trips_view LIMIT 5;
SELECT COUNT(*) FROM completed_trips_view;
--- answer: 2863


 ---Q3: Create driver_summary view
CREATE OR REPLACE VIEW driver_summary AS
SELECT
    d.driver_name,

    COUNT(t.trip_id) AS total_trips,

    COUNT(t.trip_id) FILTER (WHERE t.status = 'completed')
        AS completed_trips,

    COUNT(t.trip_id) FILTER (WHERE t.status = 'cancelled')
        AS cancelled_trips,

    ROUND(
        COUNT(t.trip_id) FILTER (WHERE t.status = 'cancelled')
        * 100.0
        / NULLIF(COUNT(t.trip_id), 0),
        1
    ) AS cancellation_rate,

    ROUND(
        AVG(t.fare_amount) FILTER (WHERE t.status = 'completed'),
        2
    ) AS avg_fare,

    ROUND(
        AVG(t.rating) FILTER (WHERE t.status = 'completed'),
        1
    ) AS avg_rating
      FROM drivers d
     LEFT JOIN trips t ON d.driver_id = t.driver_id
      GROUP BY d.driver_name;
    
    SELECT * FROM driver_summary ORDER BY completed_trips DESC;
    
    -- Q4: Transaction with intentional failure
    BEGIN;

-- 1. Insert new driver
INSERT INTO drivers (driver_name)
VALUES ('Test Driver');

-- 2. Insert 3 valid trips
INSERT INTO trips (
    driver_id, rider_id,
    pickup_location_id, dropoff_location_id,
    fare_amount, distance_km,
    status, rating,
    payment_method, requested_at, completed_at
)
SELECT
    d.driver_id, 1, 1, 2,
    500, 10,
    'completed', 5,
    'cash', NOW(), NOW()
FROM drivers d
WHERE d.driver_name = 'Test Driver'
LIMIT 3;

-- 3. Invalid trip (rating = 99 → CHECK constraint fails)
INSERT INTO trips (
    driver_id, rider_id,
    pickup_location_id, dropoff_location_id,
    fare_amount, distance_km,
    status, rating,
    payment_method, requested_at, completed_at
)
SELECT
    d.driver_id, 1, 1, 2,
    600, 12,
    'completed', 99,
    'cash', NOW(), NOW()
FROM drivers d
WHERE d.driver_name = 'Test Driver';

COMMIT;

SELECT
    'drivers' AS tbl,
    COUNT(*) AS test_driver_rows
FROM drivers
WHERE driver_name = 'Test Driver'
UNION ALL
SELECT 'trips', COUNT(*)
FROM trips t
JOIN drivers d ON t.driver_id = d.driver_id
WHERE d.driver_name = 'Test Driver';

---Answer drivers:0   trips:0

-- Q6 (STRETCH): Window function — running total fare per driver
SELECT
    t.trip_id,
    d.driver_name,
    t.requested_at,
    t.fare_amount,
    SUM(t.fare_amount) OVER (
        PARTITION BY t.driver_id
        ORDER BY t.requested_at
    ) AS running_total_fare
FROM trips t
JOIN drivers d ON t.driver_id = d.driver_id
WHERE t.status = 'completed'
ORDER BY d.driver_name, t.requested_at;



