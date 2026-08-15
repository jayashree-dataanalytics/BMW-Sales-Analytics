SELECT COUNT(*) AS total_dealers
FROM dealers;
SELECT COUNT(*) AS total_models
FROM models;

-- Total Revenue
SELECT
    SUM(Revenue) AS total_revenue
FROM sales;


-- Total Net Sales
SELECT
    SUM(Net_Sales) AS total_net_sales
FROM sales;


-- Total Cars Sold
SELECT
    SUM(Quantity) AS total_cars_sold
FROM sales;


-- Total Discount
SELECT
    SUM(Discount_Amount) AS total_discount
FROM sales;


-- Average Discount
SELECT
    ROUND(AVG(Discount_Percent), 2) AS average_discount
FROM sales;


-- Average Selling Price
SELECT
    ROUND(AVG(Unit_Price), 2) AS average_unit_price
FROM sales;

-- Create One KPI Query
SELECT
    COUNT(*) AS total_transactions,
    SUM(Quantity) AS total_cars_sold,
    SUM(Revenue) AS total_revenue,
    SUM(Discount_Amount) AS total_discount,
    SUM(Net_Sales) AS total_net_sales,
    ROUND(AVG(Discount_Percent), 2) AS average_discount,
    ROUND(AVG(Unit_Price), 2) AS average_unit_price
FROM sales;



-- Which BMW models are performing best?

-- We need sales + models.

-- Sales by Model
SELECT
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY m.Model
ORDER BY net_sales DESC;

-- Top 5 Models

SELECT
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY m.Model
ORDER BY net_sales DESC
LIMIT 5;




-- City Analysis

-- Business question:

-- Which cities generate the most sales?

SELECT
    City,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY City
ORDER BY net_sales DESC;

-- Top 5 cities
SELECT
    City,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY City
ORDER BY net_sales DESC
LIMIT 5;

-- Fuel Type Analysis

-- Business question:

-- Which fuel type sells the most?

SELECT
    Fuel_Type,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Fuel_Type
ORDER BY cars_sold DESC;


-- Fuel type percentage

-- This is more advanced and useful for your project.

SELECT
    Fuel_Type,
    SUM(Quantity) AS cars_sold,
    ROUND(
        SUM(Quantity) * 100.0 /
        SUM(SUM(Quantity)) OVER (),
        2
    ) AS sales_percentage
FROM sales
GROUP BY Fuel_Type
ORDER BY sales_percentage DESC;


-- Here we're using a window function:
SUM(SUM(Quantity)) OVER ()



-- Transmission Analysis
SELECT
    Transmission,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Transmission
ORDER BY cars_sold DESC;

-- Customer Segment Analysis

-- Here we need the customers table.

-- Business question:

-- Which customer segment contributes the most sales?
SELECT
    c.Customer_Segment,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY net_sales DESC;


-- Sales Channel Analysis

-- Business question:

-- Are customers buying more through showroom or online?

SELECT
    Sales_Channel,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Sales_Channel
ORDER BY net_sales DESC;

-- Dealer Performance

-- Now we'll use:

-- sales
--   +
-- dealers
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
ORDER BY net_sales DESC;

-- Top 10 dealers
SELECT
    d.Dealer_Name,
    d.City,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY
    d.Dealer_ID,
    d.Dealer_Name,
    d.City
ORDER BY net_sales DESC
LIMIT 10;


-- Monthly Sales Trend

-- This is very important for your dashboard.

-- Business question:

-- How are sales changing month by month?

SELECT
    DATE_TRUNC('month', Sale_Date) AS month,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY month
ORDER BY month;

-- Top 10 Customers

-- Business question:

-- Which customers generate the highest sales?

SELECT
    c.Customer_Name,
    c.Customer_Segment,
    SUM(s.Quantity) AS cars_bought,
    SUM(s.Net_Sales) AS total_spent
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment
ORDER BY total_spent DESC
LIMIT 10;

