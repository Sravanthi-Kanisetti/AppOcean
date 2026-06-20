# 📋 Project Summary — App Store Analytics DWH
## Quick Reference Card

---

## 🔑 Key Concepts Used — Kimball Architecture

| Concept | What it means | In this project |
|---|---|---|
| Star Schema | Fact table in center, dims around it | `fact_app_events` + 5 dim tables |
| Fact Table | Stores measurable events/numbers | revenue, sessions, ratings, discounts |
| Dimension Table | Stores descriptive context | who, what, where, when |
| Data Mart | Focused view for one department | 6 views for 6 teams |
| Staging | Raw data holding area | `Staging` schema |

---

## 🗂️ Schema Design Decisions

**Why Two Schemas?**
```
Staging schema  → raw data (never modified after loading)
DW schema       → clean data (star schema with constraints)
```
Database: `Kimball`

**Why NVARCHAR in Staging?**
- CSV may have `2020.0` not `2020` for year
- CSV may have `True\r` not `True` for boolean
- NVARCHAR accepts anything safely
- DW applies proper types during INSERT

**Why DELETE not TRUNCATE for fact table?**
- TRUNCATE is blocked on tables with FK constraints
- DELETE works even with FK constraints
- Fix: `NOCHECK CONSTRAINT` → DELETE fact → TRUNCATE dims → INSERT all → `CHECK CONSTRAINT`

---

## 🧹 Cleaning Rules Applied

**Text Columns → TRIM + Standardize**
```sql
TRIM(column)                           -- remove spaces
UPPER/LOWER + CASE                     -- standardize casing
REPLACE(col, CHAR(13), '')             -- remove hidden \r (Windows CSV artifact)
ISNULL(col, 'Unknown')                 -- NULL → Unknown
```

**Numeric Columns → Keep NULL or Fix**
```sql
-- Discount: negative = impossible → 0
CASE WHEN discount_pct < 0 THEN 0 ELSE ISNULL(discount_pct,0) END

-- Revenue: NULL = no revenue event → keep as is, never default to 0
revenue_usd  -- no change, NULL is meaningful

-- release_year: NULL = unknown → keep NULL
CASE WHEN release_year IS NULL THEN NULL ELSE CAST(release_year AS INT) END
```

---

## ⚡ SP1 — `Staging.load_data`
TRUNCATE all staging tables → BULK INSERT each CSV
Features: per-table load timing, batch timing, TRY-CATCH error handling

## ⚡ SP2 — `DW.load_data`
```
ALTER TABLE DW.fact_app_events NOCHECK CONSTRAINT ALL
DELETE FROM DW.fact_app_events           -- empty fact first, frees dims
DELETE + INSERT each dim table (cleaned + typed)
INSERT DW.fact_app_events                -- loaded last (FK dependency)
ALTER TABLE DW.fact_app_events CHECK CONSTRAINT ALL
```
Features: per-table load timing, batch timing, TRY-CATCH error handling

---

## 📊 Data Profiling Checklist

**For every TEXT column:**
- [x] DISTINCT with `COLLATE Latin1_General_CS_AS` (case-sensitive check)
- [x] GROUP BY + COUNT to see value distribution
- [x] NULL count: `COUNT(*) - COUNT(col)`

**For every NUMERIC column:**
- [x] MAX, MIN, AVG, COUNT(*), NULL count in one query
- [x] Drill down on suspicious values (negatives, outliers)

**Issues found:** mixed gender casing, inconsistent `is_premium` flags (0/1/yes/no), platform casing (android/ANDROID), age_group separator inconsistency (`25_34` vs `25 to 34`), city NULL/blank/'N/A' mix, negative discounts, hidden `\r` in boolean text fields, `v2.0` vs `2.0` version prefix mismatch, DD-MM-YYYY date strings.

---

## ✅ Data Validation Checklist
- [x] Row count: Staging rows = DW rows (no data lost) — verified across all 6 tables
- [x] Text columns: `UNION ALL` Staging vs DW to compare before/after
- [x] NULL columns: Staging nulls → DW 'Unknown' count verified
- [x] Numeric columns: MIN should not be negative in DW
- [x] `discount_pct`: Staging negatives → DW negatives = 0
- [x] `is_weekend`: Staging True/False string → DW 1/0 BIT

---

## 🏪 Mart Selection Logic

| If query needs | Use this mart |
|---|---|
| User demographics + behavior | `Marketing_Mart` |
| Revenue + discounts + region | `Finance_Mart` |
| App ratings + sessions + device | `Product_Mart` |
| Region + currency + tax | `Regional_Mart` |
| Device type + OS + manufacturer | `Device_Mart` |
| Overall KPIs for management | `Executive_Mart` |

---

## 📈 Advanced SQL Used

| Feature | Used for |
|---|---|
| `LAG()` | MoM / QoQ / YoY revenue and engagement growth |
| `RANK()` / `DENSE_RANK()` | Top-N apps per category, region, device type |
| `ROW_NUMBER()` | Latest-month snapshot per category/device |
| CTE (multi-level) | Trend analysis chains — base metrics → LAG → growth % |
| `NULLIF()` | Safe division — avoid divide-by-zero across every rate metric |
| `COLLATE` | Case-sensitive text comparison during profiling |
| `SUM() OVER (PARTITION BY)` | Revenue share % within region (window aggregation) |
| `CASE` | Pivot-style bucketing (discount tiers, screen size tiers), standardization |
| `COUNT(DISTINCT)` | Unique user counts for ARPU calculation |
| `CHAR(13)` | Remove hidden carriage return from Windows CSV exports |

---

## 🎯 Interview Talking Points

**Why Kimball?**
Business-first design — star schema designed for how teams ask questions, not how data arrives.

**Why manual cleaning, not fully automated?**
Complex logic needs human verification — SELECT first, verify with eyes, then convert to INSERT.

**Why staging at all?**
Safety net — original raw data preserved even if cleaning logic has a bug.

**FK loading order?**
Dims first, fact last (FK constraint) — or `NOCHECK` + `DELETE` fact + `TRUNCATE` dims when FK blocks truncation.

**Why indexes?**
Non-clustered on all FK columns + `event_type` — mart views run fresh joins every query; without indexes SQL Server scans all 120,500 fact rows per join.

**Data Marts vs Warehouse?**
Mart = focused VIEW for one team — no duplication, always reflects live DW data, true Kimball approach (vs. Medallion architecture which would materialize physical tables).

**NULL handling philosophy?**
Dimension NULLs → 'Unknown' (clean GROUP BY results). Fact measure NULLs → kept as NULL (a NULL revenue means "no revenue event occurred" — defaulting to 0 would silently distort every AVG calculation).

**How is ARPU calculated?**
`SUM(revenue_usd) / COUNT(DISTINCT user_key)` — true unique-user based revenue per user, not a proxy.

**How is churn calculated?**
`Uninstalls / Downloads * 100` per segment (region, device, OS version) — directly actionable retention metric.

---

## 📦 Project Scale
- **6 source tables**, 120,500+ fact rows, 10,000 users, 4 years of date dimension
- **2 stored procedures** (staging load + DW load) with TRY-CATCH and timing instrumentation
- **6 business-facing data marts** (views)
- **5 non-clustered indexes** on fact table
- **30+ analytical queries** across all marts — KPI dashboards, ARPU, conversion rate, churn rate, MoM/QoQ/YoY growth, discount ROI, top-N rankings, customer segment value ranking
