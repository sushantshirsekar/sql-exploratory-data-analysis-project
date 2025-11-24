/* =============================================================================
   DATA SEGMENTATION ANALYSIS
   =============================================================================
   This script performs segmentation for:

   1. Product Segmentation
      - Groups products into cost ranges.
      - Useful for price-band analysis, product strategy, and inventory planning.

   2. Customer Segmentation
      - Groups customers by lifespan and spending behavior.
      - Useful for loyalty programs, targeted marketing, and retention analytics.
   ============================================================================= */


/* =============================================================================
   PRODUCT SEGMENTATION
   Purpose:
       - Categorize products into cost ranges.
       - Count how many products fall into each pricing band.
   ============================================================================= */

WITH product_segments AS (
    SELECT 
        product_key,                         -- Unique product identifier
        product_name,                        -- Product name
        cost,                                -- Product cost
        CASE                                  -- Define cost segments
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100–500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500–1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
),

/* =============================================================================
   CUSTOMER SEGMENTATION
   Purpose:
       - Segment customers into VIP, Normal, and New groups.
       - Based on lifespan and total spending.
   Rules:
       - VIP:    lifespan ≥ 12 months AND spending > 5000 EUR
       - Normal: lifespan ≥ 12 months AND spending ≤ 5000 EUR
       - New:    lifespan < 12 months
   ============================================================================= */

customer_segment AS (
    SELECT 
        c.customer_key,                                  -- Customer identifier
        SUM(fs.sales_amount) AS total_spending,          -- Total spending
        MIN(order_date) AS start_date,                   -- First purchase
        MAX(order_date) AS end_date,                     -- Most recent purchase
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = fs.customer_key
    GROUP BY c.customer_key
),

customer_category AS (
    SELECT
        customer_key,
        CASE
            WHEN total_spending > 5000 AND life_span >= 12 THEN 'VIP'
            WHEN total_spending <= 5000 AND life_span >= 12 THEN 'Normal'
            ELSE 'New'
        END AS customer_type
    FROM customer_segment
)

/* =============================================================================
   FINAL OUTPUTS
   - Two result sets:
       1. Product segmentation summary
       2. Customer segmentation summary
   ============================================================================= */

-- Product segmentation result
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- Customer segmentation result
SELECT
    customer_type,
    COUNT(customer_key) AS total_customers
FROM customer_category
GROUP BY customer_type
ORDER BY total_customers DESC;
