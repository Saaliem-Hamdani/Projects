-- Time range between which the orders were placed.
SELECT 
    MIN(order_purchase_timestamp) AS Start_time,
    MAX(order_purchase_timestamp) AS End_time
FROM
    `target-sql-390706.target.orders`
-- End


-- Count the Cities & States of Customers who ordered during the given period.
SELECT 
    COUNT(DISTINCT (c.customer_city)) AS Number_of_Cities,
    COUNT(DISTINCT (c.customer_state)) AS Number_of_States
FROM
    `target-sql-390706.target.customers` AS c
        INNER JOIN
    `target-sql-390706.target.orders` AS o ON c.customer_id = o.customer_id
WHERE
    o.order_purchase_timestamp BETWEEN '2016-09-04 21:15:19' AND '2018-10-17 17:30:18'

-- End


-- Is there a growing trend in the no. of orders placed over the past years?
SELECT 
    year, month, COUNT(DISTINCT x.order_id) AS Number_of_orders
FROM
    (SELECT 
        order_id,
            EXTRACT(YEAR FROM o.order_purchase_timestamp) AS Year,
            EXTRACT(MONTH FROM o.order_purchase_timestamp) AS Month
    FROM
        `target-sql-390706.target.orders` AS o) x
GROUP BY x.Year , x.Month
ORDER BY x.Year , x.Month

-- End

-- Can we see some kind of monthly seasonality in terms of the no. of orders being placed?
SELECT 
    month, COUNT(DISTINCT x.order_id) AS Number_of_orders
FROM
    (SELECT 
        order_id,
            EXTRACT(MONTH FROM o.order_purchase_timestamp) AS Month
    FROM
        `target-sql-390706.target.orders` AS o) x
GROUP BY x.Month
ORDER BY x.Month

-- End

-- During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
SELECT 
    COUNT(DISTINCT y.order_id) AS Number_of_orders, order_timing
FROM
    (SELECT 
        CASE
                WHEN x.hour BETWEEN 0 AND 6 THEN 'Dawn'
                WHEN x.hour BETWEEN 7 AND 12 THEN 'Morning'
                WHEN x.hour BETWEEN 13 AND 18 THEN 'Afternoon'
                WHEN x.hour BETWEEN 19 AND 23 THEN 'Night'
            END AS order_timing,
            x.order_id
    FROM
        (SELECT 
        order_id,
            EXTRACT(HOUR FROM o.order_purchase_timestamp) AS hour
    FROM
        `target-sql-390706.target.orders` AS o) x) y
GROUP BY y.order_timing

-- End

-- Month on month no. of orders placed in each state.
SELECT 
    x.customer_state,
    x.month,
    COUNT(DISTINCT x.order_id) AS Number_of_orders
FROM
    (SELECT 
        c.customer_state,
            o.order_id,
            EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month
    FROM
        `target-sql-390706.target.orders` AS o
    LEFT JOIN `target-sql-390706.target.customers` AS c ON o.customer_id = c.customer_id) x
GROUP BY x.customer_state , x.month
ORDER BY x.customer_state , x.month

-- End

-- How are the customers distributed across all the states?

SELECT 
    customer_state,
    COUNT(DISTINCT customer_id) AS Number_of_customers
FROM
    `target-sql-390706.target.customers`
GROUP BY customer_state
ORDER BY Number_of_customers DESC

-- End

-- Get the % increase in the cost of orders from year 2017 to 2018 including months between January to August.

with Time_Cost as
(
  SELECT 
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS Year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS Month,
    ROUND(SUM(p.payment_value), 2) AS Cost_of_orders
FROM
    `target-sql-390706.target.orders` o
        LEFT JOIN
    `target-sql-390706.target.payments` p ON o.order_id = p.order_id
GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp) , EXTRACT(MONTH FROM o.order_purchase_timestamp)
),

Previous_Cost as
(
  SELECT 
	*,
	lag(Cost_of_orders) over (order by Year,Month) as Previous_month_cost
FROM 
	Time_Cost
WHERE 
	(Year between 2017 and 2018) and (Month between 1 and 8)
ORDER BY Year, Month 
)

SELECT 
    *,
    ROUND(((Cost_of_orders - Previous_month_cost) / Previous_month_cost) * 100,
            2) AS Percentage_increase
FROM
    Previous_Cost

-- End


-- Calculate the Total & Average value of order price for each state.

SELECT 
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS Total_price,
    ROUND(AVG(oi.price), 2) AS Average_price
FROM
    `target-sql-390706.target.order items` oi
        LEFT JOIN
    `target-sql-390706.target.orders` o ON oi.order_id = o.order_id
        LEFT JOIN
    `target-sql-390706.target.customers` c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY c.customer_state

-- End


-- Calculate the Total & Average value of order freight for each state.

SELECT 
    c.customer_state,
    ROUND(SUM(oi.freight_value), 2) AS Total_Freight_value,
    ROUND(AVG(oi.freight_value), 2) AS Average_Freight_value
FROM
    `target-sql-390706.target.order items` oi
        LEFT JOIN
    `target-sql-390706.target.orders` o ON oi.order_id = o.order_id
        LEFT JOIN
    `target-sql-390706.target.customers` c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY c.customer_state

-- End


-- Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
-- Also, calculate the difference (in days) between the estimated & actual delivery date of an order.

SELECT 
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATE_DIFF(order_delivered_customer_date,
            order_purchase_timestamp,
            day) AS time_to_deliver,
    DATE_DIFF(order_estimated_delivery_date,
            order_delivered_customer_date,
            day) AS diff_estimated_delivery
