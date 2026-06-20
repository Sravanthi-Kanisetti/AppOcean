

--------------------------------------------------------------------------------------------
------------------------LOADING CLEANED DATA INTO DW TABLES---------------------------------
--------------------------------------------------------------------------------------------



create or alter procedure DW.load_data as 
begin 
  declare @start_time datetime,@end_time datetime,@batch_start_time datetime,@batch_end_time datetime 
  begin try  
       set @batch_start_time=getdate();
	   print '----------------------------------------------------------'
	   print '----------Loading Cleaned Data----------------------------'
	   print '----------------------------------------------------------'


	   set @start_time=GETDATE();
	   print '>>>>>Deleting Fact Table  DW.fact_app_events-------------';
	   delete from DW.fact_app_events;
	   set @end_time=GETDATE();
	   print '>>>>>Delete Duration'+ cast(datediff(second,@start_time,@end_time) as nvarchar);
	   print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'


	    set @start_time=GETDATE();
		print '>> Deleting Table DW.dim_date';
		delete from Dw.dim_date;
		print '>> Inserting Data Into :Dw.dim_date';
		
		insert into DW.dim_date (
			    date_key  ,
				full_date ,
				day       ,
				month     ,
				month_name,
				quarter   ,
				year      ,
				week_of_year,
				day_of_week ,
				is_weekend   
		)
		
		select date_key,
		convert(date,trim(full_date),105) as full_date,
		day,
		month,
		upper(substring(trim(month_name),1,1))+lower(substring(trim(month_name),2,len(trim(month_name)))) as month_name ,
		quarter,
		year,
		week_of_year,
		upper(substring(trim(day_of_week),1,1))+lower(substring(trim(day_of_week),2,len(trim(day_of_week)))) as day_of_week,
		case 
			when lower(trim(replace(is_weekend,char(13),''))) = 'true' then 1 
			else 0
		end as is_weekend
		from staging.dim_date

		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';


	
		set @start_time=GETDATE();
		print '>> Deleting Table DW.dim_app';
		delete from Dw.dim_app;
		print '>> Inserting Data Into :Dw.dim_app';
		
		insert into DW.dim_app (
			    app_key  ,
				app_id   , 
				app_name ,
				category ,
				developer ,
				platform  ,
				price_usd  ,
				content_rating ,
				release_year  ,          
				size_mb  
		)
		
		select app_key,
		app_id,
		trim(app_name) as app_name,
		trim(category) as category,
		trim(developer) as developer,
		case 
		  when lower(trim(platform)) = 'android' then 'Android'
		  when lower(trim(platform)) = 'ios' then 'iOS'
		  when lower(trim(platform)) = 'both' then 'Both'
		else 'N/A'
		end as platform ,
		round(price_usd,2) as price_usd,
		case 
		   when lower(trim(content_rating))='everyone' then 'Everyone'
		   when content_rating is null then 'Not Rated'
		   else trim(content_rating )
		 end as content_rating ,
		 case 
		   when release_year is null then null
		   else cast(release_year as int) 
		   end as release_year,
		round(size_mb,2) as size_mb
		from Staging.dim_app


		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';



		
		set @start_time=GETDATE();
		print '>> Deleting Table DW.dim_device';
		delete from Dw.dim_device;
		print '>> Inserting Data Into :Dw.dim_device';
		
		insert into DW.dim_device (
		        device_key      ,
				device_type     ,
				os_version      ,
				manufacturer    ,
				screen_size_inch 
		)
		select device_key,
		case 
			when lower(trim(device_type))='pc' then 'PC'
			when lower(trim(device_type))='smartphone' then 'Smartphone'
			when lower(trim(device_type))='smartwatch' then 'Smartwatch'
			when lower(trim(device_type))='tablet' then 'Tablet' 
			else 'Unknown'
		end as device_type,
		case when os_version is null then 'Unknown' 
			 else trim(os_version) 
		end as os_version,
		case when manufacturer is null then 'Unknown' 
			 else trim(manufacturer) 
		end as manufacturer,
		round(screen_size_inch ,2) as screen_size_inch 
		from staging.dim_Device

		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';






	    set @start_time=GETDATE();
		print '>> Deleting Table DW.dim_user';
		delete from Dw.dim_user;
		print '>> Inserting Data Into :Dw.dim_user';
		
		insert into DW.dim_user(
		        user_key    ,
				user_id     ,
				gender      ,
				age_group   ,
				country     ,
				city        ,
				registration_date ,
				email_domain      ,
				is_premium       
		)
		select 
		user_key,
		user_id,
		case 
			  when lower(trim(gender)) in ('male','m') then 'Male'
			  when lower(trim(gender)) in('female','f') then 'Female'
			  when lower(trim(gender)) in ('other','o') then 'Other'
			  else 'Unknown'
		end as gender,
		isnull(trim(replace(replace(trim(age_group),'_','-'),' to ','-')),'Unknown') as age_group,
		trim(country) as country,
		case 
		   when city is null or trim(city)='' or trim(city)='N/A' then 'Unknown'
		   else trim(city)
		end as city,
		convert(date,trim(registration_date),105) as  registration_date,
		case 
		   when email_domain is null then 'Unknown' 
		   else trim(email_domain)
		end as email_domain,
		case 
		   when lower( trim(replace(is_premium,char(13),''))) in ('1','yes') then 1
		   else 0 
		end as is_premium
		from staging.dim_user

		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';


	  


		set @start_time=GETDATE();
		print '>> Deleting Table DW.dim_store_region';
		delete from Dw.dim_store_Region;
		print '>> Inserting Data Into :Dw.dim_store_Region';
		
		insert into DW.dim_store_region(
				region_key    ,
				region_name   ,
				store_currency ,
				tax_rate_pct   
		)
		select 
			region_key,
			trim(region_name) as region_name,
			trim(store_currency) as store_currency,
			round(tax_rate_pct,2) as tax_rate_pct
		from staging.dim_store_Region 

		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';


		set @start_time=GETDATE();
		print '>> Inserting Data Into :Dw.fact_app_events';
		insert into DW.fact_app_events(
			fact_key      ,
			date_key      ,
			app_key       ,
			user_key      ,
			device_key   ,
			region_key   ,
			event_type   ,
			revenue_usd  ,
			session_minutes ,
			rating        ,
			review_text_len ,
			install_source   ,
			app_version      ,
			discount_pct  
		)
		select 
		fact_key,
		date_key,
		app_key,
		user_key,
		device_key,
		region_key,
		isnull(
		   upper(substring(trim(event_type),1,1))+
		   lower(
				  substring(trim(event_type),2,len(trim(event_type)))
				  )
		  ,'Unknown') as  event_type,
		 revenue_usd,
		 round(session_minutes,2) as session_minutes,
		 rating,
		 cast(review_text_len as int) as review_text_len ,
		 isnull(
		   upper(substring(trim(install_source),1,1))+
		   lower(
				  substring(trim(install_source),2,len(trim(install_source)))
				  )
		  ,'Unknown') as  install_source,
		  isnull(trim(app_version),'Unknown') as app_version,
		  case when discount_pct<0 then 0
			  else isnull(discount_pct,0) 
		 end as discount_pct
		 from staging.fact_app_events



		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';

	 


		set @batch_end_time=GETDATE();
		print '===========================================';
		print 'Loading Cleaned Data is Completed';
		print 'Total Load Duration:'+cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar)+' seconds';
		print '==========================================='; 

	end try

	begin catch

		print '===========================================';
		print 'Error Occured During Loading Cleaned Data';
		print 'Error Message: '+error_message();
		print 'Error Number: '+cast(error_number() as nvarchar);
		print 'Error State: '+cast(error_state() as nvarchar);
		print '===========================================';

	end catch
end



exec DW.load_data;
