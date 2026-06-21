use Kimball;

-------------------------------------------------------------------------------------
------------------------------ANALTYICAL QUERIES-------------------------------------
-------------------------------------------------------------------------------------



----------------------------Marketing Mart-------------------------------------------


-- Marketing Performance & User Funnel Health Dashboard
select 
-----------------------------ACQUISITION KPIs-----------------------------
count(distinct user_key) as total_users,
count(*) as total_events,
sum(case when event_type='Download' then 1 else 0 end) as total_downloads,
sum(case when event_type='Purchase' then 1 else 0 end) as total_purchases,
round(sum(case when event_type='Purchase' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as conversion_rate_pct,
--------------------------------REVENUE KPIs-------------------------------
sum(revenue_usd) as gross_revenue,
round(sum(revenue_usd)*1.0/nullif(count(distinct user_key),0),2) as ARPU,
round(sum(revenue_usd)*1.0/nullif(count(*),0),2) as revenue_per_event,
------------------------ENGAGEMENT KPIs----------------------------------------
round(avg(session_minutes),2) as avg_session_minutes,
------------------------USER MIX KPIs----------------------------------------
round(avg(case when is_premium=1 then 1.0 else 0.0 end )*100,2) as premium_user_pct,
round(cast(sum(case when event_type='Purchase' then 1 else 0 end) as float)/nullif(count(distinct user_key),0),2) as avg_purchases_per_user,
-------------------------RETENTION / CHURN KPIs ---------------------------
sum(case when event_type='Download' then 1 else 0 end) as total_installs,
sum(case when event_type='Uninstall' then 1 else 0 end) as total_uninstalls,
round(sum(case when event_type='Uninstall' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as churn_rate_pct,
-------------------------PRODUCT QUALITY--------------------------------------
round(avg(revenue_usd),2) as avg_revenue_per_event_value 
from
	DW.Marketing_Mart;

	
	
	
	
-- Install Source Performance Analysis
-- Which install source generates the highest conversions, ARPU, and user engagement?
select
	install_source,
	count(*) as total_events ,
	sum(case when event_type = 'Download' then 1 else 0 end) as Downloads,
	sum(case when event_type = 'Purchase' then 1 else 0 end) as total_purchases,
	round(cast(sum(case when event_type = 'Purchase' then 1 else 0 end ) as float)* 100
/ nullif(sum(case when event_type='Download' then 1 else 0 end), 0), 2) as purchase_conversion_rate_pct,
	round(avg(session_minutes), 2) as avg_session_minutes,
	round(sum(revenue_usd)/ nullif(count(distinct user_key), 0), 2) as ARPU,
	round(avg(case when is_premium = 1 then 1.0 else 0.0 end)* 100, 2) as premium_user_pct
from
	DW.Marketing_Mart
group by
	install_source
order by
	purchase_conversion_rate_pct desc;
	




  
-- MoM Revenue Growth by Category
-- Measures month-over-month revenue growth for each app category.
with monthly_revenue as(
select category , year, month, month_name, sum(revenue_usd) as revenue
from DW.Marketing_Mart
group by category, year, month, month_name)
,
	prev_revenue as (
	select
		*,
		lag(revenue) over(partition by category order by year, month) as prev_month_revenue
	from
		monthly_revenue
)
select
	category ,
	year,
	month,
	month_name,
	round(revenue, 2) as revenue_usd,
	round(prev_month_revenue, 2) as prev_month_revenue_usd,
	round((revenue-prev_month_revenue)* 100.0 / nullif(prev_month_revenue, 0), 2) as MoM_growth_pct
from
	prev_revenue
where
	prev_month_revenue is not null
order by
	category,
	year,
	month;




  
-- User Segment Performance Analysis
-- Compares revenue, ARPU, engagement, and purchase behavior across user segments.
select
	gender ,
	age_group,
	case
		when is_premium = 1 then 'Premium'
		else 'Free'
	end as 'Premium/Free',
	count(distinct user_key) as total_users,
	count(*) as total_events,
	round(sum(revenue_usd), 2) as total_revenue,
	round(sum(revenue_usd)/ nullif(count(distinct user_key), 0), 2) as ARPU,
	round(avg(session_minutes), 2) as avg_session_minutes,
	sum(case when event_type = 'Purchase' then 1 else 0 end) as total_purchases ,
	round(cast(sum(case when event_type='Purchase' then 1 else 0 end) as float)/nullif(count(distinct user_key),0),2) as avg_purchases_per_user,
	round(sum(case when event_type = 'Purchase' then 1 else 0 end)* 100.0 / nullif(sum(case when event_type='Download' then 1 else 0 end), 0), 2) as purchase_rate_pct
from
	DW.Marketing_Mart
group by
	gender,
	mm.age_group,
	is_premium
order by
	total_revenue desc;
	
	

	
-- Weekend vs Weekday User Behavior Analysis
-- Compares user engagement and revenue patterns between weekends and weekdays.
select
case when is_weekend=1 then 'Weekend' else 'Weekday' end as day_type ,
event_type,
count(*) as total_events,
round(sum(revenue_usd),2) as total_revenue,
round(avg(revenue_usd),2) as avg_revenue,
round(avg(session_minutes),2) as avg_session_minutes
from DW.Marketing_Mart 
group by is_weekend,event_type 
order by day_type,total_revenue desc;




--------------------------------------Finance Mart------------------------------------------
  

-- Finance KPI Dashboard (Revenue, Tax, Pricing & Business Scale Summary)
select
--------------------REVENUE KPIs---------------------
sum(revenue_usd) as gross_revenue,
round(sum(revenue_usd*(1-tax_rate_pct/100.0)),2) as net_revenue_after_tax,
round(sum(revenue_usd)-sum(revenue_usd*(1-tax_rate_pct/100.0)),2) as total_tax_paid,
-----------------------TRANSACTION KPIs------------------
count(*) as total_events,
sum(case when event_type='Purchase' then 1 else 0 end) as total_purchases,
round(sum(case when event_type='Purchase' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as purchase_conversion_rate_pct,
-----------------------PRICING & DISCOUNT KPIs----------------------
round(avg(case when event_type='Purchase' then price_usd end),2) as avg_selling_price,
round(avg(discount_pct),2) as avg_discount_pct,
round(max(discount_pct),2) as max_discount_pct,
-----------------------USER MIX KPIs----------------
round(avg(case when is_premium=1 then 1.0 else 0.0 end)*100,2) as premium_user_pct,
------------------------CONTEXT KPIs-------------
count(distinct app_name) as total_apps,
count(distinct region_name) as total_regions 
from DW.Finance_Mart  ;





-- Revenue After Tax by Region
-- Evaluates regional profitability after accounting for taxes.
select region_name,store_currency,
round(avg(tax_rate_pct),2) as avg_tax_rate_pct,
round(sum(revenue_usd),2) as gross_revenue,
round(sum(revenue_usd*(1-tax_rate_pct/100.0)),2) as net_revenue_after_tax,
round(sum(revenue_usd)-sum(revenue_usd*(1-tax_rate_pct/100.0)),2) as total_tax_paid,
count(case when event_type='Purchase' then 1 end) as total_purchases
from DW.Finance_Mart  
group by region_name,store_currency 
order by net_revenue_after_tax desc ; 




-- Discount ROI Analysis
-- Evaluates how different discount levels affect purchases, revenue, and discount cost.
select 
case when discount_pct=0 then 'No Discount'
when discount_pct between 1 and 10 then 'Low(1-10%)'
when discount_pct between 11 and 25 then 'Medium(11-25%)'
when discount_pct>25 then 'High(>25%)' 
end as discount_tier,
count(*) as total_events,
sum(case when event_type='Purchase' then 1 else 0 end) as total_purchases,
round(sum(case when event_type='Purchase' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as purchase_conversion_pct,
round(sum(revenue_usd),2) as total_revenue,
round(avg(discount_pct),2) as avg_discount_pct
from DW.Finance_Mart 
group by 
case when discount_pct=0 then 'No Discount'
when discount_pct between 1 and 10 then 'Low(1-10%)'
when discount_pct between 11 and 25 then 'Medium(11-25%)'
when discount_pct>25 then 'High(>25%)' 
end
order by purchase_conversion_pct desc;


	
-- Premium vs Free Revenue Contribution by Region
-- Measures each user type's share of regional revenue.
select region_name,
case when is_premium=1 then 'Premium' else 'Free' end as user_type ,
round(sum(revenue_usd),2) as total_revenue,
round(sum(revenue_usd)*100.0/nullif(sum(sum(revenue_usd)) over(partition by region_name),0),2) as revenue_share_pct_in_region
from DW.Finance_Mart
group by region_name,is_premium 
order by region_name,user_type ;




	
-- Quarterly Revenue Growth by Platform
-- Measures quarter-over-quarter revenue growth across platforms.
with quarterly_data as(
select platform ,year,quarter,sum(revenue_usd)as quarterly_revenue
from Dw.Finance_Mart 
group by platform ,year,quarter)
,trend as(
select *,
lag(quarterly_revenue ) over(partition by platform order by year,quarter) as prev_quarterly_revenue
from quarterly_data )
select platform,year,quarter,
round(quarterly_revenue,2) as quarterly_revenue,
round(prev_quarterly_revenue,2) as prev_quarterly_revenue,
round(quarterly_revenue-prev_quarterly_revenue,2) as qoq_revenue_change,
round((quarterly_revenue-prev_quarterly_revenue)*100/nullif(prev_quarterly_revenue,0),2) as qoq_growth_pct
from trend
order by platform,year,quarter;

	
	
-------------------------------------------------Product Mart----------------------------------------------------

-- Product Intelligence KPI Dashboard (App Quality, Monetization & User Behavior Summary)
select 
--------------------------PRODUCT SALE KPIs------------------
count(*) as total_events,
count(distinct app_name) as total_apps,
count(distinct category) as total_categories,
count(distinct app_version) as total_app_versions,
------------------------QUALITY KPIs---------------------------
round(avg(rating),2) as avg_app_rating,
round(avg(review_text_len),2) as avg_review_length,
-----------------------ENGAGEMENT KPIs------------------------
round(avg(session_minutes),2) as avg_session_minutes,
-----------------------MONETIZATION KPIs-------------------
sum(case when event_type='Purchase' then 1 else 0 end) as total_purchases,
sum(revenue_usd) as total_revenue,
round(sum(revenue_usd)*1.0/nullif(sum(case when event_type='Purchase' then 1 else 0 end),0),2) as revenue_per_purchase,
-------------------------RETENTION/CHURN KPIs------------------------
sum(case when event_type='Uninstall' then 1 else 0 end) as total_uninstalls,
round(sum(case when event_type='Uninstall' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as uninstall_event_rate_pct,
------------------------------COMPATABILITY KPIs----------------------
count(distinct device_type) as total_device_types,
count(distinct os_version) as total_os_versions,
----------------------------USER SEGMENT MIX--------------------------------
round(avg(case when is_premium=1 then 1.0 else 0.0 end )*100,2) as premium_user_pct,
count(distinct age_group) as total_age_groups 
from DW.Product_Mart;




-- App Version Quality Analysis
-- Evaluates user ratings, engagement, reviews, and uninstall rates across app versions.
select app_name,app_version,
count(*) as total_events,
count(case when rating is not null then 1 end) as rated_events, 
round(avg(rating),2) as avg_rating,
round(avg(session_minutes),2) as avg_session_minutes,
round(avg(review_text_len),2) as avg_review_length,
sum(case when event_type='Uninstall' then 1 else 0 end) as uninstalls,
round(sum(case when event_type='Uninstall' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download'  then 1 else 0 end),0),2) as uninstall_rate_pct
from DW.Product_Mart  
where app_version!='Unknown' 
group by app_name,app_version ;



  
-- Device Compatibility Performance Analysis
-- Identifies device and OS combinations with low ratings and high uninstall rates.
select device_type,os_version,
count(*) as total_events,
round(avg(rating),2) as avg_rating,
round(avg(session_minutes),2) as avg_session_minutes,
sum(case when event_type='Uninstall' then 1 else 0 end) as uninstalls,
round(sum(case when event_type='Uninstall' then 1 else 0 end) *100.0/nullif(sum(case when event_type='Download'  then 1 else 0 end),0),2) as uninstall_rate_pct
from DW.Product_Mart 
group by device_type,os_version
order by uninstall_rate_pct desc;	

	


-- Year-End Category Engagement Growth Analysis
-- Tracks engagement growth trends across categories at the end of each year.
with monthly_engagement as (
select category,year,month,avg(session_minutes) as avg_session_minutes
from DW.Product_Mart 
group by category,year,month
),
trend as (
select *,
lag(avg_session_minutes) over(partition by category  order by year,month) as prev_month_engagement 
from monthly_engagement
),
latest_month as (
select *,row_number() over(partition by category,year order by month desc) as rn
from trend)
select category,year,month,round(avg_session_minutes,2) as avg_session_minutes,
round(prev_month_engagement,2) as prev_month_engagement,
round((avg_session_minutes-prev_month_engagement)*100.0/nullif(prev_month_engagement,0),2) as engagement_growth_pct
from latest_month   
where rn=1 and prev_month_engagement is not null
order by engagement_growth_pct desc;



-- Top 3 Apps by Category Performance
-- Ranks the best-performing apps in each category based on ratings and user engagement.
with app_metrics as(
select category,app_name,platform,
round(avg(rating),2) as avg_rating,
round(avg(session_minutes),2) as avg_session_minutes 
from DW.Product_Mart 
where rating is not null 
group by category,app_name,platform
),
ranked_apps as (
select *,rank() over(partition by category order by avg_rating desc,avg_session_minutes desc) as app_rank
from app_metrics
)
select * from ranked_apps 
where app_rank<=3 
order by category,app_rank ;




-----------------------------------------------Regional Mart---------------------------------------------


-- Regional Market Intelligence KPI Dashboard (Revenue, Engagement, Churn & Discount Impact Summary)
select
---------------------------REVENUE KPIs------------------
sum(revenue_usd) as gross_revenue,
round(avg(revenue_usd),2) as avg_revenue_per_event,
round(sum(revenue_usd)*1.0/nullif(count(distinct country),0),2) as revenue_per_country,
-------------------------ENGAGEMENT KPIs---------------------------
count(*) as total_events,
sum(case when event_type='Purchase' then 1 else 0 end) as total_purchases,
round(sum(case when event_type='Purchase' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as purchase_rate_pct,
----------------------------USER MIX KPIs---------------------------
round(avg(case when is_premium=1 then 1.0 else 0.0 end)*100,2) as premium_user_pct,
---------------------------CHURN KPIs-------------------
sum(case when event_type='Download' then 1 else 0 end) as total_downloads,
sum(case when event_type='Uninstall' then 1 else 0 end) as total_uninstalls,
round(sum(case when event_type='Uninstall' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as churn_rate_pct,
--------------------------DISCOUNT IMPACT KPIs---------------------------
round(avg(discount_pct),2) as avg_discount_pct,
round(max(discount_pct),2) as max_discount_pct,
-------------------------GEOGRAPHY COVERAGE------------------------
count(distinct region_name) as total_regions,
count(distinct country) as total_countries 
from DW.Regional_Mart;




-- Regional Revenue and Customer Engagement Analysis
-- Compares revenue, premium adoption, and purchase activity across regions and countries.
select region_name ,country,count(*) as total_events,
round(sum(revenue_usd), 2) as total_revenue,
round(avg(revenue_usd), 2) as avg_revenue,
round(avg(cast(is_premium as float))*100,2) as premium_pct,
sum(case when event_type='Purchase' then 1 else 0 end) as purchases,
round(sum(case when event_type='Purchase' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as purchase_rate_pct
from DW.Regional_Mart 
group by region_name,country 
order by total_revenue desc ;


  

-- Regional User Churn Analysis
-- Measures user loss by comparing uninstalls against downloads across regions.
with regional_events as(
select region_name,country,
sum(case when event_type='Download' then 1 else 0 end) as downloads,
sum(case when event_type='Uninstall' then 1 else 0 end) as uninstalls
from  DW.Regional_Mart
group by region_name,country
)
select *,round(uninstalls*100.0/nullif(downloads,0),2) as churn_rate_pct
from regional_events 
order by churn_rate_pct desc;




-- Regional Discount Impact Analysis
-- Compares customer purchasing behavior and revenue between discounted and non-discounted transactions across regions.
select region_name,
case when discount_pct=0 then 'No Discount' 
else 'Discounted'
end as discount_applied,
count(*) as total_events,
round(avg(discount_pct),2) as avg_discount_pct,
round(sum(revenue_usd),2) as total_revenue,
round(avg(revenue_usd),2) as  avg_revenue,
sum(case when event_type='Purchase' then 1 else 0 end) as total_purchases,
round(sum(case when event_type='Purchase' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as purchase_rate_pct
from DW.Regional_Mart 
group by region_name,
case when discount_pct=0 then 'No Discount' 
else 'Discounted'
end
order by region_name,discount_applied ;




-- Top 3 Revenue-Generating Countries by Region
-- Ranks countries within each region based on total revenue.
with country_revenue as(
select region_name,country,sum(revenue_usd) as total_revenue 
from DW.Regional_Mart 
group by region_name,country
)
,ranked_countries as (
select *,rank() over(partition by region_name order by total_revenue desc) as country_rank
from country_revenue 
)
select region_name,country,round(total_revenue,2) as total_revenue ,country_rank 
from ranked_countries 
where country_rank<=3 
order by region_name,country_rank;



-------------------------------------------------Device Mart--------------------------------------------------

-- Device Analytics KPI Summary Dashboard (Performance, Engagement, Quality, and Retention Overview)
select
-------------------------PERFORMANCE KPIs----------------
sum(revenue_usd) as gross_revenue,
round(avg(revenue_usd),2) as avg_revenue_per_event,
round(sum(revenue_usd)*1.0/nullif(count(distinct app_name),0),2) as revenue_per_app,
----------------------ACTIVITY KPIs----------------
count(*) as total_events,
count(distinct app_name) as total_apps,
count(distinct manufacturer) as total_manufacturers,
count(distinct device_type) as total_device_types,
------------------------ENGAGEMENT KPIs---------------
round(avg(session_minutes),2) as avg_session_minutes,
round(avg(screen_size_inch),2) as avg_screen_size,
------------------------QUALITY KPIs-------------
round(avg(rating),2) as avg_rating,
-------------------------RETENTION/CHURN KPIs------------------
sum(case when event_type='Uninstall' then 1 else 0 end) as total_uninstalls,
sum(case when event_type='Download' then 1 else 0 end) as total_downloads,
round(sum(case when event_type='Uninstall' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as churn_rate_pct,
----------------------PRODUCT MIX KPIs--------------------
round(avg(case when is_premium=1 then 1.0 else 0.0  END )*100,2) as premium_user_pct,
count(distinct age_group) as total_age_groups
from DW.Device_Mart ;



-- Device Manufacturer Performance and Retention Analysis
-- Evaluates user engagement, ratings, revenue, and uninstall behavior across device manufacturers.
select
	manufacturer,
	device_type,
	count(*) as total_events,
	round(avg(rating), 2) as avg_rating,
	round(avg(session_minutes), 2) as avg_session_minutes,
	round(sum(revenue_usd), 2) as total_revenue,
	sum(case when event_type = 'Uninstall' then 1 else 0 end) as uninstalls,
	sum(case when event_type = 'Download' then 1 else 0 end) as downloads,
round(
     sum(case when event_type = 'Uninstall' then 1 else 0 end)* 100.0 /
     nullif(sum(case when event_type = 'Download' then 1 else 0 end), 0)
     , 2) as uninstall_rate_pct
from
	DW.Device_Mart 
group by
	manufacturer,
	device_type
order by
	avg_rating desc,
	avg_session_minutes desc;





-- Device Engagement Growth Snapshot (Latest Month per Year)
-- Tracks month-over-month user engagement growth across device types.
with monthly_engagement as (
select device_type,year,month_name,avg(Session_minutes) as avg_session_minutes,
case month_name 
when 'January' then 1
when 'February' then 2
when 'March' then 3
when 'April' then 4
when 'May' then 5
when 'June' then 6
when 'July' then 7
when 'August' then 8
when 'September' then 9
when 'October' then 10
when 'November' then 11
when 'December' then 12
end
as month_num
from DW.Device_Mart 
where device_type!='Unknown'
group by device_type,year,month_name
)
,trend as(
select *,
lag(avg_session_minutes) over(partition by device_type order by year,month_num) as previous_avg_session_minutes ,
row_number() over(partition by device_type,year order by month_num desc ) as rn
from monthly_engagement
)
select device_type,year,month_name,
round(avg_session_minutes,2) as current_avg_session_minutes,
round(previous_avg_session_minutes,2) as previous_avg_session_minutes,
round((avg_session_minutes-previous_avg_session_minutes)*100.0/nullif(previous_avg_session_minutes,0),2) as engagement_growth_pct 
from trend 
where rn=1 and previous_avg_session_minutes is not null 
order by device_type, year;





-- OS Version Performance and User Retention Analysis
-- Evaluates user engagement, satisfaction, and uninstall behavior across operating system versions.
select os_version,count(* ) as total_events,
round(avg(rating),2) as avg_rating,
round(avg(session_minutes),2) as avg_session_minutes,
sum(case when event_type='Uninstall' then 1 else 0 end) as uninstalls,
sum(case when event_type='Download' then 1 else 0 end) as downloads,
round(sum(case when event_type='Uninstall' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as uninstall_rate_pct 
from DW.Device_Mart 
group by os_version 
order by avg_rating asc ;




-- Top 3 Performing Apps by Device Type
-- Ranks apps within each device type based on user engagement.
with app_engagement as(
select device_type,app_name,
round(avg(rating),2) as avg_rating,
round(avg(session_minutes),2) as avg_session_minutes
from DW.Device_Mart 
where device_type!='Unknown'
group by device_type,app_name),
ranked_apps as (
select *,dense_rank() over(partition by device_type order by avg_session_minutes desc,avg_rating desc,app_name) as app_rank
from app_engagement 
)
select device_type,app_name,avg_session_minutes,avg_rating,app_rank 
from ranked_apps 
where app_rank<=3 
order by device_type,app_rank;



-------------------------------------------Executive Mart----------------------------------------------

-- Executive KPI Dashboard (Business Health Summary)
-- Provides a high-level view of revenue, engagement, conversion, retention, and product quality
select 
-----------------------REVENUE KPIs-----------------------------
sum(revenue_usd) as gross_revenue,
round(sum(revenue_usd)*1.0/nullif(count(*),0),2) as revenue_per_event,
round(sum(revenue_usd)*1.0/nullif(count(distinct app_name),0),2) as avg_revenue_per_app,
------------------------EVENT KPIs--------------------------------
count(*) as total_events,
sum(case when event_type='Download' then 1 else 0 end) as total_downloads,
sum(case when event_type='Purchase' then 1 else 0 end) as total_purchases,
round(sum(case when event_type='Purchase' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as conversion_rate_pct,
-------------------------USER BEHAVIOR KPIs------------------------------
sum(case when event_type='Uninstall' then 1 else 0 end) as total_uninstalls,
round(sum(case when event_type='Uninstall' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as churn_rate_pct,
--------------------------ENGAGEMENT + QUALITY-------------------------
round(avg(rating),2) as avg_app_rating,
round(avg(session_minutes),2)  as avg_session_minutes
from DW.Executive_Mart ;






-- Executive Business Health Trend Dashboard (MoM Analysis)
-- Evaluates revenue growth, user engagement, conversion efficiency, and churn behavior over time
with monthly_kpis as (
select year,quarter,month_name,
case month_name 
when 'January' then 1
when 'February' then 2
when 'March' then 3
when 'April' then 4
when 'May' then 5
when 'June' then 6
when 'July' then 7
when 'August' then 8
when 'September' then 9
when 'October' then 10
when 'November' then 11
when 'December' then 12
end
as month_num,
round(sum(Revenue_usd),2) as revenue,
count(*) as events,
sum(case when event_type='Purchase' then 1 else 0 end) as purchases,
sum(case when event_type='Download' then 1 else 0 end) as downloads,
sum(case when event_type='Uninstall' then 1 else 0 end) as uninstalls,
avg(session_minutes) as avg_session_minutes,
avg(rating) as avg_rating
from DW.Executive_Mart  
group by year,quarter,month_name
),
trend as(
select *,lag(revenue) over(order by year,quarter,month_num) as prev_revenue,
lag(avg_session_minutes) over(order by year,quarter,month_num) as prev_session_minutes 
from monthly_kpis
)
select year,quarter,month_name, revenue,
round((revenue-prev_revenue)*100.0/nullif(prev_revenue,0),2) as revenue_growth_pct,
round(avg_session_minutes,2) as avg_session_minutes,
round((avg_session_minutes-prev_session_minutes)*100.0/nullif(prev_session_minutes,0),2) as engagement_growth_pct,
round(purchases*100.0/nullif(downloads,0),2) as conversion_rate_pct,
round(uninstalls*100.0/nullif(downloads,0),2) as churn_rate_pct 
from trend 
order by year,quarter,month_num;



-- Annual Business Growth & Performance Trend Analysis (YoY)
-- Evaluates revenue, engagement, and conversion evolution over time
with yearly as(
select year,
count(*) as total_events,
round(sum(revenue_usd),2) as revenue,
round(avg(session_minutes),2) as avg_session_minutes,
round(avg(rating),2) as avg_rating,
sum(case when event_type='Purchase' then 1 else 0 end) as purchases
from DW.Executive_Mart 
group by year
)
select year,total_events,avg_rating,
purchases,
revenue as current_revenue,
lag(revenue) over(order by year) as prev_revenue,
round((revenue-lag(revenue) over(order by year))*100.0/nullif(lag(revenue) over(order by year),0),2) as yoy_growth_pct,
avg_session_minutes as current_avg_session_minutes,
lag(avg_session_minutes) over(order by year) as prev_avg_session_minutes,
round((avg_session_minutes-lag(avg_session_minutes) over(order by year))*100.0/nullif(lag(avg_session_minutes) over(order by year),0),2) as engagement_growth_pct
from yearly 
order by year;



-- Regional App Performance Leaderboard (Revenue + Engagement Ranking)
-- Ranks apps within each region using revenue, engagement, and rating signals
with app_region as(
select region_name,app_name,category,platform,
round(sum(revenue_usd),2) as total_revenue,
round(avg(session_minutes),2) as avg_session_minutes,
round(avg(rating),2) as avg_rating
from DW.Executive_Mart 
where region_name!='Unknown' and app_name!='Unknown'
and category!='Unknown' and platform!='Unknown'
group by region_name,app_name,category,platform
),
ranked as(
Select *,dense_rank() over(partition by region_name order by total_revenue desc,avg_session_minutes desc) as revenue_rank 
from app_region 
)
select region_name,app_name,category,platform,
total_revenue, 
avg_rating,avg_session_minutes,revenue_rank 
from ranked 
where revenue_rank<=5 
ORDER BY region_name, revenue_rank;









-- Customer Segment Value Ranking Analysis (Revenue Per Event Based)
-- Ranks demographic and behavioral segments to identify highest revenue contributors
with segment_metrics as(
select 
case when is_premium=1 then 'Premium' else 'Free' end as user_type,
age_group,region_name,gender,
count(*) as total_events,sum(revenue_usd) as total_revenue,
round(sum(revenue_usd)*1.0/nullif(count(*),0),2) as revenue_per_event,
round(avg(session_minutes),2) as avg_session_minutes,
round(avg(rating),2) as avg_rating,
sum(case when event_type='Uninstall' then 1 else 0 end) as uninstalls,
round(sum(case when event_type='Uninstall' then 1 else 0 end)*100.0/nullif(sum(case when event_type='Download' then 1 else 0 end),0),2) as churn_rate_pct
from DW.Executive_Mart 
where age_group!='Unknown' and gender!='Unknown'
group by is_premium,age_group,region_name,gender 
),
ranked as(
select *,dense_rank() over(partition by region_name order by revenue_per_event desc) as segment_rank
from segment_metrics
)
select *
from ranked
where segment_rank<=10 
order by segment_rank;







