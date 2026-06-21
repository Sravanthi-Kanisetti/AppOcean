# 🏗️ App Store Analytics — Kimball Data Warehouse

**Built with SQL Server | Kimball Dimensional Modelling | Star Schema**

---

## 📌 Project Overview

A complete end-to-end Kimball Data Warehouse built on Microsoft SQL Server for App Store Analytics. This project covers the full data engineering lifecycle, from raw CSV ingestion to business-ready analytical queries across 6 data marts.

**Goal:** Transform raw app store data into a clean, performant, queryable star schema that answers real business questions for marketing, finance, product, regional, device, and executive teams.

---

## 🏛️ Architecture
CSV SOURCE FILES

dim_app, dim_date, dim_device, dim_user, dim_store_region, fact_app_events
    |
    |   BULK INSERT
    v
STAGING LAYER  (Staging schema)

Stored Procedure: Staging.load_data

All columns NVARCHAR, accepts any raw format safely
    |
    |   Data Profiling
    |   Data Cleaning
    v
DW LAYER  (DW schema)

Stored Procedure: DW.load_data

Star Schema with PK and FK constraints
    dim_date
    dim_app
    dim_user        --------->   fact_app_events
    dim_device
    dim_store_region

    |
    |   CREATE VIEW
    v
DATA MARTS  (Views)

Marketing_Mart,  Finance_Mart,  Product_Mart

Regional_Mart,   Device_Mart,   Executive_Mart
    |
    v
30+ ANALYTICAL QUERIES

ARPU,  Churn Rate,  MoM / QoQ / YoY Growth,  Discount ROI,  Segment Ranking

---

## ⭐ Star Schema — All 5 Dimensions + 1 Fact Table
                               dim_date
                               ------------------
                               date_key      (PK)
                               full_date
                               day
                               month
                               month_name
                               quarter
                               year
                               week_of_year
                               day_of_week
                               is_weekend
                                      |
                                      |  date_key  (FK)
                                      |
dim_userdim_appuser_key       (PK)app_key        (PK)user_idapp_idgenderapp_nameage_groupcategorycountrydevelopercityplatformregistration_dateprice_usdemail_domaincontent_ratingis_premiumrelease_year
    |                                |                                  size_mb
    |  user_key (FK)                 |                                          |
    |                                |                                          |  app_key (FK)
    +------------------>   fact_app_events   <------------------------+
                           ------------------
                           fact_key        (PK)
                           date_key        (FK  ->  dim_date.date_key)
                           app_key         (FK  ->  dim_app.app_key)
                           user_key        (FK  ->  dim_user.user_key)
                           device_key      (FK  ->  dim_device.device_key)
                           region_key      (FK  ->  dim_store_region.region_key)
                           event_type
                           revenue_usd
                           session_minutes
                           rating
                           review_text_len
                           install_source
                           app_version
                           discount_pct
                                      ^                                          ^
                                      |  device_key (FK)                         |  region_key (FK)
                                      |                                          |
                          dim_device                                 dim_store_region
                          ------------------                         ------------------
                          device_key     (PK)                        region_key     (PK)
                          device_type                                region_name
                          os_version                                 store_currency
                          manufacturer                               tax_rate_pct
                          screen_size_inch

**Relationships (Grain: one row per app event):**

| Fact column | References | Relationship |
|---|---|---|
| `date_key` | `dim_date.date_key` | Many fact rows belong to one date |
| `app_key` | `dim_app.app_key` | Many fact rows belong to one app |
| `user_key` | `dim_user.user_key` | Many fact rows belong to one user |
| `device_key` | `dim_device.device_key` | Many fact rows belong to one device |
| `region_key` | `dim_store_region.region_key` | Many fact rows belong to one region |

This is a classic Kimball star: one wide fact table at the center, five independent dimension tables radiating outward, each joined by a single surrogate key. No dimension joins to another dimension directly — everything passes through the fact table.

---

## 📁 Project Structure
App-Store-Analytics-DWH/
README.md
01_Database_Schema_Creation/

DB_and_Schema_creation.sql

