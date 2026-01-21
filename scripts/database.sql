/*
  Name        : database.sql
  Purpose     :  Database and Schema creation 
  Description :  This will create the database "Datawarehouse" after checking for the existense, if already exists , it will DROP the database abd recreate the database 
                  It also creates the schemas bronze, silver and gold under this database

   Caution    :  Please do not run the script before reding the script.  
                 If executed it will drop the existing database and  you will lose all your work.
*/


-- datawarehouse and analytics -project 
use master;
GO

--drop an dreate the datawarehouse database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'datawarehouse')
   BEGIN
        ALTER Database datawarehouse SET SINGLE_USER WITH rollback immediate;
        DROP Database datawarehouse;
    END;
GO

  -- create the database datawarehouse
  
create database datawarehouse;
GO
  
use datawarehouse;
GO
  -- Create schemas
create schema bronze;
GO
create schema silver;
GO
create schema gold;
