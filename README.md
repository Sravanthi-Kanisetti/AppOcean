🏗️ App Store Analytics — Kimball Data Warehouse

Built with SQL Server | Kimball Dimensional Modelling | Star Schema


📌 Project Overview

A complete end-to-end Kimball Data Warehouse built on Microsoft SQL Server for App Store Analytics. This project covers the full data engineering lifecycle — from raw CSV ingestion to business-ready analytical queries across 6 data marts.

Goal: Transform raw app store data into a clean, performant, queryable star schema that answers real business questions for marketing, finance, product, regional, device and executive teams.


🏛️ Architecture

                          CSV SOURCE FILES
                 (dim_app, dim_date, dim_device,
                  dim_user, dim_store_region,
                  fact_app_events)
                              |
                              |  BULK INSERT
                              v
                  +-------------------------+
                  |     STAGING LAYER       |
                  |   (Staging schema)      |
                  |                         |
                  | Stored Procedure:       |
                  | Staging.load_data       |
                  |                         |
                  | All columns NVARCHAR -- |
                  | accepts any raw format  |
                  +-----------+-------------+
                              |
                              |  Data Profiling
                              |  Data Cleaning
                              v
                  +-------------------------+
                  |       DW LAYER          |
                  |     (DW schema)         |
                  |                         |
                  | Stored Procedure:       |
                  | DW.load_data            |
                  |                         |
                  | Star Schema with        |
                  | PK / FK constraints     |
                  |                         |
                  |  dim_date               |
                  |  dim_app                |
                  |  dim_user     --------> fact_app_events
                  |  dim_device             |
                  |  dim_store_region       |
                  +-----------+-------------+
                              |
                              |  CREATE VIEW
                              v
        +-----------------------------------------------+
        |              DATA MARTS (Views)                |
        |                                                 |
        |  Marketing_Mart   Finance_Mart   Product_Mart   |
        |  Regional_Mart    Device_Mart    Executive_Mart |
        +-----------------------+-------------------------+
                              |
                              v
                  +-------------------------+
                  |   30+ ANALYTICAL        |
                  |       QUERIES           |
                  |                         |
                  |  ARPU, churn, MoM/QoQ/  |
                  |  YoY growth, discount   |
                  |  ROI, segment ranking   |
                  +-------------------------+


⭐ Star Schema

                              DW.dim_date
                              (date_key PK)
                                   |
                                   |
    DW.dim_user ------------------+------------------ DW.dim_app
    (user_key PK)                 |                   (app_key PK)
                                   |
                        DW.fact_app_events
                        (fact_key PK)
                        -------------------
                        date_key     (FK)
                        app_key      (FK)
                        user_key     (FK)
                        device_key   (FK)
                        region_key   (FK)
                        revenue_usd
                        session_minutes
                        rating
                        discount_pct
                        event_type
                        install_source
                        app_version
                                   |
                                   |
DW.dim_device --------------------+------------------ DW.dim_store_region
(device_key PK)                                       (region_key PK)


📁 Project Structure

App-Store-Analytics-DWH/
│
├── README.md
│
├── 01_Database_Schema_Creation/
│   └── DB_and_Schema_creation.sql
│       (Creates: Kimball DB, Staging schema, DW schema)
│
├── 02_Staging/
│   ├── 01_ddl_staging.sql
│   │   (6 staging tables with NVARCHAR types for safe loading)
│   └── 02_procLoad_Staging.sql
│       (Stored Procedure: TRUNCATE -> BULK INSERT, timing + TRY-CATCH)
│
├── 03_Data_Profiling/
│   └── Data_Profiling.sql
│       (DISTINCT + COLLATE, COUNT NULL checks, MAX/MIN/AVG)
│
├── 04_Data_Cleaning/
│   └── Cleaning_Logic.sql
│       (SELECT-first cleaning logic verified before SP2)
│
├── 05_DW_Layer/
│   ├── 01_ddl_dw.sql
│   │   (Star schema with PRIMARY KEY + FOREIGN KEY constraints)
│   └── 02_procLoad_dw.sql
│       (SP: NOCHECK FK -> DELETE fact -> TRUNCATE dims -> INSERT)
│
├── 06_Data_Validation/
│   └── Data_Validation.sql
│       (Staging vs DW comparison using UNION ALL)
│
├── 07_Indexes/
│   └── Indexes.sql
│       (Non-clustered indexes on all FK columns + event_type)
│
├── 08_Data_Marts/
│   └── DataMarts.sql
│       (6 Views: Marketing, Finance, Product,
│        Regional, Device, Executive)
│
└── 09_Analytical_Queries/
    └── Analytical_Queries.sql
        (30+ business queries across 6 data marts)


📊 Dataset

TableRowsDescriptionfact_app_events120,500Core events: Download, Purchase, Review, Update, Uninstalldim_user10,000User demographics and premium statusdim_app30App metadata, categories, platformsdim_date1,461Calendar table (4 years)dim_device10Device types, OS versions, manufacturersdim_store_region5Regional store info, currencies, tax rates


