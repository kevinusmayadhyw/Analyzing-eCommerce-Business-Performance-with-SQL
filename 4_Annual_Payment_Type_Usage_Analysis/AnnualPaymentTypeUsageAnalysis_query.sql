--------------------------------------------------------------------------------------------
-- 1. FAVORITE PAYMENT METHOD
WITH NO1 AS(
	SELECT 
		payment_type,
		COUNT(payment_type) AS total_payment
	FROM payments_dataset
	GROUP BY payment_type
	ORDER BY total_payment DESC
),

--------------------------------------------------------------------------------------------
-- 2. FAVORITE PAYMENT METHOD per year
NO2 AS (
	WITH orders_paymentType AS (
		SELECT 
			payment_type,
			COUNT(payment_type) AS total_used,
			date_part('year', order_purchase_timestamp) AS year
		FROM payments_dataset
			JOIN orders_dataset USING (order_id)
		GROUP BY payment_type, year
	)

	SELECT 
		payment_type,
		SUM(CASE WHEN year = 2016 THEN total_used ELSE 0 END) AS "2016",
		SUM(CASE WHEN year = 2017 THEN total_used ELSE 0 END) AS "2017",
		SUM(CASE WHEN year = 2018 THEN total_used ELSE 0 END) AS "2018"
	FROM orders_paymentType
	GROUP BY payment_type
),

--------------------------------------------------------------------------------------------
-- 3. MERGE FAVORITE PAYMENT METHOD total and per year
MERGED AS (
	SELECT * FROM NO1 JOIN NO2 USING(payment_type)
	ORDER BY total_payment DESC
)

----------------------------------------------------------------------------------
-- PRINT all result

-- SELECT * FROM NO1;
-- SELECT * FROM NO2;
SELECT * FROM MERGED;