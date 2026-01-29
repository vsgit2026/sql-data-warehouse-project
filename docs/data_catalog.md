# Data Dictionery for Gold Layer
the gold layer is the business laevel data representation, structured to support analytical and reprting use cases.
It consists of dimension tables and fact tables for specific business metrics.

1. gold.dim_customers
   Purpose: stores the customer details  enriched with demographic and geographic data
   columns:
   
| column name | data type | description |
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
| --- | --- | --- |




   



