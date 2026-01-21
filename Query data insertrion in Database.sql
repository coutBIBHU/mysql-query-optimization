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
-- Sample Data Insertion
-- =========================================

INSERT INTO customers VALUES
(1,'Amit','North'),
(2,'Ravi','South'),
(3,'Neha','East'),
(4,'Suman','West'),
(5,'Karan','North');

INSERT INTO products VALUES
(101,'Laptop','Electronics'),
(102,'Mobile','Electronics'),
(103,'Chair','Furniture'),
(104,'Table','Furniture'),
(105,'Headphones','Accessories');

INSERT INTO orders VALUES
(1001,1,'2024-01-10'),
(1002,1,'2024-02-15'),
(1003,2,'2024-01-20'),
(1004,3,'2024-03-05'),
(1005,4,'2024-02-28'),
(1006,5,'2024-03-10');

INSERT INTO order_items VALUES
(1,1001,101,1,60000),
(2,1001,105,2,1500),
(3,1002,102,1,25000),
(4,1003,103,4,2000),
(5,1004,104,2,5000),
(6,1005,101,1,62000),
(7,1006,102,2,24000);

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


