-- Gold layer

-- validate - quality check  Customers
  select DISTINCT
	ci.cst_gndr,
    ca.gen,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  -- CRM is the master for Gender info
         ELSE COALESCE(ca.gen,'n/a')
    END new_gen
from silver.crm_cust_info ci
     LEFT JOIN silver.erp_cust_az12 ca
     ON ci.cst_key = ca.cid
     LEFT JOIN silver.erp_loc_a101 la
     ON ci.cst_key = la.cid
order by 1,2

  select cst_id, count(*)
from (
select 
	ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.bdate,
    ca.gen,
    la.cntry
from silver.crm_cust_info ci
     LEFT JOIN silver.erp_cust_az12 ca
     ON ci.cst_key = ca.cid
     LEFT JOIN silver.erp_loc_a101 la
     ON ci.cst_key = la.cid
)a
group by cst_id
having count(*) >1
  

     select DISTINCT gender from gold.dim_customers;

     -- validate - quality check  Products
     select 
        pn.prd_id,
        pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance
     from  silver.crm_prd_info pn
     LEFT JOIN silver.erp_px_cat_g1v2 pc
     ON pn.cat_id = pc.ID
     where prd_end_dt IS NULL  -- filter out all old data

select prd_key, count(*)
from (
select 
        pn.prd_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance
     from  silver.crm_prd_info pn
     LEFT JOIN silver.erp_px_cat_g1v2 pc
     ON pn.cat_id = pc.ID
     where pn.prd_end_dt IS NULL  -- filter out all old data
     )a
     group by prd_key
     having count(*) >1


    -- query check fact table 

     select * from gold.fact_sales f
     LEFT JOIN gold.dim_customers c
     ON c.customer_key = f.customer_key
     LEFT JOIN gold.dim_products p
     ON p.product_key = f.product_key
     WHERE f.customer_key IS NULL
     and f.product_key IS NULL



   
