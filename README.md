# Optimizing MySQL Queries with Window Functions and Subqueries

## Technologies Used
- MySQL
- MySQL Workbench

## Project Overview
This project analyzes and optimizes slow-performing SQL queries in a sales database (`sales_db`).
The original queries relied on correlated subqueries and repeated aggregations, leading to poor
performance and scalability issues.

The queries were optimized using modern MySQL window functions such as `RANK()` and `ROW_NUMBER()`,
along with appropriate indexing strategies. Performance improvements were validated using
`EXPLAIN ANALYZE`.

## Key Optimizations
- Replaced correlated subqueries with window functions
- Used `RANK()` for top-N per group queries
- Used `ROW_NUMBER()` for latest-record-per-group queries
- Applied indexing to optimize joins and partitioning
- Compared execution plans before and after optimization

## Files Included
- `Sales_db.sql` – Complete database setup and optimized queries
- `Execution_Plan_Comparison.pdf` – Detailed performance analysis report

## Validation
Query improvements were validated using `EXPLAIN ANALYZE`, confirming:
- Elimination of dependent subqueries
- Reduced execution cost
- Efficient index utilization
- Improved scalability and maintainability
