/*
  Name        :  ddl_silver_layer.sql
  Purpose     :  Build Siver Layer
  Description :  This will re-build the Siver layer table structure , 
                 if already exists , it will DROP the table and recreate it everytime the script is executed. 
                 Now this table structure includes a new meta data column  dwh_create_date  

   Caution    :  Please do not run the script before reading the script.  
                 If executed it will drop the existing tables in Silver Layer and  you will lose all your work.
*/

IF object_id('silver.crm_cust_info','U') IS NOT NULL
drop table silver.crm_cust_info

Create  table silver.crm_cust_info
(
cst_id				int,
cst_key				nvarchar(50),
cst_firstname		nvarchar(50),	
cst_lastname		nvarchar(50),
cst_marital_status	nvarchar(50),
cst_gndr			nvarchar(50),
cst_create_date		date,
dwh_create_date     datetime2 default GETDATE()
);

IF object_id('silver.crm_prd_info','U') IS NOT NULL
drop table silver.crm_prd_info
create table silver.crm_prd_info
(
  prd_id		int,
  cat_id		nvarchar(50),  -- new derived col
  prd_key		nvarchar(50),
  prd_nm		nvarchar(50),
  prd_cost		int,
  prd_line		nvarchar(50),
  prd_start_dt	date,
  prd_end_dt	date,
  dwh_create_date     datetime2 default GETDATE()
);

IF object_id('silver.crm_sales_details','U') IS NOT NULL
drop table silver.crm_sales_details
create table silver.crm_sales_details
(
  sls_ord_num		nvarchar(50),
  sls_prd_key		nvarchar(50),
  sls_cust_id		int,
  sls_order_dt		date,  -- changed from int to date 
  sls_ship_dt		date,  -- changed from int to date 
  sls_due_dt		date,  -- changed from int to date 
  sls_sales			int,
  sls_quantity		int,
  sls_price			int,
  dwh_create_date     datetime2 default GETDATE()
);

IF object_id('silver.erp_cust_az12','U') IS NOT NULL
drop table silver.erp_cust_az12
create table silver.erp_cust_az12
(
  CID		nvarchar(50),
  BDATE		date,
  GEN		nvarchar(50),
  dwh_create_date     datetime2 default GETDATE()
);

IF object_id('silver.erp_loc_a101','U') IS NOT NULL
drop table silver.erp_loc_a101
create table silver.erp_loc_a101
(
  CID		nvarchar(50),
  CNTRY		nvarchar(50),
  dwh_create_date     datetime2 default GETDATE()
);

IF object_id('silver.erp_px_cat_g1v2','U') IS NOT NULL
drop table silver.erp_px_cat_g1v2
create table silver.erp_px_cat_g1v2
(
  ID			nvarchar(50), 		 
  CAT			nvarchar(50),
  SUBCAT		nvarchar(50),
  MAINTENANCE	nvarchar(50),
  dwh_create_date     datetime2 default GETDATE()
);
