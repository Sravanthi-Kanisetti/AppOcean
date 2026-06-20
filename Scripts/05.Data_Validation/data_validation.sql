use Kimball;



----------------------------------------------------------------
-----------------------DATA VALIDATION--------------------------
----------------------------------------------------------------


---------------------------------------------------------------
------------------No Data Loss During Loading -----------------
---------------------------------------------------------------

select 'dim_app' as table_name,
(select count(*) from Staging.dim_app)  as Staging_rows,
(select count(*) from DW.dim_app )as DW_rows
union all
select 'dim_date' as table_name,
(select count(*) from Staging.dim_date)  as Staging_rows,
(select count(*) from DW.dim_date )as DW_rows
union all
select 'dim_device' as table_name,
(select count(*) from Staging.dim_device)  as Staging_rows,
(select count(*) from DW.dim_device )as DW_rows
union all
select 'dim_user' as table_name,
(select count(*) from Staging.dim_user)  as Staging_rows,
(select count(*) from DW.dim_user)as DW_rows
union all
select 'dim_store_region' as table_name,
(select count(*) from Staging.dim_store_region)  as Staging_rows,
(select count(*) from DW.dim_store_region)as DW_rows
union all
select 'fact_app_events' as table_name,
(select count(*) from Staging.fact_app_events)  as Staging_rows,
(select count(*) from DW.fact_app_events)as DW_rows




select 
distinct event_type collate latin1_general_CS_AS as event_type,'Staging' as source
from staging.fact_app_events
union all
select 
distinct event_type collate latin1_general_CS_AS,'DW' as source
from DW.fact_app_events


select 
count(distinct event_type collate latin1_general_CS_AS) as unique_values_count,'Staging' as source,'event_type' as column_name
from staging.fact_app_events
union all
select 
count(distinct event_type collate latin1_general_CS_AS),'DW' as source,'event_type'
from DW.fact_app_events




select count(*)-count(install_source) as nulls_count ,'Staging' as source ,'install_source' as column_name
from Staging.fact_app_events 
union all
select count(*)-count(install_source) as nulls_count ,'DW' as source ,'install_source' as column_name
from DW.fact_app_events 


select 
count(distinct install_source collate latin1_general_CS_AS) as unique_values_count,'Staging' as source,'install_source' as column_name
from staging.fact_app_events
union all
select 
count(distinct install_source collate latin1_general_CS_AS),'DW' as source,'install_source'
from DW.fact_app_events



select 
distinct install_source collate latin1_general_CS_AS as install_source,'Staging' as source
from staging.fact_app_events
union all
select 
distinct install_source collate latin1_general_CS_AS,'DW' as source
from DW.fact_app_events

select 'Staging' as source,
max(discount_pct) as max_discount_pct,
min(discount_pct) as min_discount_pct,
sum(case when discount_pct<0 then 1 else 0 end) as negative_count,
count(*)-count(discount_pct) as nulls_count
from Staging.fact_app_events
union all
select 'DW' as source,max(discount_pct) as max_discount_pct,min(discount_pct) as min_discount_pct,
sum(case when discount_pct<0 then 1 else 0 end),
count(*)-count(discount_pct)
from DW.fact_app_events



select 'Staging' as source,count(*)-count(app_version)  as nulls_count
from Staging.fact_app_events
union all 
select 'DW' as source,count(*)-count(app_version)
from DW.fact_app_events




select distinct platform  collate latin1_general_CS_AS as platform,'Staging' as source
from Staging.dim_app
union all
select distinct platform collate latin1_general_CS_AS,'DW' as source
from DW.dim_app


select count(*)-count(content_rating) as nulls_count ,'Staging' as source,'content_rating' as column_name
from Staging.dim_app
union all 
select count(*)-count(content_rating) as nulls_count ,'DW' as source,'content_rating'
from DW.dim_app




