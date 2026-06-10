# Data-Cleaning-project
This project focuses on data cleaning using SQL. It transforms raw data into a clean and consistent dataset by handling missing values, removing duplicates, standardizing formats, and correcting inconsistencies. The goal is to prepare reliable data for analysis and reporting.

-- 1) Creation of a Table where I can work in order to not modify the RAW DATA

CREATE TABLE `long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging` AS
SELECT* FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_table`

-- 2) Removing all the duplicates in the dataset - If ROW_NUM > 1 means we have duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, Location, Industry, Total_Laid_Off, Percentage_laid_off, 'date', stage, country, funds_raised_million) AS ROW_NUM
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging`

-- Identifying the duplicates lines (ROW_NUM>1)

WITH Duplicate_CTE AS (SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, Location, Industry, Total_Laid_Off, Percentage_laid_off, date, stage, country, funds_raised_million) AS ROW_NUM
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging`)

SELECT *,
FROM Duplicate_CTE
WHERE ROW_NUM>1;

-- Double checking if it is right

SELECT*
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging`
WHERE Company ="Elemy" OR Company ="Cazoo" OR Company ="Hibob" OR Company ="Wildlife Studios" OR Company ="Yahoo"

-- Creating additional table from which we are going to delete the duplications 

CREATE TABLE `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`
(
    company STRING,
    location STRING,
    industry STRING,
    total_laid_off INT64,
    percentage_laid_off STRING,
    date STRING,
    stage STRING,
    country STRING,
    funds_raised_million INT64,
    row_num INT64
);

-- Table with same data of the original one adding the ROW_NUM Column

CREATE OR REPLACE TABLE `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2` AS
WITH Duplicate_CTE AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company, location, industry,
                            total_laid_off, percentage_laid_off,
                            date, stage, country, funds_raised_million
           ) AS row_num
    FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging`
)
SELECT *
FROM Duplicate_CTE;

-- Deleting duplication taking out lines with ROW_NUM>1

CREATE OR REPLACE TABLE `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2` AS
SELECT *
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`
WHERE row_num = 1;

-- Double checking if it is right

SELECT*
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`
WHERE ROW_NUM>1

-- 3) Standardazing Data

-- Making TRIM in the first column

CREATE OR REPLACE TABLE `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2` AS
SELECT
  * EXCEPT(company),
  TRIM(company) AS company
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`;

-- Renaming Industries "Crypto%" naming in the same way

CREATE OR REPLACE TABLE `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2` AS
SELECT
  * EXCEPT(industry),
  CASE
    WHEN industry LIKE 'Crypto%' THEN 'Crypto'
    ELSE industry
  END AS industry
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`;

SELECT *
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`
WHERE industry LIKE "%Crypto%"

SELECT DISTINCT industry
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`
ORDER BY industry

SELECT DISTINCT country
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`
ORDER BY 1

-- Renaming country "United States%" naming in the same way

CREATE OR REPLACE TABLE `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2` AS
SELECT
  * EXCEPT(country),
  CASE
    WHEN country LIKE 'United States%' THEN 'United States'
    ELSE country
  END AS country
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`;

SELECT DISTINCT country
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2`
ORDER BY 1
