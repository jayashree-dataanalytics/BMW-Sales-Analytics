 -- Rank BMW Models
 SELECT
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales,
    RANK() OVER (
        ORDER BY SUM(s.Net_Sales) DESC
    ) AS sales_rank
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY m.Model
ORDER BY sales_rank;

-- Rank Dealers
SELECT
    d.Dealer_Name,
    d.City,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales,
    RANK() OVER (
        ORDER BY SUM(s.Net_Sales) DESC
    ) AS dealer_rank
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY
    d.Dealer_ID,
    d.Dealer_Name,
    d.City
ORDER BY dealer_rank;

-- Rank Cities
SELECT
    City,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales,
    RANK() OVER (
        ORDER BY SUM(s.Net_Sales) DESC
    ) AS city_rank
FROM sales s
GROUP BY City
ORDER BY city_rank;

-- Sales Category Using CASE
SELECT
    Sale_ID,
    Net_Sales,
    CASE
        WHEN Net_Sales >= 20000000 THEN 'High Value'
        WHEN Net_Sales >= 10000000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS sales_category
FROM sales
ORDER BY Net_Sales DESC;

-- Count Sales Categories
SELECT
    CASE
        WHEN Net_Sales >= 20000000 THEN 'High Value'
        WHEN Net_Sales >= 10000000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS sales_category,

    COUNT(*) AS transactions,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales

FROM sales

GROUP BY sales_category

ORDER BY net_sales DESC;

-- Running Total of Sales
SELECT
    Sale_Date,
    Net_Sales,

    SUM(Net_Sales) OVER (
        ORDER BY Sale_Date
    ) AS cumulative_sales

FROM sales

ORDER BY Sale_Date;

-- Monthly Running Total
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

    SUM(net_sales) OVER (
        ORDER BY month
    ) AS cumulative_sales

FROM monthly_sales

ORDER BY month;

-- Top 3 Models
WITH model_sales AS (

    SELECT
        m.Model,
        SUM(s.Net_Sales) AS net_sales

    FROM sales s

    JOIN models m
        ON s.Model_ID = m.Model_ID

    GROUP BY m.Model
),

ranked_models AS (

    SELECT
        Model,
        net_sales,

        RANK() OVER (
            ORDER BY net_sales DESC
        ) AS sales_rank

    FROM model_sales
)

SELECT
    Model,
    net_sales,
    sales_rank

FROM ranked_models

WHERE sales_rank <= 3

ORDER BY sales_rank;

-- What to run
-- ① Model Ranking
SELECT
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales,
    RANK() OVER (
        ORDER BY SUM(s.Net_Sales) DESC
    ) AS sales_rank
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY m.Model
ORDER BY sales_rank;

-- ② Dealer Ranking
SELECT
    d.Dealer_Name,
    d.City,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales,
    RANK() OVER (
        ORDER BY SUM(s.Net_Sales) DESC
    ) AS dealer_rank
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY
    d.Dealer_ID,
    d.Dealer_Name,
    d.City
ORDER BY dealer_rank;

-- ③ Sales Category
SELECT
    CASE
        WHEN Net_Sales >= 20000000 THEN 'High Value'
        WHEN Net_Sales >= 10000000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS sales_category,
    COUNT(*) AS transactions,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY sales_category
ORDER BY net_sales DESC;

-- ④ Running Total
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
    SUM(net_sales) OVER (
        ORDER BY month
    ) AS cumulative_sales
FROM monthly_sales
ORDER BY month;

-- ⑤ Top 3 Models
WITH model_sales AS (
    SELECT
        m.Model,
        SUM(s.Net_Sales) AS net_sales
    FROM sales s
    JOIN models m
        ON s.Model_ID = m.Model_ID
    GROUP BY m.Model
),
ranked_models AS (
    SELECT
        Model,
        net_sales,
        RANK() OVER (
            ORDER BY net_sales DESC
        ) AS sales_rank
    FROM model_sales
)
SELECT
    Model,
    net_sales,
    sales_rank
FROM ranked_models
WHERE sales_rank <= 3
ORDER BY sales_rank;