-- Color Analysis
SELECT
    Color,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Color
ORDER BY cars_sold DESC;


-- Advanced Query: Best Model in Each City

-- Now we're moving toward intermediate SQL.

-- We want:

-- For every city, which BMW model generated the highest sales?

-- First create a ranking:

WITH model_city_sales AS (
    SELECT
        s.City,
        m.Model,
        SUM(s.Net_Sales) AS net_sales
    FROM sales s
    JOIN models m
        ON s.Model_ID = m.Model_ID
    GROUP BY
        s.City,
        m.Model
),

ranked_models AS (
    SELECT
        City,
        Model,
        net_sales,
        RANK() OVER (
            PARTITION BY City
            ORDER BY net_sales DESC
        ) AS rank
    FROM model_city_sales
)

SELECT
    City,
    Model,
    net_sales
FROM ranked_models
WHERE rank = 1
ORDER BY City;


-- Dealer Ranking

-- Let's rank all dealers.

WITH dealer_sales AS (
    SELECT
        d.Dealer_Name,
        d.City,
        SUM(s.Net_Sales) AS net_sales
    FROM sales s
    JOIN dealers d
        ON s.Dealer_ID = d.Dealer_ID
    GROUP BY
        d.Dealer_ID,
        d.Dealer_Name,
        d.City
)

SELECT
    Dealer_Name,
    City,
    net_sales,
    RANK() OVER (
        ORDER BY net_sales DESC
    ) AS dealer_rank
FROM dealer_sales
ORDER BY dealer_rank;

-- Create SQL Views

-- This is where we make your project more professional.

-- Instead of repeatedly writing queries, we'll save important analyses as views.

-- KPI View
CREATE OR REPLACE VIEW vw_sales_kpis AS
SELECT
    COUNT(*) AS total_transactions,
    SUM(Quantity) AS total_cars_sold,
    SUM(Revenue) AS total_revenue,
    SUM(Discount_Amount) AS total_discount,
    SUM(Net_Sales) AS total_net_sales,
    ROUND(AVG(Discount_Percent), 2) AS average_discount,
    ROUND(AVG(Unit_Price), 2) AS average_unit_price
FROM sales;

SELECT *
FROM vw_sales_kpis;

-- Model Performance View
CREATE OR REPLACE VIEW vw_model_performance AS
SELECT
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY m.Model
ORDER BY net_sales DESC;

SELECT *
FROM vw_model_performance;

-- Dealer Performance View
CREATE OR REPLACE VIEW vw_dealer_performance AS
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
ORDER BY net_sales DESC;


SELECT COUNT(*) AS total_sales
FROM sales;

SELECT COUNT(*) AS total_dealers
FROM dealers;

SELECT COUNT(*) AS total_models
FROM models;

SELECT
    COUNT(*) AS total_transactions,
    SUM(Quantity) AS total_cars_sold,
    SUM(Revenue) AS total_revenue,
    SUM(Discount_Amount) AS total_discount,
    SUM(Net_Sales) AS total_net_sales,
    ROUND(AVG(Discount_Percent), 2) AS average_discount,
    ROUND(AVG(Unit_Price), 2) AS average_unit_price
FROM sales;

-- Model Analysis

-- Now we're going to answer our first real business question:

-- Which BMW models are performing best?
SELECT
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY m.Model
ORDER BY net_sales DESC;

-- Top 5 Models
SELECT
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY m.Model
ORDER BY net_sales DESC
LIMIT 5;


-- Sales by City
SELECT
    City,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY City
ORDER BY net_sales DESC;


-- Find Top 5 Cities

SELECT
    City,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY City
ORDER BY net_sales DESC
LIMIT 5;


-- City Sales Percentage
SELECT
    City,
    SUM(Net_Sales) AS net_sales,
    ROUND(
        SUM(Net_Sales) * 100.0 /
        SUM(SUM(Net_Sales)) OVER (),
        2
    ) AS sales_percentage