🔧 Tech Stack

ToolPurposeSQL ServerDatabase engineSSMSDevelopment environmentT-SQLAll data engineering codeGitHubVersion control


🚀 How to Run This Project

Prerequisites


Microsoft SQL Server installed
SSMS (SQL Server Management Studio)
CSV files placed in a local folder (e.g. C:\AppAnalytics\data)


Step 1 — Create Database & Schemas

sql-- Run: 01_Database_Schema_Creation/DB_and_Schema_creation.sql
-- Creates: Kimball database, Staging schema, DW schema

Step 2 — Create Staging Tables

sql-- Run: 02_Staging/01_ddl_staging.sql
-- Creates: 6 staging tables with NVARCHAR types for safe CSV loading

Step 3 — Create & Execute SP1 (Raw Data Load)

sql-- Run: 02_Staging/02_procLoad_Staging.sql
-- Creates stored procedure Staging.load_data

-- Before executing: update CSV file paths inside the SP to your local folder
EXEC Staging.load_data;
-- Loads all 6 CSV files into staging via BULK INSERT
-- Prints row counts and timing for each table

Step 4 — Data Profiling (Optional — Reference Only)

sql-- Run: 03_Data_Profiling/Data_Profiling.sql
-- Explores every column: NULLs, casing issues, value distributions
-- No data is modified here — read-only analysis

Step 5 — Review Data Cleaning Logic (Optional — Reference Only)

sql-- Run: 04_Data_Cleaning/Cleaning_Logic.sql
-- SELECT-only queries showing the cleaning logic that was verified
-- before being embedded inside DW.load_data (Step 7)

Step 6 — Create DW Tables (Star Schema)

sql-- Run: 05_DW_Layer/01_ddl_dw.sql
-- Creates: 5 dimension tables + 1 fact table
-- Applies: PRIMARY KEY on dims, FOREIGN KEY on fact

Step 7 — Create & Execute SP2 (Cleaned Data Load)

sql-- Run: 05_DW_Layer/02_procLoad_dw.sql
-- Creates stored procedure DW.load_data

EXEC DW.load_data;
-- Cleans and loads all staging data into the DW star schema
-- Applies: gender standardization, NULL handling,
--          discount fixes, date conversions, casing fixes
-- Order: NOCHECK FK -> DELETE fact -> DELETE+INSERT dims -> INSERT fact -> CHECK FK
-- Prints row counts and timing for each table

Step 8 — Validate Data Quality

sql-- Run: 06_Data_Validation/Data_Validation.sql
-- Compares Staging vs DW side by side using UNION ALL
-- Verifies: row counts match, cleaning applied correctly

Step 9 — Create Indexes

sql-- Run: 07_Indexes/Indexes.sql
-- Creates 5 non-clustered indexes on fact table FK columns + event_type
-- Improves JOIN performance on all mart queries

Step 10 — Create Data Marts

sql-- Run: 08_Data_Marts/DataMarts.sql
-- Creates 6 views: Marketing_Mart, Finance_Mart, Product_Mart,
--                  Regional_Mart, Device_Mart, Executive_Mart

Step 11 — Run Analytical Queries

sql-- Run: 09_Analytical_Queries/Analytical_Queries.sql
-- 30+ business queries across 6 marts
-- Uses: LAG, RANK, DENSE_RANK, ROW_NUMBER,
--       multi-level CTEs, Window SUM, NULLIF, PARTITION BY

⚡ Quick Run Order Summary

DB_and_Schema_creation.sql
        |
01_ddl_staging.sql
        |
02_procLoad_Staging.sql -> EXEC Staging.load_data
        |
Data_Profiling.sql           (reference only)
        |
Cleaning_Logic.sql           (reference only)
        |
01_ddl_dw.sql
        |
02_procLoad_dw.sql -> EXEC DW.load_data
        |
Data_Validation.sql
        |
Indexes.sql
        |
DataMarts.sql
        |
Analytical_Queries.sql


🧹 Data Cleaning Summary

ColumnIssue FoundFix Appliedgendermale, MALE, M mixedStandardized to Male/Female/Other/Unknownis_premium0, 1, yes, no mixedConverted to BIT (0/1)platformandroid, ANDROID mixedStandardized to Android/iOS/Bothdevice_typesmartphone, TABLET mixedStandardized to Smartphone/Tablet/PC/Smartwatchage_group25_34, 25 to 34 mixedStandardized to 25-34 formatcityNULL, empty, N/AReplaced with 'Unknown'email_domainNULL valuesReplaced with 'Unknown'content_ratingNULL valuesReplaced with 'Not Rated'release_yearFLOAT with NULLsCast to INT, NULLs preserveddiscount_pctNegative valuesReplaced with 0is_weekend'True\r'/'False\r' hidden carriage returnConverted to BIT (1/0) via REPLACE(col, CHAR(13), '')install_sourceNULL valuesReplaced with 'Unknown'app_versionNULL / mixed v-prefixTRIM + replaced NULLs with 'Unknown'registration_dateDD-MM-YYYY stringCONVERT(DATE, col, 105)


