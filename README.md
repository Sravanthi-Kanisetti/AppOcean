# 🏗️ App Store Analytics — Kimball Data Warehouse
### Built with SQL Server | Kimball Dimensional Modelling | Star Schema

---

## 📌 Project Overview

A complete **end-to-end Kimball Data Warehouse** built on **Microsoft SQL Server** for App Store Analytics. This project covers the full data engineering lifecycle — from raw CSV ingestion to business-ready analytical queries across 6 data marts.

> **Goal:** Transform raw app store data into a clean, performant, queryable star schema that answers real business questions for marketing, finance, product, regional, device and executive teams.

---

## 🏛️ Architecture

```
📂 CSV Source Files
        │
        ▼
┌─────────────────┐
│   Staging Layer │  ← Raw data loaded via Stored Procedure (SP1)
│  (Stg schema)   │  ← NVARCHAR columns — accepts everything safely
└────────┬────────┘
         │
         ▼  [Data Profiling → Data Cleaning]
         │
┌─────────────────┐
│   DW Layer      │  ← Cleaned data loaded via Stored Procedure (SP2)
│  (DW schema)    │  ← Star Schema with PK/FK constraints
│                 │
│  ┌───────────┐  │
│  │ dim_date  │  │
│  │ dim_app   │  │
│  │ dim_user  │──┼──→  fact_app_events
│  │ dim_device│  │
│  │ dim_region│  │
│  └───────────┘  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│              Data Marts (Views)         │
│  Marketing | Finance | Product          │
│  Regional  | Device  | Executive        │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│ 30+ Analytical  │
│    Queries      │
└─────────────────┘
```

---

## ⭐ Star Schema

```
                    DW.dim_date
                    (date_key PK)
                         │
                         │
DW.dim_user ─────────────┼─────────── DW.dim_app
(user_key PK)            │            (app_key PK)
                         │
              DW.fact_app_events
              (fact_key PK)
              ├── date_key FK
              ├── app_key FK
              ├── user_key FK
              ├── device_key FK
              ├── region_key FK
              ├── revenue_usd
              ├── session_minutes
              ├── rating
              ├── discount_pct
              └── event_type
                         │
DW.dim_device ───────────┼─────────── DW.dim_store_region
(device_key PK)                       (region_key PK)
```

---

## 📁 Project Structure

```
App-Store-Analytics-DWH/
│
├── 📄 README.md
│
├── 📂 01.Database_Schema_Creation/
│     └── db_and_schema_creation.sql
│         └── Creates: Kimball DB, Staging schema, DW schema
│
├── 📂 02.Staging/
│     ├── 01.ddl_staging.sql
│     │   └── 6 staging tables with NVARCHAR types for safe loading
│     └── 02.Proc_Load_Staging.sql
│         └── Stored Procedure: TRUNCATE → BULK INSERT with timing + TRY-CATCH
│
├── 📂 03.Data_Profiling/
│     └── data_profiling.sql
│         └── DISTINCT, COUNT, NULL checks, MAX/MIN/AVG for all columns
│
├── 📂 04.DW_Layer/
│     ├── 01.ddl_dw.sql
│     │   └── Star schema with PRIMARY KEY + FOREIGN KEY constraints
│     └── 02.Proc_Load_dw.sql
│         └── Stored Procedure: NOCHECK FK → DELETE fact → TRUNCATE dims → INSERT
│
├── 📂 05.Data_Validation/
│     └── data_validation.sql
│         └── Staging vs DW comparison using UNION ALL
│
├── 📂 06.Indexes/
│     └── indexes.sql
│         └── Non-clustered indexes on all FK columns + event_type
│
├── 📂 07.Data_Marts/
│     └── dataaarts.sql
│         └── 6 Views: Marketing, Finance, Product, Regional, Device, Executive
│
└── 📂 08.Analytical_Queries/
      └── analytical_queries.sql
          └── 30+ business queries across 6 data marts
```

---

## 📊 Dataset

| Table | Rows | Description |
|---|---|---|
| `fact_app_events` | 120,500 | Core events: download, purchase, review, update, uninstall |
| `dim_user` | 10,000 | User demographics and premium status |
| `dim_app` | 30 | App metadata, categories, platforms |
| `dim_date` | 1,461 | Calendar table (2021–2024) |
| `dim_device` | 10 | Device types, OS versions, manufacturers |
| `dim_store_region` | 5 | Regional store info, currencies, tax rates |

---

## 🔧 Tech Stack

| Tool | Purpose |
|---|---|
| **SQL Server** | Database engine |
| **SSMS** | Development environment |
| **T-SQL** | All data engineering code |
| **GitHub** | Version control |

---

## 🚀 How to Run This Project

