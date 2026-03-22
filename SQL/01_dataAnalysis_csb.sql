select * from customer LIMIT 20

-- total revenue generated M vs F

SELECT gender, SUM(purchase_amount) AS revenue
FROM customer
GROUP BY gender

-- used discount but still spent more than the avg purchase amt

SELECT customer_id, purchase_amount 
FROM customer
WHERE discount_applied = 'Yes' AND purchase_amount >= (select AVG(purchase_amount) FROM customer)

-- top 5 products with highest avg review rating

SELECT item_purchased, ROUND(avg(review_rating),2) as 'Average Product Rating'
FROM customer
GROUP BY item_purchased
ORDER BY avg(review_rating) DESC
LIMIT 5

-- compare the avg purchase amount b/w std and express shipping

select shipping_type, AVG(purchase_amount)
from customer
WHERE shipping_type in ('Standard', 'Express')
GROUP BY shipping_type

-- do subscribed customers spend more? Compare Avg spend and total revenue b/w subs and non subs

SELECT subscription_status,
COUNT(customer_id) AS total_customers,
ROUND(AVG(purchase_amount),2) AS avg_spend,
ROUND(SUM(purchase_amount),2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue, avg_spend DESC

-- 5 prods with highest percentage of purchases with discount applied

SELECT item_purchased,
ROUND(100 *SUM(
                 CASE 
                 WHEN discount_applied = 'Yes' THEN 1  
                 ELSE 0
             END) / COUNT(*),2) AS discount_rate
from customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- segment customers -> NEW, RETURNING, LOYAL based -> no. of prev purchases, show CNT each segment

WITH customer_type AS (
    SELECT customer_id, previous_purchases,
    CASE 
        WHEN previous_purchases = 1 THEN "New"
        WHEN previous_purchases BETWEEN 2 AND 10 THEN "Returning"
        ELSE 'Loyal'
    END AS customer_segment
FROM customer
)
SELECT customer_segment, COUNT(*) as "Number of Customers"
FROM customer_type
GROUP BY customer_segment

-- top three most purchased products within each category

WITH item_counts AS
(
    SELECT category, item_purchased, COUNT(*) AS total_orders,
    ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(*) DESC
    ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank, category, item_purchased, total_orders
FROM item_counts
WHERE item_counts.item_rank < 4

-- are customer who are repeat buyers (more than 5 purchases) also likely to subsribe?

SELECT subscription_status, count(customer_id) as repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status

-- revenue contribution of each age group

SELECT age_groups, SUM(purchase_amount) as total_revenue
FROM customer
GROUP BY age_groups
ORDER BY total_revenue DESC

-----------------------------------------------------------------------------------------------------