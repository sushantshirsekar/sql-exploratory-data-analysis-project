/*---------------------------------------------------------------------------
 Change Over Time – Trend Analysis
---------------------------------------------------------------------------  
Objective:
    Evaluate how key business metrics behave across time periods.  
    Useful for spotting trends, seasonal patterns, and overall growth/decline.

Core Techniques:
    - Time bucketing using DATEPART(), DATETRUNC()
    - Aggregating KPIs such as revenue, customer count, and units sold
---------------------------------------------------------------------------*/

-- 1. Monthly trend using YEAR() + MONTH()
-- Captures each month as a separate bucket without string formatting overhead
SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS unique_customers,
    SUM(quantity) AS total_units
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY sales_year, sales_month;



-- 2. Monthly trend using DATETRUNC()
-- Ideal when you want a true date object representing the first day of that month
SELECT
    DATETRUNC(MONTH, order_date) AS month_bucket,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS unique_customers,
    SUM(quantity) AS total_units
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY month_bucket;



-- 3. Month labels in "YYYY-MMM" format using FORMAT()
-- Gives a readable month label while still tracking KPIs
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS month_label,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS unique_customers,
    SUM(quantity) AS total_units
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
