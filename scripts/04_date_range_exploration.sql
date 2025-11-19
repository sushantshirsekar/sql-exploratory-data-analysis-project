/* =============================================================================
   Date Range Exploration
   =============================================================================
   Purpose:
     • Identify the time boundaries of available sales data.
     • Determine the historical depth for analysis.
     • Examine customer age distribution using birthdate information.
   =============================================================================
*/

-- Determine the first and last order dates and the total span in months
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;



-- Identify the youngest and oldest customers based on birth_date
SELECT
    MIN(birth_date) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS oldest_age,
    MAX(birth_date) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS youngest_age
FROM gold.dim_customers;
