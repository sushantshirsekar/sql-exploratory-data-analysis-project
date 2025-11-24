/* ============================================================================
   Part-to-Whole Analysis
   Purpose:
       - Identify how much each category contributes to total sales.
       - Useful for understanding which product groups drive business impact.

   Method:
       1. Aggregate sales by category.
       2. Calculate total sales across all categories using a window function.
       3. Compute each category’s percentage contribution.
   ============================================================================ */

WITH category_sales AS (
    SELECT 
        p.category,                       -- Product category
        SUM(f.sales_amount) AS total_sales -- Total sales for each category
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key   -- Join product details
    GROUP BY p.category                     -- Group by category level
)

SELECT 
    category,                                -- Category label
    total_sales,                              -- Total sales for this category
    SUM(total_sales) OVER () AS aggregate_sales,  -- Overall total sales
    CONCAT(
        ROUND(
            (total_sales / SUM(total_sales) OVER ()) * 100, 
            2
        ),
        '%'
    ) AS percentage_of_total                 -- Contribution to whole
FROM category_sales
ORDER BY total_sales DESC;                   -- Highest contributors first
