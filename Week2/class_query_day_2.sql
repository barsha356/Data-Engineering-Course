DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS passengers;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS payment_methods ;

-- Cities that appear as pickup or dropoff locations
CREATE TABLE locations (
    location_id   SERIAL        PRIMARY KEY,
    city_name     VARCHAR(100)   NOT NULL UNIQUE
);

-- Drivers (canonical names, deduped from the flat table)
CREATE TABLE drivers (
    driver_id     SERIAL        PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL
);

-- passenger
CREATE TABLE passengers (
    passenger_id     SERIAL        PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL
);

CREATE TABLE payment_methods (
	payment_method_id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE 
);

-- ─────────────────────────────────────────────────────────────────
-- STEP 2: Create the trips table with foreign keys
-- ─────────────────────────────────────────────────────────────────

CREATE TABLE trips (
    trip_id              SERIAL        PRIMARY KEY,
    driver_id            INTEGER       NOT NULL REFERENCES drivers(driver_id),
    passenger_id         INTEGER       NOT NULL REFERENCES passengers(passenger_id),
    pickup_location_id   INTEGER       NOT NULL REFERENCES locations(location_id),
    dropoff_location_id  INTEGER       NOT NULL REFERENCES locations(location_id),
    fare_amount          NUMERIC(10,2) NOT NULL CHECK (fare_amount > 0),
    distance_km          NUMERIC(6,2)  NOT NULL,
    status               varchar(50)   NOT NULL CHECK (status IN ('completed','cancelled','no_show')),
    requested_at         TIMESTAMP     NOT NULL,
    completed_at         TIMESTAMP,
    rating               NUMERIC(2,1)  CHECK (rating BETWEEN 1.0 AND 5.0),
    payment_method_id    INTEGER       REFERENCES payment_methods(payment_method_id)
);

SELECT * FROM drivers d ;
--------------------------------------------------------
SELECT DISTINCT driver_name FROM rides r ;

SELECT DISTINCT trim(driver_name) FROM rides;



SELECT trim(' bishal  rijal ');
SELECT DISTINCT driver_name FROM rides r 
WHERE driver_name LIKE '%  %';

SELECT
	DISTINCT REPLACE(driver_name, '  ', ' ')
FROM
	rides r ;

SELECT  DISTINCT driver_name FROM rides;


SELECT
	count (DISTINCT REPLACE(driver_name, '  ', ' '))
FROM
	rides r ;

SELECT
	 DISTINCT lower(REPLACE(driver_name, '  ', ' '))
FROM
	rides r ;

SELECT  DISTINCT lower(replace(driver_name,'  ',' ')) FROM rides r ; 

SELECT
	DISTINCT INITCAP(REPLACE(driver_name, '  ', ' '))
FROM
	rides r ;


SELECT initcap('BISHAL j 
  Rijal');

SELECT REGEXP_REPLACE(' BISHAL j 
  Rijal', '\s+', ' ', 'g');


SELECT
	DISTINCT INITCAP(TRIM(REGEXP_REPLACE(
	r.driver_name, '\s+', ' ', 'g')))
FROM
	rides r;



INSERT INTO drivers (name)
SELECT
	DISTINCT INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))
FROM
	rides r;

SELECT * FROM drivers;
--------------------

INSERT INTO passengers (name)
SELECT
	DISTINCT INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))
FROM
	rides r;

SELECT * FROM passengers;

SELECT DISTINCT pickup_city locations FROM rides
EXCEPT 
SELECT DISTINCT dropoff_city city FROM rides;


SELECT DISTINCT pickup_city locations FROM rides
INTERSECT  
SELECT DISTINCT dropoff_city city FROM rides;


SELECT DISTINCT pickup_city locations FROM rides r 
UNION  ALL 
SELECT DISTINCT dropoff_city city FROM rides;

-----------------------------

INSERT INTO locations(city_name)
SELECT DISTINCT(pickup_city) FROM rides r 
UNION 
SELECT DISTINCT(dropoff_city ) FROM rides r ;

INSERT INTO payment_methods (name)
select DISTINCT payment_method FROM rides
WHERE payment_method IS NOT NULL 


INSERT INTO payment_methods (name)
VALUES ('IME pay5')


SELECT * FROM payment_methods pm ;

SELECT * FROM pg_get_serial_sequence('payment_methods','payment_method_id')

ALTER SEQUENCE public.payment_methods_payment_method_id_seq RESTART WITH 1
-------------------------------------------------
--Let's talk about join first 

INSERT INTO payment_methods(name)
SELECT DISTINCT(payment_method) FROM rides r 
WHERE payment_method IS NOT NULL ;


SELECT * FROM trips;


SELECT *  FROM drivers ;
SELECT * FROM rides;
--- 
SELECT 
	(SELECT  driver_id 
		FROM drivers d 
	 WHERE d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))) driver_id
, *
	 FROM rides r;

SELECT 
	(SELECT  passenger_id 
		FROM passengers p
	 WHERE p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))) passenger_id
FROM rides r;

SELECT * FROM drivers;
SELECT * FROM passengers p ;
SELECT * FROM locations;
SELECT * FROM payment_methods pm ;

SELECT 
	(SELECT  location_id  
		FROM locations p
	 WHERE p.city_name = r.pickup_city ) pickup_location_id
FROM rides r;

SELECT 
	(SELECT  location_id  
		FROM locations p
	 WHERE p.city_name = r.dropoff_city ) dropoff_location_id
FROM rides r;

SELECT 
	(SELECT  payment_method_id  
		FROM payment_methods pm  
		WHERE pm.name = r.payment_method  ) payment_method_id
FROM rides r;
    



INSERT INTO trips (
	driver_id,
	passenger_id,
	pickup_location_id,
	dropoff_location_id,
	fare_amount,
	distance_km,
	status,
	requested_at,
	completed_at,
	rating,
	payment_method_id
)
SELECT 
(SELECT  driver_id 
	FROM drivers d 
	 WHERE d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))) driver_id,
(SELECT  passenger_id 
		FROM passengers p
	 WHERE p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))) passenger_id,
(SELECT  location_id  
		FROM locations p
	 WHERE p.city_name = r.pickup_city ) pickup_location_id,
(SELECT  location_id  
		FROM locations p
	 WHERE p.city_name = r.dropoff_city ) dropoff_location_id,
fare_amount,
ride_distance_km,
ride_status,
requested_at,
completed_at,
rating,
(SELECT  payment_method_id  
		FROM payment_methods pm  
		WHERE pm.name = r.payment_method  ) payment_method_id
FROM rides r;

SELECT * FROM trips;

SELECT * FROM drivers;

SELECT * FROM locations l ;

SELECT * FROM passengers p ;