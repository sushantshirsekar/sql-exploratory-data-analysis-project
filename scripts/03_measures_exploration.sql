/* =============================================================================
   Measures Exploration
   =============================================================================
   Purpose:
     • Compute core business KPIs.
     • Analyze revenue, order volume, and customer activity.
     • Provide a unified metrics summary for reporting.
   =============================================================================
*/

-- Total revenue
SELECT 
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;


-- Total quantity sold
SELECT 
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;


-- Average product selling price
SELECT 
    AVG(price) AS avg_price
FROM gold.fact_sales;


-- Total number of orders
SELECT 
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;


-- Total number of products
SELECT 
    COUNT(DISTINCT product_key) AS total_products
FROM gold.dim_products;


-- Total number of customers
SELECT 
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers;


-- Customers who placed at least one order
SELECT 
    COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales;


-- Consolidated KPI table
SELECT 'Total Sales' AS metric_name, SUM(sales_amount) AS metric_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_key) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(DISTINCT customer_key) FROM gold.dim_customers;
