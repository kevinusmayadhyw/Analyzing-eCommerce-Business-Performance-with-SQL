-- 1. Create Table and copy data from CSV file 
-- customers_dataset
CREATE TABLE customers_dataset (
    customer_id CHARACTER VARYING,
    customer_unique_id CHARACTER VARYING,
    customer_zip_code_prefix CHARACTER VARYING,
    customer_city CHARACTER VARYING,
    customer_state CHARACTER VARYING,
    CONSTRAINT pk_customers_dataset PRIMARY KEY (customer_id)
);

COPY customers_dataset(customer_id, "customer_unique_id", "customer_zip_code_prefix", "customer_city", "customer_state")
FROM 'E:\Rakamin\JAP\Mini Project\Analyzing eCommerce Business Performance with SQL\Dataset\customers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- geolocation_dataset
CREATE TABLE geolocations_dataset (
    geolocation_zip_code_prefix CHARACTER VARYING,
    geolocation_lat DOUBLE PRECISION,
    geolocation_lng DOUBLE PRECISION,
    geolocation_city CHARACTER VARYING,
    geolocation_state CHARACTER VARYING
);

COPY geolocations_dataset(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
FROM 'E:\Rakamin\JAP\Mini Project\Analyzing eCommerce Business Performance with SQL\Dataset\geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;

-- order_items_dataset
CREATE TABLE order_items_dataset (
    order_id CHARACTER VARYING,
    order_item_id INT,
    product_id CHARACTER VARYING,
    seller_id CHARACTER VARYING,
    shipping_limit_date TIMESTAMP,
    price DOUBLE PRECISION,
    freight_value DOUBLE PRECISION
);

COPY order_items_dataset(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
FROM 'E:\Rakamin\JAP\Mini Project\Analyzing eCommerce Business Performance with SQL\Dataset\order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

-- payments_dataset
CREATE TABLE payments_dataset (
    order_id CHARACTER VARYING, 
    payment_sequential INT, 
    payment_type CHARACTER VARYING, 
    payment_installments INT, 
    payment_value DOUBLE PRECISION
);

COPY payments_dataset(order_id, payment_sequential, payment_type, payment_installments, payment_value)
FROM 'E:\Rakamin\JAP\Mini Project\Analyzing eCommerce Business Performance with SQL\Dataset\order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

-- reviews_dataset
CREATE TABLE reviews_dataset (
    review_id CHARACTER VARYING, 
    order_id CHARACTER VARYING, 
    review_score INT, 
    review_comment_title CHARACTER VARYING, 
    review_comment_message CHARACTER VARYING, 
    review_creation_date TIMESTAMP, 
    review_answer_timestamp TIMESTAMP
);

COPY reviews_dataset(review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
FROM 'E:\Rakamin\JAP\Mini Project\Analyzing eCommerce Business Performance with SQL\Dataset\order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;

-- orders_dataset
CREATE TABLE orders_dataset (
    order_id CHARACTER VARYING, 
    customer_id CHARACTER VARYING, 
    order_status CHARACTER VARYING, 
    order_purchase_timestamp TIMESTAMP, 
    order_approved_at TIMESTAMP, 
    order_delivered_carrier_date TIMESTAMP, 
    order_delivered_customer_date TIMESTAMP, 
    order_estimated_delivery_date TIMESTAMP,
    CONSTRAINT pk_orders_dataset PRIMARY KEY (order_id)
);

COPY orders_dataset(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
FROM 'E:\Rakamin\JAP\Mini Project\Analyzing eCommerce Business Performance with SQL\Dataset\orders_dataset.csv'
DELIMITER ','
CSV HEADER;

-- product_dataset (The first column is missing, my assumption is product_no)
CREATE TABLE products_dataset (
    product_no INT,
    product_id CHARACTER VARYING, 
    product_category_name CHARACTER VARYING, 
    product_name_lenght DOUBLE PRECISION, 
    product_description_lenght DOUBLE PRECISION, 
    product_photos_qty DOUBLE PRECISION, 
    product_weight_g DOUBLE PRECISION, 
    product_length_cm DOUBLE PRECISION, 
    product_height_cm DOUBLE PRECISION, 
    product_width_cm DOUBLE PRECISION,
    CONSTRAINT pk_products_dataset PRIMARY KEY (product_id)
);

COPY products_dataset(product_no, product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
FROM 'E:\Rakamin\JAP\Mini Project\Analyzing eCommerce Business Performance with SQL\Dataset\product_dataset.csv'
DELIMITER ','
CSV HEADER;

-- sellers_dataset
CREATE TABLE sellers_dataset (
    seller_id CHARACTER VARYING, 
    seller_zip_code_prefix CHARACTER VARYING, 
    seller_city CHARACTER VARYING, 
    seller_state CHARACTER VARYING,
	CONSTRAINT pk_sellers_dataset PRIMARY KEY (seller_id)
);

COPY sellers_dataset(seller_id, seller_zip_code_prefix, seller_city, seller_state)
FROM 'E:\Rakamin\JAP\Mini Project\Analyzing eCommerce Business Performance with SQL\Dataset\sellers_dataset.csv'
DELIMITER ','
CSV HEADER;

-----------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Cleaning geolocations_dataset
-- Create temp table
CREATE TABLE temp_table (LIKE geolocations_dataset);

-- Insert new geolocation_zip_code_prefix from customers_dataset
INSERT INTO geolocations_dataset(geolocation_zip_code_prefix)
SELECT DISTINCT customer_zip_code_prefix
FROM customers_dataset;

-- Insert new geolocation_zip_code_prefix from sellers_dataset
INSERT INTO geolocations_dataset(geolocation_zip_code_prefix)
SELECT DISTINCT seller_zip_code_prefix
FROM sellers_dataset;

-- Insert DISTINCT geolocation_zip_code_prefix value to temp table
INSERT INTO temp_table(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
SELECT DISTINCT ON (geolocation_zip_code_prefix) geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state
FROM geolocations_dataset;

-- Drop geolocations_dataset
DROP TABLE IF EXISTS geolocations_dataset;

-- Rename temp table to geolocations_dataset
ALTER TABLE IF EXISTS temp_table
RENAME TO geolocations_dataset;

-- Adding PK for geolocations_dataset
ALTER TABLE geolocations_dataset
ADD CONSTRAINT pk_geolocations_dataset PRIMARY KEY (geolocation_zip_code_prefix);

-----------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. Added Foreign Key
-- Alter order_id to foreign key
ALTER TABLE reviews_dataset ADD CONSTRAINT fk_reviews_dataset_order_id FOREIGN KEY (order_id) REFERENCES orders_dataset;
ALTER TABLE payments_dataset ADD CONSTRAINT fk_payments_dataset_order_id FOREIGN KEY (order_id) REFERENCES orders_dataset;
ALTER TABLE order_items_dataset ADD CONSTRAINT fk_order_items_dataset_order_id FOREIGN KEY (order_id) REFERENCES orders_dataset;

-- Alter customer_id to foreign key
ALTER TABLE orders_dataset ADD CONSTRAINT fk_orders_dataset_customer_id FOREIGN KEY (customer_id) REFERENCES customers_dataset;

-- Alter product_id to foreign key
ALTER TABLE order_items_dataset ADD CONSTRAINT fk_order_items_dataset_product_id FOREIGN KEY (product_id) REFERENCES products_dataset;

-- Alter seller_id to foreign key
ALTER TABLE order_items_dataset ADD CONSTRAINT fk_order_items_dataset_seller_id FOREIGN KEY (seller_id) REFERENCES sellers_dataset;

-- Alter zip_code_prefix to foreign key
ALTER TABLE sellers_dataset ADD CONSTRAINT fk_sellers_dataset_seller_zip_code_prefix FOREIGN KEY (seller_zip_code_prefix) REFERENCES geolocations_dataset;
ALTER TABLE customers_dataset ADD CONSTRAINT fk_customers_dataset_customer_zip_code_prefix FOREIGN KEY (customer_zip_code_prefix) REFERENCES geolocations_dataset;