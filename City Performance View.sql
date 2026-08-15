 -- City Performance View
 CREATE VIEW vw_city_performance AS
SELECT
    City,
    SUM(Quantity) AS cars_sold,
    SUM(Revenue) AS revenue,
    SUM(Discount_Amount) AS discount,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY City;

SELECT * FROM vw_city_performance
ORDER BY net_sales DESC;

-- Dealer Performance View
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

SELECT *
FROM vw_dealer_performance
ORDER BY net_sales DESC;

-- Monthly Sales View
CREATE VIEW vw_monthly_sales AS
SELECT
    DATE_TRUNC('month', Sale_Date)::date AS month,
    SUM(Quantity) AS cars_sold,
    SUM(Revenue) AS revenue,
    SUM(Discount_Amount) AS discount,
    SUM(Net_Sales) AS net_sales
FROM sales
GROUP BY DATE_TRUNC('month', Sale_Date);

SELECT *
FROM vw_monthly_sales
ORDER BY month;

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

SELECT *
FROM vw_customer_segment
ORDER BY net_sales DESC;

-- ✅ Final Check
SELECT * FROM vw_bmw_kpis;

SELECT * FROM vw_model_performance;

SELECT * FROM vw_city_performance;

SELECT * FROM vw_dealer_performance;

SELECT * FROM vw_monthly_sales;

SELECT * FROM vw_customer_segment;

