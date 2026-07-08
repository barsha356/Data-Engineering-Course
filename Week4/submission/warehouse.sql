DROP TABLE IF EXISTS fact_trips;
DROP TABLE IF EXISTS dim_date; 

CREATE TABLE dim_date (
    date_key        INTEGER      PRIMARY KEY,      -- e.g. 20240315
    full_date       DATE         NOT NULL,
    year            SMALLINT     NOT NULL,
    quarter         SMALLINT     NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    month           SMALLINT     NOT NULL CHECK (month BETWEEN 1 AND 12),
    month_name      VARCHAR(10)  NOT NULL,          -- 'January' … 'December'
    week_of_year    SMALLINT     NOT NULL,          -- ISO week 1-53
    day_of_week     SMALLINT     NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Sun
    day_name        VARCHAR(10)  NOT NULL,          -- 'Sunday' … 'Saturday'
    is_weekend      BOOLEAN      NOT NULL
);

SELECT * FROM drivers;

DROP TABLE IF EXISTS dim_driver;
CREATE TABLE dim_driver (
    driver_key      SERIAL       PRIMARY KEY,
    driver_id       INTEGER      NOT NULL UNIQUE,          -- natural key from OLTP
    name            VARCHAR(100) NOT NULL,
    status          VARCHAR(20)  NOT NULL,          -- active / inactive / suspended
    joined_at       TIMESTAMP,
    tenure_bucket   VARCHAR(20)                 -- '0-6 months' / '6-12 months' / '1-2 years' / '2+ years'
);

SELECT * FROM passengers;
DROP TABLE IF EXISTS dim_passenger;
CREATE TABLE dim_passenger (
    passenger_key   SERIAL       PRIMARY KEY,
    passenger_id    INTEGER      NOT NULL UNIQUE ,
    name            VARCHAR(100) NOT NULL,
    status          VARCHAR(20)  NOT NULL,
    cohort_month    VARCHAR(7),                    -- 'YYYY-MM' — when they first joined
    created_at      TIMESTAMP
);

SELECT * FROM locations;
CREATE TABLE dim_location (
    location_key    SERIAL       PRIMARY KEY,
    location_id     INTEGER      NOT NULL UNIQUE,  -- natural key from OLTP
    city_name       VARCHAR(100) NOT NULL,
    state_province  VARCHAR(100),
    country         VARCHAR(100),
    region          VARCHAR(30),   -- derived: 'Northeast' / 'West' / 'South' / 'Midwest' / 'International'
    latitude        NUMERIC(9,6),
    longitude       NUMERIC(9,6)
);


---SELECT * FROM payment_methods;

CREATE TABLE dim_payment_method (
    payment_method_key  SERIAL      PRIMARY KEY,
    payment_method_id   INTEGER     UNIQUE,     -- NULL for the "Unknown" row
    name                VARCHAR(30) NOT NULL,
    type                VARCHAR(20),            -- card / cash / wallet / voucher
    is_active           BOOLEAN
);

---SELECT * FROM promo_codes pc ;
CREATE TABLE dim_promo_code (
    promo_code_key  SERIAL       PRIMARY KEY,
    promo_code_id   INTEGER      UNIQUE,    -- NULL = "No Promo" sentinel row
    code            VARCHAR(30),
    discount_type   VARCHAR(10),            -- percent / flat
    discount_value  NUMERIC(8,2),
    is_active       BOOLEAN
);

---Assignment 1
--Creating table of time and vechicle
CREATE TABLE IF NOT EXISTS dim_time (
    time_key INT PRIMARY KEY,          -- e.g. 1430
    hour INT NOT NULL,                  -- 0–23
    minute INT NOT NULL,                -- 0, 15, 30, 45
    time_label TEXT                     -- '14:30'
);

CREATE TABLE dim_vehicle (
    vehicle_key   SERIAL PRIMARY KEY,
    vehicle_id    INT UNIQUE NOT NULL,
    plate_number  VARCHAR(20),
    make          VARCHAR(50),
    model         VARCHAR(50),
    year          INT,
    color         VARCHAR(30),
    category      VARCHAR(30),
    is_active     BOOLEAN
);


 

