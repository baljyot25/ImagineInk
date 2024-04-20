# Project ImaginInk

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
	- **Leave a review:**
	  Customers can share their feedback and experiences, contributing to the community and helping artists improve.
	- **Report:**
	  Customers would be able to report designs containing offensive content or those that infringe upon intellectual property rights.

- **Artist:**
	- **Login/Signup:**
	  Artists will have the option to create a new account or log in to an already existing account, while ensuring that each email address is uniquely linked to a single account.
	- **Upload Design:**
	  Artists would be able to upload their designs to the database, specify their price, and label the product with appropriate tags.
	- **Receive payment:**
	  Artists would be compensated on a commission basis for each sale of their respective products.
	- **Artist help:**
	  Artists can seek assistance for navigating the platform and addressing any issues they encounter.
	- **View user analytics:**
	  Artists would be able to view how many times their design was viewed, number of search appearances, and the number of sales.

- **Admin:**
	- **Add/Remove accounts:**
	  Admins would have the ability to add or remove customer and artist accounts.
	- **Manage reports:**
	  Admins would be able to view reports raised by customers and artists and subsequently take appropriate actions in order to resolve the highlighted issues.
	- **Manage designs:**
	  Admins will have the option to view all uploaded designs and modify or remove the product.
	- **View analytics:**
	  Admins would be able to view both customer and artist analytics, such as the number of customer and artist accounts, trending search queries and top-selling products.
	- **Due deliveries:**
	  Admins would be able to monitor and manage the timely delivery of purchased prints to customers.

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
**![](https://lh7-us.googleusercontent.com/2Q33hvtScEgEYdQ1XsFzY6kYyriNS5hyQUQyghdUMa2050Ou4kjfqL8lm8BzREyCmFkkKVeYmsQGoV57c_tECxiafWRrGY5sQJixHDqOGAVyR5hAelIDsjTD3cUcoKoKZsF1wWFouo9HlrLZUMICw2s)**

## Implementation of Schema
- Table `ImaginInk.users`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`users` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `email_id` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `username` VARCHAR(45) NOT NULL,
  `address` VARCHAR(85) NOT NULL,
  `account_status` VARCHAR(25) NOT NULL, -- deleted/logged in /logged out....
  `full_name` VARCHAR(45) NOT NULL,
  `registration_date` DATE NOT NULL DEFAULT (CURRENT_DATE),
  `last_login_date` DATE NOT NULL DEFAULT (CURRENT_DATE),
  `account_type` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `email_id_UNIQUE` (`email_id` ASC) VISIBLE)
