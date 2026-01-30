# Data Dictionery for Gold Layer
the gold layer is the business laevel data representation, structured to support analytical and reprting use cases.
It consists of dimension tables and fact tables for specific business metrics.

1. gold.dim_customers
   
   Purpose: stores the customer details  enriched with demographic and geographic data
   
   columns:
   
|  column name | data type | description |
| --- | --- | --- |
| customer_key | INT	| Surrogate Key uniquely identfying each customer record in the dimension table |
| customer_id	| INT	| Unique numberic identifier assigned to each customer |
| customer_number	| NVARCHAR(50)	| Alpha numeric identifier representing the customer, used for tracing and referencing |
| first_name	| NVARCHAR(50)	| The customer first name , as recorderdd in the system |
| last_name |	NVARCHAR(50)	| The customer last name or family name |
| country |	NVARCHAR(50)	| The country of residence for the customer ('United States') |
| marital_status |	NVARCHAR(50)	| The marital Status of the customer ('Married', 'Single') |
| gender |	NVARCHAR(50)	| The gender of the customer ('Male', 'Female', 'n/a') |
| birthdate	| DATE	| The date of birth of the customer formatted as YYYY-MM-DD (1971-10-06) |
| create_date |	DATE	| The date and time when the customer record was created in the system|

2. gold.dim_products
   Purpose: stores the productr details enriched with product data

   columns:
   
| column name | data type | description |
| --- | --- | --- |
| product_key	| INT	| Surrogate Key uniquely identfying each product |
| product_id	| INT |	Unique numberic identifier assigned to each product|
| product_number	| NVARCHAR(50)	| A structured alpha numeric code representing the product often used for categorization or inventory |
| product_name 	| NVARCHAR(50)	| Descriptive name of the product including key details such as type, color, size |
| category_id 	| NVARCHAR(50)	| Unique identifier for product category , linking to its high level classification |
| category	| NVARCHAR(50)	| A broader classification of the product , to group related items (bikes) |
| subcategory	| NVARCHAR(50)	| A more detailed classification ogf the product within the category,  such as product type |
| maintenance	| NVARCHAR(50)	| Indicates whether the product requires maintenance |
| cost	| INT	| The cost or base price of the product measured in monetory units |
| product_line	| NVARCHAR(50)	| The specific product line or series to which the product belongs (Road, mountain) |
| prd_start_dt   	| DATE	| The date on which the product became available for sale or use , stored in  YYYY-MM-DD format |




   



