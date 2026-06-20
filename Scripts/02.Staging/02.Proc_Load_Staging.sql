
--Inserting records into Staging Tables
create or alter procedure Staging.load_data as 
begin
	declare @start_time datetime,@end_time datetime,@batch_start_time datetime ,@batch_end_time datetime
	begin try
	
	    set @batch_start_time=GETDATE();
		print '===========================================';
		print 'Loading Raw Data';
		print '===========================================';

		set @start_time=GETDATE();
		print '>> Truncating Table Staging.dim_app';
		truncate table Staging.dim_app;
		print '>> Inserting Data Into :Staging.dim_app';
		bulk insert Staging.dim_app
		from 'C:\Users\kanis\App Store Analytics Project\dim_app.csv'
		with(
			firstrow=2,
			fieldterminator=',',
			rowterminator='0x0A',
			tablock
		);
		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';


		set @start_time=GETDATE();
		print '>> Truncating Table Staging.dim_date';
		truncate table Staging.dim_date;
		print '>> Inserting Data Into :Staging.dim_date';
		bulk insert Staging.dim_date
		from 'C:\Users\kanis\App Store Analytics Project\dim_date.csv'
		with(
			firstrow=2,
			fieldterminator=',',
			rowterminator='0x0A',
			tablock
		);
		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';


		set @start_time=GETDATE();
		print '>> Truncating Table Staging.dim_device';
		truncate table Staging.dim_device;
		print '>> Inserting Data Into :Staging.dim_device';
		bulk insert Staging.dim_device
		from 'C:\Users\kanis\App Store Analytics Project\dim_device.csv'
		with(
			firstrow=2,
			fieldterminator=',',
			rowterminator='0x0A',
			tablock
		);
		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';


		set @start_time=GETDATE();
		print '>> Truncating Table Staging.dim_store_region';
		truncate table Staging.dim_store_region;
		print '>> Inserting Data Into :Staging.dim_store_region';
		bulk insert Staging.dim_store_region
		from 'C:\Users\kanis\App Store Analytics Project\dim_store_region.csv'
		with(
			firstrow=2,
			fieldterminator=',',
			rowterminator='0x0A',
			tablock
		);
		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';


		set @start_time=GETDATE();
		print '>> Truncating Table Staging.dim_user';
		truncate table Staging.dim_user;
		print '>> Inserting Data Into :Staging.dim_user';
		bulk insert Staging.dim_user
		from 'C:\Users\kanis\App Store Analytics Project\dim_user.csv'
		with(
			firstrow=2,
			fieldterminator=',',
			rowterminator='0x0A',
			tablock
		);
		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';

		
		set @start_time=GETDATE();
		print '>> Truncating Table Staging.fact_app_events';
		truncate table Staging.fact_app_events;
		print '>> Inserting Data Into :Staging.fact_app_events';
		bulk insert Staging.fact_app_events
		from 'C:\Users\kanis\App Store Analytics Project\fact_app_events (1).csv'
		with(
			firstrow=2,
			fieldterminator=',',
			rowterminator='0x0A',
			tablock
		);
		set @end_time=getdate();
		print 'Load Duration:'+cast(datediff(Second,@start_time,@end_time) as nvarchar)+' seconds';
		print '>>-----------------------------------------';

		set @batch_end_time=GETDATE();
		print '===========================================';
		print 'Loading Raw Data is Completed';
		print 'Total Load Duration:'+cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar)+' seconds';
		print '==========================================='; 

	end try

	begin catch

		print '===========================================';
		print 'Error Occured During Loading Raw Data';
		print 'Error Message: '+error_message();
		print 'Error Number: '+cast(error_number() as nvarchar);
		print 'Error State: '+cast(error_state() as nvarchar);
		print '===========================================';

	end catch
end

exec Staging.load_data;
