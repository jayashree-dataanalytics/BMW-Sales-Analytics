--  MONTHLY SALES ANALYSIS

-- Our business questions:

-- Which month had the highest sales?
-- Which month sold the most cars?
-- How does sales change month-to-month?
-- What is the monthly growth rate?

-- Monthly Sales

-- First, run this:

SELECT
    DATE_TRUNC('month', Sale_Date) AS month,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY month
ORDER BY month;

-- Best Sales Month

-- Now find the highest-sales month:

SELECT
    DATE_TRUNC('month', Sale_Date) AS month,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY month
ORDER BY net_sales DESC
LIMIT 1;


-- Best Month by Cars Sold
SELECT
    DATE_TRUNC('month', Sale_Date) AS month,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY month
ORDER BY cars_sold DESC
LIMIT 1;



-- Monthly Sales Growth

-- Now we're going one level up.

-- We want:

-- Current month's sales vs previous month's sales.

-- Run:

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', Sale_Date) AS month,
        SUM(Net_Sales) AS net_sales
    FROM sales
    GROUP BY month
)

SELECT
    month,
    net_sales,
    LAG(net_sales) OVER (
        ORDER BY month
    ) AS previous_month_sales
FROM monthly_sales
ORDER BY month;


-- Monthly Growth Percentage
WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', Sale_Date) AS month,
        SUM(Net_Sales) AS net_sales
    FROM sales
    GROUP BY month
),

sales_with_previous AS (

    SELECT
        month,
        net_sales,
        LAG(net_sales) OVER (
            ORDER BY month
        ) AS previous_month_sales
    FROM monthly_sales
)

SELECT
    month,
    net_sales,
    previous_month_sales,
    ROUND(
        (
            (net_sales - previous_month_sales)
            / NULLIF(previous_month_sales, 0)
        ) * 100,
        2
    ) AS mom_growth_percentage
FROM sales_with_previous
ORDER BY month;



-- Monthly Sales by Model
SELECT
    DATE_TRUNC('month', s.Sale_Date) AS month,
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY
    month,
    m.Model
ORDER BY
    month,
    net_sales DESC;


-- Best Model Each Month
WITH monthly_model_sales AS (

    SELECT
        DATE_TRUNC('month', s.Sale_Date) AS month,
        m.Model,
        SUM(s.Net_Sales) AS net_sales
    FROM sales s
    JOIN models m
        ON s.Model_ID = m.Model_ID
    GROUP BY
        month,
        m.Model
),

ranked_models AS (

    SELECT
        month,
        Model,
        net_sales,
        RANK() OVER (
            PARTITION BY month
            ORDER BY net_sales DESC
        ) AS model_rank
    FROM monthly_model_sales
)

SELECT
    month,
    Model,
    net_sales
FROM ranked_models
WHERE model_rank = 1
ORDER BY month;

-- What you should run now
-- 1️⃣ Monthly sales
SELECT
    DATE_TRUNC('month', Sale_Date) AS month,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY month
ORDER BY month;

-- 2️⃣ Best month
SELECT
    DATE_TRUNC('month', Sale_Date) AS month,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY month
ORDER BY net_sales DESC
LIMIT 1;

-- 3️⃣ MoM growth
WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', Sale_Date) AS month,
        SUM(Net_Sales) AS net_sales
    FROM sales
    GROUP BY month
),

sales_with_previous AS (

    SELECT
        month,
        net_sales,
        LAG(net_sales) OVER (
            ORDER BY month
        ) AS previous_month_sales
    FROM monthly_sales
)

SELECT
    month,
    net_sales,
    previous_month_sales,
    ROUND(
        (
            (net_sales - previous_month_sales)
            / NULLIF(previous_month_sales, 0)
        ) * 100,
        2
    ) AS mom_growth_percentage
FROM sales_with_previous
ORDER BY month;