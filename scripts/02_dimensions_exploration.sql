/* =============================================================================
   Dimension Exploration
   =============================================================================
   Purpose:
     • Explore descriptive entities in the model.
     • Review customer and product-level attributes.
     • Understand segmentation fields used for analytics.
   =============================================================================
*/

-- Countries where customers reside
SELECT DISTINCT 
    country
FROM gold.dim_customers;


-- Product category structure (category → sub-category → product)
SELECT DISTINCT 
    category,
    sub_category,
    product_name
FROM gold.dim_products
ORDER BY 
    category,
    sub_category,
    product_name;


-- Customer demographic extremes: youngest & oldest
SELECT 
    MAX(birth_date) AS youngest_birth_date,
    DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS youngest_age,
    MIN(birth_date) AS oldest_birth_date,
    DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS oldest_age
FROM gold.dim_customers;
