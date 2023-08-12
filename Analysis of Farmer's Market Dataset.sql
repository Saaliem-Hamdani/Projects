-- Get all the products available in the market.

SELECT 
    *
FROM
    farmers_market.product
    
-- End


-- Write a query to calculate the total amount that the customer has paid along with date, customer id, vendor_id, qty, cost per quantity and the total amount.

SELECT 
    market_date,
    customer_id,
    vendor_id,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price
FROM
    farmers_market.customer_purchases

-- End


-- Extract all the product names that are part of product category 1

SELECT 
    product_id, product_name, product_category_id
FROM
    farmers_market.product
WHERE
    product_category_id = 1
    
-- End


-- Analyze purchases made at the farmer’s market on days when it rained.

SELECT
  *
FROM
  farmers_market.customer_purchases
WHERE
  market _date IN (
  SELECT
    market_date
  FROM
    farmers _market.market_ info
  WHERE
    market_rain_flag 1)

-- End


-- Question: Put the total cost to customer purchases into bins of under $5.00, $5.00 19.99, or $20.00 and over.

SELECT 
    market_date,
    customer_id,
    vendor_id,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS Price,
    CASE
        WHEN quantity * cost_to_customer_per_qty < 5.00 THEN 'Under $'
        WHEN quantity * cost_to_customer_per_qty < 10.00 THEN '$5 - $9.99'
        WHEN quantity * cost_to_customer_per_qty < 20.00 THEN '$10 - $19.99'
        WHEN quantity * cost_to_customer_per_qty >= 20.00 THEN '$20 and Up'
    END AS price_bin
FROM
    farmers_market.customer_ purchases
    
-- End


-- List each product name along with its product category name.

SELECT 
    p.product_id,
    p.product_name,
    pc.product_category_id,
    pc.product_category_name
FROM
    product AS p
        LEFT JOIN
    product_category AS pc ON p.product_category_id = pc.product_category_id
    
-- End


-- Get all the Customers who have not purchased anything from the market yet.

SELECT 
    c.*
FROM
    customer AS c
        LEFT JOIN
    customer_purchases AS cp ON c.customer_id = cp.customer_id
WHERE
    cp.customer_id IS NULL
    
-- End


-- Write a query that returns a list of all customers who did not make a purchase on March 2, 2019.

SELECT DISTINCT
    c.*
FROM
    customer AS c
        LEFT JOIN
    customer_purchases AS cp ON c.customer_id = cp.customer_id
WHERE
    (cp.market_date <> '2019-03-02'
        OR cp.market_date IS NULL)

-- End


-- Fetch details about all farmer’s market booths, as well as every vendor booth assignment for every market date.

SELECT 
    b.booth_number,
    b.booth_type,
    vba.market_date,
    v.vendor_id,
    v.vendor_name,
    v.vendor_type
FROM
    booth AS b
        LEFT JOIN
    vendor_booth_assignments AS vba ON b.booth_number = vba.booth_number
        LEFT JOIN
    vendor AS v ON v.vendor_id = vba.vendor_id
ORDER BY b.booth_number , vba.market_date

-- End


-- Get a list of customer IDs of customers who made purchases on each market date.

SELECT 
    market_date customer_id
FROM
    farmers_market.customer_purchases
GROUP BY market_date , customer_id
ORDER BY market_date , customer_id

-- End


-- Count the number of purchases each customer made per market date.

SELECT 
    market_date, customer_id, COUNT(*) AS num_purchases
FROM
    farmers_market.customer_purchases
GROUP BY market_date , customer_id
ORDER BY market_date , customer_id

-- End


-- Calculate the total quantity that each customer bought per market date.

SELECT 
    market_date,
    customer_id,
    SUM(quantity) AS total_qty_purchased
FROM
    farmers_market.customer_purchases
GROUP BY market_date , customer_id
ORDER BY market_date , customer_id

-- End


-- How many different kinds of products were purchased by each customer on each market date?

SELECT 
    market_date,
    customer_id,
    COUNT(DISTINCT product_id) AS different_products_purchased
FROM
    farmers_market.customer_purchases
GROUP BY market_date , customer_id
ORDER BY market_date , customer_id

-- End


-- Find out how much a customer had spent at each vendor, regardless of date?

SELECT 
    customer_id,
    vendor_id,
    SUM(quantity * cost_to_customer_per_qty) AS total_spent
FROM
    farmers_market.customer_purchases
GROUP BY customer_id , vendor_id
ORDER BY customer_id , vendor_id

-- End


-- Add some customer details and vendor details to the above query.

SELECT 
    c.customer_first_name,
    c.customer_last_name,
    cp.customer_id,
    v.vendor_id,
    v.vendor_name,
    SUM(quantity * cost_to_customer_per_qty) AS total_price
FROM
    customer AS c
        LEFT JOIN
    customer_purchases AS cp ON c.customer_id = cp.customer_id
        LEFT JOIN
    vendor AS v ON cp.vendor_id = v.vendor_id
