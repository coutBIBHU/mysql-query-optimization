

# Optimizing MySQL Queries with Window Functions and Subqueries

## Technologies Used

* MySQL
* MySQL Workbench

## Project Overview

This project focuses on identifying and optimizing slow-performing SQL queries in a sales database (`sales_db`).
The original queries relied heavily on correlated subqueries and repeated aggregations, which resulted in poor
performance and scalability issues as the dataset grew.

To address these challenges, the queries were redesigned using modern MySQL window functions such as
`RANK()` and `ROW_NUMBER()`. These functions efficiently solve analytical problems like top-N per group
and latest-record-per-group scenarios. Additional performance improvements were achieved through
targeted indexing strategies on key join, filtering, and partition columns. Query optimizations were
validated using `EXPLAIN ANALYZE`.

## Key Optimizations

* Replaced correlated subqueries with window functions
* Used `RANK()` for top-N per group analysis
* Used `ROW_NUMBER()` for retrieving the latest record per group
* Applied indexing to optimize joins and partitioning
* Compared execution plans before and after optimization using `EXPLAIN ANALYZE`

## Data Preparation

Since no source dataset was provided, the data was created independently in the form of CSV files to
simulate real-world data ingestion. These CSV files were imported into MySQL Workbench using the
Table Data Import Wizard.
For completeness, an alternative SQL script using direct `INSERT` statements is also included.

## Files Included

* `Query using CSV file.sql` – Database schema and queries using CSV-imported data
* `Query data insertrion in Database.sql` – Database schema and queries using direct SQL inserts
* `customers.csv`, `products.csv`, `orders.csv`, `order_items.csv` – Sample dataset files
* `Execution_Plan_Comparison.pdf` – Detailed execution plan analysis and performance comparison

## Validation

Query improvements were validated using `EXPLAIN ANALYZE`, confirming:

* Elimination of dependent subqueries
* Reduced execution cost
* Effective index utilization
* Improved scalability and maintainability
