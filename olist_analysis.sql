-- ============================================================
-- Olist E-Commerce Analytics — SQL Queries
-- Database: olist_ecommerce (MySQL)
-- ============================================================

-- Query 1: Total revenue + monthly revenue trend
SELECT 
    ROUND(SUM(price), 2) AS Total_Revenue,
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS Months
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m');


-- Query 2: Revenue by product category (English names)
SELECT 
    p.product_category_name_english,
    SUM(oi.price) AS Total_Revenue
FROM order_items AS oi
JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name_english
ORDER BY Total_Revenue DESC;


-- Query 3: Revenue by state
SELECT 
    c.customer_state,
    SUM(oi.price) AS Revenue
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY Revenue DESC;


-- Query 4: Average order value (total revenue / distinct orders)
SELECT 
    (SUM(price)) / COUNT(DISTINCT(order_id)) AS Avg_Order_Value
FROM order_items;


-- Query 5: Top cities/states by number of orders
SELECT 
    c.customer_city,
    c.customer_state,
    COUNT(o.order_id) AS Total_Orders
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_city, c.customer_state
ORDER BY Total_Orders DESC;


-- Query 6: Average delivery time (days between purchase and delivery)
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS Avg_Delivery_Days
FROM orders;


-- Query 7: Count of late deliveries (delivered after estimated date)
SELECT 
    COUNT(order_id) AS Late_Deliveries
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;


-- Query 8a: Average review score (overall)
SELECT 
    AVG(review_score) AS Avg_Review_Score
FROM order_reviews;


-- Query 8b: Average review score by product category
SELECT 
    AVG(orr.review_score) AS Average_Review_Score,
    p.product_category_name_english
FROM order_reviews AS orr
JOIN order_items AS oi
    ON orr.order_id = oi.order_id
JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name_english
ORDER BY Average_Review_Score;


-- Query 9: Delivery status (late vs on-time) vs average review score
SELECT 
    AVG(review_score) AS Avg_Review_Score,
    CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'late'
        ELSE 'on_time'
    END AS delivery_status
FROM order_reviews AS orr
JOIN orders AS o
    ON o.order_id = orr.order_id
GROUP BY
    CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'late'
        ELSE 'on_time'
    END;


-- Query 10: Category ranking by revenue (window function)
SELECT 
    category_totals.product_category_name_english,
    category_totals.category_revenue,
    RANK() OVER (ORDER BY category_totals.category_revenue DESC) AS revenue_rank
FROM (
    SELECT 
        p.product_category_name_english,
        SUM(oi.price) AS category_revenue
    FROM order_items AS oi
    JOIN products AS p
        ON p.product_id = oi.product_id
    GROUP BY p.product_category_name_english
) AS category_totals
ORDER BY revenue_rank;
