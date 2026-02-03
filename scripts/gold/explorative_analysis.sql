/*
    Data Explorative Analysis (EDA)
    Purpose : to understand the data , base queries, data profiling, sample aggregations, sub queries
    This shows the types Explorative Analysis
    1. Data Exploration     -  Explore all objects in the Database
    2. Measure Exploration  -  Explore the aggregations
    3. Magnitude analysis   -  Explore data grouping 
                                 customers by countries
                                 customers by age group
                                 products by categories

*/
-- Explore all objects in the  db
select * from INFORMATION_SCHEMA.TABLES;

-- Explore all columns in the table
select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'dim_customers'

--EXplore Dimensions
select * from silver.erp_loc_a101

select * from gold.dim_customers where country is NULL

select DISTINCT country from gold.dim_customers order by 1

select * from gold.dim_products where category_id  = 'CO_PE'

select * from gold.dim_products where category is  NULL

select DISTINCT category, subcategory,  product_name from gold.dim_products order by 1,2,3

select min(birthdate), max(birthdate) from gold.dim_customers 

-- what is the first and last order 
-- how many years of sales available
select min(order_date) first_order_date , max(order_date)  last_order_date from gold.fact_sales

select datediff(YEAR,min(order_date), max(order_date) ) order_date_range from gold.fact_sales

-- Youngest and oldest customer 
select min(birthdate) oldest_bdate, 
datediff(YEAR, min(birthdate), GETDATE()) oldest_age,  --110
max(birthdate) youngest_bdate ,
datediff(YEAR, max(birthdate), GETDATE()) youngest_age  --40
from gold.dim_customers


-- Measure Exploration

-- Total sales 
select   sum(sales_amount) tot_sales 
from gold.fact_sales
 
 -- No.of items sold 
 select   sum(quantity) items_sold
from gold.fact_sales

-- Average Selling price 
 select   avg(price) avg_selling_price
from gold.fact_sales

-- total no of orders 
 select   count( distinct order_number) total_orders
from gold.fact_sales

-- total no of products
 select   count( product_key) total_products
from gold.dim_products

-- total no of customers
 select   count(customer_key) total_customers
from gold.dim_customers

-- total no of customers placed orders
 select   count(DISTINCT customer_key) total_customers_placed_orders
from gold.fact_sales

-- genrate a report with all metrics 
select  'total_sales' measure_name ,  sum(sales_amount)  measure_value from gold.fact_sales
union all
select  'items_sold' measure_name , sum(quantity)  measure_value from gold.fact_sales
union all
 select  'avg_selling_price' measure_name , avg(price) measure_value from gold.fact_sales
union
 select  'total_orders' measure_name , count( distinct order_number) measure_value from gold.fact_sales
union all
 select  'total_products' measure_name , count( product_key) measure_value from gold.dim_products
union all
select  'total_customers' measure_name , count(customer_key) measure_value from gold.dim_customers
union all
 select  'total_customers_placed_orders' measure_name , count(DISTINCT customer_key) measure_value from gold.fact_sales


-- Magnitude analysis
-- customers by countries
select country, count(customer_key)total_customers
from gold.dim_customers cust
group by country
order by 2 desc

-- customers by gender
select gender, count(customer_key)total_customers
from gold.dim_customers  
group by gender
order by 2 desc

-- products by category 
select category , count(product_key) total_products
from gold.dim_products
group by category
order by 2 desc

-- Average cost of each category 
select category , avg(cost) avg_cat_cost
from gold.dim_products
group by category
order by 2 desc


select * from gold.dim_products where category = 'Accessories' order by category_id

AC_BC

select * from gold.fact_sales where category = 'Accessories' order by category_id


--total revenue for  each category 
select category , sum(sales_amount) total_revenue
from gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key 
group by category
order by 2 desc


--total revenue by  each customer
select customer_number , c.customer_key, first_name , last_name ,
sum(sales_amount) total_revenue
from gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key 
group by customer_number , c.customer_key, first_name , last_name 
order by total_revenue desc

-- distribution of sold items across countries
select country,
sum(quantity) items_sold
from gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key 
group by country
order by 2 desc

-- 5 products generating high revenue
select TOP 5 product_name , 
     sum(sales_amount) total_revenue
from gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key 
group by product_name
order by 2 desc

--
select * 
from (
select p.product_name,
     sum(sales_amount) total_revenue,
     row_number() OVER( ORDER BY sum(sales_amount) DESC) product_rank
from gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key 
group by p.product_name
)t
where product_rank <= 5

-- 5 worse performing products 
select TOP 5 product_name , 
     sum(sales_amount) total_revenue
from gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key 
group by product_name
order by 2 
