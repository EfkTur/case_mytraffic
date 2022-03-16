-- Creating our table
CREATE TABLE visits (
  shopping_center_id VARCHAR(50) ,
  datetime_UTC TIMESTAMP WITHOUT TIME ZONE,
  device_hash VARCHAR(50)
);

-- Showing our data in sorted by shopping center, datetime_utc, and device hash 
CREATE MATERIALIZED VIEW sorted_dataset AS (
	SELECT 
		* 
	FROM 
		visits
	ORDER BY 
		shopping_center_id, 
		datetime_utc DESC,
		device_hash
);

--Showing the number of pings for each shopping center. Note that the 4th shopping center has much more pings
SELECT
	shopping_center_id, count(*)
FROM 
	sorted_dataset
GROUP BY 
	shopping_center_id;

--Creating the day and hours column
ALTER TABLE visits
ADD COLUMN days INTEGER;

ALTER TABLE visits
ADD COLUMN ping_time TIME WITHOUT TIME ZONE;

UPDATE visits
SET days = EXTRACT(ISODOW FROM datetime_utc);

UPDATE visits
SET ping_time = CAST(datetime_utc AS time);

--Updating the day and hour column
ALTER TABLE visits 
ADD COLUMN weekdays VARCHAR(50);

--Updating the creating and updating weekdays
UPDATE visits
SET weekdays = CASE
	WHEN days = 1 THEN 'Monday'
	WHEN days = 2 THEN 'Tuesday'
	WHEN days = 3 THEN 'Wednesday'
	WHEN days = 4 THEN 'Thursday'
	WHEN days = 5 THEN 'Friday'
	WHEN days = 6 THEN 'Saturday'
	WHEN days = 7 THEN 'Sunday'
	END
;

--Creating the ping hour column
ALTER TABLE visits
ADD COLUMN ping_hour INTEGER;

UPDATE visits
SET ping_hour = EXTRACT(HOUR FROM datetime_utc)

--Putting shopping center names in simpler formats
UPDATE visits
SET shopping_center_id = CASE
	WHEN shopping_center_id = 'b43e9e4f-acd1-4941-874d-e0c5650ab91e' THEN 'SC1'
	WHEN shopping_center_id = '599cb959-11ef-49aa-9eb3-e6c17b4ea6ba' THEN 'SC2'
	WHEN shopping_center_id = '0cd35523-1eca-4f09-ab0d-0b506ae9d986' THEN 'SC3'
	WHEN shopping_center_id = 'cb2d5bb6-c372-4a51-8231-4ffa288a0c28' THEN 'SC4'
	END

--Showing the number of customers for each shopping centers
SELECT 
	shopping_center_id,
	COUNT(DISTINCT device_hash)
FROM
	visits
GROUP BY shopping_center_id
ORDER BY shopping_center_id