## Advanced Analytics in Data Engineering 
 # change over time
 # analyze sales performance over time

 select year(order_date) order_year, month(order_date) order_month, 
 sum(sales_amount) total_sales ,
 count(distinct customer_key) total_customers,
 sum(quantity) total_quantity
 from gold.fact_sales
 where order_date IS NOT NULL
 group by year(order_date),month(order_date)
 order by year(order_date),month(order_date)


  select datetrunc(month,order_date) order_date,  -- trancate date to the beginning of the month
 sum(sales_amount) total_sales ,
 count(distinct customer_key) total_customers,
 sum(quantity) total_quantity
 from gold.fact_sales
 where order_date IS NOT NULL
 group by datetrunc(month,order_date)
 order by datetrunc(month,order_date)
 

 select FORMAT( order_date,'yyyy-MM') order_date ,  
 sum(sales_amount) total_sales ,
 count(distinct customer_key) total_customers,
 sum(quantity) total_quantity
 from gold.fact_sales
 where order_date IS NOT NULL
 group by FORMAT( order_date,'yyyy-MM')
 order by FORMAT( order_date,'yyyy-MM')


# cumulative analysis 

 -- total sales per month 
 -- running total sales over time 

 select order_date,
        total_sales,
        sum(total_sales) OVER(ORDER BY order_date) running_sales_total
from(
 select datetrunc(month,order_date) order_date , 
 sum(sales_amount) total_sales
 from gold.fact_sales
 where order_date IS NOT NULL
 group by datetrunc(month,order_date) 
 )t

 -- for each year calculate running total
 
 select order_date,
        total_sales,
        sum(total_sales) OVER(PARTITION BY order_date ORDER BY order_date) running_sales_total
from(
 select datetrunc(month,order_date) order_date , 
 sum(sales_amount) total_sales
 from gold.fact_sales
 where order_date IS NOT NULL
 group by datetrunc(month,order_date) 
 )t

 --
  select order_date,
        total_sales,
        sum(total_sales) OVER( ORDER BY order_date) running_sales_total
from(
 select datetrunc(year,order_date) order_date , 
 sum(sales_amount) total_sales
 from gold.fact_sales
 where order_date IS NOT NULL
 group by datetrunc(year,order_date) 
 )t

 -- Performance analysis 
 -- yearly performance of the products by comparing to the 
 -- yearly average sales performance and previous year sales

 WITH yearly_product_sales
 AS
 (select YEAR(f.order_date) order_year,
        p.product_name,
        SUM(f.sales_amount) current_sales
 from gold.fact_sales f
 left join gold.dim_products p
 on f.product_key = p.product_key
 where order_date IS NOT NULL
 group by YEAR(f.order_date) ,
        p.product_name)

SELECT order_year ,product_name, current_sales,
       AVG(current_sales) OVER(PARTITION BY product_name ) avg_sales,
       current_sales - AVG(current_sales) OVER(PARTITION BY product_name ) diff_avg,
       CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name )  <0
                 THEN 'Below AVG'
            WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name )  >0
                 THEN 'Above AVG'
            ELSE 'AVG'
        END avg_chg,
        -- YOY (Tear Over Year ) analysis
       LAG(current_sales) OVER (PARTITION BY product_name  ORDER BY order_year) PY_sales,
       current_sales - LAG(current_sales) OVER (PARTITION BY product_name  ORDER BY order_year) diff_py,
       CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name  ORDER BY order_year) <0
                 THEN 'Decrease'
            WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name  ORDER BY order_year) >0
                 THEN 'Increase'
            ELSE 'No change'
        END py_chg
FROM yearly_product_sales  y



-- Part to whole analysis 
-- which category contributes the most to the overall sales
WITH category_sales 
AS
(select 
        p.category,
        SUM(f.sales_amount) current_sales
 from gold.fact_sales f
 left join gold.dim_products p
 on f.product_key = p.product_key
 where order_date IS NOT NULL
 group by p.category )

SELECT category, current_sales,
      SUM(current_sales) OVER() Overall_cat_sales,
     CONCAT(ROUND(( CAST(current_sales as FLOAT) /SUM(current_sales) OVER() ) *100,2),'%') percent_tot
from category_sales 
order by current_sales desc

-- Data segmentation
-- segment products into cost ranges and count how many products fall into segments
WITH cost_segment
AS
(
SELECT  product_key,product_name,cost,
CASE WHEN cost <100 THEN 'Below 100'
     WHEN cost BETWEEN 100 and 500  THEN '100 - 500'
     WHEN cost BETWEEN 500 and 1000  THEN '500 - 1000'
     ELSE 'Above 1000'
END cost_range
from gold.dim_products
)

SELECT cost_range, count(product_key) total_products
FROM   cost_segment
group by cost_range
order by cost_range desc

