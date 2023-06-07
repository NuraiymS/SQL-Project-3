--Create a View called “forestation” by joining all three tables - forest_area, land_area and regions in the workspace.

CREATE VIEW forestation AS
SELECT
f.country_code, f.country_name, f.year, f.forest_area_sqkm,
l.country_code, l.country_name, l.year, l.total_area_sq_mi, r.country_code, r.country_name, r.region
AS f_country_code,
AS f_country_name,
AS f_year,
AS f_forest_area_sqkm, AS l_country_code,
AS l_country_name,
AS l_year,
AS l_total_area_sq_mi, AS r_country_code,
AS r_country_name,
AS r_region, r.income_group AS r_income_group 
FROM forest_area f
JOIN land_area l
ON f.country_code = l.country_code
AND f.year = l.year JOIN regions r
ON l.country_code = r.country_code;


--What was the total forest area (in sq km) of the world in 1990?

SELECT f_country_name, f_year, f_forest_area_sqkm AS total 
FROM forestation
WHERE f_year = '1990'
AND f_country_name = 'World'
LIMIT 1;


--What was the total forest area (in sq km) of the world in 2016? 

SELECT ((SELECT Sum(f_forest_area_sqkm) total_forest_area
FROM forestation
WHERE f_year = 1990 AND f_country_name = 'World') - (SELECT Sum(f_forest_area_sqkm) total_forest_area
FROM forestation
WHERE f_year = 2016 AND f_country_name = 'World')) Difference;


--What was the change (in sq km) in the forest area of the world from 1990 to 2016?

SELECT ((((SELECT Sum(f_forest_area_sqkm) total_forest_area
FROM forestation
WHERE f_year = 1990 AND f_country_name = 'World') - (SELECT Sum(f_forest_area_sqkm) total_forest_area
      FROM forestation
      WHERE f_year = 2016 AND f_country_name ='World')) *100 )/ (SELECT Sum(f_forest_area_sqkm) total_forest_area
            FROM forestation
            WHERE f_year = 1990 AND f_country_name = 'World')) Difference;


--What was the percent change in forest area of the world between 1990 and 2016?

CREATE VIEW forestation AS
SELECT f.country_code AS country_code, 
       f.country_name AS country_name, 
       f.year AS YEAR,
       f.forest_area_sqkm AS forest_area_sqkm, 
       l.total_area_sq_mi AS total_area_sq_mi, 
       r.region AS region,
       r.income_group AS income_group,
       ((f.forest_area_sqkm / (l.total_area_sq_mi * 2.59)) *100) AS perc_land_area_sqkm,
       (l.total_area_sq_mi * 2.59) AS land_area_sqkm 
FROM forest_area f
JOIN land_area l
ON f.country_code = l.country_code AND f.year = l.year
JOIN regions r
ON l.country_code = r.country_code;


--If you compare the amount of forest area lost between 1990 and 2016, 
--to which country's total area in 2016 is it closest to?

SELECT country_name, year, land_area_sqkm,
    ((SELECT Sum(forest_area_sqkm) total_forest_area
FROM forestation WHERE year = 1990 AND country_name = 'World') -
     (SELECT Sum(forest_area_sqkm) total_forest_area 
      FROM forestation
      WHERE year = 2016 AND country_name = 'World')) AS total 
FROM forestation
WHERE year = '2016' AND land_area_sqkm < 1324449 
ORDER BY land_area_sqkm DESC
LIMIT 1;


--Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) 
--in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km)

SELECT Sum (forest_area_sqkm) * 100 / Sum (land_area_sqkm) forest_perc 
FROM forestation
WHERE year = '2016' AND country_name = 'World';

--Then

SELECT region, Sum (forest_area_sqkm) * 100 / Sum (land_area_sqkm) forest_perc
FROM forestation
WHERE year = '2016'
GROUP BY region
ORDER BY forest_perc DESC 
LIMIT 2;

--Then

SELECT region, Sum (forest_area_sqkm) * 100 / Sum (land_area_sqkm) forest_perc
FROM forestation
WHERE year = '2016' 
GROUP BY region 
ORDER BY forest_perc 
LIMIT 2;


--What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, 
--and which had the LOWEST, to 2 decimal places?

SELECT Sum (forest_area_sqkm) * 100 / Sum (land_area_sqkm) forest_perc 
FROM forestation
WHERE year = '1990' AND country_name = 'World';

--Then

SELECT region, Sum (forest_area_sqkm) * 100 / Sum (land_area_sqkm)) forest_perc
FROM forestation
WHERE year = '1990'
GROUP BY region
ORDER BY forest_perc DESC 
LIMIT 2;

--Then

SELECT region, Sum (forest_area_sqkm) * 100 / Sum (land_area_sqkm) forest_perc
FROM forestation
WHERE year = '1990'
GROUP BY region 
ORDER BY forest_perc 
LIMIT 2;


-- What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, 
--and which had the LOWEST, to 2 decimal places?

WITH t1 AS
(SELECT ROUND((sum(forest_area_sqkm)*100/sum(land_area_sqkm))::NUMERIC, 2) AS tf1_1990, region
FROM forestation 
WHERE year = 1990
GROUP BY region, year 
ORDER BY tf1_1990 DESC),
t2 AS 
(SELECT ROUND((sum(forest_area_sqkm)*100/sum(land_area_sqkm))::NUMERIC,2) AS tfa2_2016, region
FROM forestation
WHERE year = 2016 AND forest_area_sqkm IS NOT NULL 
GROUP BY region, year)

