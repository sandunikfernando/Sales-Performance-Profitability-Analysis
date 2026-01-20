# 📊 Sales Performance & Profitability Dashboard

## 📌 Project Overview

This project focuses on analyzing sales performance and profitability using the **Superstore Sales dataset**. The goal is to transform raw sales data into a clean, analysis-ready format using **SQL**, and then build an **interactive Power BI dashboard** to generate business insights.

The project simulates a real-world **data analyst workflow**, starting from raw CSV ingestion to insight-driven reporting.


## 🎯 Business Objectives

* Understand overall sales and profit trends
* Identify profitable and loss-making segments
* Analyze sales performance by region, category, and sub-category
* Detect negative-profit orders that impact business performance
* Support data-driven decision making for management


## 🛠 Tools & Technologies

* **MySQL Workbench** – Data storage, cleaning, transformation, and analysis
* **SQL** – Data cleaning, type conversion, EDA, and business queries
* **Power BI** – Data visualization and dashboard creation
* **CSV Dataset** – Superstore Sales data


## 📂 Dataset Description

The dataset contains historical sales transactions with the following key attributes:

* Order and shipping details
* Customer and regional information
* Product category and sub-category
* Sales, quantity, discount, and profit values

Initially, all columns were imported as TEXT to prevent data loss and parsing errors.


## 🔄 Data Import Strategy (Why TEXT First?)

During CSV import, all columns were set to **TEXT** because:

* Dates were in mixed formats
* Numeric columns contained commas and invalid values
* Prevented MySQL import failures
* Allowed full control during cleaning



## 🧹 Data Cleaning & Type Conversion

A cleaned table was created from the raw table using explicit SQL transformations.

### Cleaning Logic Applied

* Converted dates using `STR_TO_DATE()`
* Converted numeric columns using `CAST()` with validation
* Handled invalid values using `CASE WHEN` and `REGEXP`
* Replaced non-numeric values with `NULL`

### Clean Table Schema

* Dates → `DATE`
* Sales & Profit → `DECIMAL(10,2)`
* Quantity → `INT`
* Discount → `DECIMAL(5,2)`

This ensured analysis-ready, reliable data.


## 🔍 Exploratory Data Analysis (EDA)

### Null Value Analysis
Checked missing values in critical columns such as sales, profit, and dates.

### Date Range Validation
Verified minimum and maximum order dates to ensure data completeness.

### Negative Profit Analysis
Identified loss-making orders to highlight areas impacting profitability.



## 🔗 Table Joins – Are They Required?

This project uses a **single-table structure**, so joins are **not compulsory**.

However, in real-world projects:

* Data is often normalized into multiple tables
* Joins are essential for combining customer, sales, and product data

This project demonstrates **cleaning and analysis fundamentals**, while remaining scalable for multi-table designs.



## 📈 Power BI Dashboard Features

* Total Sales, Profit, and Orders KPIs
* Sales & profit trends over time
* Category and sub-category performance
* Regional sales distribution
* Identification of loss-making segments



## 💡 Key Insights

* Certain sub-categories generate high sales but low profit
* Month-to-month variations impact profitability
* A significant number of orders generate negative profit
* Regional performance varies significantly




## 🚀 Skills Demonstrated

* SQL data cleaning & transformation
* Handling messy real-world data
* Business-focused EDA
* Power BI dashboard development
* Analytical and problem-solving skills


## 📌 Conclusion
This project demonstrates an end-to-end data analytics workflow, from raw data ingestion to business insight generation.