Creates Kimball DB, Staging schema, DW schema
02_Staging/

01_ddl_staging.sql

6 staging tables with NVARCHAR types for safe loading

02_procLoad_Staging.sql

Stored Procedure: TRUNCATE then BULK INSERT, with timing and TRY-CATCH
03_Data_Profiling/

Data_Profiling.sql

DISTINCT plus COLLATE, COUNT NULL checks, MAX / MIN / AVG
04_Data_Cleaning/

Cleaning_Logic.sql

SELECT-first cleaning logic, verified before being placed into SP2
05_DW_Layer/

01_ddl_dw.sql

Star schema with PRIMARY KEY and FOREIGN KEY constraints

02_procLoad_dw.sql

SP: NOCHECK FK, then DELETE fact, then TRUNCATE dims, then INSERT
06_Data_Validation/

Data_Validation.sql

Staging vs DW comparison using UNION ALL
07_Indexes/

Indexes.sql

Non-clustered indexes on all FK columns plus event_type
08_Data_Marts/

DataMarts.sql

6 Views: Marketing, Finance, Product, Regional, Device, Executive
09_Analytical_Queries/

Analytical_Queries.sql

30+ business queries across 6 data marts

---

## 📊 Dataset

| Table | Rows | Description |
|---|---|---|
| `fact_app_events` | 120,500 | Core events: Download, Purchase, Review, Update, Uninstall |
| `dim_user` | 10,000 | User demographics and premium status |
| `dim_app` | 30 | App metadata, categories, platforms |
| `dim_date` | 1,461 | Calendar table covering 4 years |
| `dim_device` | 10 | Device types, OS versions, manufacturers |
| `dim_store_region` | 5 | Regional store info, currencies, tax rates |

---

## 🔧 Tech Stack

| Tool | Purpose |
|---|---|
| SQL Server | Database engine |
| SSMS | Development environment |
| T-SQL | All data engineering code |
| GitHub | Version control |

---

## 🚀 How to Run This Project

### Prerequisites

- Microsoft SQL Server installed
- SSMS (SQL Server Management Studio)
- CSV files placed in a local folder, for example `C:\AppAnalytics\data`

### Step 1 — Create Database and Schemas

```sql
-- Run: 01_Database_Schema_Creation/DB_and_Schema_creation.sql
-- Creates: Kimball database, Staging schema, DW schema
```

### Step 2 — Create Staging Tables

```sql
-- Run: 02_Staging/01_ddl_staging.sql
-- Creates: 6 staging tables with NVARCHAR types for safe CSV loading
```

### Step 3 — Create and Execute SP1 (Raw Data Load)

```sql
-- Run: 02_Staging/02_procLoad_Staging.sql
-- Creates stored procedure Staging.load_data

-- Before executing: update CSV file paths inside the SP to your local folder
EXEC Staging.load_data;
-- Loads all 6 CSV files into staging via BULK INSERT
-- Prints row counts and timing for each table
```

### Step 4 — Data Profiling (Optional, Reference Only)

```sql
-- Run: 03_Data_Profiling/Data_Profiling.sql
-- Explores every column: NULLs, casing issues, value distributions
-- No data is modified here, this is read-only analysis
```

### Step 5 — Review Data Cleaning Logic (Optional, Reference Only)

```sql
-- Run: 04_Data_Cleaning/Cleaning_Logic.sql
-- SELECT-only queries showing the cleaning logic that was verified
-- before being embedded inside DW.load_data in Step 7
```

### Step 6 — Create DW Tables (Star Schema)

```sql
-- Run: 05_DW_Layer/01_ddl_dw.sql
-- Creates: 5 dimension tables plus 1 fact table
-- Applies: PRIMARY KEY on dims, FOREIGN KEY on fact
```

### Step 7 — Create and Execute SP2 (Cleaned Data Load)

```sql
-- Run: 05_DW_Layer/02_procLoad_dw.sql
-- Creates stored procedure DW.load_data

EXEC DW.load_data;
-- Cleans and loads all staging data into the DW star schema
-- Applies: gender standardization, NULL handling,
--          discount fixes, date conversions, casing fixes
-- Order: NOCHECK FK, DELETE fact, DELETE plus INSERT dims, INSERT fact, CHECK FK
-- Prints row counts and timing for each table
```

