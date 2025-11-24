/* 
==========================================================================
Product Report
==========================================================================
Purpose:
    - Consolidates key product metrics and behaviors into one unified view.

Highlights:
    1. Extracts essential product fields (name, category, subcategory, cost).
    2. Segments products into revenue-based tiers:
           - High Performer
           - Mid Performer
           - Low Performer
    3. Aggregates product-level KPIs:
           - total orders
           - total sales
           - total quantity sold
           - total unique customers
           - lifespan (months between first & last sale)
    4. Calculates additional insights:
           - recency (months since last sale)
           - average order revenue (AOR)
           - average monthly revenue
==========================================================================
*/

CREATE VIEW gold.report_products AS

/* ---------------------------------------------------------------------
1) Base Query: Retrieves core data for each product transaction
--------------------------------------------------------------------- */
WITH base_query AS (
    SELECT
        f.order_number,
        f.customer_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.sub_category,
        p.cost
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    WHERE order_date IS NOT NULL
),

/* ---------------------------------------------------------------------
2) Product Aggregations: Summarize metrics at the product level
--------------------------------------------------------------------- */
product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        sub_category,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity_sold,
        COUNT(DISTINCT customer_key) AS total_customers,
        MIN(order_date) AS first_sale_date,
        MAX(order_date) AS last_sale_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
    FROM base_query
    GROUP BY 
        product_key, product_name, category, sub_category, cost
),

/* ---------------------------------------------------------------------
3) Product Segmentation: Categorize products by sales performance
--------------------------------------------------------------------- */
product_segmentation AS (
    SELECT
        *,
        CASE
            WHEN total_sales > 5000 THEN 'High Performer'
            WHEN total_sales BETWEEN 1000 AND 5000 THEN 'Mid Performer'
            ELSE 'Low Performer'
        END AS performance_segment
    FROM product_aggregations
),

/* ---------------------------------------------------------------------
4) KPI Calculations: Add recency, AOR, monthly revenue
--------------------------------------------------------------------- */
final_metrics AS (
    SELECT
        *,
        -- Months since last sale
        DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency,

        -- Average order revenue
        CASE WHEN total_orders > 0 
             THEN total_sales / total_orders 
             ELSE 0 
        END AS avg_order_revenue,

        -- Average monthly revenue
        CASE WHEN life_span > 0 
             THEN total_sales / life_span 
             ELSE total_sales 
        END AS avg_monthly_revenue
    FROM product_segmentation
)

/* ---------------------------------------------------------------------
5) Final Output View
--------------------------------------------------------------------- */
SELECT *
FROM final_metrics;