FROM sales
GROUP BY City
ORDER BY net_sales DESC;

-- Dealer + City Analysis
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
ORDER BY net_sales DESC;

SELECT
    City,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY City
ORDER BY net_sales DESC;

SELECT
    City,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY City
ORDER BY net_sales DESC
LIMIT 5;

SELECT
    City,
    SUM(Net_Sales) AS net_sales,
    ROUND(
        SUM(Net_Sales) * 100.0 /
        SUM(SUM(Net_Sales)) OVER (),
        2
    ) AS sales_percentage
FROM sales
GROUP BY City
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
ORDER BY net_sales DESC;


-- FUEL TYPE ANALYSIS

-- Now we'll answer:

-- Which fuel type is performing best in the BMW sales data?

-- Sales by Fuel Type
SELECT
    Fuel_Type,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Fuel_Type
ORDER BY cars_sold DESC;

-- Fuel Type Sales Percentage

-- Now let's calculate each fuel type's contribution to total cars sold.

SELECT
    Fuel_Type,
    SUM(Quantity) AS cars_sold,
    ROUND(
        SUM(Quantity) * 100.0 /
        SUM(SUM(Quantity)) OVER (),
        2
    ) AS sales_percentage
FROM sales
GROUP BY Fuel_Type
ORDER BY sales_percentage DESC;

-- Fuel Type Revenue Analysis

-- Now let's see which fuel type generates the most revenue.

SELECT
    Fuel_Type,
    SUM(Revenue) AS total_revenue,
    SUM(Discount_Amount) AS total_discount,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Fuel_Type
ORDER BY net_sales DESC;


-- Fuel Type + Model 🔥

-- This is a more useful business analysis.

-- Question:

-- Which BMW models are popular for each fuel type?

-- Run:

SELECT
    s.Fuel_Type,
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY
    s.Fuel_Type,
    m.Model
ORDER BY
    s.Fuel_Type,
    net_sales DESC;


-- Advanced: Best Model for Each Fuel Type

-- Now we'll use a CTE + RANK().

WITH fuel_model_sales AS (

    SELECT
        s.Fuel_Type,
        m.Model,
        SUM(s.Net_Sales) AS net_sales
    FROM sales s
    JOIN models m
        ON s.Model_ID = m.Model_ID
    GROUP BY
        s.Fuel_Type,
        m.Model
),

ranked_models AS (

    SELECT
        Fuel_Type,
        Model,
        net_sales,
        RANK() OVER (
            PARTITION BY Fuel_Type
            ORDER BY net_sales DESC
        ) AS model_rank
    FROM fuel_model_sales
)

SELECT
    Fuel_Type,
    Model,
    net_sales
FROM ranked_models
WHERE model_rank = 1
ORDER BY Fuel_Type;


-- Main analysis
SELECT
    Fuel_Type,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Fuel_Type
ORDER BY cars_sold DESC;


-- Percentage
SELECT
    Fuel_Type,
    SUM(Quantity) AS cars_sold,
    ROUND(
        SUM(Quantity) * 100.0 /
        SUM(SUM(Quantity)) OVER (),
        2
    ) AS sales_percentage
FROM sales
GROUP BY Fuel_Type
ORDER BY sales_percentage DESC;


-- Best model by fuel
WITH fuel_model_sales AS (

    SELECT
        s.Fuel_Type,
        m.Model,
        SUM(s.Net_Sales) AS net_sales
    FROM sales s
    JOIN models m
        ON s.Model_ID = m.Model_ID
    GROUP BY
        s.Fuel_Type,
        m.Model
),

ranked_models AS (

    SELECT
        Fuel_Type,
        Model,
        net_sales,
        RANK() OVER (
            PARTITION BY Fuel_Type
            ORDER BY net_sales DESC
        ) AS model_rank
    FROM fuel_model_sales
)

SELECT
    Fuel_Type,
    Model,
    net_sales
FROM ranked_models
WHERE model_rank = 1
ORDER BY Fuel_Type;

