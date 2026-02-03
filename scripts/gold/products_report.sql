CREATE OR ALTER VIEW gold.report_products
AS
  /*
     Product Report 
     Purpose : This report consolidates the key product metrics, behaviors
     Highlights 
       get the product name , category, subcategory and cost 
       segments product into categories like High performers, mid range and low perfomers 
       Aggreagates customer metrics 
           Total orders
           Total sale
           Total qty purchased
           Total customers(unique)
           Lifespan(in months)
           Average selling price
     valuable KPIs
           recency (months since last order )
           average order value 
           average monthly spend
*/

-- baseqry
WITH product_details
AS
(
SELECT p.product_key,product_id,product_name , category, subcategory,cost,
       f.order_number, f.customer_key, f.order_date, f.sales_amount,
       f.quantity
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
)

, prod_aggregate  -- aggregates
AS
(
SELECT product_key,product_id,product_name , category, subcategory,cost,
       count(distinct order_number) tot_orders,
       sum(sales_amount) tot_sales,
       sum(quantity) tot_qty,
       count(distinct customer_key) tot_customers,
       MAX(order_date) last_order_date,
       DATEDIFF(month, MIN(order_date), MAX(order_date)) lifespan ,
       ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)),1) avg_selling_price
FROM product_details
GROUP BY product_key,product_id,product_name , category, subcategory,cost
)

SELECT product_key,product_name , category, subcategory,cost,
       tot_orders total_orders,
       tot_sales total_sales,
       tot_qty total_quantity,
       tot_customers total_customers,
       last_order_date,
       lifespan,
       -- segment product performance 
      CASE WHEN tot_sales > 50000 THEN 'High Performer'
           WHEN tot_sales > 10000 THEN 'Mid Range'
           ELSE 'Low Performer'
       END prod_segment,
       -- KPI recency
       DATEDIFF(month, last_order_date, GETDATE()) recency,
       -- KPI Average Order Revenue
       CASE WHEN tot_orders = 0 THEN 0
            ELSE tot_sales/tot_orders 
       END aor,
       -- KPI Average MonthlyRevenue
       CASE WHEN lifespan = 0 THEN tot_sales
            ELSE tot_sales/lifespan 
       END  avg_monthly_revenue
FROM   prod_aggregate;



select prod_segment, category,aor, avg_monthly_revenue from gold.report_products
order by prod_segment;