SELECT t1.region, t1.tf1_1990, t2.tfa2_2016, (t1.tf1_1990 - t2.tfa2_2016) AS forest_per_change
FROM t1
JOIN t2
ON t1.region = t2.region
GROUP BY 1,t1.tf1_1990, t2.tfa2_2016 
ORDER BY forest_per_change DESC;


--Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?

WITH t1 AS (
SELECT country_name c1, region r1990, forest_area_sqkm as fld_1
FROM forestation
WHERE year = '1990' AND country_name NOT LIKE 'World' AND region IS NOT NULL 
    AND forest_area_sqkm IS NOT NULL),
t2 AS 
(SELECT country_name c2, region r2016, forest_area_sqkm as fld_2 
FROM forestation
WHERE year = '2016' AND country_name NOT LIKE 'World' AND region IS NOT NULL AND forest_area_sqkm IS NOT NULL)

SELECT t2.c2, t2.r2016, (t2.fld_2 - t1.fld_1) change 
FROM t2
JOIN t1 ON t1.c1 = t2.c2
ORDER BY change desc 
LIMIT 5;

WITH t1 AS (
SELECT country_name c1, region r1990, forest_area_sqkm as fld_1
FROM forestation
WHERE year = '1990' AND country_name NOT LIKE 'World' AND region IS NOT
NULL AND forest_area_sqkm IS NOT NULL),
t2 AS (select country_name c2, region r2016, forest_area_sqkm as fld_2 FROM forestation
WHERE year = '2016' AND country_name NOT LIKE 'World' AND region IS NOT
NULL AND forest_area_sqkm IS NOT NULL)
SELECT t2.c2, t2.r2016, ROUND(((t2.fld_2 - t1.fld_1)*100/( t1.fld_1)) :: numeric,2) change
FROM t2
JOIN t1
ON t1.c1 = t2.c2 ORDER BY change desc LIMIT 5


--Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? 
--What was the difference in forest area for each?

WITH t1 AS (
SELECT country_name c1, region r1990, forest_area_sqkm as fld_1
FROM forestation
WHERE year = '1990' AND country_name NOT LIKE 'World' AND region IS NOT NULL AND forest_area_sqkm IS NOT NULL),

t2 AS (
SELECT country_name c2, region r2016, forest_area_sqkm as fld_2 
FROM forestation
WHERE year = '2016' AND country_name NOT LIKE 'World' AND region IS NOT NULL AND forest_area_sqkm IS NOT NULL)

SELECT t2.c2, t2.r2016, (t1.fld_1 - t2.fld_2) change 
FROM t2
JOIN t1 ON t1.c1 = t2.c2
ORDER BY change DESC 
LIMIT 5;


--Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? 
--What was the percent change to 2 decimal places for each?

WITH t1 AS (
SELECT country_name c1, region r1990, forest_area_sqkm as fld_1
FROM forestation
WHERE year = '1990' AND country_name NOT LIKE 'World' AND region IS NOT NULL AND forest_area_sqkm IS NOT NULL),

t2 AS (
SELECT country_name c2, region r2016, forest_area_sqkm as fld_2 
FROM forestation
WHERE year = '2016' AND country_name NOT LIKE 'World' AND region IS NOT NULL AND forest_area_sqkm IS NOT NULL)

SELECT t2.c2, t2.r2016, ROUND(((t1.fld_1 - t2.fld_2)*100/( t1.fld_1)) :: numeric,2) change
FROM t2
JOIN t1 ON t1.c1 = t2.c2
ORDER BY change DESC 
LIMIT 5;


--If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

WITH Quarts AS(
SELECT perc_land_area_sqkm, country_name,
CASE
WHEN perc_land_area_sqkm <25 THEN '25'
WHEN perc_land_area_sqkm >25 AND perc_land_area_sqkm <50 THEN '25-50' 
WHEN perc_land_area_sqkm >50 AND perc_land_area_sqkm <75 THEN '50-75' 
WHEN perc_land_area_sqkm > 75 THEN '75-100'
ELSE NULL END AS quartile 
FROM forestation
WHERE country_name NOT LIKE 'World' AND perc_land_area_sqkm IS NOT NULL AND year = '2016')

SELECT quartile, COUNT(*) AS num_countries 
FROM Quarts
GROUP BY quartile
ORDER BY quartile;


--List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016

WITH q AS(
SELECT country_name country, region, perc_land_area_sqkm, 
CASE WHEN perc_land_area_sqkm > 75 THEN '75-100' END AS quartile
FROM forestation
WHERE country_name NOT LIKE 'World' AND perc_land_area_sqkm IS NOT NULL AND year = '2016')

SELECT q.country, q.region, q.perc_land_area_sqkm, q.quartile 
FROM q
GROUP BY q.country, q.region, q.perc_land_area_sqkm, q.quartile 
ORDER BY q.perc_land_area_sqkm DESC
LIMIT 9;


--How many countries had a percent forestation higher than the United States in 2016?

SELECT COUNT (*) perc_land_area_sqkm
FROM forestation
WHERE perc_land_area_sqkm > (SELECT perc_land_area_sqkm
                             FROM forestation
                             WHERE country_code = 'USA' AND year = '2016')
AND year = '2016';