FROM
    `target.orders`
    
-- End


-- Find out the top 5 states with the Highest average freight value.
SELECT 
    c.customer_state,
    ROUND(AVG(oi.freight_value), 2) AS Average_Freight_value
FROM
    `target-sql-390706.target.order items` oi
        LEFT JOIN
    `target-sql-390706.target.orders` o ON oi.order_id = o.order_id
        LEFT JOIN
    `target-sql-390706.target.customers` c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY Average_Freight_value DESC
LIMIT 5

-- End


-- Find out the top 5 states with the lowest average freight value.

SELECT 
    c.customer_state,
    ROUND(AVG(oi.freight_value), 2) AS Average_Freight_value
FROM
    `target-sql-390706.target.order items` oi
        LEFT JOIN
    `target-sql-390706.target.orders` o ON oi.order_id = o.order_id
        LEFT JOIN
    `target-sql-390706.target.customers` c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY Average_Freight_value
LIMIT 5

-- End


-- Find out the top 5 states with the Highest average delivery time.

SELECT 
    c.customer_state,
    ROUND(AVG(DATE_DIFF(order_delivered_customer_date,
                    order_purchase_timestamp,
                    day)),
            2) AS Average_delivery_time
FROM
    target.orders o
        LEFT JOIN
    target.customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY Average_delivery_time DESC
LIMIT 5

-- End



-- Find out the top 5 states with the lowest average delivery time.

SELECT 
    c.customer_state,
    ROUND(AVG(DATE_DIFF(order_delivered_customer_date,
                    order_purchase_timestamp,
                    day)),
            2) AS Average_delivery_time
FROM
    target.orders o
        LEFT JOIN
    target.customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY Average_delivery_time
LIMIT 5

-- End


-- Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.

SELECT 
    c.customer_state,
    ROUND(AVG(DATE_DIFF(order_estimated_delivery_date,
                    order_delivered_customer_date,
                    day)),
            2) AS Duration_Actual_Estimated
FROM
    target.orders o
        LEFT JOIN
    target.customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY Duration_Actual_Estimated DESC
LIMIT 5

-- End


-- Number of order based on payment_type

SELECT 
    payment_type, COUNT(order_id) AS Number_of_orders
FROM
    `target.payments`
GROUP BY payment_type
ORDER BY Number_of_orders DESC

-- End



-- Find the month on month no. of orders placed using different payment types.

SELECT 
    *
FROM
    (SELECT 
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS Month,
            p.payment_type,
            COUNT(o.order_id) AS Number_of_orders
    FROM
        `target.orders` o
    LEFT JOIN `target.payments` p ON o.order_id = p.order_id
    GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp) , p.payment_type)
ORDER BY Month, Number_of_orders

-- End


-- Find the no. of orders placed on the basis of the payment installments that have been paid.
SELECT 
    payment_installments, COUNT(order_id) AS Number_of_orders
FROM
    `target.payments`
GROUP BY payment_installments
ORDER BY payment_installments

-- End

/* OBSERVATIONS:
1. Orders were placed between September, 2016 to October 2018.
2. There are 4119 different cities and 27 different states in Brazil from which the customers have placed their orders in the given time period.
3. In 2016, the numbers of orders placed increased from October to November but decreased in December.
4. In 2017, the numbers of orders placed increased from January to November but decreased in December.
5. In 2018, we saw a mixed trend, decrement from January to February, increment in March, decrement till June, increment till August, and decreased after on.
6. We saw a monthly seasonality in terms of number of orders placed. Maximum orders were placed in May, July and August. Least Orders were placed in September and October.
7. Brazilian customers ordered most in afternoon and least in Dawn.
8. Most number of customers belong to Sao Paulo whereas Roraima has the least number of customers.
9. Highest Percentage increase in cost of orders was observed in February 2017 of 110.78%.
10. Highest Percentage decrease in cost of orders was observed in June 2017 of 13.77%.
11. Highest total price was observed in Sao Paulo while the lowest was observed in Raoraima.
12. Lowest average price was observed in Sao Paulo while the highest was observed in Paraiba.
13. Highest total freight value was observed in Sao Paulo while the lowest was observed in Raoraima.
14. Highest average freight value was observed in Raoraima while the lowest was observed in Sao Paulo.
15. Fastest delivery was observed in Sao Paulo as compared to other states with an average delivery time of 8 days.
16. Slowest delivery was observed in Raoraima as compared to other states with an average delivery time of 29 days.
17. Lowest average difference in Estimated time and Actual time was observed in Alagoas of 8 days.
18. Highest average difference in Estimated time and Actual time was observed in Acre of 19 days.
19. Most number of payments were done from credit card.
20. Most number of payments were done in only 1 installment while the least were done in 22 and 23 installments.

RECOMMENDATIONS:
1. As Brazilian customers mostly buy in afternoon, we can apply different types of offers and discounts in afternoon to increase the orders. Stores should be open specially in afternoon. All the repairing work can be done in Dawn as there are least orders.
2. We should increase the customer aquisition in Raoraima by marketing, advertisements etc. as it has the least customers. It also has the slowest delivery which may be the the factor of low customers which should be improved.
3. Average difference between estimated time and actual time in acre should be reduced to improve revenue.
4. As most number of payments were done through credit card, offers and discounts on credit cards should be provided to increase the revenue.
*/
 
 