### Prerequisites
- Microsoft SQL Server installed
- SSMS (SQL Server Management Studio)
- CSV files placed in a local folder (e.g. C:\Kimball\data\)

---

### Step 1 — Create Database & Schemas
```sql
-- Run: 01.Database_Schema_Creation/db_and_schema_creation.sql
-- Creates: Kimball database, Staging schema, DW schema
```

---

### Step 2 — Create Staging Tables
```sql
-- Run: 02.Staging/01.ddl_staging.sql
-- Creates: 6 staging tables with NVARCHAR types for safe CSV loading
```

---

### Step 3 — Create & Execute SP1 (Raw Data Load)
```sql
-- Run: 02.Staging/02.Proc_Load_Staging.sql
-- Creates stored procedure Staging.load_data

-- ⚠️ Before executing: Update CSV file paths inside SP to your local folder
-- Then execute:
EXEC Staging.Load_data;
-- Loads all 6 CSV files into staging via BULK INSERT
-- Prints row counts and timing for each table
```

---

### Step 4 — Data Profiling (Optional — Reference Only)
```sql
-- Run: 03.Data_Profiling/data_profiling.sql
-- Explores every column: NULLs, casing issues, value distributions
-- No data is modified here — read only analysis
```

---

### Step 5 — Create DW Tables (Star Schema)
```sql
-- Run: 04.DW_Layer/01.ddl_dw.sql
-- Creates: 5 dimension tables + 1 fact table
-- Applies: PRIMARY KEY on dims, FOREIGN KEY on fact
```

---

### Step 6 — Create & Execute SP2 (Cleaned Data Load)
```sql
-- Run: 04.DW_Layer/02.Proc_Load_dw.sql
-- Creates stored procedure DW.load_data

-- Then execute:
EXEC DW.load_data;
-- Cleans and loads all staging data into DW star schema
-- Applies: gender standardization, NULL handling,
--          discount fixes, date conversions, casing fixes
-- Prints row counts and timing for each table
```

---

### Step 7 — Validate Data Quality
```sql
-- Run: 05.Data_Validation/data_validation.sql
-- Compares Staging vs DW side by side using UNION ALL
-- Verifies: row counts match, cleaning applied correctly
```

---

### Step 8 — Create Indexes
```sql
-- Run: 06.Indexes/indexes.sql
-- Creates 6 non-clustered indexes on fact table FK columns
-- Improves JOIN performance on all mart queries
```

---

### Step 9 — Create Data Marts
```sql
-- Run: 07.Data_Marts/datamarts.sql
-- Creates 6 views: Marketing, Finance, Product,
--                  Regional, Device, Executive
```

---

### Step 10 — Run Analytical Queries
```sql
-- Run: 08.Analytical_Queries/analytical_queries.sql
-- 25 business queries across 6 marts
-- Uses: LAG, CTE, RANK, DENSE_RANK, ROW_NUMBER,
--       Window SUM, NULLIF, PARTITION BY
```

---

### ⚡ Quick Run Order Summary:
```
db_and_schema_creation.sql
        ↓
01.ddl_staging.sql
        ↓
02.Proc_Load_Staging.sql → EXEC Staging.load_data
        ↓
data_profiling.sql
        ↓
01.ddl_dw.sql
        ↓
02.Proc_Load_dw.sql → EXEC DW.load_data
        ↓
data_validation.sql
        ↓
indexes.sql
        ↓
datamarts.sql
        ↓
analytical_queries.sql
```

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
| `Marketing_Mart` | Marketing | gender, age_group, install_source, session_minutes |
| `Finance_Mart` | Finance | revenue_usd, discount_pct, region, price_usd |
| `Product_Mart` | Product | rating, session_minutes, device_type, app_name |
| `Regional_Mart` | Regional Managers | region_name, currency, tax_rate, revenue |
| `Device_Mart` | Tech/Engineering | device_type, os_version, manufacturer, screen_size |
| `Executive_Mart` | Management | All KPIs — revenue, rating, session, downloads |

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
-- Non-clustered indexes on all FK columns

create nonclustered index IX_fact_date_key on DW.fact_app_events(date_key);

create nonclustered index IX_fact_app_key on DW.fact_app_events(app_key);

create nonclustered index IX_fact_user_key on DW.fact_app_events(user_key);

create nonclustered index IX_fact_device_key on DW.fact_app_events(device_key);

create nonclustered index IX_fact_region_key on DW.fact_app_events(region_key);

create nonclustered index IX_fact_event_typeon DW.fact_app_events(event_type);
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

**Sravanthi Kanisetti** — Data Engineering Project | 2026

---

*Built using SQL Server and Kimball Dimensional Modelling*
