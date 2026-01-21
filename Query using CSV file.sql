-- =========================================
-- Database Setup
-- =========================================

CREATE DATABASE sales_db;
USE sales_db;

-- =========================================
-- Table Creation
-- =========================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =========================================
-- Checking the CSV file is imported or not
-- =========================================
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;



-- =========================================
-- Query 1: Top 3 Customers per Region
-- ORIGINAL (Slow) Query + EXPLAIN
-- =========================================

EXPLAIN ANALYZE
SELECT c.region, c.customer_id, SUM(oi.quantity * oi.price) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.region, c.customer_id
HAVING total_sales IN (
    SELECT SUM(oi2.quantity * oi2.price)
    FROM customers c2
    JOIN orders o2 ON c2.customer_id = o2.customer_id
    JOIN order_items oi2 ON o2.order_id = oi2.order_id
    WHERE c2.region = c.region
    GROUP BY c2.customer_id
    ORDER BY SUM(oi2.quantity * oi2.price) DESC
    LIMIT 3
);

-- =========================================
-- Query 2: Latest Order per Customer
-- ORIGINAL (Slow) Query + EXPLAIN
-- =========================================

EXPLAIN ANALYZE
SELECT *
FROM orders o
WHERE order_date = (
    SELECT MAX(order_date)
    FROM orders
    WHERE customer_id = o.customer_id
);

-- =========================================
-- Index Optimization (Performance Improvement)
-- =========================================

CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_customers_region ON customers(region);



SHOW INDEX FROM customers;
SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;

-- =========================================
-- Query 1: Top 3 Customers per Region
-- OPTIMIZED using Window Function (RANK)
-- =========================================

EXPLAIN ANALYZE
WITH customer_sales AS (
    SELECT
        c.region,
        c.customer_id,
        SUM(oi.quantity * oi.price) AS total_sales
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.region, c.customer_id
),
ranked_customers AS (
    SELECT *,
           RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rnk
    FROM customer_sales
)
SELECT region, customer_id, total_sales
FROM ranked_customers
WHERE rnk <= 3;

-- =========================================
-- Query 2: Latest Order per Customer
-- OPTIMIZED using Window Function (ROW_NUMBER)
-- =========================================

EXPLAIN ANALYZE
SELECT order_id, customer_id, order_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC
           ) AS rn
    FROM orders
) t
WHERE rn = 1;
