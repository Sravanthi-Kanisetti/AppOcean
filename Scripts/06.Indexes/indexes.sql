use Kimball;

create nonclustered index IX_fact_date_key 
on DW.fact_app_events(date_key);


create nonclustered index IX_fact_app_key 
on DW.fact_app_events(app_key);

create nonclustered index IX_fact_user_key 
on DW.fact_app_events(user_key);


create nonclustered index IX_fact_device_key 
on DW.fact_app_events(device_key);

create nonclustered index IX_fact_region_key 
on DW.fact_app_events(region_key);

create nonclustered index IX_fact_event_type
on DW.fact_app_events(event_type);

