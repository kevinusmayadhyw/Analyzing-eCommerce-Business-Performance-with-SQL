--------------------------------------------------------------------------------------------
-- 1. Product Revenue
CREATE TABLE Product_Revenue AS 
	WITH orderRevenue AS (
		SELECT
			*,
			date_part('year', shipping_limit_date) AS year,
			price + freight_value AS revenue
		FROM orders_dataset JOIN order_items_dataset
		USING (order_id)
	)
	
	SELECT 
		year,
		SUM(revenue) as revenue_total
	FROM orderRevenue
	WHERE order_status = 'delivered'
	GROUP BY year
	ORDER BY year;

--------------------------------------------------------------------------------------------
-- 2. Total Order Canceled
CREATE TABLE totalOrder_Canceled AS 
	SELECT
		date_part('year', order_purchase_timestamp) AS year,
		COUNT(order_status) AS total_order_canceled
	FROM orders_dataset
	WHERE order_status = 'canceled'
	GROUP BY year
	ORDER BY year;


--------------------------------------------------------------------------------------------
-- 3. Highest Revenue Per year
CREATE TABLE highest_Revenue AS 
	WITH orderProduct_Revenue AS (
		SELECT 
			year,
			product_category_name,
			SUM(revenue) AS revenue,
			RANK() OVER (PARTITION BY year
						 ORDER BY SUM(revenue) DESC) AS ranking
		FROM(
			SELECT
				*,
				date_part('year', shipping_limit_date) AS year,
				price + freight_value AS revenue
			FROM orders_dataset 
				JOIN order_items_dataset USING (order_id)
				JOIN products_dataset USING (product_id)	
		) AS sum_revenue
		WHERE order_status = 'delivered'
		GROUP BY year, product_category_name
		ORDER BY year
	)

	SELECT 
		year,
		product_category_name AS highest_product_revenue,
		MAX(revenue) AS revenue_product
	FROM orderProduct_Revenue
	WHERE ranking = 1
	GROUP BY year, product_category_name;

--------------------------------------------------------------------------------------------
-- 4. Most Canceled Order Per year
CREATE TABLE mostCanceled_order AS 
	WITH orderProduct_Revenue AS (
			SELECT 
				year,
				product_category_name,
				COUNT(product_category_name) AS total_product,
				RANK() OVER (PARTITION BY year
							 ORDER BY COUNT(product_category_name) DESC) AS ranking
			FROM(
				SELECT
					*,
					date_part('year', shipping_limit_date) AS year
				FROM orders_dataset 
					JOIN order_items_dataset USING (order_id)
					JOIN products_dataset USING (product_id)	
			) AS sum_revenue
			WHERE order_status = 'canceled'
			GROUP BY year, product_category_name
			ORDER BY year
		)
		
		SELECT 
			year,
			product_category_name AS most_canceled_product,
			MAX(total_product) AS total_product
		FROM orderProduct_Revenue
		WHERE ranking = 1
		GROUP BY year, product_category_name;

--------------------------------------------------------------------------------------------
-- 5. Combined all result
CREATE TABLE all_result AS 
	SELECT * 
		FROM Product_Revenue 
			JOIN totalOrder_Canceled USING(year)
			JOIN highest_Revenue USING(year)
			JOIN mostCanceled_order USING(year);
			
SELECT * FROM all_result;