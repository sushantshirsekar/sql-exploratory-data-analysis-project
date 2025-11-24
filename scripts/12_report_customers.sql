/* 
====================================================================
Customer Report
====================================================================
Purpose: 
    - Consolidate key customer metrics and behaviors into a single view.

Highlights: 
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value (AOV)
        - average monthly spend
=====================================================================
*/

CREATE VIEW gold.report_customers AS 

/* -------------------------------------------------------------------
1) Base Query: Retrieves essential customer + transaction fields
------------------------------------------------------------------- */
WITH base_query AS (
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birth_date, GETDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),

/* -------------------------------------------------------------------
2) Customer Aggregations: Summarize transaction metrics per customer
------------------------------------------------------------------- */
customer_metrics AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT product_key) AS total_products,
        SUM(quantity) AS total_quantity,
        SUM(sales_amount) AS total_sales,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_months
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name
),

/* -------------------------------------------------------------------
3) Customer Segmentation: Segment by spending + lifespan
------------------------------------------------------------------- */
customer_segments AS (
    SELECT 
        *,
        CASE
            WHEN total_sales > 5000 AND lifespan_months >= 12 THEN 'VIP'
            WHEN total_sales <= 5000 AND lifespan_months >= 12 THEN 'Regular'
            ELSE 'New'
        END AS customer_category
    FROM customer_metrics
),

/* -------------------------------------------------------------------
4) Age Group Segmentation
------------------------------------------------------------------- */
age_groups AS (
    SELECT 
        cq.*,
        CASE
            WHEN age < 25 THEN 'Under 25'
            WHEN age BETWEEN 25 AND 40 THEN '25–40'
            WHEN age BETWEEN 40 AND 60 THEN '40–60'
            ELSE '60+'
        END AS age_group
    FROM (
        SELECT DISTINCT 
            b.customer_key,
            b.customer_number,
            b.customer_name,
            b.age
        FROM base_query b
    ) cq
),

/* -------------------------------------------------------------------
5) Final Combination: Add KPIs + Segments
------------------------------------------------------------------- */
final_report AS (
    SELECT 
        cm.customer_key,
        cm.customer_number,
        cm.customer_name,
        ag.age,
        ag.age_group,
        cm.total_orders,
        cm.total_products,
        cm.total_quantity,
        cm.total_sales,
        cm.first_order_date,
        cm.last_order_date,
        cm.lifespan_months,

        /* Recency: Months since last order */
        DATEDIFF(MONTH, cm.last_order_date, GETDATE()) AS recency_months,

        /* Average Order Value */
        CASE WHEN cm.total_orders = 0 
            THEN 0
            ELSE ROUND(cm.total_sales * 1.0 / cm.total_orders, 2)
        END AS avg_order_value,

        /* Average Monthly Spend */
        CASE WHEN cm.lifespan_months = 0 
            THEN cm.total_sales
            ELSE ROUND(cm.total_sales * 1.0 / cm.lifespan_months, 2)
        END AS avg_monthly_spend,

        cs.customer_category
    FROM customer_metrics cm
    LEFT JOIN customer_segments cs
        ON cm.customer_key = cs.customer_key
    LEFT JOIN age_groups ag
        ON cm.customer_key = ag.customer_key
)

SELECT * FROM final_report;
