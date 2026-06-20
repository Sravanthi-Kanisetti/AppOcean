USE kimball;


---------------------------------------------------------------------------------------------------------
---------------------------------------------***DATA PROFILING***----------------------------------------
---------------------------------------------------------------------------------------------------------




--Staging.dim_app table 
--==========================================
select *
from Staging.dim_app

select distinct app_name collate latin1_general_CS_AS
from Staging.dim_app

select app_name,count(*)
from Staging.dim_app
group by app_name


select count(*)-count(app_name) as nulls
from Staging.dim_app


select count(distinct app_name),count(distinct lower(ltrim(rtrim(app_name))))
from Staging.dim_app

select distinct category collate latin1_general_CS_AS
from staging.dim_app

select  category ,count(*) 
from staging.dim_app
group by category

select count(*)-count(category) as nulls
from staging.dim_app


select distinct platform collate latin1_general_cS_AS
from staging.dim_app

select count(*)-count(platform) as nulls
from staging.dim_app

select platform,count(*)
from  staging.dim_app
group by platform

select distinct content_rating collate latin1_general_cS_AS
from Staging.dim_app

select count(*)-count(content_rating) as nulls
from Staging.dim_app

select content_rating,count(*)
from Staging.dim_app
group by content_rating

select max(size_mb) ,min(size_mb),count(*),avg(size_mb),count(*)-count(size_mb) as nulls
from staging.dim_app

select distinct release_year ,count(*)
from staging.dim_app
group by release_year

select count(*)-count(release_year) as nulls,max(release_year),min(release_year),count(*)
from staging.dim_app


--Stagiing.dim_date
--==========================================
select *
from Staging.dim_date

select distinct month_name collate latin1_general_CS_AS 
from Staging.dim_date

select month_name,count(*)
from Staging.dim_date
group by month_name

select count(*)-count(month_name) as nulls
from Staging.dim_date


select   quarter ,count(*)
from Staging.dim_date
group by quarter

select count(*)-count(quarter) as nulls
from Staging.dim_date

select  year ,count(*) as count_per_year
from Staging.dim_date
group by year

select count(*)-count(year) as nulls
from Staging.dim_date

select max(week_of_year),min(week_of_year),count(*),count(*)-count(week_of_year) as nulls
from Staging.dim_Date 


select distinct day_of_Week collate latin1_general_CS_AS 
from Staging.dim_date

select day_of_week,count(*)
from Staging.dim_date
group by day_of_week

select count(*)-count(day_of_week) as nulls
from Staging.dim_date

select distinct is_weekend collate latin1_general_CS_AS  
from Staging.dim_date

select is_weekend,count(*)
from Staging.dim_date
group by is_weekend

select count(*)-count(is_weekend) as nulls
from Staging.dim_date


--Staging.dim_device
--==========================================
select *
from Staging.dim_device

select distinct device_type collate latin1_general_CS_AS
from Staging.dim_device

select device_type,count(*)
from Staging.dim_device
group by device_type

select count(*)-count(device_type) as nulls 
from Staging.dim_device


select distinct os_version collate latin1_general_CS_AS
from Staging.dim_device


select os_version,count(*)
from Staging.dim_device
group by os_version

select count(*)-count(os_version) as nulls 
from Staging.dim_device


select distinct manufacturer collate latin1_general_CS_AS
from Staging.dim_device


select manufacturer,count(*)
from Staging.dim_device
group by manufacturer

select count(*)-count(manufacturer) as nulls 
from Staging.dim_device



select max(screen_size_inch) ,min(screen_size_inch),count(*),avg(screen_size_inch),count(*)-count(screen_size_inch) as nulls
from Staging.dim_device


--Staging.dim_store_region
--==========================================
select *
from Staging.dim_store_region

select distinct region_name collate latin1_general_CS_AS
from Staging.dim_store_region

select region_name,count(*)
from Staging.dim_store_region
group by region_name

select count(*)-count(region_name) as nulls 
from Staging.dim_store_region


select distinct store_currency collate latin1_general_CS_AS
from Staging.dim_store_region

select store_currency,count(*)
from Staging.dim_store_region
group by store_currency

select count(*)-count(store_currency) as nulls 
from Staging.dim_store_region



