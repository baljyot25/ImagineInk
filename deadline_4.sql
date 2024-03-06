USE ImaginInk;

-- 1. Sort artists in descending order based on their revenue
SELECT 
    a.artist_id,
    u.username AS artist_username,
    SUM(IFNULL(d.price * d.sales_count, 0)) AS total_revenue
FROM 
	artist a
JOIN 
	user u ON a.artist_id = u.user_id
LEFT JOIN 
	design d ON a.artist_id = d.artist_id
GROUP BY
    a.artist_id
ORDER BY
    total_revenue DESC;

-- 2. Display all users who have reported a particular artist along with design name
SELECT DISTINCT
	u.username, 
    a.username AS artist_name, d.title as title
FROM 
	user u
JOIN 
	report r ON u.user_id = r.reporter_user_id
JOIN 
	design d ON r.reported_design_id = d.design_id
JOIN 
	user a ON d.artist_id = a.user_id;
    
-- 3. Identify designs with reported issues and their corresponding reports
SELECT 
    d.design_id,
    d.title,
    r.report_description
FROM 
	design d
JOIN 
	report r ON d.design_id = r.reported_design_id;


-- 4. Users who have items in shopping carts but have not placed an order along with the items
SELECT
	u.username,
    d.title AS 'design',
    p.title AS 'product',
    ci.quantity
FROM 
	user u
JOIN 
	carry c ON u.user_id = c.customer_id
JOIN 
	shopping_cart sc ON c.cart_id = sc.cart_id
JOIN 
	cart_items ci ON ci.cart_id = sc.cart_id
JOIN
	design d ON d.design_id = ci.design_id
JOIN 
	product p ON p.product_id = ci.product_id;

-- 5. Select customers with most orders:
SELECT
    c.customer_id,
    u.username AS customer_username,
    COUNT(o.order_id) AS total_purchases
FROM
    user u
JOIN
    customer c ON u.user_id = c.customer_id
JOIN
	view_history vh ON c.customer_id = vh.customer_id
JOIN
    ImaginInk.order o ON vh.order_id = o.order_id
GROUP BY
    c.customer_id, u.username
ORDER BY
    total_purchases DESC;

-- 6. Selecting the best selling product and design combination
SELECT
	p.title AS 'product',
    d.title AS 'design',
    SUM(ci.quantity) AS total_sales
FROM
	cart_items ci
JOIN
	product p ON ci.product_id = p.product_id
JOIN
	design d ON d.design_id = ci.design_id
WHERE ci.cart_id IN (
	SELECT co.cart_id
    FROM checkout co)
GROUP BY
	ci.product_id, ci.design_id
ORDER BY
	total_sales DESC
LIMIT 1;

-- 7. Selecting designs with their respective tags
SELECT
	d.design_id,
    d.title,
    t.tag_name
FROM
	design d
JOIN
	design_tags dt ON d.design_id = dt.design_id
JOIN
	tag t ON dt.tag_id = t.tag_id
ORDER BY
	d.design_id ASC;
    
-- 8. Selecting most reviewed designs
SELECT
	d.design_id AS design_id,
    d.title AS design_title,
    COUNT(r.review_id) AS reviews
FROM
	design d
LEFT JOIN
	review_relates_to rrt ON d.design_id = rrt.design_id
LEFT JOIN
	review r ON rrt.review_id = r.review_id
GROUP BY
	d.design_id, d.title
ORDER BY
	reviews DESC;

-- 9. Updating orders' delivery status where the delivery address is in Gandhi Lane
UPDATE 
	ImaginInk.order o
JOIN 
	ImaginInk.view_history vh ON o.order_id = vh.order_id
JOIN 
	ImaginInk.customer c ON vh.customer_id = c.customer_id
SET 
	o.delivery_status = 
		CASE
			WHEN o.delivery_status = 'pending' THEN 'shipped'
			ELSE 'delivered'
		END
WHERE
	c.address LIKE '%gandhi lane%';
    
-- 10. Delete designs with their corresponding reviews that have been reported as containing hateful content
DELETE 
	design, 
	review
FROM
	design
JOIN 
	report r ON design.design_id = r.reported_design_id
JOIN 
	review_relates_to rrt ON design.design_id = rrt.design_id
JOIN 
	review ON rrt.review_id = review.review_id
WHERE 
	r.report_description = 'Hateful content';
    
-- Showcasing Constraints
INSERT INTO ImaginInk.user (email_id, password, username, account_status, full_name, registration_date, last_login_date, account_type, payment_method) VALUES
-- Invalid query as saurabh@example.com has already been used as an email for a customer
('saurabh@example.com', 'password321', 'saurabh_mishra', 'logged_out', 'Saurabh Mishra', '2024-02-01', '2024-02-02', 'customer', 'Credit Card');

INSERT INTO ImaginInk.user (email_id, password, username, account_status, full_name, registration_date, last_login_date, account_type, payment_method) VALUES
-- Valid query as saurabh@example.com has not been used before as an email for an artist
('saurabh@example.com', 'password321', 'saurabh_mishra', 'logged_out', 'Saurabh Mishra', '2024-02-01', '2024-02-02', 'artist', 'Credit Card');

INSERT INTO ImaginInk.user (email_id, password, username, account_status, full_name, registration_date, last_login_date, account_type, payment_method) VALUES
-- Invalid email
('birexample.com', 'password321', 'Harsha_mehtani', 'logged_out', 'Harsha Mehtani', '2024-02-01', '2024-02-02', 'customer', 'PayTM');

INSERT INTO ImaginInk.design(artist_id, title, description, image, creation_date, price, sales_count, views_count) VALUES
-- Invalid price
(2, 'abc', 'def', 'image2.jpg', '2024-01-01', -1, 0, 100);
