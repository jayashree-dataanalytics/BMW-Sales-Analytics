-- Our business question:

-- Which transmission type generates more BMW sales?

-- Sales by Transmission
SELECT
    Transmission,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Transmission
ORDER BY cars_sold DESC;

-- Transmission Sales Percentage
SELECT
    Transmission,
    SUM(Quantity) AS cars_sold,
    ROUND(
        SUM(Quantity) * 100.0 /
        SUM(SUM(Quantity)) OVER (),
        2
    ) AS sales_percentage
FROM sales
GROUP BY Transmission
ORDER BY sales_percentage DESC;

-- Transmission + Model
SELECT
    s.Transmission,
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY
    s.Transmission,
    m.Model
ORDER BY
    s.Transmission,
    net_sales DESC;

-- Best Model for Each Transmission
WITH transmission_model_sales AS (

    SELECT
        s.Transmission,
        m.Model,
        SUM(s.Net_Sales) AS net_sales
    FROM sales s
    JOIN models m
        ON s.Model_ID = m.Model_ID
    GROUP BY
        s.Transmission,
        m.Model
),

ranked_models AS (

    SELECT
        Transmission,
        Model,
        net_sales,
        RANK() OVER (
            PARTITION BY Transmission
            ORDER BY net_sales DESC
        ) AS model_rank
    FROM transmission_model_sales
)

SELECT
    Transmission,
    Model,
    net_sales
FROM ranked_models
WHERE model_rank = 1
ORDER BY Transmission;

-- Fuel + Transmission Analysis
SELECT
    Fuel_Type,
    Transmission,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY
    Fuel_Type,
    Transmission
ORDER BY cars_sold DESC;

-- Model + Fuel + Transmission
SELECT
    m.Model,
    s.Fuel_Type,
    s.Transmission,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY
    m.Model,
    s.Fuel_Type,
    s.Transmission
ORDER BY net_sales DESC;

-- What you should run now

-- Start with these 3 queries:

SELECT
    Transmission,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY Transmission
ORDER BY cars_sold DESC;


SELECT
    Transmission,
    SUM(Quantity) AS cars_sold,
    ROUND(
        SUM(Quantity) * 100.0 /
        SUM(SUM(Quantity)) OVER (),
        2
    ) AS sales_percentage
FROM sales
GROUP BY Transmission
ORDER BY sales_percentage DESC;




SELECT
    Fuel_Type,
    Transmission,
    SUM(Quantity) AS cars_sold,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY
    Fuel_Type,
    Transmission
ORDER BY cars_sold DESC;