select distinct is_weekend ,'Staging' as source
from Staging.dim_date 
union all
select distinct cast( is_weekend as nvarchar),'DW'
from DW.dim_date 



select distinct device_type collate latin1_general_CS_AS as device_type ,'Staging' as source
from Staging.dim_device 
union all
select distinct device_type collate latin1_general_CS_AS ,'DW' as source
from DW.dim_device 

select count(distinct device_type collate latin1_general_CS_AS) as unique_values_count,'Staging' as source ,'device_type' as column_name
from Staging.dim_device 
union all
select count(distinct device_type collate latin1_general_CS_AS),'DW' as source ,'device_type' as column_name
from DW.dim_device 


select count(*)-count(device_type) as nulls_count ,'Staging' as source ,'device_type' as column_name
from Staging.dim_device 
union all
select count(*)-count(device_type) as nulls_count ,'DW' as source ,'device_type' as column_name
from DW.dim_device 

select count(*)-count(os_version) as nulls_count ,'Staging' as source ,'os_version' as column_name
from Staging.dim_device 
union all
select count(*)-count(os_version) as nulls_count ,'DW' as source ,'os_version' as column_name
from DW.dim_device 

select count(*)-count(manufacturer) as nulls_count ,'Staging' as source ,'manufacturer' as column_name
from Staging.dim_device 
union all
select count(*)-count(manufacturer) as nulls_count ,'DW' as source ,'manufacturer' as column_name
from DW.dim_device 

 



select distinct gender collate latin1_general_CS_AS as gender ,'Staging' as source
from Staging.dim_user 
union all
select distinct gender collate latin1_general_CS_AS ,'DW' as source
from DW.dim_user 

select count(distinct gender collate latin1_general_CS_AS) as unique_values_count,'Staging' as source ,'gender' as column_name
from Staging.dim_user 
union all
select count(distinct gender collate latin1_general_CS_AS),'DW' as source ,'gender' as column_name
from DW.dim_user 


select count(*)-count(gender) as nulls_count ,'Staging' as source ,'gender' as column_name
from Staging.dim_user 
union all
select count(*)-count(gender) as nulls_count ,'DW' as source ,'gender' as column_name
from DW.dim_user 




select distinct age_group collate latin1_general_CS_AS as age_group ,'Staging' as source
from Staging.dim_user 
union all
select distinct age_group collate latin1_general_CS_AS ,'DW' as source
from DW.dim_user 

select count(distinct age_group collate latin1_general_CS_AS) as unique_values_count,'Staging' as source ,'age_group' as column_name
from Staging.dim_user 
union all
select count(distinct age_group collate latin1_general_CS_AS),'DW' as source ,'age_group' as column_name
from DW.dim_user 


select count(*)-count(age_group) as nulls_count ,'Staging' as source ,'age_group' as column_name
from Staging.dim_user 
union all
select count(*)-count(age_group) as nulls_count ,'DW' as source ,'age_group' as column_name
from DW.dim_user 



select count(*)-count(city) as nulls_count ,'Staging' as source ,'city' as column_name
from Staging.dim_user 
union all
select count(*)-count(city) as nulls_count ,'DW' as source ,'city' as column_name
from DW.dim_user 


select count(*)-count(email_domain) as nulls_count ,'Staging' as source ,'email_domain' as column_name
from Staging.dim_user 
union all
select count(*)-count(email_domain) as nulls_count ,'DW' as source ,'email_domain' as column_name
from DW.dim_user 



select distinct is_premium collate latin1_general_CS_AS as is_premium ,'Staging' as source
from Staging.dim_user 
union all
select distinct cast( is_premium   as nvarchar),'DW' as source
from DW.dim_user 

select count(distinct is_premium collate latin1_general_CS_AS) as unique_values_count,'Staging' as source ,'is_premium' as column_name
from Staging.dim_user 
union all
select count(distinct is_premium ),'DW' as source ,'is_premium' as column_name
from DW.dim_user 





