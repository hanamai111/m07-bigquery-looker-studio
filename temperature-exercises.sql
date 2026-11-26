-- Run each SELECT independently in BigQuery Studio using GoogleSQL in the US.
-- 1. Inspect coverage and reproduce the one-table AVG with a missing-value guard.
SELECT COUNT(*) AS observations,
       COUNTIF(temp < 9999.9) AS valid_observations,
       ROUND(AVG(IF(temp < 9999.9, temp, NULL)), 2) AS mean_temp_f
FROM `bigquery-public-data.noaa_gsod.gsod1929`;

-- 2. One row per year. Bound the wildcard scan to the study years.
SELECT _TABLE_SUFFIX AS year, COUNT(*) AS valid_observations,
       ROUND(AVG(temp), 2) AS mean_temp_f
FROM `bigquery-public-data.noaa_gsod.gsod*`
WHERE _TABLE_SUFFIX BETWEEN '1929' AND '2022' AND temp < 9999.9
GROUP BY year
ORDER BY year;

-- 3. Join station metadata on both identifiers. Exclude ambiguous country mappings.
WITH station_country AS (
  SELECT usaf, wban, ANY_VALUE(st.country) AS country
  FROM `bigquery-public-data.noaa_gsod.stations` AS st
  WHERE country IS NOT NULL
  GROUP BY usaf, wban
  HAVING COUNT(DISTINCT st.country) = 1
)
SELECT CONCAT(SUBSTR(_TABLE_SUFFIX, 1, 3), '0s') AS decade,
       country, COUNT(*) AS observations, ROUND(AVG(temp), 2) AS mean_temp_f
FROM `bigquery-public-data.noaa_gsod.gsod*` AS w
JOIN station_country AS s ON w.stn = s.usaf AND w.wban = s.wban
WHERE _TABLE_SUFFIX BETWEEN '1929' AND '1999'
  AND country IN ('UK', 'US', 'IN') AND temp < 9999.9
GROUP BY decade, country
ORDER BY decade, country;

-- 4. Build a 50-year baseline with equal weight for each annual mean.
-- Translate the GSOD UK code to ISO GB for the three-country map adaptation.
WITH station_country AS (
  SELECT usaf, wban, ANY_VALUE(st.country) AS country
  FROM `bigquery-public-data.noaa_gsod.stations` AS st
  WHERE country IS NOT NULL
  GROUP BY usaf, wban
  HAVING COUNT(DISTINCT st.country) = 1
),
annual AS (
  SELECT SAFE_CAST(_TABLE_SUFFIX AS INT64) AS year,
         CASE country WHEN 'UK' THEN 'GB' ELSE country END AS iso2,
         AVG(temp) AS annual_f
  FROM `bigquery-public-data.noaa_gsod.gsod*` AS w
  JOIN station_country AS s ON w.stn = s.usaf AND w.wban = s.wban
  WHERE _TABLE_SUFFIX BETWEEN '1973' AND '2022'
    AND country IN ('UK', 'US', 'IN') AND temp < 9999.9
  GROUP BY year, iso2
),
baseline AS (
  SELECT iso2, AVG(annual_f) AS baseline_f, COUNT(*) AS baseline_years
  FROM annual
  GROUP BY iso2
)
SELECT a.iso2, COUNT(*) AS comparison_years, b.baseline_years,
       ROUND(AVG(a.annual_f), 2) AS comparison_f,
       ROUND(b.baseline_f, 2) AS baseline_f,
       ROUND(AVG(a.annual_f) - b.baseline_f, 2) AS delta_f
FROM annual AS a
JOIN baseline AS b USING (iso2)
WHERE a.year BETWEEN 2001 AND 2010
GROUP BY a.iso2, b.baseline_years, b.baseline_f
ORDER BY iso2;
