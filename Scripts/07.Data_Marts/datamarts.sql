---------------------------------------------------------------------------------
----------------------- ***Creating Data Marts*** -------------------------------
---------------------------------------------------------------------------------


---------------------------------------------------------------------------------
----------------------- ***Creating Data Marts*** -------------------------------
---------------------------------------------------------------------------------



-- Creating Marketing Mart
IF OBJECT_ID('DW.Marketing_Mart','V') IS NOT NULL
	DROP VIEW DW.Marketing_Mart;
GO


create view DW.Marketing_Mart as
select a.app_name,a.category,a.platform,a.price_usd,
d.year,d.month,d.month_name,d.quarter,d.day_of_week,d.is_weekend,
u.gender,u.age_group,u.country,u.city,u.is_premium,
f.user_key,f.event_type,f.session_minutes,f.install_source,f.revenue_usd
from DW.fact_app_events as f
join DW.dim_date d on f.date_key=d.date_key
join DW.dim_app a on f.app_key=a.app_key
join DW.dim_user u on f.user_key=u.user_key;


-- Creating Finance Mart
IF OBJECT_ID('DW.Finance_Mart','V') IS NOT NULL
	DROP VIEW DW.Finance_Mart;
GO

create view DW.Finance_Mart as 
select a.app_name,a.category,a.platform,a.price_usd,a.content_rating,a.release_year,
r.region_name,r.store_currency,r.tax_rate_pct,
d.year,d.month,d.month_name,d.quarter,
u.is_premium,u.country,
f.revenue_usd,f.discount_pct,f.event_type ,f.app_version
from DW.fact_app_events f 
join DW.dim_app a on f.app_key=a.app_key
join DW.dim_store_region r on f.region_key=r.region_key
join DW.dim_date d on f.date_key=d.date_key
join DW.dim_user u on f.user_key=u.user_key;


-- Creating Product Mart
IF OBJECT_ID('DW.Product_Mart','V') IS NOT NULL
	DROP VIEW DW.Product_Mart;
GO


create view DW.Product_Mart as
select a.app_name,a.category,a.platform ,a.price_usd,a.content_rating ,a.release_year,a.size_mb,
d.device_type,d.os_version,d.manufacturer ,
dt.year,dt.month,dt.month_name,dt.quarter,
u.is_premium,u.age_group,
f.rating,f.session_minutes,f.review_text_len,f.event_type ,f.app_version,f.revenue_usd
from DW.fact_app_events f
join DW.dim_app a on f.app_key=a.app_key
join DW.dim_device d on f.device_key=d.device_key
join DW.dim_date dt on f.date_key=dt.date_key
join DW.dim_user u on f.user_key=u.user_key;


-- Creating Regional Mart
IF OBJECT_ID('DW.Regional_Mart','V') IS NOT NULL
	DROP VIEW DW.Regional_Mart;
GO 

create view DW.Regional_Mart as 
select a.app_name,a.category,a.platform,a.price_usd,
d.year,d.month_name,d.quarter,
u.country,u.is_premium,u.gender,
s.region_name,s.store_currency,s.tax_rate_pct,
f.revenue_usd,f.discount_pct,f.event_type
from DW.fact_app_events f 
join DW.dim_app a on f.app_key=a.app_key
join DW.dim_date d on f.date_key=d.date_key
join DW.dim_user u on f.user_key=u.user_key 
join Dw.dim_store_region s on f.region_key=s.region_key ;

 
-- Creating Device Mart
IF OBJECT_ID('DW.Device_Mart','V') IS NOT NULL
	DROP VIEW DW.Device_Mart;
GO


create view DW.Device_Mart as 
select a.app_name,a.category,a.platform,a.size_mb,
dt.year,dt.month_name,dt.quarter,
u.age_group,u.is_premium,
d.device_type,d.os_version,d.manufacturer,d.screen_size_inch,
f.session_minutes,f.event_type,f.rating,f.revenue_usd ,f.discount_pct,f.app_version
from DW.fact_app_events f 
join DW.dim_app a on f.app_key=a.app_key
join DW.dim_date dt on f.date_key=dt.date_key
join DW.dim_user u on f.user_key=u.user_key 
join Dw.dim_device d on f.device_key =d.device_key;

-- Creating Executive Mart
IF OBJECT_ID('DW.Executive_Mart','V') IS NOT NULL
	DROP VIEW DW.Executive_Mart;
GO

create view  Dw.Executive_Mart as 
select  a.app_name,a.category,a.platform,a.price_usd,
s.region_name,s.store_currency,
u.is_premium,u.country,u.gender,u.age_group,
d.year,d.quarter,d.month_name,d.is_weekend,
f.revenue_usd,f.session_minutes,f.rating,f.discount_pct,f.event_type 
from DW.fact_app_events f 
join DW.dim_app a on f.app_key=a.app_key
join DW.dim_date d on f.date_key=d.date_key
join DW.dim_user u on f.user_key=u.user_key 
join Dw.dim_store_region s on f.region_key=s.region_key;
