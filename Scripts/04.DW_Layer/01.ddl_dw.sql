use Kimball;



---------------------------------------------------------------------------
---------------------------CREATING DW TABLES------------------------------
---------------------------------------------------------------------------

if object_id('DW.fact_app_events','U') is not null 
    drop table DW.fact_app_events ;
go

if object_id('DW.dim_date','U') is not null 
    drop table DW.dim_date ;
go

CREATE TABLE DW.dim_date (
    date_key      INT PRIMARY KEY,
    full_date     DATE,
    day           INT,
    month         INT,
    month_name    NVARCHAR(20),
    quarter       INT,
    year          INT,
    week_of_year  INT,
    day_of_week   NVARCHAR(20),
    is_weekend   BIT
);
go



if object_id('DW.dim_app','U') is not null 
    drop table DW.dim_app ;
go

CREATE TABLE DW.dim_app (
    app_key         INT PRIMARY KEY,
    app_id          NVARCHAR(20),
    app_name        NVARCHAR(100),
    category        NVARCHAR(100),
    developer       NVARCHAR(100),
    platform        NVARCHAR(50),
    price_usd       FLOAT,
    content_rating  NVARCHAR(20),
    release_year    INT,          
    size_mb         FLOAT
);
go





if object_id('DW.dim_device','U') is not null 
    drop table DW.dim_device;
go

CREATE TABLE DW.dim_device (
    device_key        INT PRIMARY KEY,
    device_type       NVARCHAR(50),
    os_version        NVARCHAR(50),
    manufacturer      NVARCHAR(50),
    screen_size_inch  FLOAT
);
go
 
 if object_id('DW.dim_user','U') is not null 
    drop table DW.dim_user ;
go

CREATE TABLE DW.dim_user (
    user_key           INT PRIMARY KEY,
    user_id            NVARCHAR(20),
    gender             NVARCHAR(20),
    age_group          NVARCHAR(20),
    country            NVARCHAR(100),
    city               NVARCHAR(100),
    registration_date  DATE,
    email_domain       NVARCHAR(100),
    is_premium         BIT
);
go



if object_id('DW.dim_store_region','U') is not null 
    drop table DW.dim_store_region;
go

CREATE TABLE DW.dim_store_region (
    region_key      INT PRIMARY KEY,
    region_name     NVARCHAR(100),
    store_currency  NVARCHAR(10),
    tax_rate_pct    FLOAT
);
go



CREATE TABLE DW.fact_app_events (
    fact_key         INT PRIMARY KEY ,
    date_key         INT REFERENCES DW.dim_date(date_key),
    app_key          INT REFERENCES DW.dim_app(app_key),
    user_key         INT REFERENCES DW.dim_user(user_key),
    device_key       INT REFERENCES DW.dim_device(device_key),
    region_key       INT REFERENCES DW.dim_store_region(region_key),
    event_type       NVARCHAR(50),
    revenue_usd      FLOAT,
    session_minutes  FLOAT,
    rating           FLOAT,
    review_text_len  INT,
    install_source   NVARCHAR(50),
    app_version      NVARCHAR(20),
    discount_pct     FLOAT
);
go

