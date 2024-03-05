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
    
-- 2. Display all users who have reported a particular artist
SELECT DISTINCT
	u.username, 
    a.username AS artist_name
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

-- 7. Selecting popular tags
SELECT
	tag_name,
    usage_count
FROM
	tag
ORDER BY
	usage_count DESC;
    
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