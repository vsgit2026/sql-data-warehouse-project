
CREATE OR ALTER PROCEDURE silver.load_silver
AS
/*
  Name        : proc_build_silver_layer.sql
  Purpose     :  Build Silver Layer from bronze layer data 
  Description :  This will re-load the silver layer tables from the bronze layer data on daily basis , 
                 It will first Truncate the table data and load it from the bronze layer after cleansing and enriched data
  Parameters  :  There are no parameters passed for this procedure. It will not return any data set                

   Usage    :  EXEC silver.load_silver

*/
DECLARE 
       @start_time datetime, 
       @end_time datetime,
       @batch_start datetime,
       @batch_end datetime;

BEGIN
     BEGIN TRY
        
        SET @batch_start  = GETDATE();
        PRINT '======================================================================== ';
        PRINT 'Loading Silver Layer ';
        PRINT '======================================================================== ';

        PRINT '------------------------------------------------------------------------';
        PRINT ' Populating tables from CRM Bronze tables data ';
        PRINT '------------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT ' >> truncating table : silver.crm_cust_info ';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT ' >> Inserting data into : silver.crm_cust_info ';
   
        INSERT INTO silver.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        ) 
        SELECT cst_id,
               cst_key,
               TRIM(cst_firstname) as cst_firstname,
               TRIM(cst_lastname) as cst_lastname,
               CASE 
                    WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                    WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                    ELSE 'n/a'
               END cst_marital_status,
               CASE 
                    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                    ELSE 'n/a'
               END  cst_gndr,
               cst_create_date
        FROM
        (
        SELECT *, 
               row_number() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) last_flag 
        FROM Bronze.crm_cust_info 
        WHERE cst_id is NOT NULL)a
        WHERE a.last_flag =1 ;

        SET @end_time = GETDATE();
        PRINT ' >>  silver.crm_cust_info Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR ) + 'seconds';
        PRINT '>> -----------';

        SET @start_time = GETDATE();
        PRINT ' >> truncating table : silver.crm_prd_info ';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT ' >> Inserting data into : silver.crm_prd_info ';

        INSERT INTO silver.crm_prd_info
        (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
        )
        SELECT prd_id,
            REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
            SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
            prd_nm,
            ISNULL(prd_cost,0) as prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END  prd_line,
            CAST(prd_start_dt as DATE) as prd_start_dt,
            DATEADD(day, -1, CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) as DATE)) as prd_end_dt
        FROM   Bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT ' >>  silver.crm_prd_info Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR ) + 'seconds';
        PRINT '>> -----------';

        SET @start_time = GETDATE();
        PRINT ' >> truncating table : silver.crm_sales_details ';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT ' >> Inserting data into : silver.crm_sales_details ';

        INSERT INTO silver.crm_sales_details
        (
            sls_ord_num	,
            sls_prd_key	,
            sls_cust_id	,
            sls_order_dt,  -- changed from int to date 
            sls_ship_dt	,  -- changed from int to date 
            sls_due_dt	,  -- changed from int to date 
            sls_sales,
            sls_quantity,
            sls_price
        )
        select sls_ord_num,
               sls_prd_key,
               sls_cust_id, 
               CASE WHEN (sls_order_dt =0 OR LEN(sls_order_dt) != 8 ) THEN NULL
                    ELSE CAST(CAST(sls_order_dt as VARCHAR) as DATE)
               END sls_order_dt,
               CASE WHEN (sls_ship_dt =0 OR LEN(sls_ship_dt) != 8 ) THEN NULL
                    ELSE CAST(CAST(sls_ship_dt as VARCHAR) as DATE)
               END sls_ship_dt,
               CASE WHEN (sls_due_dt =0 OR LEN(sls_due_dt) != 8 ) THEN NULL
                    ELSE CAST(CAST(sls_due_dt as VARCHAR) as DATE)
               END sls_due_dt,
               CASE WHEN (sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price))
                          THEN sls_quantity * ABS(sls_price)
                    ELSE sls_sales
               END sls_sales,
               sls_quantity,
               CASE WHEN (sls_price IS NULL OR sls_price = 0)
                         THEN  sls_sales /NULLIF( sls_quantity,0)
                    WHEN sls_price <0  
                         THEN ABS(sls_price )
                    ELSE sls_price
               END sls_price
        from bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT ' >>  silver.crm_sales_details Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR ) + 'seconds';
        PRINT '>> -----------';

        SET @start_time = GETDATE();
        PRINT ' >> truncating table : silver.erp_cust_az12 ';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT ' >> Inserting data into : silver.erp_cust_az12 ';

        INSERT INTO silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )
        select 
               CASE  WHEN cid like 'NASA%'   -- invalid cst key vale
                     THEN SUBSTRING(cid,4,LEN(CID)) 
                     ELSE cid
               END as cid,
               CASE WHEN bdate > GETDATE()   -- future bdate
                    THEN NULL 
                    ELSE bdate     
               END as bdate,
               CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                    WHEN UPPER(TRIM(gen)) IN ('M','MALE')    THEN 'Male'
                    ELSE 'n/a'
               END as gen
        from bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT ' >>  silver.erp_cust_az12 Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR ) + 'seconds';
        PRINT '>> -----------';

        SET @start_time = GETDATE();
        PRINT ' >> truncating table : silver.erp_loc_a101 ';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT ' >> Inserting data into : silver.erp_loc_a101 ';

        INSERT INTO silver.erp_loc_a101
        (
            cid,
            cntry
        )
        select  
               REPLACE(cid, '-' ,'') as cid ,
               CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                    WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
                    WHEN TRIM(cntry) IN (NULL,'')  THEN 'n/a'
                    ELSE  TRIM(cntry)
               END cntry
        from bronze.erp_loc_a101 ;
       
        SET @end_time = GETDATE();
        PRINT ' >>  silver.erp_loc_a101 Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR ) + 'seconds';
        PRINT '>> -----------';

        SET @start_time = GETDATE();
        PRINT ' >> truncating table : silver.erp_px_cat_g1v2 ';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT ' >> Inserting data into : silver.erp_px_cat_g1v2 ';

        INSERT INTO silver.erp_px_cat_g1v2
        (
            ID,
            Cat,
            Subcat,
            Maintenance
        )
        select ID,
            Cat,
            Subcat,
            Maintenance
        from bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT ' >>  silver.erp_px_cat_g1v2 Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR ) + 'seconds';
        PRINT '>> -----------';

        SET @batch_end  = GETDATE();
        PRINT ' >>  silver Load Duration : ' + CAST(DATEDIFF(second, @batch_start, @batch_end) AS NVARCHAR ) + 'seconds';
        PRINT '>> ===========';
    END TRY
    BEGIN CATCH
        PRINT 'Error occured during loading the silver layer ';
        PRINT 'Error Message : ' + ERROR_MESSAGE() ;
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR) ;
        PRINT 'Error State : ' + CAST(ERROR_STATE() AS NVARCHAR);

    END CATCH;
END

