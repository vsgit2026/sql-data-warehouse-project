CREATE OR ALTER VIEW gold.report_customers
AS
/*
  Report Name :customers report 
  Purpose : This report consolidates the key customer metrics, behaviors
  Highlights 
     get the customer name , age and transaction details 
     segments customer into categories (VIP, Regular and New), age groups 
     aggreagates customer metrics 
        Total orders 
        Total sale 
        Total qty purchased 
        Total products 
        Lifespan(in months)
    valuable KPIs
        recency (months since last order )
        average order value 
        average monthly spend
*/
-- get the customer name , age and transaction details 
WITH base_qry 
AS
(
SELECT c.customer_key, c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) customer_name ,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) age,
       f.order_number, f.product_key, f.order_date, f.sales_amount,
       f.quantity
FROM   gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON  f.customer_key = c.customer_key
WHERE f.order_date IS NOT NULL
)
-- Aggreagates customer metrics
, cust_aggregate
AS
(
select customer_key, customer_number,
       customer_name , age,
       count(distinct order_number) tot_orders,
       sum(sales_amount) tot_sales,
       sum(distinct  product_key) tot_products,
       sum(quantity) tot_qty,
       max(order_date) last_order_date,
       datediff(month, min(order_date), max(order_date)) lifespan
from   base_qry 
group by customer_key, customer_number,
       customer_name , age
)
-- segments customer into categories (VIP, Regular and New), age groups 

SELECT customer_key, customer_number,
       customer_name , age,
       CASE WHEN age < 20 THEN 'Below 20'
            WHEN age BETWEEN 20 AND 29 THEN '20-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            ELSE 'Above 50'
       END age_grp,
        CASE WHEN tot_sales > 5000  and lifespan >=12 THEN 'VIP'
            WHEN tot_sales < 5000  and lifespan >=12 THEN 'Regular'
       ELSE 'New'
       END cust_segment,
       last_order_date,
       DATEDIFF(month,last_order_date,GETDATE()) recency,  --KPI
       tot_orders,
       tot_sales,
       tot_products,
       tot_qty,
       lifespan,
       -- compute avg order value
       CASE WHEN tot_orders = 0 THEN 0
             ELSE tot_sales/ tot_orders 
       END avo,
       --average monthly spend
        CASE WHEN lifespan = 0 THEN tot_sales
             ELSE tot_sales/lifespan
        END avg_monthly_spend
from cust_aggregate;

-- cust report extract
select cust_segment,age_grp,
count(customer_key) total_customers,
sum(tot_sales) Total_sales
from gold.report_customers
group by cust_segment,age_grp;
