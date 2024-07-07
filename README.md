# Project ImaginInk
## Table of Contents
![Report](Pasted%20image%2020240420224151.png)
---
- [Project ImaginInk](#project-imaginink)
  - [Table of Contents](#table-of-contents)
  - [Contributors](#contributors)
  - [Project Overview](#project-overview)
  - [Objectives](#objectives)
  - [Scope and Features](#scope-and-features)
  - [Tech Stack](#tech-stack)
  - [Entity-Relationship Diagram](#entity-relationship-diagram)
  - [Relational Model](#relational-model)
  - [Implementation of Schema](#implementation-of-schema)
  - [Data Generation](#data-generation)
  - [Data Population](#data-population)
  - [SQL queries](#sql-queries)
  - [Triggers](#triggers)
  - [Transactions](#transactions)
    - [Non-Conflicting Transactions](#non-conflicting-transactions)
    - [Conflicting Transactions](#conflicting-transactions)
  - [Workflows](#workflows)
    - [User](#user)
    - [Artist](#artist)
    - [Admin](#admin)
## Contributors
---
- Baljyot Singh Modi
- Saurav Mehra
- Kushagra Gupta
- Mudit Bansal

## Project Overview
---
"ImagineInk" aims to establish a user-friendly platform catering to small-scale designers. The platform facilitates the exhibition of designers' creations to a broader audience while
simultaneously allowing customers to acquire their preferred prints. This initiative prioritises a seamless and secure payment and delivery process for users, contributing to artists' income generation.

The platform is designed to support both emerging and established talent, providing a specialized space for art enthusiasts to explore and purchase unique designs. The project aims to foster a community of artists and customers, enabling artists to showcase their work and receive compensation for their creations. The platform also encourages customers to share their feedback and experiences, contributing to the community and helping artists improve.
## Objectives
---
1. Create a platform for designers to showcase their work.
2. Provide customers with an accessible avenue to acquire desired prints.
3. Facilitate income generation for artists, supporting both emerging and established talent.
4. Curate a specialized space for art enthusiasts.
## Scope and Features
---
- **Customer**:
	- **Login/Signup:**
	  Customers can create a new account or log in to an existing one, while ensuring that each email address is uniquely linked to a single account.
	- **Search for Products:**
	  Customers can easily find specific designs or discover new ones based on tags associated with each product.
	- **Select product:**
	  Users can choose their preferred artworks and explore various designs from various small-scale designers.
	- **Shopping Cart:**
	  A virtual cart system where customers can review and manage their selected items, following which they can proceed to checkout to finalise their items.
	- **Make Payment:**
	  Seamless and secure payment options to complete the purchasing process efficiently.

- **Artist:**
	- **Login/Signup:**
	  Artists will have the option to create a new account or log in to an already existing account, while ensuring that each email address is uniquely linked to a single account.
	- **Upload Design:**
	  Artists would be able to upload their designs to the database, specifying their price.
	- **Receive payment:**
	  Artists would be compensated on a commission basis for each sale of their respective products.
	- **View user analytics:**
	  Artists would be able to view the analysis of their own designs.

- **Admin:**
	- **Manage accounts:**
	  Admins would have the ability to view all customers and artists and delete their accounts.
	- **Manage designs:**
	  Admins will have the option to view all uploaded designs and remove the designs.
	- **View analytics:**
	  Admins would be able to view both customer and artist analytics, such as the number of customer and artist accounts, along with the design and product analytics.

## Tech Stack
---
- Frontend: Python, Streamlit
- Backend: Python (Flask Framework)
- Database Management: MySQL
- Version Control: Git, GitHub

## Entity-Relationship Diagram
---
**![](https://lh7-us.googleusercontent.com/F3okA3NQE0EZFcSUik5Ic0VHcW9brfH9arAn6uC7BMBfja3iEWJ21kzFfDVfb2-24eB5hDeOsVSm4K64pCl6JDJsnRUn61GAVdNj2SbRBJKYLp-MES2QahfZfZhkz5cCzM9TMgX_colyEX70EUxraZc)**

## Relational Model
---
![](Pasted%20image%2020240420223203.png)

## Implementation of Schema
- Table `ImaginInk.users`
```SQL
CREATE TABLE IF NOT EXISTS ImaginInk.user (
  user_id INT NOT NULL AUTO_INCREMENT,
  email_id VARCHAR(45) NOT NULL,
  password VARCHAR(45) NOT NULL,
  username VARCHAR(45) NOT NULL,
  account_status ENUM('logged_in', 'logged_out','deleted' ) NOT NULL,
  full_name VARCHAR(45) NOT NULL,
  registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),	
  last_login_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  account_type ENUM('customer', 'artist') NOT NULL,
  payment_method ENUM('Credit Card', 'PayTM', 'Google Pay', 'Bank Transfer'),
  PRIMARY KEY (user_id),
  UNIQUE KEY unique_email_account_type (email_id, account_type),
  CONSTRAINT chk_email_format CHECK (email_id LIKE '_%@_%.com')
);	
```
- Table `ImaginInk.customers`
```SQL
CREATE TABLE ImaginInk.customer (
  customer_id INT NOT NULL,
  address VARCHAR(255) NOT NULL,
  PRIMARY KEY (customer_id),
  FOREIGN KEY (customer_id) REFERENCES ImaginInk.user (user_id)
);
```
- Table `ImaginInk.artists`
  ```SQL
CREATE TABLE ImaginInk.artist (
  artist_id INT NOT NULL,
  PRIMARY KEY (artist_id),
  FOREIGN KEY (artist_id) REFERENCES ImaginInk.user (user_id)
);
```
- Table `ImaginInk.designs`
```SQL
CREATE TABLE ImaginInk.design (
  design_id INT NOT NULL AUTO_INCREMENT,
  artist_id INT NOT NULL,
  title VARCHAR(45) NOT NULL,
  description VARCHAR(100),
  image BLOB NOT NULL,
  creation_date DATE,
  price INT NOT NULL,
  sales_count INT DEFAULT 0,
  views_count INT DEFAULT 0,
  status ENUM('deleted','visible','hidden') NOT NULL default 'visible',
  PRIMARY KEY (design_id),
  FOREIGN KEY (artist_id) REFERENCES ImaginInk.artist (artist_id),
  CONSTRAINT chk_design_price CHECK (price > 0)
);
```
- Table `ImaginInk.tags`
```SQL
CREATE TABLE ImaginInk.tag (
  tag_id INT NOT NULL AUTO_INCREMENT,
  tag_name VARCHAR(45) NOT NULL,
  description VARCHAR(45),
  usage_count INT DEFAULT 0,
  PRIMARY KEY (tag_id)
);
```
- Table `ImaginInk.design_tags`
```SQL
CREATE TABLE ImaginInk.design_tags (
  tag_id INT NOT NULL,
  design_id INT NOT NULL,
  PRIMARY KEY (tag_id, design_id),
  FOREIGN KEY (design_id) REFERENCES ImaginInk.design (design_id),
  FOREIGN KEY (tag_id) REFERENCES ImaginInk.tag (tag_id) 
  ON DELETE CASCADE
  ON UPDATE CASCADE
);
```
- Table `ImaginInk.artist_assist`
```SQL
CREATE TABLE ImaginInk.artist_assist (
  request_id INT NOT NULL AUTO_INCREMENT,
  request_date DATE DEFAULT (CURRENT_DATE),
  description VARCHAR(100) NOT NULL,
  request_status ENUM('pending', 'resolved') DEFAULT 'pending',
  request_closure_date DATE,
  artist_id INT NOT NULL,
  PRIMARY KEY (request_id),
  FOREIGN KEY (artist_id) REFERENCES ImaginInk.artist (artist_id)
);
```
- Table `ImaginInk.orders`
```SQL
CREATE TABLE ImaginInk.order (
  order_id INT NOT NULL AUTO_INCREMENT,
  order_date DATE NOT NULL,
  delivery_date DATE NOT NULL,
  delivery_status ENUM('shipped', 'pending', 'delivered') DEFAULT 'pending',
  PRIMARY KEY (order_id)
);
```
- Table `ImaginInk.shopping_carts`
```SQL
CREATE TABLE ImaginInk.shopping_cart (
  cart_id INT NOT NULL AUTO_INCREMENT,
  grand_total INT DEFAULT 0,
  total_items INT DEFAULT 0,
  PRIMARY KEY (cart_id)
);
```
- Table `ImaginInk.products`
```SQL
CREATE TABLE ImaginInk.product (
  product_id INT NOT NULL AUTO_INCREMENT,
  title VARCHAR(45) NOT NULL,
  image BLOB NOT NULL,
  price INT NOT NULL,
  sales_count INT DEFAULT 0,
  dimensions ENUM('16x20', 'S, M, L, XL', 'Standard', 'Various', '18x24', 'A5', 'Set of 4') NOT NULL,
  PRIMARY KEY (product_id),
  CONSTRAINT chk_product_price CHECK (price > 0)
);
```
- Table `ImaginInk.cart_items`
```SQL
CREATE TABLE ImaginInk.cart_items (
  cart_id INT NOT NULL,
  product_id INT NOT NULL,
  design_id INT NOT NULL,
  quantity INT NOT NULL,
  price INT NOT NULL,
  PRIMARY KEY (cart_id, product_id, design_id),
  FOREIGN KEY (product_id) REFERENCES ImaginInk.product (product_id),
  FOREIGN KEY (design_id) REFERENCES ImaginInk.design (design_id),
  FOREIGN KEY (cart_id) REFERENCES ImaginInk.shopping_cart (cart_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);
```
- Table `ImaginInk.reviews`
```SQL
CREATE TABLE ImaginInk.review (
  review_id INT NOT NULL AUTO_INCREMENT,
  customer_id INT NOT NULL,
  review_description VARCHAR(45) NOT NULL,
  review_date DATE NOT NULL,
  PRIMARY KEY (review_id),
  FOREIGN KEY (customer_id) REFERENCES ImaginInk.customer (customer_id)
);
```
- Table `ImaginInk.reports`
```SQL
CREATE TABLE ImaginInk.report (
  report_date DATE NOT NULL,
  report_description ENUM('Copyright violation', 'Hateful content') NOT NULL,
  reporter_user_id INT NOT NULL,
  reported_design_id INT NOT NULL,
  PRIMARY KEY (reported_design_id, reporter_user_id),
  FOREIGN KEY (reporter_user_id) REFERENCES ImaginInk.user (user_id),
  FOREIGN KEY (reported_design_id) REFERENCES ImaginInk.design (design_id)
);
```
- Table `ImaginInk.admin`
```SQL
CREATE TABLE ImaginInk.admin (
  admin_id INT NOT NULL AUTO_INCREMENT,
  username VARCHAR(45) NOT NULL,
  password VARCHAR(45) NOT NULL,
  PRIMARY KEY (admin_id)
);
```
- Table `ImaginInk.view_history`
```SQL
CREATE TABLE ImaginInk.view_history (
  order_id INT NOT NULL,
  customer_id INT NOT NULL,
  PRIMARY KEY (customer_id, order_id),
  FOREIGN KEY (order_id) REFERENCES ImaginInk.order (order_id),
  FOREIGN KEY (customer_id) REFERENCES ImaginInk.customer (customer_id)
);
```
- Table `ImaginInk.carry`
```SQL
CREATE TABLE ImaginInk.carry (
  customer_id INT NOT NULL,
  cart_id INT NOT NULL,
  PRIMARY KEY (customer_id, cart_id),
  FOREIGN KEY (customer_id) REFERENCES ImaginInk.customer (customer_id),
  FOREIGN KEY (cart_id) REFERENCES ImaginInk.shopping_cart (cart_id)
);
```
- Table `ImaginInk.checkout`
```SQL
CREATE TABLE ImaginInk.checkout (
  order_id INT NOT NULL,
  cart_id INT NOT NULL,
  PRIMARY KEY (order_id, cart_id),
  FOREIGN KEY (order_id) REFERENCES ImaginInk.order (order_id),
  FOREIGN KEY (cart_id) REFERENCES ImaginInk.shopping_cart (cart_id)
);
```
- Table `ImaginInk.related_to`
```SQL
CREATE TABLE ImaginInk.review_relates_to (
  review_id INT NOT NULL,
  design_id INT NOT NULL,
  PRIMARY KEY (review_id, design_id),
  FOREIGN KEY (review_id) REFERENCES ImaginInk.review (review_id)
  ON DELETE CASCADE  
  ON UPDATE CASCADE,
  FOREIGN KEY (design_id) REFERENCES ImaginInk.design (design_id)
);
```
## Data Generation
---
Majority of the data was generated with the use of large language models. We provided our database schema to the model and got the data to fill the database after which we made sure to follow integrity constraints while filling the data.

## Data Population
---
All the tables of the database were pre-populated with data with integrity-constrains maintained to start querying. The database was populated with the following number of rows of data:
- **users**: 31 entries
- **customers**: 15 entries
- **artists**: 15 entries
- **designs**: 10 entries
- **tags**: 10 entries
- **design_tags**: 20 entries 
- **artist_assist**: 10 entries
- **orders**: 10 entries
- **shopping_carts**: 25 entries
- **products**: 10 entries

## SQL queries
---
1. Sort artists in descending order based on their revenue
```SQL
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
```
- Display all users who have reported a particular artist along with design name
```SQL
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
```
- Identify designs with reported issues and their corresponding reports
```SQL
SELECT 
    d.design_id,
    d.title,
    r.report_description
FROM 
	design d
JOIN 
	report r ON d.design_id = r.reported_design_id;
```
- Users who have items in shopping carts but have not placed an order along with the items
```SQL
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
```
- Select customers with most orders
```SQL
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
    c.customer_id
ORDER BY
    total_purchases DESC;

```
- Selecting the best selling product and design combination
```SQL
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
```
- Selecting designs with their respective tags
```SQL
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
```
- Selecting most reviewed designs
```SQL
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
	d.design_id
ORDER BY
	reviews DESC;
```
- Updating orders' delivery status where the delivery address is in Gandhi Lane
```SQL
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
```
- Delete designs with their corresponding reviews that have been reported as containing hateful content
```SQL
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
```

## Triggers
--- 
- Adds a row to the artist and customer table when a new user signs up.
```SQL
DELIMITER // 
CREATE TRIGGER trg_insert_user AFTER INSERT ON ImaginInk.user
FOR EACH ROW
BEGIN
    IF NEW.account_type LIKE 'artist' THEN
        INSERT INTO ImaginInk.artist (artist_id) VALUES (NEW.user_id);
    ELSEIF NEW.account_type LIKE 'customer' THEN
        INSERT INTO ImaginInk.customer (customer_id, address) VALUES (NEW.user_id, 'NA');
		INSERT INTO ImaginInk.shopping_cart () VALUES ();
        INSERT INTO ImaginInk.carry (customer_id, cart_id) VALUES (NEW.user_id, LAST_INSERT_ID());
    END IF;
END //
```
- Increments the tag usage count when a design is linked to a tag
```SQL
DELIMITER //
CREATE TRIGGER trg_add_design_tag AFTER INSERT ON ImaginInk.design_tags
FOR EACH ROW
BEGIN
    UPDATE ImaginInk.tag
    SET usage_count = usage_count + 1
    WHERE tag_id = NEW.tag_id;
END //
```
- Decrements the tag usage count when a design is unlinked from a tag
```SQL
DELIMITER //
CREATE TRIGGER trg_remove_design_tag AFTER DELETE ON ImaginInk.design_tags
FOR EACH ROW
BEGIN
    UPDATE ImaginInk.tag
    SET usage_count = usage_count - 1
    WHERE tag_id = OLD.tag_id;
END //
```
- Updates the number of items and grand total of the shopping cart when a new item is selected by the customer
```SQL
DELIMITER //
CREATE TRIGGER add_cart_item AFTER INSERT ON ImaginInk.cart_items
FOR EACH ROW
BEGIN
    UPDATE ImaginInk.shopping_cart
        SET grand_total = grand_total + NEW.price
        WHERE cart_id = NEW.cart_id;
	UPDATE ImaginInk.shopping_cart
        SET total_items = total_items + 1
        WHERE cart_id = NEW.cart_id;
END //  
```
- Updates the grand total of the shopping cart when the quantity of an item is changed
```SQL
DELIMITER //
CREATE TRIGGER update_cart_item BEFORE UPDATE ON ImaginInk.cart_items
FOR EACH ROW
BEGIN
    DECLARE individual_price INT;

    SET individual_price = (SELECT price FROM ImaginInk.product WHERE product_id = NEW.product_id)
            + (SELECT price FROM ImaginInk.design WHERE design_id = NEW.design_id);

	UPDATE ImaginInk.shopping_cart
        SET grand_total = grand_total - OLD.price + individual_price * NEW.quantity
        WHERE cart_id = NEW.cart_id;

    SET NEW.price = individual_price * NEW.quantity;
END //
```
- Updates the grand total and number of items in the shopping cart when an item is removed from the cart
```SQL
DELIMITER //
CREATE TRIGGER remove_cart_item AFTER DELETE ON ImaginInk.cart_items
FOR EACH ROW
BEGIN
    UPDATE ImaginInk.shopping_cart
        SET grand_total = grand_total - OLD.price
        WHERE cart_id = OLD.cart_id;
	UPDATE ImaginInk.shopping_cart
        SET total_items = total_items - 1
        WHERE cart_id = OLD.cart_id;
END //
```
- Triggers a number of actions when a user places an order. It links the customer to the placed order through the view_history table, increases the sales counts of the designs and the products ordered and assigns a new empty shopping cart to the customer.
```SQL
DELIMITER //
CREATE TRIGGER place_order AFTER INSERT ON ImaginInk.checkout
FOR EACH ROW
BEGIN
    INSERT INTO ImaginInk.shopping_cart () VALUES ();

    INSERT INTO ImaginInk.view_history (customer_id, order_id)
        SELECT customer_id, NEW.order_id
        FROM ImaginInk.carry
        WHERE cart_id = NEW.cart_id;

    UPDATE ImaginInk.carry
        SET cart_id = LAST_INSERT_ID()
        WHERE cart_id = NEW.cart_id;


    UPDATE ImaginInk.design d
		JOIN ImaginInk.cart_items ci ON d.design_id = ci.design_id
        SET d.sales_count = d.sales_count + ci.quantity
        WHERE cart_id = NEW.cart_id;
    
    UPDATE ImaginInk.product p
        JOIN ImaginInk.cart_items ci ON p.product_id = ci.product_id
        SET p.sales_count = p.sales_count + ci.quantity
        WHERE cart_id = NEW.cart_id;
END //
```
- Updates the status of the designs to 'deleted' when an admin deleted an artist
```SQL
DELIMITER //
CREATE TRIGGER remove_artist_designs AFTER UPDATE ON ImaginInk.user
FOR EACH ROW
BEGIN
    IF NEW.account_type = 'artist' AND NEW.account_status = 'deleted' THEN
        UPDATE ImaginInk.design
            SET status = 'deleted'
            WHERE artist_id = NEW.user_id;
    END IF;
END //
```
- Updates the items in the customers' current carts when the status of a design is set to 'hidden' or 'deleted'.
```SQL
DELIMITER //
CREATE TRIGGER update_design_status AFTER UPDATE ON ImaginInk.design
FOR EACH ROW
BEGIN
    IF NEW.status <> 'visible' THEN
        DELETE FROM ImaginInk.cart_items
            WHERE design_id = NEW.design_id
            AND cart_id IN (SELECT cart_id FROM ImaginInk.carry);
    END IF;
END //
```
## Transactions
---
### Non-Conflicting Transactions
---
1. Two customers add the same items to their respective carts 
   Non-conflicting since they read the same rows but write on independent rows
```SQL
START TRANSACTION;
INSERT INTO ImaginInk.cart_items (cart_id, product_id, design_id, price, quantity) VALUES
(16, 1, 1, 100, 1),
(16, 1, 2, 110, 1);
COMMIT;

START TRANSACTION;
INSERT INTO ImaginInk.cart_items(cart_id, product_id, design_id, price, quantity) VALUES
(17, 1, 1, 100, 1),
(17, 1, 2, 110, 1);
COMMIT;
```
2. Adding a customer's review for a product that they have ordered, while another customer reports that design
   Non-conflicting transactions since they operate on independent rows
```SQL
DROP PROCEDURE IF EXISTS add_review_transaction;
DELIMITER //
CREATE PROCEDURE add_review_transaction()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

	START TRANSACTION;
	INSERT INTO ImaginInk.review (customer_id, review_description, review_date) VALUES
	(1, 'Low quality', '2024-01-01');
	INSERT INTO ImaginInk.review_relates_to (review_id, design_id) VALUES
	(LAST_INSERT_ID(), 2);

	SET @order_count = (SELECT COUNT(*)
		FROM customer c
		JOIN view_history vh ON c.customer_id = vh.customer_id
		JOIN ImaginInk.order o ON vh.order_id = o.order_id
		JOIN ImaginInk.checkout co ON o.order_id = co.order_id
		JOIN ImaginInk.shopping_cart sc ON co.cart_id = sc.cart_id
		JOIN cart_items ci ON ci.cart_id = sc.cart_id
		WHERE c.customer_id = 1 AND ci.design_id = 2);
	SELECT @order_count;
	IF @order_count = 0 THEN ROLLBACK;
	ELSE COMMIT;
    END IF;
END //
DELIMITER ;
CALL add_review_transaction;

START TRANSACTION;
INSERT INTO ImaginInk.report (report_date, report_description, reporter_user_id, reported_design_id) VALUES
('2024-02-10', 'Copyright violation', 3, 1);
COMMIT;
```
3. A customer adds items to their cart, while the admin tries to view design analytics
   Non-conflicting since the sales count is not updated till the order has been placed, avoiding a read-write conflict
```SQL
START TRANSACTION;
INSERT INTO ImaginInk.cart_items (cart_id, product_id, design_id, price, quantity) VALUES
(17, 1, 1, 200, 2),
(17, 1, 2, 330, 3);
COMMIT;

START TRANSACTION;
SELECT
    d.design_id,
    d.title,
    d.price,
    d.sales_count,
    d.views_count,
    GROUP_CONCAT(t.tag_name) AS tags
FROM
    ImaginInk.design d
LEFT JOIN
    ImaginInk.design_tags dt ON d.design_id = dt.design_id
LEFT JOIN
    ImaginInk.tag t ON dt.tag_id = t.tag_id
GROUP BY
    d.design_id;
COMMIT;
```
4. The artist requests for assistance using the artist assist tool and uploads a design
   Non-conflicting transactions since they do not affect the same data
```SQL
START TRANSACTION;
INSERT INTO ImaginInk.artist_assist (request_date, description, request_status, request_closure_date, artist_id) VALUES
('2020-01-01', 'Unable to add tags', 'pending', NULL, 2);
COMMIT;

START TRANSACTION;
INSERT INTO ImaginInk.design (artist_id, title, description, image, creation_date, price, sales_count, views_count) VALUES
(2, 'Concrete Jungle', 'A cityscape of a bustling metropolis', 'concrete_jungle.jpg', '2020-01-01', 50, 0, 0);
COMMIT;
```
### Conflicting Transactions
---
5. Two customers add the same items to their cart and place the order at the same time.  
   Both the transactions would trigger a query to update the sales count of the designs and products
   LAST_INSERT_ID() could also be modified by the other transaction
   Conflict would occur if the transactions were not executed serially
```SQL
START TRANSACTION;
INSERT INTO ImaginInk.cart_items (cart_id, product_id, quantity, price, design_id) VALUES
(16, 1, 1, 100, 1);
INSERT INTO ImaginInk.order(order_date, delivery_date) VALUES
('2024-04-20', '2024-04-24');
INSERT INTO ImaginInk.checkout (cart_id, order_id) VALUES
(16, LAST_INSERT_ID());
COMMIT;

START TRANSACTION;
INSERT INTO ImaginInk.cart_items (cart_id, product_id, quantity, price, design_id) VALUES
(17, 1, 1, 100, 1);
INSERT INTO ImaginInk.order(order_date, delivery_date) VALUES
('2024-04-20', '2024-04-24');
INSERT INTO ImaginInk.checkout (cart_id, order_id) VALUES
(17, LAST_INSERT_ID());
COMMIT;
```
6. Deleting the artist triggers a query to delete all their designs as well as remove them from the carts
   Not executing these commands serially may allow the customer to add the deleted designs to their cart, causing conflict
```SQL
START TRANSACTION;
UPDATE ImaginInk.user
SET account_status = 'deleted'
WHERE user_id = 2;
COMMIT;

START TRANSACTION;
INSERT INTO ImaginInk.cart_items (cart_id, product_id, design_id, quantity, price) VALUES
(16, 1, 1, 100, 1);
COMMIT;
```

## Workflows
---
We have made a streamlitt application for the front-end of our project. It is a python library which provides tools for simple and easy to build user interfaces. The workflows of the different kinds of users are as follows along with their images.
### User
---
- Login Page
  ![](Pasted%20image%2020240420223729.png)
- Home Page
  ![](Pasted%20image%2020240420223800.png)
- Products Page
  ![](Pasted%20image%2020240420223841.png)
- Cart
  ![](Pasted%20image%2020240420223852.png)
- Order History
  ![](Pasted%20image%2020240420223909.png)
### Artist
---
- The login page for all the users is made common
- Artist Dashboard
  ![](Pasted%20image%2020240420223946.png)
- Manage Designs
  ![](Pasted%20image%2020240420224009.png)
- Upload Design
  ![](Pasted%20image%2020240420224027.png)
### Admin
---
- Dashboard
  ![](Pasted%20image%2020240420224054.png)
  ![](Pasted%20image%2020240420224117.png)
  ![](Pasted%20image%2020240420224127.png)
  ![](Pasted%20image%2020240420224135.png)
  ![](Pasted%20image%2020240420224144.png)
  ![Report](Pasted%20image%2020240420224151.png)
  
