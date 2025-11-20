/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank products and customers based on key performance measures.
    - To identify top-performing and bottom-performing entities.
    - To analyze revenue contribution and order activity.

Key SQL Concepts:
    - Window Functions: RANK(), ROW_NUMBER()
    - TOP clause for limiting results
    - Aggregations with GROUP BY
===============================================================================
*/


---------------------------------------------
-- Top 5 products generating the highest revenue
---------------------------------------------
SELECT TOP 5
    p.product_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS p
    ON p.product_key = fs.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC;


---------------------------------------------
-- Top 5 products using window function ranking
---------------------------------------------
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(fs.sales_amount) AS total_sales,
        RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = fs.product_key
    GROUP BY p.product_name
) t
WHERE rank_products < 6;   -- Same as TOP 5 but more flexible


---------------------------------------------
-- Bottom 5 worst-performing products (by sales)
---------------------------------------------
SELECT TOP 5
    p.product_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS p
    ON p.product_key = fs.product_key
GROUP BY p.product_name
ORDER BY total_sales ASC;   -- Lowest sales first


---------------------------------------------
-- Top 10 customers generating the highest revenue
---------------------------------------------
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = fs.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_sales DESC;


---------------------------------------------
-- 3 customers with the fewest orders (method 1: window function)
---------------------------------------------
SELECT *
FROM (
    SELECT
        c.customer_key,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT fs.order_number) AS total_orders,
        ROW_NUMBER() OVER (
            ORDER BY COUNT(DISTINCT fs.order_number), c.customer_key
        ) AS rank_customers
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers AS c
        ON c.customer_key = fs.customer_key
    GROUP BY 
        c.customer_key,
        c.first_name,
        c.last_name
) t
WHERE rank_customers < 4;


---------------------------------------------
-- 3 customers with the fewest orders (method 2: simple TOP)
---------------------------------------------
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT fs.order_number) AS total_orders
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = fs.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC;