🏪 Data Marts

MartTarget TeamKey ColumnsMarketing_MartMarketinggender, age_group, install_source, user_key, session_minutesFinance_MartFinancerevenue_usd, discount_pct, region_name, tax_rate_pct, price_usdProduct_MartProductrating, session_minutes, device_type, app_name, app_versionRegional_MartRegional Managersregion_name, store_currency, tax_rate_pct, revenue_usdDevice_MartTech/Engineeringdevice_type, os_version, manufacturer, screen_size_inchExecutive_MartManagementAll KPIs — revenue, rating, session, events, churn


📈 Sample Analytical Queries

Which install source brings the highest quality users?

sqlSELECT install_source,
       COUNT(DISTINCT user_key) AS users_count,
       ROUND(AVG(revenue_usd), 2) AS avg_revenue,
       ROUND(AVG(session_minutes), 2) AS avg_session,
       ROUND(SUM(revenue_usd) / NULLIF(COUNT(DISTINCT user_key), 0), 2) AS ARPU
FROM DW.Marketing_Mart
GROUP BY install_source
ORDER BY avg_revenue DESC;

Year-over-year revenue growth?

sqlWITH yearly AS (
    SELECT year, SUM(revenue_usd) AS revenue
    FROM DW.Executive_Mart
    GROUP BY year
)
SELECT year, revenue,
       LAG(revenue) OVER (ORDER BY year) AS prev_revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY year)) * 100.0
             / NULLIF(LAG(revenue) OVER (ORDER BY year), 0), 2) AS yoy_growth_pct
FROM yearly
ORDER BY year;

Which manufacturer has the lowest uninstall rate?

sqlSELECT manufacturer,
       SUM(CASE WHEN event_type = 'Uninstall' THEN 1 ELSE 0 END) AS uninstalls,
       SUM(CASE WHEN event_type = 'Download' THEN 1 ELSE 0 END) AS downloads,
       ROUND(SUM(CASE WHEN event_type = 'Uninstall' THEN 1 ELSE 0 END) * 100.0
             / NULLIF(SUM(CASE WHEN event_type = 'Download' THEN 1 ELSE 0 END), 0), 2) AS uninstall_rate_pct
FROM DW.Device_Mart
GROUP BY manufacturer
ORDER BY uninstall_rate_pct ASC;


⚡ Performance Optimizations

sql-- Non-clustered indexes on all FK columns + event_type
CREATE NONCLUSTERED INDEX IX_fact_date_key   ON DW.fact_app_events(date_key);
CREATE NONCLUSTERED INDEX IX_fact_app_key    ON DW.fact_app_events(app_key);
CREATE NONCLUSTERED INDEX IX_fact_user_key   ON DW.fact_app_events(user_key);
CREATE NONCLUSTERED INDEX IX_fact_device_key ON DW.fact_app_events(device_key);
CREATE NONCLUSTERED INDEX IX_fact_region_key ON DW.fact_app_events(region_key);
CREATE NONCLUSTERED INDEX IX_fact_event_type ON DW.fact_app_events(event_type);


💡 Key Design Decisions

DecisionReasonNVARCHAR in stagingAccept any format safely — staging's job is safe loading, not validationManual cleaning (no SP)Complex business logic needs human verification — SELECT, verify, then INSERTDELETE before TRUNCATEFK constraints block TRUNCATE — DELETE fact first to free dimension tablesNOCHECK CONSTRAINTTemporarily disables FK enforcement so dims can be truncated and reloaded safelyNULL → Unknown in dimsBusiness queries GROUP BY dimensions — NULL causes confusing, fragmented resultsNULL kept in fact measuresrevenue NULL = event didn't generate revenue — meaningful, not missingViews for Data MartsNo data duplication, always fresh, true Kimball approach (vs Medallion architecture)user_key exposed in Marketing_MartNeeded for accurate ARPU — COUNT(DISTINCT user_key), not a proxy


🎓 What I Learned


Kimball Architecture — star schema design principles, fact vs dimension modeling
ETL Pipeline — Staging → Profiling → Cleaning → DW loading with stored procedures
Data Profiling — systematic column analysis using COLLATE, COUNT, MAX/MIN
Data Quality — handling NULLs, casing issues, negative values, hidden carriage-return characters
SQL Server Internals — FK constraints, TRUNCATE vs DELETE, NOCHECK, COLLATE
Window Functions — LAG for MoM/QoQ/YoY trend analysis, RANK/DENSE_RANK/ROW_NUMBER for leaderboards, SUM() OVER (PARTITION BY) for share-of-total metrics
CTEs — multi-level chained logic for trend and ranking queries
Indexing Strategy — non-clustered indexes on FK and filter columns to avoid full table scans on 120,500 fact rows
Business Metrics — ARPU, conversion rate, churn rate, discount ROI, customer segment value ranking



👤 Author

Data Engineering Project | 2026
Built using SQL Server and Kimball dimensional modelling
