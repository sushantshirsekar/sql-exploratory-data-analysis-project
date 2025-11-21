/*---------------------------------------------------------------------------
Performance Analysis – Comparing Sales vs Average & Previous Year
---------------------------------------------------------------------------  
Goal:
    Evaluate how each product performs year by year by measuring:
        • Deviation from its own average performance
        • Growth or decline compared to the previous year

Concepts Used:
    - Window functions: LAG(), AVG() OVER()
    - Conditional evaluation using CASE
    - CTE for cleaner structure
---------------------------------------------------------------------------*/

WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        p.product_name
)

SELECT
    order_year,
    product_name,
    current_sales,

    -- Benchmark against average performance
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales 
        - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_from_avg,
    CASE
        WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name)
            THEN 'Above Average'
        WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name)
            THEN 'Below Average'
        ELSE 'At Average'
    END AS avg_performance_flag,

    -- Compare with previous year (YoY)
    LAG(current_sales) OVER (
        PARTITION BY product_name 
        ORDER BY order_year
    ) AS previous_year_sales,
    current_sales 
        - LAG(current_sales) OVER (
            PARTITION BY product_name 
            ORDER BY order_year
        ) AS yoy_difference,
    CASE
        WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)
            THEN 'Increase'
        WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)
            THEN 'Decrease'
        ELSE 'No Change'
    END AS yoy_trend

FROM yearly_product_sales
ORDER BY product_name, order_year;