CREATE TABLE fact_trips (
    trip_key                SERIAL          PRIMARY KEY,
    source_trip_id          INTEGER         NOT NULL UNIQUE,   -- OLTP trips.trip_id — for lineage + ON CONFLICT
 
    -- ── Dimension keys ────────────    -- ── Audit timestamp ──────────────────────────────────────────────────────

    date_key                INTEGER         NOT NULL REFERENCES dim_date(date_key),
    driver_key              INTEGER         NOT NULL REFERENCES dim_driver(driver_key),
    passenger_key           INTEGER         NOT NULL REFERENCES dim_passenger(passenger_key),
    pickup_location_key     INTEGER         NOT NULL REFERENCES dim_location(location_key),
    dropoff_location_key    INTEGER         NOT NULL REFERENCES dim_location(location_key),
    payment_method_key      INTEGER         REFERENCES dim_payment_method(payment_method_key),
    promo_code_key          INTEGER         REFERENCES dim_promo_code(promo_code_key),
 
    -- ── Additive measures ───────────────────────────────────────────────────
    base_fare               NUMERIC(10,2),
    tip_amount              NUMERIC(8,2)    NOT NULL DEFAULT 0.00,
    discount_amount         NUMERIC(8,2)    NOT NULL DEFAULT 0.00,
    fare_amount             NUMERIC(10,2),  -- computed: (base_fare × surge) + tip − discount
    distance_km             NUMERIC(6,2),
    duration_minutes        NUMERIC(6,1),   -- NULL for cancelled / no_show
    trip_count              SMALLINT        NOT NULL DEFAULT 1,   -- always 1; useful for COUNT queries
 
    -- ── Semi-additive measures ───────────────────────────────────────────────
    driver_rating           NUMERIC(2,1),   -- passenger → driver (AVG only)
    passenger_rating        NUMERIC(2,1),   -- driver → passenger (AVG only)
 
    -- ── Non-additive measure 
    surge_multiplier        NUMERIC(4,2),   -- ratio; never SUM, only AVG
 
    -- ── Audit timestamp 
    requested_at            TIMESTAMP       NOT NULL   -- kept for incremental watermark queries
);

--- Assignment 1.(second part) 
---Add vehicle_key and time_key columns to fact_trips, referencing dim_vehicle(vehicle_key) and dim_time(time_key)
ALTER TABLE fact_trips
ADD COLUMN vehicle_key INT,
ADD COLUMN time_key INT;

ALTER TABLE fact_trips
ADD CONSTRAINT fk_vehicle
FOREIGN KEY (vehicle_key) REFERENCES dim_vehicle(vehicle_key);

ALTER TABLE fact_trips
ADD CONSTRAINT fk_time
FOREIGN KEY (time_key) REFERENCES dim_time(time_key);




--------------------------


--Populate dim_date
-- Generates one row per calendar day from 2023-01-01 to 2026-12-31.
-- Covers the full range of the sample dataset with room for future trips.
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO dim_date (
    date_key, full_date, year, quarter, month,
    month_name, week_of_year, day_of_week, day_name, is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER                  AS date_key,
    d::DATE                                          AS full_date,
    EXTRACT(YEAR    FROM d)::SMALLINT                AS year,
    EXTRACT(QUARTER FROM d)::SMALLINT                AS quarter,
    EXTRACT(MONTH   FROM d)::SMALLINT                AS month,
    TRIM(TO_CHAR(d, 'Month'))                        AS month_name,   -- trim trailing spaces!
    EXTRACT(WEEK    FROM d)::SMALLINT                AS week_of_year,
    EXTRACT(DOW     FROM d)::SMALLINT                AS day_of_week,  -- 0=Sun, 6=Sat
    TRIM(TO_CHAR(d, 'Day'))                          AS day_name,     -- trim trailing spaces!
    EXTRACT(DOW FROM d) IN (0, 6)                    AS is_weekend
FROM generate_series(
    '2023-01-01'::TIMESTAMP,
    '2026-12-31'::TIMESTAMP,
    '1 day'::INTERVAL
) AS d;


----Assignment 3
---Revenue by city / month
---Write a warehouse query that returns total revenue grouped by pickup city and month.
SELECT
    l.city_name,
    d.month,
    SUM(f.fare_amount) AS total_revenue
FROM fact_trips f
JOIN dim_location l ON f.pickup_location_key = l.location_key
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY l.city_name, d.month;
---Answer = Warehouse query uses 2 joins.
---OLTP query uses 1 join, but requires runtime calculations.
---Warehouse needs fewer computations because data is pre-aggregated and modeled for analytics.

---Asssignment 4. Payment method revenue
---Write a warehouse query for total revenue per payment method.
SELECT
    pm.name,
    SUM(f.fare_amount) AS total_revenue
FROM fact_trips f
JOIN dim_payment_method pm ON f.payment_method_key = pm.payment_method_key
GROUP BY pm.name;

---Avg fare per month
---Extend it (or write a second query) for average fare per trip, per payment method, per month.
SELECT
    pm.name,
    d.month,
    AVG(f.fare_amount) AS avg_fare
FROM fact_trips f
JOIN dim_payment_method pm ON f.payment_method_key = pm.payment_method_key
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY pm.name, d.month;

---Assignment 5
---Busiest hour of day
---Write a warehouse query that returns trip count per hour of day (0–23), along with each hour's 
---percentage of all trips — computed with a window function (not a second query for the grand total).
SELECT
    time_key / 100 AS hour,
    COUNT(*) AS trip_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM fact_trips
GROUP BY hour
ORDER BY hour;






