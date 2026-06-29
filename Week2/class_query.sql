
---- count
SELECT * from rides;

SELECT count(*) FROM rides;

SELECT sum(fare_amount) FROM rides;

SELECT avg(fare_amount) FROM rides;


SELECT min(ride_distance_km ) FROM rides;

SELECT max(ride_distance_km ) FROM rides;


----- break down 

SELECT
	driver_name,
	count(*), 
	sum(fare_amount )
FROM rides 
GROUP by driver_name;


---- how group by work under the hood

----- Now pathao introduce the scheme to incentivise the rider who complete their 30 rides?
--provide me the list OF rider
SELECT 
	driver_name, count(*)
FROM rides
WHERE ride_status = 'completed'	
GROUP BY driver_name
HAVING count(*) >150;


SELECT 
	driver_name, count(*)
FROM rides
WHERE ride_status = 'completed'	
GROUP BY driver_name
HAVING count(*) >150;


SELECT * FROM rides r;

SELECT 
	driver_name, count(*)
FROM rides
WHERE ride_status = 'completed'	
GROUP BY driver_name
HAVING count(*) >150
ORDER BY driver_name;


SELECT driver_name , count(*), sum(fare_amount )
FROM rides
GROUP BY driver_name
ORDER BY driver_name;


SELECT * FROM rides;


--------------Normalization 
SELECT *
INTO TEMP temp_rides
FROM rides r ;

SELECT * FROM temp_rides;

---- let's add the driver_phone number in the table
ALTER TABLE temp_rides ADD phone_number varchar(100);

SELECT * FROM temp_rides;

---let's update the phone number for anita
SELECT * FROM temp_rides r WHERE driver_name LIKE '%Anita Rai%'

UPDATE temp_rides 
SET phone_number = '987654321'
WHERE driver_name LIKE '%Anita Rai%';

UPDATE temp_rides 
SET phone_number = '9876543210'
WHERE driver_name LIKE '%Anita Rai%'
AND ride_id >1000;

SELECT DISTINCT driver_name, phone_number 
FROM temp_rides
WHERE driver_name LIKE '%Anita Rai%';


SELECT * FROM rides;



----- Bishal is enrolled into the app but has not got the rides at
--how can I have the data ?
SELECT * FROM temp_rides ORDER BY ride_id DESC LIMIT 1;


--- insert anamoly 
--How to insert without ride ?

INSERT INTO temp_rides (ride_id,driver_name,passenger_name,pickup_city,dropoff_city,fare_amount,ride_distance_km,ride_status,requested_at,completed_at,rating,payment_method,phone_number) VALUES
	 (5001,'Bishal Rijal','Sabina Dahal','Birgunj','Kathmandu',17.96,31.75,'completed','2024-10-27 12:16:55','2024-10-27 13:26:12.960719',4.6,'esewa','9876543210');


DELETE FROM temp_rides WHERE ride_id = 5001;




------ 
SELECT * FROM rides;


WHERE ride_id = 1;



SELECT passenger_name FROM rides WHERE driver_name LIKE '%Ramesh%';

SELECT completed_at FROM rides WHERE ride_status = ''


SELECT ride_distance_km, min(fare_amount ), max(fare_amount) FROM rides
GROUP BY ride_distance_km 
;
