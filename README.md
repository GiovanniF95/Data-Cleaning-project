📌 Project Overview

This project focuses on cleaning and preparing a layoffs dataset using SQL in Google BigQuery.
The goal is to transform raw, inconsistent data into a structured and analysis-ready dataset.

The process includes data exploration, deduplication, handling missing values, standardization, and final dataset creation.

⚙️ Tools Used
Google BigQuery
SQL
Data cleaning techniques (CTAS approach)

🚧 Important Context / Limitations
Due to limitations in the BigQuery environment used for this project, row-level UPDATE operations were not utilized.

Instead, the data cleaning process was implemented using a modular ELT approach, relying on:

CREATE OR REPLACE TABLE (CTAS)
step-by-step transformation pipelines
staging tables for intermediate processing

This approach is commonly used in data warehouse environments and ensures full reproducibility of the pipeline.

🧹 Data Cleaning Process
The project follows these main steps:

1. Data Exploration
Initial inspection of dataset structure
Identification of missing values and duplicates
Understanding data types and inconsistencies

2. Staging Table Creation
A working copy of the raw dataset was created to avoid modifying original data.

3. Deduplication
Duplicate rows were identified using ROW_NUMBER()
Duplicates were removed keeping the first occurrence

4. Standardization
Trimmed inconsistent values (e.g., company names)
Standardized categories such as:
Crypto* → Crypto
United States* → United States

5. Date Formatting
Converted string dates into proper DATE format using SAFE.PARSE_DATE
Removed invalid or redundant date columns

6. Handling Missing Values
Identified NULL, empty strings, and 'NULL' values
Filled missing industry values using related records from the same company
Applied COALESCE and NULLIF logic

7. Final Dataset Creation
Removed unreliable records (e.g., rows with missing layoffs data)
Created final clean table ready for analysis

📊 Final Output
The final dataset (tabella_FINAL) is:

cleaned
standardized
deduplicated
analysis-ready

It can be used for:

exploratory data analysis (EDA)
business insights
visualization dashboards

🧠 Key SQL Techniques Used
ROW_NUMBER() OVER (PARTITION BY ...)
COALESCE
NULLIF
CASE WHEN
SAFE.PARSE_DATE
CREATE OR REPLACE TABLE
Self JOINs
Data standardization with LIKE

📈 What I Learned
Handling real-world messy datasets
Building ETL-style pipelines in SQL
Working within BigQuery limitations
Designing reproducible data workflows
Deduplication and missing data strategies

🚀 Future Improvements
Add data validation tests
Automate pipeline with scheduled queries
Build dashboard (Looker Studio / Tableau)
Add data quality checks (row counts, null checks)


