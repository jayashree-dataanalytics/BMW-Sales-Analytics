 -- Sales by Channel
 SELECT
    Sales_Channel,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Sales_Channel
ORDER BY net_sales DESC;

-- Sales Channel Percentage

-- Now calculate each channel's percentage of total cars sold:

SELECT
    Sales_Channel,
    SUM(Quantity) AS cars_sold,
    ROUND(
        SUM(Quantity) * 100.0 /
        SUM(SUM(Quantity)) OVER (),
        2
    ) AS sales_percentage
FROM sales
GROUP BY Sales_Channel
ORDER BY sales_percentage DESC;


-- Channel + Customer Segment 🔥

-- Business question:

-- Which customer segment prefers which sales channel?

SELECT
    c.Customer_Segment,
    s.Sales_Channel,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
GROUP BY
    c.Customer_Segment,
    s.Sales_Channel
ORDER BY
    c.Customer_Segment,
    net_sales DESC;


-- Channel + Model

-- Now let's see which models perform best through each channel.

SELECT
    s.Sales_Channel,
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY
    s.Sales_Channel,
    m.Model
ORDER BY
    s.Sales_Channel,
    net_sales DESC;


-- Best Model in Each Sales Channel

-- This is an interview-level query using RANK().

WITH channel_model_sales AS (

    SELECT
        s.Sales_Channel,
        m.Model,
        SUM(s.Net_Sales) AS net_sales
    FROM sales s
    JOIN models m
        ON s.Model_ID = m.Model_ID
    GROUP BY
        s.Sales_Channel,
        m.Model
),

ranked_models AS (

    SELECT
        Sales_Channel,
        Model,
        net_sales,
        RANK() OVER (
            PARTITION BY Sales_Channel
            ORDER BY net_sales DESC
        ) AS model_rank
    FROM channel_model_sales
)

SELECT
    Sales_Channel,
    Model,
    net_sales
FROM ranked_models
WHERE model_rank = 1
ORDER BY Sales_Channel;


-- DEALER PERFORMANCE

-- Now we'll analyze your 40 dealers.

-- This is important because your database has a separate dealers table.

-- Business questions:
-- Which dealer sells the most cars?
-- Which dealer generates the highest revenue?
-- Which city has the best dealer?
-- Does dealer rating relate to sales?

-- Dealer Performance

-- Run:

SELECT
    d.Dealer_Name,
    d.City,
    d.Dealer_Rating,
    d.Years_Operating,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY
    d.Dealer_ID,
    d.Dealer_Name,
    d.City,
    d.Dealer_Rating,
    d.Years_Operating
ORDER BY net_sales DESC;

-- Top 10 Dealers
SELECT
    d.Dealer_Name,
    d.City,
    d.Dealer_Rating,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY
    d.Dealer_ID,
    d.Dealer_Name,
    d.City,
    d.Dealer_Rating
ORDER BY net_sales DESC
LIMIT 10;

-- Dealer Rating vs Sales

-- Now let's investigate:

-- Do highly-rated dealers generate more sales?

SELECT
    d.Dealer_Rating,
    COUNT(DISTINCT d.Dealer_ID) AS dealer_count,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY d.Dealer_Rating
ORDER BY d.Dealer_Rating DESC;


-- Dealer Performance by City
SELECT
    d.City,
    COUNT(DISTINCT d.Dealer_ID) AS dealer_count,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY d.City
ORDER BY net_sales DESC;

-- What to run now

-- You don't need to run everything at once.

SELECT
    Sales_Channel,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Sales_Channel
ORDER BY net_sales DESC;

SELECT
    d.Dealer_Name,
    d.City,
    d.Dealer_Rating,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY
    d.Dealer_ID,
    d.Dealer_Name,
    d.City,
    d.Dealer_Rating
ORDER BY net_sales DESC
LIMIT 10;

SELECT
    d.Dealer_Rating,
    COUNT(DISTINCT d.Dealer_ID) AS dealer_count,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY d.Dealer_Rating
ORDER BY d.Dealer_Rating DESC;


