CREATE DATABASE sales_analytics_db;
USE sales_analytics_db;

SELECT * FROM rawsuperstore;

RENAME TABLE sales_analytics_db.`sample - superstore` TO rawsuperstore;

SHOW WARNINGS;

DROP TABLE raw_superstore_sales;


USE sales_analytics_db;

SELECT * FROM raw_superstore_sales LIMIT 10;


SELECT COUNT(*) AS missing_revenue FROM raw_superstore_sales WHERE profit IS NULL;

SELECT COUNT(*) FROM raw_superstore_sales;


CREATE TABLE clean_superstore_sales (
    row_id INT,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(255),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2)
);


INSERT INTO clean_superstore_sales
SELECT
    CAST(`Row ID` AS SIGNED),
    `Order ID`,
    STR_TO_DATE(`Order Date`, '%m/%d/%Y'),
    STR_TO_DATE(`Ship Date`, '%m/%d/%Y'),
    `Ship Mode`,
    `Customer ID`,
    `Customer Name`,
    Segment,
    Country,
    City,
    State,
    `Postal Code`,
    Region,
    Category,
    `Sub-Category`,
    `Product Name`,

    CASE 
        WHEN REPLACE(Sales, ',', '') REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
        THEN CAST(REPLACE(Sales, ',', '') AS DECIMAL(10,2))
        ELSE NULL
    END,

    CASE 
        WHEN Quantity REGEXP '^-?[0-9]+$'
        THEN CAST(Quantity AS SIGNED)
        ELSE NULL
    END,

    CASE 
        WHEN Discount REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
        THEN CAST(Discount AS DECIMAL(5,2))
        ELSE NULL
    END,

    CASE 
        WHEN REPLACE(Profit, ',', '') REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
        THEN CAST(REPLACE(Profit, ',', '') AS DECIMAL(10,2))
        ELSE NULL
    END

FROM raw_superstore_sales;



SELECT * FROM clean_superstore_sales;

SELECT COUNT(*) FROM clean_superstore_sales;


SELECT
    SUM(Sales IS NULL) AS sales_nulls,
    SUM(Quantity IS NULL) AS quantity_nulls,
    SUM(Discount IS NULL) AS discount_nulls,
    SUM(Profit IS NULL) AS profit_nulls
FROM clean_superstore_sales;


SELECT 
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date
FROM clean_superstore_sales;


SELECT
    SUM(order_date IS NULL) AS order_date_nulls,
    SUM(ship_date IS NULL) AS ship_date_nulls,
    SUM(sales IS NULL) AS sales_nulls,
    SUM(profit IS NULL) AS profit_nulls
FROM clean_superstore_sales;

SELECT COUNT(*) AS loss_orders
FROM clean_superstore_sales
WHERE profit < 0;


SELECT *
FROM clean_superstore_sales
WHERE sales IS NULL;


DESCRIBE clean_superstore_sales;

DESCRIBE raw_superstore_sales;


-- CREATE DIMENSION & FACT TABLES
CREATE TABLE dim_customer AS
SELECT DISTINCT
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code
FROM clean_superstore_sales;


CREATE TABLE dim_product AS
SELECT DISTINCT
    product_name,
    category,
    sub_category
FROM clean_superstore_sales;


CREATE TABLE dim_region AS
SELECT DISTINCT
    region
FROM clean_superstore_sales;

CREATE TABLE dim_date AS
SELECT DISTINCT
    order_date,
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    MONTHNAME(order_date) AS month_name,
    QUARTER(order_date) AS quarter
FROM clean_superstore_sales
WHERE order_date IS NOT NULL;

CREATE TABLE fact_sales AS
SELECT
    row_id,
    order_id,
    order_date,
    ship_date,
    customer_id,
    product_name,
    region,
    sales,
    profit,
    quantity,
    discount
FROM clean_superstore_sales
WHERE sales IS NOT NULL;

SELECT COUNT(*) FROM fact_sales;
SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_product;
SELECT COUNT(*) FROM dim_region;
SELECT COUNT(*) FROM dim_date;


SELECT
    d.year,
    p.category,
    SUM(f.sales) AS total_sales
FROM fact_sales f
JOIN dim_product p
    ON f.product_name = p.product_name
JOIN dim_date d
    ON f.order_date = d.order_date
GROUP BY d.year, p.category;



-- KPI QUERIES (SQL EDA)

-- Total Revenue & Profit (Executive KPI)
SELECT
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100, 2) AS profit_margin_pct
FROM clean_superstore_sales
WHERE sales IS NOT NULL;


-- Year-over-Year Sales Growth %
SELECT
    YEAR(order_date) AS year,
    ROUND(SUM(sales), 2) AS yearly_sales,
    ROUND(
        (SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)))
        / LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)) * 100,
    2) AS yoy_growth_pct
FROM clean_superstore_sales
WHERE sales IS NOT NULL
GROUP BY year
ORDER BY year;



-- Top 10 Products by Revenue
SELECT
    product_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM clean_superstore_sales
WHERE sales IS NOT NULL
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;


-- Worst Products (Loss Makers)
SELECT
    product_name,
    ROUND(SUM(profit), 2) AS total_loss
FROM clean_superstore_sales
WHERE profit < 0
GROUP BY product_name
ORDER BY total_loss ASC
LIMIT 10;

-- Regional Performance Analysis
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100, 2) AS profit_margin_pct
FROM clean_superstore_sales
WHERE sales IS NOT NULL
GROUP BY region
ORDER BY total_sales DESC;


-- Category-Level Profitability
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit)/SUM(sales)*100, 2) AS profit_margin_pct
FROM clean_superstore_sales
WHERE sales IS NOT NULL
GROUP BY category;