### Step 8 — Validate Data Quality

```sql
-- Run: 06_Data_Validation/Data_Validation.sql
-- Compares Staging vs DW side by side using UNION ALL
-- Verifies: row counts match, cleaning applied correctly
```

### Step 9 — Create Indexes

```sql
-- Run: 07_Indexes/Indexes.sql
-- Creates 5 non-clustered indexes on fact table FK columns plus event_type
-- Improves JOIN performance on all mart queries
```

### Step 10 — Create Data Marts

```sql
-- Run: 08_Data_Marts/DataMarts.sql
-- Creates 6 views: Marketing_Mart, Finance_Mart, Product_Mart,
--                  Regional_Mart, Device_Mart, Executive_Mart
```

### Step 11 — Run Analytical Queries

```sql
-- Run: 09_Analytical_Queries/Analytical_Queries.sql
-- 30+ business queries across 6 marts
-- Uses: LAG, RANK, DENSE_RANK, ROW_NUMBER,
--       multi-level CTEs, Window SUM, NULLIF, PARTITION BY
```

### ⚡ Quick Run Order Summary
DB_and_Schema_creation.sql
    |
    v
01_ddl_staging.sql
    |
    v
02_procLoad_Staging.sql   -->   EXEC Staging.load_data
    |
    v
Data_Profiling.sql   (reference only)
    |
    v
Cleaning_Logic.sql   (reference only)
    |
    v
01_ddl_dw.sql
    |
    v
02_procLoad_dw.sql   -->   EXEC DW.load_data
    |
    v
Data_Validation.sql
    |
    v
Indexes.sql
    |
    v
DataMarts.sql
    |
    v
Analytical_Queries.sql

---

## 🧹 Data Cleaning Summary

| Column | Issue Found | Fix Applied |
|---|---|---|
| `gender` | male, MALE, M mixed | Standardized to Male / Female / Other / Unknown |
| `is_premium` | 0, 1, yes, no mixed | Converted to BIT (0 / 1) |
| `platform` | android, ANDROID mixed | Standardized to Android / iOS / Both |
| `device_type` | smartphone, TABLET mixed | Standardized to Smartphone / Tablet / PC / Smartwatch |
| `age_group` | 25_34, 25 to 34 mixed | Standardized to 25-34 format |
| `city` | NULL, empty, N/A | Replaced with 'Unknown' |
| `email_domain` | NULL values | Replaced with 'Unknown' |
| `content_rating` | NULL values | Replaced with 'Not Rated' |
| `release_year` | FLOAT with NULLs | Cast to INT, NULLs preserved |
| `discount_pct` | Negative values | Replaced with 0 |
| `is_weekend` | Hidden carriage return in 'True' / 'False' | Converted to BIT (1 / 0) via `REPLACE(col, CHAR(13), '')` |
| `install_source` | NULL values | Replaced with 'Unknown' |
| `app_version` | NULL or mixed v-prefix | TRIM, NULLs replaced with 'Unknown' |
| `registration_date` | DD-MM-YYYY string | `CONVERT(DATE, col, 105)` |

---

## 🏪 Data Marts

| Mart | Target Team | Key Columns |
|---|---|---|
| `Marketing_Mart` | Marketing | gender, age_group, install_source, user_key, session_minutes |
| `Finance_Mart` | Finance | revenue_usd, discount_pct, region_name, tax_rate_pct, price_usd |
| `Product_Mart` | Product | rating, session_minutes, device_type, app_name, app_version |
| `Regional_Mart` | Regional Managers | region_name, store_currency, tax_rate_pct, revenue_usd |
| `Device_Mart` | Tech and Engineering | device_type, os_version, manufacturer, screen_size_inch |
| `Executive_Mart` | Management | All KPIs: revenue, rating, session, events, churn |

---

## 📈 Sample Analytical Queries

### Which install source brings the highest quality users?

