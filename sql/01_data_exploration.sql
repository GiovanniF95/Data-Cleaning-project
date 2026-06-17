-- DATA CLEANING PROJECT - LAYOFFS DATASET
--
-- This project focuses on cleaning and standardizing a layoffs dataset using SQL in BigQuery.
--
-- IMPORTANT CONTEXT / LIMITATIONS:
-- Due to the limitations of the BigQuery environment used in this project,
-- row-level UPDATE operations were not utilized.
-- Instead, the cleaning process was implemented using a modular ETL approach,
-- relying on CREATE OR REPLACE TABLE (CTAS) statements at each transformation step.
--
-- This approach ensures full reproducibility of the pipeline and follows a
-- data warehouse / ELT-style workflow commonly used in analytics environments.
--
-- The dataset was progressively transformed through staging tables until reaching
-- a final clean version ready for analysis.

-- 1) Creation of a Table where I can work in order to not modify the RAW DATA

CREATE TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging AS SELECT* FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_table

-- 2) Removing all the duplicates in the dataset - If ROW_NUM > 1 means we have duplicates

SELECT*, 
ROW_NUMBER() OVER( PARTITION BY company, Location, Industry, Total_Laid_Off, Percentage_laid_off, 'date', stage, country, funds_raised_million) AS ROW_NUM FROM long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging

-- Identifying the duplicates lines (ROW_NUM>1)

WITH Duplicate_CTE AS (SELECT *, ROW_NUMBER() OVER( PARTITION BY company, Location, Industry, Total_Laid_Off, Percentage_laid_off, date, stage, country, funds_raised_million) AS ROW_NUM FROM long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging)

SELECT *, 
FROM Duplicate_CTE WHERE ROW_NUM>1;

-- Double checking if it is right

SELECT* FROM long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging WHERE Company ="Elemy" OR Company ="Cazoo" OR Company ="Hibob" OR Company ="Wildlife Studios" OR Company ="Yahoo"

-- Creating additional table from which we are going to delete the duplications

CREATE TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 ( company STRING, location STRING, industry STRING, total_laid_off INT64, percentage_laid_off STRING, date STRING, stage STRING, country STRING, funds_raised_million INT64, row_num INT64 );

-- Table with same data of the original one adding the ROW_NUM Column

CREATE OR REPLACE TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 AS WITH Duplicate_CTE AS ( SELECT *, ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_million ) AS row_num FROM long-way-462416-v0.DATA_CLEANING_PROJECT.Layoff_Staging ) 
SELECT * FROM Duplicate_CTE;

-- Deleting duplication taking out lines with ROW_NUM>1

CREATE OR REPLACE TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 AS 
SELECT * FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 WHERE row_num = 1;

-- Double checking if it is right

SELECT* FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 WHERE ROW_NUM>1

-- 3) Standardazing Data

-- Making TRIM in the first column

CREATE OR REPLACE TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 AS 
SELECT*

EXCEPT(company), TRIM(company) AS company FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2;

-- Renaming Industries "Crypto%" naming in the same way

CREATE OR REPLACE TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 AS SELECT*

EXCEPT(industry), CASE WHEN industry LIKE 'Crypto%' THEN 'Crypto' ELSE industry END AS industry FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2;

SELECT * FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 WHERE industry LIKE "%Crypto%"

SELECT DISTINCT industry FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 ORDER BY industry

SELECT DISTINCT country FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 ORDER BY 1

-- Renaming country "United States%" naming in the same way

CREATE OR REPLACE TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 AS SELECT*

EXCEPT(country), CASE WHEN country LIKE 'United States%' THEN 'United States' ELSE country 

END AS country FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2;

SELECT DISTINCT country FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 ORDER BY 1

SELECT DISTINCT company FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2 ORDER BY 1

-- Changin column "date" in a date type (now is a STRING)

SELECT date, SAFE.PARSE_DATE('%m/%d/%Y', date) AS date_New

from long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2

-- Create new table in which I have the correct format of the date

CREATE OR REPLACE TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean AS
SELECT*,
  SAFE.PARSE_DATE('%m/%d/%Y', TRIM(date)) AS date_new -- I transform from STRING to format DATE in a new column named "date_NEW"
FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2;

ALTER TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean DROP COLUMN date; -- deleting the column date that is made of strings

-- Remove NULL and blank values (checking if there are in the table)

SELECT*

FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean

WHERE Total_Laid_Off = "NULL" AND Percentage_laid_off = "NULL"; -- identifying 'NULL' in columns 'Total_Laid_Off' and 'Percentage_laid_off'

SELECT *,

FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean

WHERE industry= "NULL" OR industry IS NULL; -- identifying 'NULL' and NULL in column 'industry'

-- Populating NULL values in column 'industry' based on similar lines

SELECT T1.industry, T2.industry
FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean AS T1
JOIN long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean AS T2
    ON T1.company= T2.company
    WHERE (T1.industry= 'NULL' OR T1.industry IS NULL)
    AND T2.industry IS NOT NULL AND T2.industry !='NULL' -- showing if there are similar lines where we can take info over the industry


CREATE OR REPLACE TABLE `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean_NEW` AS
SELECT
    T1.* REPLACE(
        COALESCE(NULLIF(T1.industry, 'NULL'), T2.industry) AS industry
    )
FROM `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean` T1
LEFT JOIN `long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean` T2
    ON T1.company = T2.company
    AND T2.industry IS NOT NULL
    AND T2.industry != 'NULL'; -- creating new table where we replace cells NULL or blanl with values of "industry" taken from other lines with same "company"

SELECT *
FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean_NEW
WHERE company= "Bally's Interactive" -- still will remain one line with industry = "NULL" because we have not other similar lines

-- Eliminating column "row_num" not more required and ALL the lines with Total_Laid_Off = "NULL" AND Percentage_laid_off = "NULL" that most probably are not reliable data

ALTER TABLE long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean_NEW DROP COLUMN row_num; -- deleting the column row_num

CREATE OR REPLACE TABLE `long-way-462416-v0.DATA_CLEANING_PROJECT.tabella_FINAL` AS
SELECT *
FROM long-way-462416-v0.DATA_CLEANING_PROJECT.layoff_Staging2_clean_NEW
WHERE NOT (Total_Laid_Off = 'NULL' AND Percentage_laid_off = "NULL"); -- creating Final table WITHOUT lines with Total_Laid_Off = "NULL" AND Percentage_laid_off = "NULL"

SELECT*
FROM long-way-462416-v0.DATA_CLEANING_PROJECT.tabella_FINAL
WHERE Total_Laid_Off = 'NULL' AND Percentage_laid_off = "NULL" -- check if it worked
