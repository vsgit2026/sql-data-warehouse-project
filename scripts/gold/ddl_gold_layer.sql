CREATE VIEW gold.dim_customers
AS
select 
    ROW_NUMBER() OVER(ORDER BY cst_id ) as customer_key,  -- surrogate_key
	ci.cst_id as customer_id,
    ci.cst_key as customer_number,
    ci.cst_firstname as first_name,
    ci.cst_lastname as last_name ,
    la.cntry as country,
    ci.cst_marital_status as marital_status,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  -- CRM is the master for Gender info
         ELSE COALESCE(ca.gen,'n/a')
    END gender,
    ca.bdate as birthdate,
    ci.cst_create_date as create_date
from silver.crm_cust_info ci
     LEFT JOIN silver.erp_cust_az12 ca
     ON ci.cst_key = ca.cid
     LEFT JOIN silver.erp_loc_a101 la
     ON ci.cst_key = la.cid;

    
     CREATE VIEW gold.dim_products
     AS
     select 
        row_number() OVER(ORDER By pn.prd_start_dt , pn.prd_id) as product_key,
        pn.prd_id as product_id,
        pn.prd_key as product_number,
        pn.prd_nm as product_name ,
        pn.cat_id as category_id ,
        pc.cat  as category,
        pc.subcat as subcategory,
        pc.maintenance,
        pn.prd_cost as cost,
        pn.prd_line as product_line,
        pn.prd_start_dt   
     from  silver.crm_prd_info pn
     LEFT JOIN silver.erp_px_cat_g1v2 pc
     ON pn.cat_id = pc.ID
     where prd_end_dt IS NULL  -- filter out all old data


     CREATE VIEW gold.fact_sales
     AS
     select 
        sd.sls_ord_num as order_number,
        pr.product_key,
        cu.customer_key	,
        sd.sls_order_dt as order_date,   
        sd.sls_ship_dt	 as shipping_date,   
        sd.sls_due_dt	as due_date,   
        sd.sls_sales as sales_amount,
        sd.sls_quantity as quantity,
        sd.sls_price as price
     from silver.crm_sales_details sd
     LEFT JOIN  gold.dim_products pr
     ON sd.sls_prd_key = pr.product_number
     LEFT JOIN gold.dim_customers cu
     ON sd.sls_cust_id = cu.customer_id;





  
