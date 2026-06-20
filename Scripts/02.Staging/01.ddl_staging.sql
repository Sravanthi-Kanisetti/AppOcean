USE  Kimball;


--Creating Staging
if object_id('Staging.dim_device','U') is not null 
    drop table Staging.dim_device;
go

CREATE TABLE Staging.dim_device (
    device_key        INT,
    device_type       NVARCHAR(50),
    os_version        NVARCHAR(50),
    manufacturer      NVARCHAR(50),
    screen_size_inch  FLOAT
);
go
 

if object_id('Staging.dim_store_region','U') is not null 
    drop table Staging.dim_store_region;
go

CREATE TABLE Staging.dim_store_region (
    region_key      INT,
    region_name     NVARCHAR(100),
    store_currency  NVARCHAR(10),
    tax_rate_pct    FLOAT
);
go


if object_id('Staging.dim_date','U') is not null 
    drop table Staging.dim_date ;
go

CREATE TABLE Staging.dim_date (
    date_key      INT,
    full_date     NVARCHAR(50),
    day           INT,
    month         INT,
    month_name    NVARCHAR(20),
    quarter       INT,
    year          INT,
    week_of_year  INT,
    day_of_week   NVARCHAR(20),
    is_weekend    NVARCHAR(10)
);
go
 

if object_id('Staging.dim_user','U') is not null 
    drop table Staging.dim_user ;
go

CREATE TABLE Staging.dim_user (
    user_key           INT,
    user_id            NVARCHAR(20),
    gender             NVARCHAR(20),
    age_group          NVARCHAR(20),
    country            NVARCHAR(100),
    city               NVARCHAR(100),
    registration_date  NVARCHAR(50),
    email_domain       NVARCHAR(100),
    is_premium         NVARCHAR(10)  
);
go

if object_id('Staging.dim_app','U') is not null 
    drop table Staging.dim_app ;
go

CREATE TABLE Staging.dim_app (
    app_key         INT,
    app_id          NVARCHAR(20),
    app_name        NVARCHAR(100),
    category        NVARCHAR(100),
    developer       NVARCHAR(100),
    platform        NVARCHAR(50),
    price_usd       FLOAT,
    content_rating  NVARCHAR(20),
    release_year    FLOAT,          
    size_mb         FLOAT
);
go


if object_id('Staging.fact_app_events','U') is not null 
    drop table Staging.fact_app_events ;
go

CREATE TABLE Staging.fact_app_events (
    fact_key         INT,
    date_key         INT,
    app_key          INT,
    user_key         INT,
    device_key       INT,
    region_key       INT,
    event_type       NVARCHAR(50),
    revenue_usd      FLOAT,
    session_minutes  FLOAT,
    rating           FLOAT,
    review_text_len  FLOAT,
    install_source   NVARCHAR(50),
    app_version      NVARCHAR(20),
    discount_pct     FLOAT
);
go

