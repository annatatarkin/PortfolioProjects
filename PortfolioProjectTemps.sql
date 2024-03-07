SELECT * 
FROM city_temperature

ALTER TABLE city_temperature
RENAME COLUMN avgtemperature TO avg_temp_f

--Delete all wrong year data
SELECT * FROM city_temperature
WHERE LENGTH(CAST(year AS VARCHAR)) < 4;

--Avg temp for years 1995-2020 for each country
SELECT country, year, ROUND(AVG(avg_temp_f::NUMERIC), 2) AS yearly_avg_temp_country
FROM city_temperature
GROUP BY country, year

--Avg temp for years 1995-2020 for each region
SELECT region, year, ROUND(AVG(avg_temp_f::NUMERIC), 2) AS yearly_avg_temp_region
FROM city_temperature
GROUP BY region, year

--What is the overall trend in global temperature over the years 1995-2020?
--Can you identify any long-term climate trends or changes by analyzing the dataset over the years?
--Creating VIEW to store data for later visualizations
CREATE OR REPLACE VIEW global_yearly_temp_trend
AS
SELECT year, ROUND(AVG(avg_temp_f::NUMERIC), 2) AS avg_global_temp,
ROUND((ROUND(AVG(avg_temp_f::NUMERIC), 2) - LAG(ROUND(AVG(avg_temp_f::NUMERIC), 2)) OVER(ORDER BY year)) * 100 / ROUND(AVG(avg_temp_f::NUMERIC), 2), 2) AS increase_percent
FROM city_temperature
GROUP BY year
ORDER BY year

--How does the average temperature vary daily in each city, country globally from 1995 to 2020?
CREATE OR REPLACE VIEW country_city_daily_temp
AS
SELECT country, city, TO_DATE(CONCAT(month, '/', day, '/', year), 'MM/DD/YYYY') AS full_date, avg_temp_f
FROM city_temperature
WHERE avg_temp_f != -99
ORDER BY full_date, country, city;

--Which countries, cities have the highest and lowest average temperatures on record?
CREATE OR REPLACE VIEW countries_temp_records
AS
SELECT DISTINCT(country), 
MAX(avg_temp_f) OVER(PARTITION BY country) AS max_temp_ever, 
MIN(avg_temp_f) OVER(PARTITION BY country) AS min_temp_ever
FROM city_temperature
WHERE avg_temp_f != -99
ORDER BY max_temp_ever DESC, min_temp_ever ASC

--How does the average temperature vary between different regions over the years 1995-2020?
--USE CTE
WITH yearly_avg_temp_region (region, year, yearly_avg_temp)
AS (
	SELECT region, year, ROUND(AVG(avg_temp_f::NUMERIC), 2) AS yearly_avg_temp
	FROM city_temperature
	GROUP BY region, year
)
SELECT *
FROM yearly_avg_temp_region
WHERE year = 2000;

--USE TEMP TABLE
DROP TABLE IF EXISTS yearly_avg_temp_region;
CREATE TEMP TABLE yearly_avg_temp_region (
	region TEXT, 
	year INT, 
	yearly_avg_temp NUMERIC
);

INSERT INTO yearly_avg_temp_region(region, year, yearly_avg_temp)
SELECT region, year, ROUND(AVG(avg_temp_f::NUMERIC), 2) AS yearly_avg_temp
FROM city_temperature
GROUP BY region, year;


-- TEST
SELECT * 
FROM yearly_avg_temp_region
WHERE year = 1995;

SELECT *
FROM countries_temp_records

SELECT *
FROM global_yearly_temp_trend

SELECT *
FROM country_city_daily_temp