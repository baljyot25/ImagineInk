-- Contributions:
-- Saurav Mehra: Creating schema and data population
-- Baljyot Singh Modi: Creating schema and data population
-- Kushagra Gupta: Creating schema and data population
-- Mudit Bansal: Creating schema and data population

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ImaginInk
-- -----------------------------------------------------

DROP SCHEMA IF EXISTS ImaginInk;

CREATE SCHEMA ImaginInk;
USE ImaginInk;

-- -----------------------------------------------------
-- Table ImaginInk.user
-- -----------------------------------------------------
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
-- -----------------------------------------------------
-- Table ImaginInk.customer
-- -----------------------------------------------------
CREATE TABLE ImaginInk.customer (
  customer_id INT NOT NULL,
  address VARCHAR(255) NOT NULL,
  PRIMARY KEY (customer_id),
  FOREIGN KEY (customer_id) REFERENCES ImaginInk.user (user_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.artist
-- -----------------------------------------------------
CREATE TABLE ImaginInk.artist (
  artist_id INT NOT NULL,
  PRIMARY KEY (artist_id),
  FOREIGN KEY (artist_id) REFERENCES ImaginInk.user (user_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.design
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table ImaginInk.tags
-- -----------------------------------------------------
CREATE TABLE ImaginInk.tag (
  tag_id INT NOT NULL AUTO_INCREMENT,
  tag_name VARCHAR(45) NOT NULL,
  description VARCHAR(45),
  usage_count INT DEFAULT 0,
  PRIMARY KEY (tag_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.design_tags
-- -----------------------------------------------------
CREATE TABLE ImaginInk.design_tags (
  tag_id INT NOT NULL,
  design_id INT NOT NULL,
  PRIMARY KEY (tag_id, design_id),
  FOREIGN KEY (design_id) REFERENCES ImaginInk.design (design_id),
  FOREIGN KEY (tag_id) REFERENCES ImaginInk.tag (tag_id) 
  ON DELETE CASCADE
  ON UPDATE CASCADE
  );

-- -----------------------------------------------------
-- Table ImaginInk.artist_assist
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table ImaginInk.order
-- -----------------------------------------------------
CREATE TABLE ImaginInk.order (
  order_id INT NOT NULL AUTO_INCREMENT,
  order_date DATE NOT NULL,
  delivery_date DATE NOT NULL,
  delivery_status ENUM('shipped', 'pending', 'delivered') DEFAULT 'pending',
  PRIMARY KEY (order_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.shopping_cart
-- -----------------------------------------------------
CREATE TABLE ImaginInk.shopping_cart (
  cart_id INT NOT NULL AUTO_INCREMENT,
  grand_total INT DEFAULT 0,
  total_items INT DEFAULT 0,
  PRIMARY KEY (cart_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.product
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table ImaginInk.cart_items
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table ImaginInk.review
-- -----------------------------------------------------
CREATE TABLE ImaginInk.review (
  review_id INT NOT NULL AUTO_INCREMENT,
  customer_id INT NOT NULL,
  review_description VARCHAR(45) NOT NULL,
  review_date DATE NOT NULL,
  PRIMARY KEY (review_id),
  FOREIGN KEY (customer_id) REFERENCES ImaginInk.customer (customer_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.report
-- -----------------------------------------------------
CREATE TABLE ImaginInk.report (
  report_date DATE NOT NULL,
  report_description ENUM('Copyright violation', 'Hateful content') NOT NULL,
  reporter_user_id INT NOT NULL,
  reported_design_id INT NOT NULL,
  PRIMARY KEY (reported_design_id, reporter_user_id),
  FOREIGN KEY (reporter_user_id) REFERENCES ImaginInk.user (user_id),
  FOREIGN KEY (reported_design_id) REFERENCES ImaginInk.design (design_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.admin
-- -----------------------------------------------------
CREATE TABLE ImaginInk.admin (
  admin_id INT NOT NULL AUTO_INCREMENT,
  username VARCHAR(45) NOT NULL,
  password VARCHAR(45) NOT NULL,
  PRIMARY KEY (admin_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.view_history
-- -----------------------------------------------------
CREATE TABLE ImaginInk.view_history (
  order_id INT NOT NULL,
  customer_id INT NOT NULL,
  PRIMARY KEY (customer_id, order_id),
  FOREIGN KEY (order_id) REFERENCES ImaginInk.order (order_id),
  FOREIGN KEY (customer_id) REFERENCES ImaginInk.customer (customer_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.carry
-- -----------------------------------------------------
CREATE TABLE ImaginInk.carry (
  customer_id INT NOT NULL,
  cart_id INT NOT NULL,
  PRIMARY KEY (customer_id, cart_id),
  FOREIGN KEY (customer_id) REFERENCES ImaginInk.customer (customer_id),
  FOREIGN KEY (cart_id) REFERENCES ImaginInk.shopping_cart (cart_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.checkout
-- -----------------------------------------------------
CREATE TABLE ImaginInk.checkout (
  order_id INT NOT NULL,
  cart_id INT NOT NULL,
  PRIMARY KEY (order_id, cart_id),
  FOREIGN KEY (order_id) REFERENCES ImaginInk.order (order_id),
  FOREIGN KEY (cart_id) REFERENCES ImaginInk.shopping_cart (cart_id)
);

-- -----------------------------------------------------
-- Table ImaginInk.review_relates_to
-- -----------------------------------------------------
CREATE TABLE ImaginInk.review_relates_to (
  review_id INT NOT NULL,
  design_id INT NOT NULL,
  PRIMARY KEY (review_id, design_id),
  FOREIGN KEY (review_id) REFERENCES ImaginInk.review (review_id)
  ON DELETE CASCADE  
  ON UPDATE CASCADE,
  FOREIGN KEY (design_id) REFERENCES ImaginInk.design (design_id)
  
);

-- -----------------------------------------------------
-- Populating ImaginInk.user
-- -----------------------------------------------------
INSERT INTO ImaginInk.user (email_id, password, username, account_status, full_name, registration_date, last_login_date, account_type, payment_method) VALUES
('rahul@example.com', 'pass123', 'rahul_gupta', 'logged_in', 'Rahul Gupta', '2024-02-01', '2024-02-10', 'customer', 'Credit Card'),
('priya@example.com', 'securepass', 'priya_sharma', 'logged_in', 'Priya Sharma', '2024-02-02', '2024-02-10', 'artist', 'PayTM'),
('sandeep@example.com', 'password123', 'sandeep_kumar', 'logged_out', 'Sandeep Kumar', '2024-02-03', '2024-02-08', 'customer', 'Credit Card'),
('ananya@example.com', 'password321', 'ananya_patel', 'logged_in', 'Ananya Patel', '2024-02-04', '2024-02-10', 'artist', 'Google Pay'),
('amit@example.com', 'pass123', 'amit_singh', 'logged_in', 'Amit Singh', '2024-02-05', '2024-02-10', 'customer', 'Credit Card'),
('nisha@example.com', 'securepass', 'nisha_shah', 'logged_out', 'Nisha Shah', '2024-02-03', '2024-02-05', 'artist', 'PayTM'),
('rohit@example.com', 'password123', 'rohit_sharma', 'logged_in', 'Rohit Sharma', '2024-02-07', '2024-02-10', 'customer', 'Credit Card'),
('divya@example.com', 'pass123', 'divya_joshi', 'logged_in', 'Divya Joshi', '2024-02-08', '2024-02-10', 'artist', 'Google Pay'),
('saurabh@example.com', 'password321', 'saurabh_mishra', 'logged_out', 'Saurabh Mishra', '2024-02-01', '2024-02-02', 'customer', 'Credit Card'),
('pooja@example.com', 'securepass', 'pooja_verma', 'logged_in', 'Pooja Verma', '2024-02-10', '2024-02-10', 'artist', 'PayTM'),
('gaurav@example.com', 'pass123', 'gaurav_agarwal', 'logged_out', 'Gaurav Agarwal', '2024-02-09', '2024-02-10', 'customer', 'Bank Transfer'),
('meera@example.com', 'password123', 'meera_sharma', 'logged_in', 'Meera Sharma', '2024-02-09', '2024-02-10', 'artist', 'Credit Card'),
('vikram@example.com', 'securepass', 'vikram_singh', 'logged_out', 'Vikram Singh', '2024-02-01', '2024-02-08', 'customer', 'PayTM'),
('neha@example.com', 'pass123', 'neha_jain', 'logged_in', 'Neha Jain', '2024-02-01', '2024-02-10', 'artist', 'Credit Card'),
('raj@example.com', 'password321', 'raj_kumar', 'logged_out', 'Raj Kumar', '2024-02-01', '2024-02-06', 'customer', 'Google Pay'),
('rinku@example.com', 'securepass', 'rinku_sharma', 'logged_in', 'Rinku Sharma', '2024-02-01', '2024-02-10', 'artist', 'Credit Card'),
('sumit@example.com', 'pass123', 'sumit_gupta', 'logged_out', 'Sumit Gupta', '2024-02-02', '2024-02-11', 'customer', 'PayTM'),
('tanya@example.com', 'password123', 'tanya_singh', 'logged_in', 'Tanya Singh', '2024-02-03', '2024-02-10', 'artist', 'Credit Card'),
('akash@example.com', 'securepass', 'akash_sharma', 'logged_out', 'Akash Sharma', '2024-02-01', '2024-02-02', 'customer', 'Google Pay'),
('anu@example.com', 'pass123', 'anu_kumar', 'logged_in', 'Anu Kumar', '2024-02-04', '2024-02-10', 'artist', 'Credit Card'),
('anil@example.com', 'password321', 'anil_yadav', 'logged_out', 'Anil Yadav', '2024-02-02', '2024-02-10', 'customer', 'PayTM'),
('rekha@example.com', 'securepass', 'rekha_sharma', 'logged_in', 'Rekha Sharma', '2024-02-06', '2024-02-10', 'artist', 'Credit Card'),
('avinash@example.com', 'pass123', 'avinash_singh', 'logged_out', 'Avinash Singh', '2024-02-01', '2024-02-08', 'customer', 'Google Pay'),
('meenakshi@example.com', 'password123', 'meenakshi_patel', 'logged_in', 'Meenakshi Patel', '2024-02-02', '2024-02-10', 'artist', 'Credit Card'),
('sahil@example.com', 'securepass', 'sahil_sharma', 'logged_out', 'Sahil Sharma', '2024-02-02', '2024-02-06', 'customer', 'PayTM'),
('sonali@example.com', 'pass123', 'sonali_gupta', 'logged_in', 'Sonali Gupta', '2024-02-01', '2024-02-10', 'artist', 'Credit Card'),
('pradeep@example.com', 'password321', 'pradeep_kumar', 'logged_out', 'Pradeep Kumar', '2024-02-03', '2024-02-04', 'customer', 'Google Pay'),
('shivani@example.com', 'securepass', 'shivani_sharma', 'logged_in', 'Shivani Sharma', '2024-02-01', '2024-02-03', 'artist', 'Credit Card'),
('sunil@example.com', 'pass123', 'sunil_yadav', 'logged_out', 'Sunil Yadav', '2024-02-01', '2024-02-02', 'customer', 'PayTM'),
('monika@example.com', 'password123', 'monika_patel', 'logged_in', 'Monika Patel', '2024-02-01', '2024-02-01', 'artist', 'Credit Card');

-- -----------------------------------------------------
-- Populating ImaginInk.customer
-- -----------------------------------------------------
INSERT INTO ImaginInk.customer (customer_id, address) VALUES
(1, '123 Nehru Road, Mumbai, India'),
(3, '789 Patel Street, Bangalore, India'),
(5, '202 Gandhi Lane, Hyderabad, India'),
(7, '404 Nehru Road, Pune, India'),
(9, '606 Nehru Road, Ahmedabad, India'),
(11, '808 Gandhi Lane, Chandigarh, India'),
(13, '909 Nehru Road, Bhopal, India'),
(15, '1010 Patel Street, Indore, India'),
(17, '1111 Gandhi Lane, Surat, India'),
(19, '1212 Nehru Road, Varanasi, India'),
(21, '1313 Patel Street, Nagpur, India'),
(23, '1414 Gandhi Lane, Patna, India'),
(25, '1515 Nehru Road, Ranchi, India'),
(27, '1616 Patel Street, Raipur, India'),
(29, '1717 Gandhi Lane, Jaipur, India');

-- -----------------------------------------------------
-- Populating ImaginInk.artist
-- -----------------------------------------------------
INSERT INTO ImaginInk.artist (artist_id) VALUES
(2),
(4),
(6),
(8),
(10),
(12),
(14),
(16),
(18),
(20),
(22),
(24),
(26),
(28),
(30);

-- -----------------------------------------------------
-- Populating ImaginInk.design
-- -----------------------------------------------------
INSERT INTO ImaginInk.design (artist_id, title, description, image, creation_date, price, sales_count, views_count) VALUES
(2, 'Floral Bliss', 'Beautiful floral design', 'image1.jpg', '2024-02-01', 50, 1, 100),
(2, 'Serenity', 'Tranquil landscape design', 'image2.jpg', '2024-02-02', 60, 1, 150),
(4, 'Abstract Chaos', 'Vibrant abstract design', 'image3.jpg', '2024-02-03', 70, 1, 200),
(4, 'Ocean Dreams', 'Calming ocean-inspired design', 'image4.jpg', '2024-02-04', 80, 1, 250),
(6, 'Cityscape', 'Dynamic city skyline design', 'image5.jpg', '2024-02-05', 90, 1, 300),
(6, 'Wildlife Wonder', 'Captivating wildlife design', 'image6.jpg', '2024-02-06', 100, 1, 350),
(8, 'Sunset Glow', 'Warm sunset-themed design', 'image7.jpg', '2024-02-07', 110, 1, 400),
(8, 'Celestial Symphony', 'Ethereal celestial design', 'image8.jpg', '2024-02-08', 120, 1, 450),
(10, 'Vintage Vibes', 'Nostalgic vintage design', 'image9.jpg', '2024-02-09', 130, 1, 500),
(10, 'Modern Minimalism', 'Sleek modern design', 'image10.jpg', '2024-02-10', 140, 1, 550);

-- -----------------------------------------------------
-- Populating ImaginInk.tag
-- -----------------------------------------------------
INSERT INTO ImaginInk.tag (tag_name, description, usage_count) VALUES
('Nature', 'Designs inspired by nature', 4),
('Abstract', 'Abstract art designs', 3),
('Cityscape', 'Designs depicting cityscapes', 2),
('Floral', 'Designs featuring floral elements', 1),
('Ocean', 'Designs inspired by the ocean', 2),
('Wildlife', 'Designs showcasing wildlife', 2),
('Sunset', 'Designs capturing sunset scenes', 1),
('Vintage', 'Vintage-themed designs', 2),
('Modern', 'Modern and minimalist designs', 2),
('Celestial', 'Designs featuring celestial elements', 1);

-- -----------------------------------------------------
-- Populating ImaginInk.design_tags
-- -----------------------------------------------------
INSERT INTO ImaginInk.design_tags (tag_id, design_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(1, 2),
(4, 3),
(2, 3),
(5, 4),
(1, 4),
(3, 5),
(6, 5),
(2, 6),
(5, 6),
(7, 7),
(1, 7),
(8, 8),
(6, 8),
(9, 9),
(8, 9),
(10, 10),
(9, 10);

-- -----------------------------------------------------
-- Populating ImaginInk.artist_assist
-- -----------------------------------------------------
INSERT INTO ImaginInk.artist_assist (request_date, description, request_status, request_closure_date, artist_id) VALUES
('2024-02-01', 'Assistance with design concept', 'pending', NULL, 2),
('2024-02-02', 'Feedback on artwork composition', 'resolved', '2024-02-05', 4),
('2024-02-03', 'Guidance on color palette selection', 'resolved', '2024-02-06', 6),
('2024-02-04', 'Assistance with pricing strategy', 'pending', NULL, 8),
('2024-02-05', 'Feedback on design presentation', 'pending', NULL, 10),
('2024-02-06', 'Assistance with product packaging', 'resolved', '2024-02-10', 12),
('2024-02-07', 'Guidance on marketing strategy', 'pending', NULL, 14),
('2024-02-08', 'Feedback on portfolio creation', 'resolved', '2024-02-15', 16),
('2024-02-09', 'Assistance with art exhibition setup', 'resolved', '2024-02-20', 18),
('2024-02-10', 'Guidance on art promotion techniques', 'pending', NULL, 20);

-- -----------------------------------------------------
-- Populating ImaginInk.order
-- -----------------------------------------------------
INSERT INTO ImaginInk.order (order_date, delivery_date, delivery_status) VALUES
('2024-02-01', '2024-02-10', 'shipped'),
('2024-02-02', '2024-02-11', 'shipped'),
('2024-02-03', '2024-02-12', 'pending'),
('2024-02-04', '2024-02-13', 'pending'),
('2024-02-05', '2024-02-14', 'pending'),
('2024-02-06', '2024-02-15', 'pending'),
('2024-02-07', '2024-02-16', 'delivered'),
('2024-02-08', '2024-02-17', 'delivered'),
('2024-02-09', '2024-02-18', 'shipped'),
('2024-02-10', '2024-02-19', 'shipped');

-- -----------------------------------------------------
-- Populating ImaginInk.shopping_cart
-- -----------------------------------------------------
INSERT INTO ImaginInk.shopping_cart (grand_total, total_items) VALUES
(100, 1),
(110, 1),
(120, 1),
(130, 1),
(140, 1),
(150, 1),
(160, 1),
(170, 1),
(180, 1),
(190, 1),
(175, 2),
(0, 0),
(90, 1),
(220, 1),
(0, 0),
(0, 0),
(0, 0),
(0, 0),
(0, 0),
(0, 0),
(0, 0),
(0, 0),
(0, 0),
(0, 0),
(0, 0);

-- -----------------------------------------------------
-- Populating ImaginInk.product
-- -----------------------------------------------------
INSERT INTO ImaginInk.product (title, image, price, sales_count, dimensions) VALUES
('Canvas Print', 'canvas_print.jpg', 50, 10, '16x20'),
('T-Shirt', 'tshirt.jpg', 20, 0, 'S, M, L, XL'),
('Mug', 'mug.jpg', 15, 0, 'Standard'),
('Phone Case', 'phone_case.jpg', 25, 0, 'Various'),
('Poster', 'poster.jpg', 30, 0, '18x24'),
('Notebook', 'notebook.jpg', 10, 0, 'A5'),
('Pillow', 'pillow.jpg', 35, 0, 'Standard'),
('Tote Bag', 'tote_bag.jpg', 25, 0, 'Standard'),
('Mousepad', 'mousepad.jpg', 12, 0, 'Standard'),
('Coaster Set', 'coaster_set.jpg', 18, 0, 'Set of 4');

-- -----------------------------------------------------
-- Populating ImaginInk.cart_items
-- -----------------------------------------------------
INSERT INTO ImaginInk.cart_items (cart_id, product_id, quantity, price, design_id) VALUES
(1, 1, 1, 100, 1),
(2, 1, 1, 110, 2),
(3, 1, 1, 120, 3),
(4, 1, 1, 130, 4),
(5, 1, 1, 140, 5),
(6, 1, 1, 150, 6),
(7, 1, 1, 160, 7),
(8, 1, 1, 170, 8),
(9, 1, 1, 180, 9),
(10, 1, 1, 190, 10),
(11, 1, 2, 200, 1),
(11, 3, 1, 75, 2),
(13, 2, 1, 90, 3),
(14, 5, 2, 220, 4);

-- -----------------------------------------------------
-- Populating ImaginInk.report
-- -----------------------------------------------------
INSERT INTO ImaginInk.report (report_date, report_description, reporter_user_id, reported_design_id) VALUES
('2024-02-01', 'Copyright violation', 2, 10),
('2024-02-02', 'Copyright violation', 4, 9),
('2024-02-03', 'Copyright violation', 6, 8),
('2024-02-04', 'Hateful content', 8, 1),
('2024-02-05', 'Copyright violation', 10, 2),
('2024-02-06', 'Copyright violation', 12, 2),
('2024-02-07', 'Copyright violation', 14, 3),
('2024-02-08', 'Copyright violation', 16, 4),
('2024-02-09', 'Copyright violation', 18, 2),
('2024-02-10', 'Copyright violation', 20, 2);

-- -----------------------------------------------------
-- Populating ImaginInk.view_history
-- -----------------------------------------------------
INSERT INTO ImaginInk.view_history (order_id, customer_id) VALUES
(1, 1),
(2, 3),
(3, 5),
(4, 7),
(5, 9),
(6, 11),
(7, 13),
(8, 15),
(9, 17),
(10, 19);

-- -----------------------------------------------------
-- Populating ImaginInk.review
-- -----------------------------------------------------
INSERT INTO ImaginInk.review (customer_id, review_description, review_date) VALUES
(1, 'Extremely slow delivery!', '2024-02-01'),
(3, 'Still waiting for the product.', '2024-02-02'),
(13, 'Impressed with the quality, will buy again.', '2024-02-07'),
(15, 'Highly recommended, great customer service!', '2024-02-08'),
(17, 'Very happy with my purchase, thank you!', '2024-02-09'),
(19, 'Unique designs, excellent value.', '2024-02-10');

-- -----------------------------------------------------
-- Populating ImaginInk.carry
-- -----------------------------------------------------
INSERT INTO ImaginInk.carry (customer_id, cart_id) VALUES
(1, 16),
(3, 17),
(5, 18),
(7, 19),
(9, 20),
(11, 21),
(13, 22),
(15, 23),
(17, 24),
(19, 25),
(21, 11),
(23, 12),
(25, 13),
(27, 14),
(29, 15);

-- -----------------------------------------------------
-- Populating ImaginInk.checkout
-- -----------------------------------------------------
INSERT INTO ImaginInk.checkout (order_id, cart_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- -----------------------------------------------------
-- Populating ImaginInk.review_relates_to
-- -----------------------------------------------------
INSERT INTO ImaginInk.review_relates_to (review_id, design_id) VALUES
(1, 1),
(2, 2),
(3, 7),
(4, 8),
(5, 9),
(6, 10);

-- -----------------------------------------------------
-- Populating ImaginInk.admin
-- -----------------------------------------------------
INSERT INTO ImaginInk.admin (username, password) VALUES 
('admin1', 'admin123'),
('admin2', 'admin111'),
('admin3', 'admin012'),
('admin4', 'admin123456'),
('admin5', 'admin98765');

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;