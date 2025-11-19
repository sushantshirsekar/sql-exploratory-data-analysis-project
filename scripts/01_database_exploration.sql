/* =============================================================================
   Database Exploration
   =============================================================================
   Objective:
     • Inspect the overall structure of the database.
     • Review available tables and column-level metadata.
     • Perform basic structural checks to support further analysis.

   System Views Used:
     • INFORMATION_SCHEMA.TABLES
     • INFORMATION_SCHEMA.COLUMNS
   =============================================================================
*/

-- List all tables available in the current database
SELECT 
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;



-- Inspect column details for a specific table (dim_customers)
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';



-- Explore list of all countries represented in the customer base
SELECT DISTINCT 
    country
FROM gold.dim_customers;



-- View product categorization (main category → sub category → product)
SELECT DISTINCT 
    category, 
    sub_category, 
    product_name
FROM gold.dim_products
ORDER BY 
    category, 
    sub_category, 
    product_name;