select max(tax_rate_pct) ,min(tax_rate_pct),avg(tax_rate_pct),count(*),count(*)-count(tax_rate_pct) as nulls
from Staging.dim_store_region


--Staging.dim_user
--==========================================
select *
from Staging.dim_user


select count(*)-count(user_id) as nulls 
from Staging.dim_user


select distinct gender collate latin1_general_CS_AS
from Staging.dim_user


select  gender collate latin1_general_CS_AS,count(*)
from Staging.dim_user
group by  gender collate latin1_general_CS_AS

select count(*)-count(gender) as nulls 
from Staging.dim_user


select distinct age_group collate latin1_general_CS_AS
from Staging.dim_user

select  age_group collate latin1_general_CS_AS,count(*)
from Staging.dim_user
group by  age_group collate latin1_general_CS_AS

select count(*)-count(age_group) as nulls 
from Staging.dim_user


select distinct country collate latin1_general_CS_AS
from Staging.dim_user


select  country collate latin1_general_CS_AS,count(*)
from Staging.dim_user
group by  country collate latin1_general_CS_AS

select count(*)-count(country) as nulls 
from Staging.dim_user



select distinct city collate latin1_general_CS_AS
from Staging.dim_user


select  city collate latin1_general_CS_AS,count(*)
from Staging.dim_user
group by  city collate latin1_general_CS_AS

select count(*)-count(city) as nulls 
from Staging.dim_user



select distinct year(registration_Date),count(*)
from Staging.dim_user
group by year(registration_Date)
order by year(registration_Date)


select count(*)-count(registration_Date) as nulls 
from Staging.dim_user


select distinct email_domain collate latin1_general_CS_AS
from Staging.dim_user

select  email_domain collate latin1_general_CS_AS,count(*)
from Staging.dim_user
group by  email_domain collate latin1_general_CS_AS

select count(*)-count(email_domain) as nulls 
from Staging.dim_user



select distinct is_premium collate latin1_general_CS_AS
from Staging.dim_user

select  is_premium collate latin1_general_CS_AS,count(*)
from Staging.dim_user
group by  is_premium collate latin1_general_CS_AS

select count(*)-count(is_premium) as nulls 
from Staging.dim_user


--Staging.fact_app_events
--==========================================
select *
from Staging.fact_app_events

select distinct event_type collate latin1_general_CS_AS
from Staging.fact_app_events

select  event_type collate latin1_general_CS_AS,count(*)
from Staging.fact_app_events
group by  event_type collate latin1_general_CS_AS

select count(*)-count(event_type) as nulls 
from Staging.fact_app_events



select max(revenue_usd),min(revenue_usd),avg(revenue_usd),count(*),count(*)-count(revenue_usd) as nulls
from Staging.fact_app_events


select max(session_minutes),min(session_minutes),avg(session_minutes),count(*),count(*)-count(session_minutes) as nulls
from Staging.fact_app_events


select max(rating),min(rating),avg(rating),count(*),count(*)-count(rating) as nulls
from Staging.fact_app_events

select max(review_text_len),min(review_text_len),avg(review_text_len),count(*),count(*)-count(review_text_len) as nulls
from Staging.fact_app_events

select distinct install_source collate latin1_general_CS_AS
from Staging.fact_app_events

select  install_source collate latin1_general_CS_AS,count(*)
from Staging.fact_app_events
group by  install_source collate latin1_general_CS_AS

select count(*)-count(install_source) as nulls 
from Staging.fact_app_events



select distinct app_version collate latin1_general_CS_AS
from Staging.fact_app_events


select  app_version collate latin1_general_CS_AS,count(*)
from Staging.fact_app_events
group by  app_version collate latin1_general_CS_AS

select count(*)-count(app_version) as nulls 
from Staging.fact_app_events


select sum(case when app_version like 'v%' then 1 else 0 end) as with_v_prefix,
sum(case when app_version not like 'v%' then 1 else 0 end ) as without_v_prefix
from Staging.fact_app_events

select max(discount_pct),min(discount_pct),avg(discount_pct),count(*),count(*)-count(discount_pct) as nulls
from Staging.fact_app_events


select count(discount_pct)
from Staging.fact_app_events
where discount_pct<0


select count(discount_pct)
from Staging.fact_app_events
where discount_pct>=0


select count(*)-count(discount_pct) as nulls
from Staging.fact_app_events

