--  6.1 Sales by Customer Segment

-- Business question:

-- Which customer segment generates the most sales?

SELECT
    c.Customer_Segment,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY net_sales DESC;

-- Customer Segment Percentage

-- Now calculate each segment's contribution to total net sales:

SELECT
    c.Customer_Segment,
    SUM(s.Net_Sales) AS net_sales,
    ROUND(
        SUM(s.Net_Sales) * 100.0 /
        SUM(SUM(s.Net_Sales)) OVER (),
        2
    ) AS sales_percentage
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY sales_percentage DESC;

-- Average Spending per Customer

-- Now an important business metric:

-- On average, how much does one customer spend?

SELECT
    ROUND(
        SUM(s.Net_Sales) / COUNT(DISTINCT s.Customer_ID),
        2
    ) AS average_customer_spending
FROM sales s;

-- Repeat Customers

-- Business question:

-- How many customers purchased more than once?

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        Customer_ID
    FROM sales
    GROUP BY Customer_ID
    HAVING COUNT(*) > 1
) AS customer_orders;



-- Top 10 Customers

-- Now identify your highest-value customers:

SELECT
    c.Customer_Name,
    c.Customer_Segment,
    COUNT(s.Sale_ID) AS number_of_purchases,
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

-- Customer Lifetime Value — Basic Version

-- For your synthetic dataset, we can calculate a simple customer value:

SELECT
    c.Customer_Name,
    c.Customer_Segment,
    SUM(s.Net_Sales) AS customer_lifetime_value
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment
ORDER BY customer_lifetime_value DESC
LIMIT 10;



-- Segment + Fuel Type

-- Now combine customer behavior with vehicle preference.

-- Business question:

-- Which fuel type does each customer segment prefer?

SELECT
    c.Customer_Segment,
    s.Fuel_Type,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
GROUP BY
    c.Customer_Segment,
    s.Fuel_Type
ORDER BY
    c.Customer_Segment,
    cars_sold DESC;

-- Your task

-- Segment Performance

SELECT
    c.Customer_Segment,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY net_sales DESC;


-- Average Customer Spending
SELECT
    ROUND(
        SUM(s.Net_Sales) / COUNT(DISTINCT s.Customer_ID),
        2
    ) AS average_customer_spending
FROM sales s;

-- Repeat Customers
SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT Customer_ID
    FROM sales
    GROUP BY Customer_ID
    HAVING COUNT(*) > 1
) AS customer_orders;

-- Top 10 Customers

SELECT
    c.Customer_Name,
    c.Customer_Segment,
    COUNT(s.Sale_ID) AS number_of_purchases,
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