ENGINE = InnoDB;
```
- Table `ImaginInk.customers`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`customers` (
  `customer_user_id` INT NOT NULL AUTO_INCREMENT,
  `shipping_address` VARCHAR(45) NULL,
  `payment_information` VARCHAR(45) NULL,
  INDEX `user_id_idx` (`customer_user_id` ASC) VISIBLE,
  PRIMARY KEY (`customer_user_id`),
  CONSTRAINT `customer_user_id`
    FOREIGN KEY (`customer_user_id`)
    REFERENCES `ImaginInk`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.artists`
  ```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`artists` (
	`artist_user_id` INT NOT NULL,
	`payment_information` VARCHAR(45) NULL,
	INDEX `user_id_idx` (`artist_user_id` ASC) VISIBLE,
	CONSTRAINT `artist_user_id`
	FOREIGN KEY (`artist_user_id`)
	REFERENCES `ImaginInk`.`users` (`user_id`)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.designs`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`designs` (
  `design_id` INT NOT NULL AUTO_INCREMENT,
  `designer_artist_id` INT NOT NULL,
  `title` VARCHAR(45) NOT NULL,
  `description` VARCHAR(100) NULL,
  `image` BLOB NOT NULL,
  `creation_date` DATE NULL DEFAULT (CURRENT_DATE),
  `price` INT NOT NULL,
  `sales_count` INT NULL,
  `views_count` INT NULL,
  `sales_revenue` INT NULL,
  PRIMARY KEY (`design_id`),
  UNIQUE INDEX `design_id_UNIQUE` (`design_id` ASC) VISIBLE,
  INDEX `user_id_idx` (`designer_artist_id` ASC) VISIBLE,
  CONSTRAINT `designer_artist_id`
    FOREIGN KEY (`designer_artist_id`)
    REFERENCES `ImaginInk`.`artists` (`artist_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.tags`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`tags` (
  `tag_id` INT NOT NULL AUTO_INCREMENT,
  `tag_name` VARCHAR(45) NOT NULL,
  `description` VARCHAR(45) NULL,
  `usage_count` INT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE INDEX `tag_name_UNIQUE` (`tag_name` ASC) VISIBLE)
ENGINE = InnoDB;
```
- Table `ImaginInk.design_tags`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`design_tags` (
  `design_tag_id` INT NOT NULL,
  `design_id` INT NOT NULL,
  -- `artist_id` INT NOT NULL; 
  INDEX `design_id_idx` (`design_id` ASC) VISIBLE,
  INDEX `tag_id_idx` (`design_tag_id` ASC) VISIBLE,
  -- INDEX `artist_id_idx` (`artist_id` ASC) VISIBLE,
  PRIMARY KEY (`design_tag_id`, `design_id`),-- , `artist_id`),
  CONSTRAINT `design_id`
    FOREIGN KEY (`design_id`)
    REFERENCES `ImaginInk`.`designs` (`design_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `tag_id`
    FOREIGN KEY (`design_tag_id`)
    REFERENCES `ImaginInk`.`tags` (`tag_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
  -- CONSTRAINT `artist_id`
--     FOREIGN KEY (`artist_id`)
--     REFERENCES `ImaginInk`.`design` (`designer_artist_id`)
--     ON DELETE NO ACTION
--     ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.artist_assist`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`artist_assist` (
  `request_id` INT NOT NULL AUTO_INCREMENT,
  `request_date` DATE NULL DEFAULT (CURRENT_DATE),
  `description` VARCHAR(100) NOT NULL,
  `request_status` VARCHAR(10) NULL,
  `request_closure_date` DATE NULL,
  `request_artist_id` INT NOT NULL,
  PRIMARY KEY (`request_id`),
  INDEX `artist_user_id_idx` (`request_artist_id` ASC) VISIBLE,
  CONSTRAINT `resuest_artist_id`
    FOREIGN KEY (`request_artist_id`)
    REFERENCES `ImaginInk`.`artists` (`artist_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.orders`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`orders` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `order_date` DATE NOT NULL,
  `delivery_date` DATE NOT NULL,
  `delivery_status` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`order_id`))
ENGINE = InnoDB;
```
- Table `ImaginInk.shopping_carts`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`shopping_carts` (
  `cart_id` INT NOT NULL AUTO_INCREMENT,
  -- `user_id` INT NOT NULL,
  `grand_total` INT NULL,
  `total_items` INT NULL,
  PRIMARY KEY (`cart_id`))
ENGINE = InnoDB;
```
- Table `ImaginInk.products`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`products` (
  `product_id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(45) NOT NULL,
  `image` BLOB NOT NULL,
  `price` INT NOT NULL,
  `sales_count` INT NULL,
  `dimensions` VARCHAR(40) NOT NULL,
  `sales_revenue` INT NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE INDEX `title_UNIQUE` (`title` ASC) VISIBLE)
ENGINE = InnoDB;
```
- Table `ImaginInk.cart_items`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`cart_items` (
  `shopping_cart_id` INT NOT NULL,
  `product_item_id` INT NOT NULL,
  `design_item_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `price` INT NOT NULL,
  INDEX `product_item_id_idx` (`product_item_id` ASC) VISIBLE,
  INDEX `design_item_id_idx` (`design_item_id` ASC) VISIBLE,
  INDEX `cart_id_idx` (`shopping_cart_id` ASC) VISIBLE,
  PRIMARY KEY (`shopping_cart_id`, `product_item_id`, `design_item_id`),
  CONSTRAINT `product_item_id`
    FOREIGN KEY (`product_item_id`)
    REFERENCES `ImaginInk`.`products` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `design_item_id`
    FOREIGN KEY (`design_item_id`)
    REFERENCES `ImaginInk`.`designs` (`design_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `shopping_cart_id`
    FOREIGN KEY (`shopping_cart_id`)
    REFERENCES `ImaginInk`.`shopping_carts` (`cart_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.reviews`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`reviews` (
  `review_id` INT NOT NULL AUTO_INCREMENT,
  `reviewer_customer_id` INT NOT NULL,
  `review_description` VARCHAR(45) NOT NULL,
  `review_date` DATE NOT NULL,
  PRIMARY KEY (`review_id`),
  INDEX `user_id_idx` (`reviewer_customer_id` ASC) VISIBLE,
  CONSTRAINT `reviewer_customer_id`
    FOREIGN KEY (`reviewer_customer_id`)
    REFERENCES `ImaginInk`.`customers` (`customer_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.reports`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`reports` (
 --  `report_id` INT NOT NULL AUTO_INCREMENT,
  `report_date` VARCHAR(45) NOT NULL,
  `report_description` VARCHAR(45) NOT NULL,
  `reporter_user_id` INT NOT NULL,
  `reported_design_id` INT NOT NULL,
  PRIMARY KEY (`reported_design_id` ,`reporter_user_id` ),
  INDEX `reporter_user_id_idx` (`reporter_user_id` ASC) VISIBLE,
  INDEX `reported_design_id_idx` (`reported_design_id` ASC) VISIBLE,
  CONSTRAINT `reporter_user_id`
    FOREIGN KEY (`reporter_user_id`)
    REFERENCES `ImaginInk`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `reported_design_id`
    FOREIGN KEY (`reported_design_id`)
    REFERENCES `ImaginInk`.`designs` (`design_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.admin`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`admins` (
  `admin_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`admin_id`))
ENGINE = InnoDB;
```
- Table `ImaginInk.view_history`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`view_history` (
  `history_order_id` INT NOT NULL,
  `customer_id` INT NOT NULL,
  PRIMARY KEY (`customer_id`, `history_order_id`),
  CONSTRAINT `history_order_id`
    FOREIGN KEY (`history_order_id`)
    REFERENCES `ImaginInk`.`orders` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `history_customer_id`
    FOREIGN KEY (`customer_id`)
    REFERENCES `ImaginInk`.`customers` (`customer_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.carry`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`carry` (
  `carry_user_id` INT NOT NULL,
  `carry_cart_id` INT NOT NULL,
  PRIMARY KEY (`carry_user_id`, `carry_cart_id`),
  INDEX `carry_customer_id_idx` (`carry_cart_id` ASC) VISIBLE,
  CONSTRAINT `carry_user_id`
    FOREIGN KEY (`carry_user_id`)
    REFERENCES `ImaginInk`.`customers` (`customer_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `carry_customer_id`
    FOREIGN KEY (`carry_cart_id`)
    REFERENCES `ImaginInk`.`shopping_carts` (`cart_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.checkout`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`checkout` (
  `checkout_order_id` INT NOT NULL,
  `checkout_cart_id` INT NOT NULL,
  PRIMARY KEY (`checkout_order_id`, `checkout_cart_id`),
  INDEX `checkout_cart_id_idx` (`checkout_cart_id` ASC) VISIBLE,
  CONSTRAINT `checkout_order_id`
    FOREIGN KEY (`checkout_order_id`)
    REFERENCES `ImaginInk`.`orders` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `checkout_cart_id`
    FOREIGN KEY (`checkout_cart_id`)
    REFERENCES `ImaginInk`.`shopping_carts` (`cart_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```
- Table `ImaginInk.related_to`
```SQL
CREATE TABLE IF NOT EXISTS `ImaginInk`.`relates_to` (
  `related_review_id` INT NOT NULL,
  `related_design_id` INT NOT NULL,
  PRIMARY KEY (`related_review_id`, `related_design_id`),
  INDEX `related_design_id_idx` (`related_design_id` ASC) VISIBLE,
  CONSTRAINT `related_review_id`
    FOREIGN KEY (`related_review_id`)
    REFERENCES `ImaginInk`.`reviews` (`review_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `related_design_id`
    FOREIGN KEY (`related_design_id`)
    REFERENCES `ImaginInk`.`designs` (`design_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
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