```sql
SELECT install_source,
       COUNT(DISTINCT user_key) AS users_count,
       ROUND(AVG(revenue_usd), 2) AS avg_revenue,
       ROUND(AVG(session_minutes), 2) AS avg_session,
       ROUND(SUM(revenue_usd) / NULLIF(COUNT(DISTINCT user_key), 0), 2) AS ARPU
FROM DW.Marketing_Mart
GROUP BY install_source
ORDER BY avg_revenue DESC;
```

### Year-over-year revenue growth?

```sql
WITH yearly AS (
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
```

### Which manufacturer has the lowest uninstall rate?

```sql
SELECT manufacturer,
       SUM(CASE WHEN event_type = 'Uninstall' THEN 1 ELSE 0 END) AS uninstalls,
       SUM(CASE WHEN event_type = 'Download' THEN 1 ELSE 0 END) AS downloads,
       ROUND(SUM(CASE WHEN event_type = 'Uninstall' THEN 1 ELSE 0 END) * 100.0
             / NULLIF(SUM(CASE WHEN event_type = 'Download' THEN 1 ELSE 0 END), 0), 2) AS uninstall_rate_pct
FROM DW.Device_Mart
GROUP BY manufacturer
ORDER BY uninstall_rate_pct ASC;
```

---

## ⚡ Performance Optimizations

```sql
-- Non-clustered indexes on all FK columns plus event_type
CREATE NONCLUSTERED INDEX IX_fact_date_key   ON DW.fact_app_events(date_key);
CREATE NONCLUSTERED INDEX IX_fact_app_key    ON DW.fact_app_events(app_key);
CREATE NONCLUSTERED INDEX IX_fact_user_key   ON DW.fact_app_events(user_key);
CREATE NONCLUSTERED INDEX IX_fact_device_key ON DW.fact_app_events(device_key);
CREATE NONCLUSTERED INDEX IX_fact_region_key ON DW.fact_app_events(region_key);
CREATE NONCLUSTERED INDEX IX_fact_event_type ON DW.fact_app_events(event_type);
```

---

## 💡 Key Design Decisions

| Decision | Reason |
|---|---|
| NVARCHAR in staging | Accept any format safely, staging's job is safe loading, not validation |
| Manual cleaning (no SP) | Complex business logic needs human verification: SELECT, verify, then INSERT |
| DELETE before TRUNCATE | FK constraints block TRUNCATE, DELETE fact first to free dimension tables |
| NOCHECK CONSTRAINT | Temporarily disables FK enforcement so dims can be truncated and reloaded safely |
| NULL becomes Unknown in dims | Business queries GROUP BY dimensions, NULL causes confusing, fragmented results |
| NULL kept in fact measures | revenue NULL means the event did not generate revenue, this is meaningful, not missing |
| Views for Data Marts | No data duplication, always fresh, true Kimball approach versus Medallion architecture |
| `user_key` exposed in Marketing_Mart | Needed for accurate ARPU, `COUNT(DISTINCT user_key)`, not a proxy |

---

## 🎓 What I Learned

- **Kimball Architecture** — star schema design principles, fact versus dimension modeling
- **ETL Pipeline** — Staging to Profiling to Cleaning to DW loading with stored procedures
- **Data Profiling** — systematic column analysis using COLLATE, COUNT, MAX / MIN
- **Data Quality** — handling NULLs, casing issues, negative values, hidden carriage-return characters
- **SQL Server Internals** — FK constraints, TRUNCATE versus DELETE, NOCHECK, COLLATE
- **Window Functions** — LAG for MoM / QoQ / YoY trend analysis, RANK / DENSE_RANK / ROW_NUMBER for leaderboards, SUM() OVER (PARTITION BY) for share-of-total metrics
- **CTEs** — multi-level chained logic for trend and ranking queries
- **Indexing Strategy** — non-clustered indexes on FK and filter columns to avoid full table scans on 120,500 fact rows
- **Business Metrics** — ARPU, conversion rate, churn rate, discount ROI, customer segment value ranking

---

## 👤 Author

**Data Engineering Project | 2026**

Built using SQL Server and Kimball dimensional modelling