GROUP BY c.customer_first_name , c.customer_last_name , cp.customer_id , v.vendor_id , v.vendor_name

-- End


-- Get the most and least expensive items per product category, considering the fact that each vendor sets their own prices and can adjust prices per customer.

SELECT 
    pc.product_category_name,
    p.product_category_id,
    MIN(vi.original_price) AS minimum_price,
    MAX(vi.original_price) AS maximum_price
FROM
    farmers_market.vendor_inventory AS vi
        INNER JOIN
    farmers_market.product AS p ON vi.product_id = p.product_id
        INNER JOIN
    farmers_market.product_category AS pc ON p.product_category_id = pc.product_category_id
GROUP BY pc.product_category_name , p.product_category_id

-- End


-- Filter out vendors who brought at least 2 items to the farmer’s market over the time period 2019-05-02 and 2019-05-16.

SELECT 
    vendor_id,
    COUNT(DISTINCT product_id) AS different_products_offered,
    SUM(quantity * original_price) AS value_of_inventory,
    SUM(quantity) AS inventory_item_count,
    SUM(quantity * original_price) / SUM(quantity) AS average_item_price
FROM
    farmers_market.vendor_inventory
WHERE
    market_date BETWEEN '2019-05-02' AND '2019-05-16'
GROUP BY vendor_id
HAVING inventory_item_count >= 2
ORDER BY vendor_id

-- End


-- Find the average amount spent by customers on each day. We want to consider only those days where the number of purchases were more than 3 and the transaction amount was greater than 5.

SELECT 
    market_date,
    ROUND(AVG(quantity * cost_to_customer_per_qty),2) AS avg_spent
FROM
    customer_purchases
WHERE
    quantity * cost_to_customer_per_qty > 5
GROUP BY market_date
HAVING COUNT(*) > 3
ORDER BY market_date

-- End


-- Get the price of the most expensive item per vendor?

SELECT 
    vendor _id, MAX(original_price) AS costliest_product
FROM
    vendor_inventory
GROUP BY vendor_id

-- End


-- Rank the products in each vendor’s inventory. Expensive products get a lower rank.

SELECT
	vendor_id, market_date, product_id, original_price,
	ROW_NUMBER() OVER (PARTITION BY vendor_id ORDER BY original_price DESC) AS price_rank
FROM
	farmers_market.vendor_inventory
ORDER BY vendor_id, original_price DESC

-- End


-- The record of the highest priced item per vendor.

SELECT 
	*
FROM 
	(SELECT
		vendor_id,
		original_price,
		dense_rank() OVER (PARTITION BY vendor_id ORDER BY original_price DESC) AS price_rank
	 FROM
		vendor_inventory) x 
WHERE
	price_dense_rank = 1
    
-- End


-- As a farmer, you want to figure out which of your products were above the average price per product on each market date?


SELECT
	*
FROM 
	(SELECT
		market_date,
		vendor_id,
		product_id,
		original_price,
		AVG(original_price) OVER (PARTITION BY market_date) AS mkt_date_avg_price
	FROM
		vendor_inventory) x
WHERE
	x.original_price > x.mkt_date_avg_price
    
-- End

-- Count how many different products each vendor brought to market on each date and display that count on each row.

SELECT
	vendor_id,
	market_date,
	product_id,
	original_price,
	COUNT(product_id) OVER (PARTITION BY market_date, vendor_id) AS product_count_per_vendor_market_date
FROM
	farmers_market.vendor_inventory
ORDER BY vendor_id, market_date, original_price DESC

-- End


-- Calculate the running total of the cost of items purchased by each customer, sorted by the date and time and the product_id.

SELECT
	customer_id, 
    market_date, 
    vendor_id, 
    product_id, 
	(quantity * cost_to_customer_per_qty) AS price,
	SUM(quantity * cost_to_customer_per_qty) OVER (PARTITION BY customer_id ORDER BY market_date, transaction_time, product_id) as customer_spend_running_total
FROM
	farmers_market.customer_purchases
    
-- End


-- Display each vendor’s booth assignment for each market_date alongside their previous booth assignments.

SELECT
	market_date,
	vendor_id,
	booth_number,
	LAG(booth_number,1) OVER (PARTITION BY vendor_id ORDER BY market_date, vendor_id) AS previous_booth_number
FROM
	farmers_market.vendor_booth_assignments
    
-- End


-- The Market manager want to filter these query results to a specific market date to determine which vendors are new or changing booths that day, so we can contact them and ensure setup goes smoothly.

SELECT 
	* 
FROM
	(SELECT
		market_date,
		vendor_id,
		booth_number,
		LAG(booth_number,1) OVER (PARTITION BY vendor_id ORDER BY market_date ) AS prev_booth
	FROM
		farmers_market.vendor_booth_assignments) AS x
WHERE
	x.booth_number <> x.prev_booth OR x.prev_booth IS NULL

-- End


-- Find out if the total sales on each market date are higher or lower than they were on the previous market date.

