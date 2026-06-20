--Database Creation
if DB_ID('Kimball') is not null
begin
   drop database kimball;
end
go 

create database kimball;
go

use Kimball;
go 

--Schema Creation
create schema Staging;  --Raw imported data lands here
go
 

create schema DW; --clean dimensional model lives here 
go
