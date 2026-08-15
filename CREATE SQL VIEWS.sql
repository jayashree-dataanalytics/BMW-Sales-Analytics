-- A View is basically a saved SQL query.

-- Instead of writing the same JOIN and aggregation again and again, we save it as a view and later use:

SELECT * FROM view_name;

-- Create KPI View
CREATE OR REPLACE VIEW vw_bmw_kpis AS
SELECT
    COUNT(*) AS total_transactions,
    SUM(Quantity) AS total_cars_sold,
    SUM(Revenue) AS total_revenue,
    SUM(Discount_Amount) AS total_discount,
    SUM(Net_Sales) AS total_net_sales,
    ROUND(AVG(Discount_Percent), 2) AS average_discount,
    ROUND(AVG(Unit_Price), 2) AS average_unit_price
FROM sales;

SELECT * FROM vw_bmw_kpis;


-- Create Model Performance View
CREATE VIEW vw_model_performance AS
SELECT
    m.Model,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Revenue) AS revenue,
    SUM(s.Discount_Amount) AS discount,
    SUM(s.Net_Sales) AS net_sales,
    ROUND(AVG(s.Discount_Percent), 2) AS average_discount
FROM sales s
JOIN models m
    ON s.Model_ID = m.Model_ID
GROUP BY m.Model;

SELECT * FROM vw_model_performance;


-- City View
CREATE VIEW vw_city_performance AS
SELECT
    City,
    SUM(Quantity) AS cars_sold,
    SUM(Revenue) AS revenue,
    SUM(Discount_Amount) AS discount,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY City;

SELECT * FROM vw_city_performance;

-- Dealer View
CREATE VIEW vw_dealer_performance AS
SELECT
    d.Dealer_ID,
    d.Dealer_Name,
    d.City,
    d.State,
    d.Dealer_Rating,
    d.Years_Operating,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Revenue) AS revenue,
    SUM(s.Discount_Amount) AS discount,
    SUM(s.Net_Sales) AS net_sales
FROM sales s
JOIN dealers d
    ON s.Dealer_ID = d.Dealer_ID
GROUP BY
    d.Dealer_ID,
    d.Dealer_Name,
    d.City,
    d.State,
    d.Dealer_Rating,
    d.Years_Operating;

-- Monthly View
CREATE VIEW vw_monthly_sales AS
SELECT
    DATE_TRUNC('month', Sale_Date)::date AS month,
    SUM(Quantity) AS cars_sold,
    SUM(Revenue) AS revenue,
    SUM(Discount_Amount) AS discount,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY DATE_TRUNC('month', Sale_Date);

-- Customer Segment View
CREATE VIEW vw_customer_segment AS
SELECT
    c.Customer_Segment,
    COUNT(DISTINCT c.Customer_ID) AS customers,
    SUM(s.Quantity) AS cars_sold,
    SUM(s.Net_Sales) AS net_sales,
    ROUND(
        SUM(s.Net_Sales) /
        NULLIF(COUNT(DISTINCT c.Customer_ID), 0),
        2
    ) AS average_customer_value
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment;


-- ✅ Finally, check everything
SELECT * FROM vw_bmw_kpis;

SELECT * FROM vw_model_performance;

SELECT * FROM vw_city_performance;

SELECT * FROM vw_dealer_performance;

SELECT * FROM vw_monthly_sales;

SELECT * FROM vw_customer_segment;
