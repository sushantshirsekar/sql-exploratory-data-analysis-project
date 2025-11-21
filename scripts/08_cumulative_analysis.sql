/*---------------------------------------------------------------------------
 Cumulative Analysis – Running Totals & Moving Averages
---------------------------------------------------------------------------  
Goal:
    Build cumulative KPIs such as running totals and rolling averages.
    Helps understand long-term growth and how metrics evolve cumulatively.

Techniques Used:
    - Window functions (SUM OVER, AVG OVER)
    - Time grouping using DATETRUNC()
---------------------------------------------------------------------------*/

-- Running total of sales + moving average of price (yearly buckets)
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_avg_price
FROM (
        SELECT
            DATETRUNC(YEAR, order_date) AS order_date,
            SUM(sales_amount) AS total_sales,
            AVG(price) AS avg_price
        FROM gold.fact_sales
        WHERE order_date IS NOT NULL
        GROUP BY DATETRUNC(YEAR, order_date)
     ) AS yearly_data
ORDER BY order_date;
