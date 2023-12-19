----------------------------------------------------------------------------------
-- 1. Average MAU (Monthly Active Users) per year 
WITH NO1 AS (
	WITH totalCustomer_by_yearMonth AS (
		SELECT
			date_part('year', order_purchase_timestamp) AS year, 
			date_part('month', order_purchase_timestamp) AS month, 
			COUNT(DISTINCT customer_unique_id) AS total_customer 
		FROM orders_dataset JOIN customers_dataset
		USING (customer_id)
		GROUP BY year, month
	)

	SELECT 
		year,
		DIV (SUM(total_customer), COUNT (month)) AS avg_mau FROM totalCustomer_by_yearMonth
	GROUP BY year
	ORDER BY year
), 

----------------------------------------------------------------------------------
-- 2. Total new customer per year 
NO2 AS (
	WITH customerOrder AS (
		SELECT
			MIN (date_part('year', order_purchase_timestamp)) AS year, 
			customer_unique_id
		FROM orders_dataset JOIN customers_dataset
		USING (customer_id)
		GROUP BY customer_unique_id
	)
	
	SELECT
		year,
		COUNT (customer_unique_id) AS total_newCustomer
	FROM customerOrder
	GROUP BY year
	ORDER BY year
),

----------------------------------------------------------------------------------
-- 3. Total customer who make repeat order per year
NO3 AS (
	WITH customerOrder AS (
		SELECT
			date_part('year', order_purchase_timestamp) AS year, 
			COUNT (customer_unique_id) AS total_order 
		FROM orders_dataset JOIN customers_dataset
		USING (customer_id)
		GROUP BY year, customer_unique_id
	)
	SELECT
		year,
		COUNT (total_order) AS total_repeatorder
	FROM customerOrder
	WHERE total_order > 1
	GROUP BY year
	ORDER BY year
),

----------------------------------------------------------------------------------
-- 4. Average customer order per year
NO4 AS (
	WITH customerOrder AS (
		SELECT
			date_part('year', order_purchase_timestamp) AS year, 
			COUNT (customer_unique_id) AS total_order 
		FROM orders_dataset JOIN customers_dataset
		USING (customer_id)
		GROUP BY year, customer_unique_id
)
	SELECT
		year,
		AVG (total_order) AS avg_order
	FROM customerOrder
	GROUP BY year
	ORDER BY year
),

----------------------------------------------------------------------------------
-- 5. Combine all result
NO5 AS (
	SELECT *
	FROM NO1
		JOIN NO2 USING(year)
		JOIN NO3 USING(year)
		JOIN NO4 USING(year)
)

----------------------------------------------------------------------------------
-- PRINT all result

-- SELECT * FROM NO1;
-- SELECT * FROM NO2;
-- SELECT * FROM NO3;
-- SELECT * FROM NO4;
SELECT * FROM NO5;