SELECT
	*,
	CASE 
		WHEN (prev_mkt_date_overall_sales > curr_mkt_date_overall_sales) THEN higher_than_prev_day
	ELSE 'lower_than_prev_day'
	END AS sale_comparison
FROM
	(SELECT
		market_date,
		sum(round(quantity * cost_to_customer_per_qty , 2)) curr_mkt_date_overall_sales,
		LAG(sum(round(quantity * cost_to_customer_per_qty , 2))) OVER (ORDER BY market_date) AS prev_mkt_date_sales
	 FROM
		customer_purchases 
	 GROUP BY
			market_date) x

-- End


-- Creation of datetime_demo table

create table farmers_market.datetime_demo as
(SELECT
	market_date,
	market_start_time,
    market_end_time,
	CONCAT(market_date,' ', market_start_time) as market_start_date,
	str_to_date(market_date,' ',market_start_time), "%Y-%m-%d %h:%i:%p") AS market_start_datetime,
	str_to_date(market_date,' ',market_end_time), "%Y-%m-%d %h:%i:%p") AS market_end_datetime
FROM
	farmers_market.market_date_info)

-- End


-- Q: Return the first and last market dates from the datetime_demo table, calculates the difference between those two dates.

SELECT
	x.first_market,
	x.last_market,
	DATEDIFF(x.last_market,x.first_market) AS days_first_to_last
FROM
	(SELECT
		min(market_start_datetime) AS first_market,
		max(market_start_datetime) AS last_market
	FROM
		farmers_market.datetime_demo) AS x

-- End


-- Write a query that gives us the days between each purchase a customer makes

SELECT
	customer_id,
	market_date,
	LAG(market_date,1) OVER (PARTITION BY customer_id ORDER BY market_date) AS last_purchase,
	DATEDIFF(market_date, LAG(market_date,1) OVER (PARTITION BY customer_id ORDER BY market_date)) AS days_from_prev_purchase
FROM
	farmers_market.customer_purchases_date

-- End


-- Find the avg. days it take for the customer between 2 purchases or how long it takes on an avg for a customer to comeback to the market.

SELECT
	customer_id,	
	AVG(days_from_prev_purchase)
    
FROM
	(SELECT
		customer_id,
		market_date,
		LAG(market_date,1) OVER (PARTITION BY customer_id ORDER BY market_date) AS last_purchase,
		DATEDIFF(market_date, LAG(market_date,1) OVER (PARTITION BY customer_id ORDER BY market_date)) AS days_from_prev_purchase
	FROM
		farmers_market.customer_purchases_date) x

GROUP BY
	x.customer_id

-- End



-- Assume today’s date is May 31, 2019, and the marketing director of the farmer’s market wants to give infrequent customers(visited only less than 2 days) in the past 30 days an incentive to return to the market in June.

SELECT
	x.customer_id,
	COUNT(DISTINCT x.market_date) AS total_visits_in_30_days

FROM
	(SELECT 
		DISTINCT customer_id,
		market_date,
		DATEDIFF('2019-05-31',market_date) as days_before_curr_date	
	FROM
		farmers_market.customer_purchases
	WHERE DATEDIFF('2019-05-31',market_date) BETWEEN 0 AND 30) AS x
    
GROUP BY
	x.customer_id
HAVING total_visits_in_30_days <=2

-- End


-- Create a CTE of sales summarized by date and vendor for a report that summarizes sales by market week.

WITH sales_by_day_vendor AS 
(SELECT
	cp.market_date,
	md.market_day,
	md.market_week,
	md.market_year,
	cp.vendor_id,
	v.vendor_name,
	v.vendor_type,
	ROUND(SUM(quantity * cost_to_customer_per_qty),2) AS total_sales
 FROM
	farmers_market.customer_purchases AS cp
		LEFT JOIN
	farmers_market.market_date_info AS md ON cp.market_date = md.market_date
		LEFT JOIN
	farmers_market.vendor AS v ON cp.vendor_id = v.vendor_id
GROUP BY
	cp.market_date, cp.vendor_id, md.market_day, md.market_week, md.market_year, v.vendor_name, v.vendor_type
ORDER BY cp.market_date, cp.vendor_id)

SELECT
	s.market_year,
	s.market_week,
	SUM(s.total_sales) AS weekly_sales
FROM
	sales_by_day_vendor AS s
GROUP BY
	s.market_year, s.market_week

-- End


-- Create a view 

CREATE VIEW farmers_market.vw_sales_by_day_vendor AS
SELECT
	cp.market_date,
	md.market_day,
    md.market_week,
	md.market_year,
	cp.vendor_id,
	v.vendor_name,
    v.vendor_type,
	ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty),2) AS sales
FROM farmers_market.customer_purchases AS cp
		LEFT JOIN
	farmers_market.market_date_info AS md ON cp.market_date = md.market_date
		LEFT JOIN
	farmers_market.vendor AS v ON cp.vendor_id = v.vendor_id
GROUP BY
	cp.market_date, cp.vendor_id
ORDER BY cp.market_date, cp.vendor_id

-- End