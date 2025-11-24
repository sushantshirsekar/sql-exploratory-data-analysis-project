/* =============================================================================
   Data Segmentation
   Purpose:
       - Group products into cost ranges.
       - Understand how many products fall into each pricing segment.
       - Useful for price-band analysis, inventory planning, and product strategy.

   Method:
       1. Assign each product to a predefined cost segment.
       2. Count how many products exist per segment.
   ============================================================================ */

WITH product_segments AS (
    SELECT 
        product_key,               -- Unique product identifier
        product_name,              -- Product name
        cost,                      -- Product cost value
        CASE                        -- Categorize cost into defined ranges
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100–500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500–1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)

SELECT
    cost_range,                    -- Cost segment label
    COUNT(product_key) AS total_products   -- Number of products in each segment
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;       -- Highest segment count first
