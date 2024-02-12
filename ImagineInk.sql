-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`user`
-- -----------------------------------------------------

-- need to confirm about relationship between and admin.

CREATE TABLE IF NOT EXISTS `mydb`.`user` (
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



-- -----------------------------------------------------
-- Table `mydb`.`customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`customer` (
  `customer_user_id` INT NOT NULL AUTO_INCREMENT,
  `shipping_address` VARCHAR(45) NULL,
  `payment_information` VARCHAR(45) NULL,
  INDEX `user_id_idx` (`customer_user_id` ASC) VISIBLE,
  PRIMARY KEY (`customer_user_id`),
  CONSTRAINT `customer_user_id`
    FOREIGN KEY (`customer_user_id`)
    REFERENCES `mydb`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`artist`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`artist` (
  `artist_user_id` INT NOT NULL,
  `payment_information` VARCHAR(45) NULL,
  INDEX `user_id_idx` (`artist_user_id` ASC) VISIBLE,
  CONSTRAINT `artist_user_id`
    FOREIGN KEY (`artist_user_id`)
    REFERENCES `mydb`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`design`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`design` (
  `design_id` INT NOT NULL AUTO_INCREMENT,
  `designer_artist_id` INT NOT NULL,
  `title` VARCHAR(45) NOT NULL,
  `description` VARCHAR(100) NULL,
  `image` BLOB NOT NULL,
  `creation_date` DATE NULL DEFAULT (CURRENT_DATE),
  `price` INT NOT NULL,
  `sales_count` INT ZEROFILL NULL,
  `views_count` INT ZEROFILL NULL,
  `sales_revenue` INT ZEROFILL NULL,
  PRIMARY KEY (`design_id`),
  UNIQUE INDEX `design_id_UNIQUE` (`design_id` ASC) VISIBLE,
  INDEX `user_id_idx` (`designer_artist_id` ASC) VISIBLE,
  CONSTRAINT `designer_artist_id`
    FOREIGN KEY (`designer_artist_id`)
    REFERENCES `mydb`.`artist` (`artist_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`tags`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`tags` (
  `tag_id` INT NOT NULL AUTO_INCREMENT,
  `tag_name` VARCHAR(45) NOT NULL,
  `description` VARCHAR(45) NULL,
  `usage_count` INT ZEROFILL NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE INDEX `tag_name_UNIQUE` (`tag_name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`design_tags`
-- -----------------------------------------------------

-- need to verify the need of artist id here .
 
CREATE TABLE IF NOT EXISTS `mydb`.`design_tags` (
  `design_tag_id` INT NOT NULL,
  `design_id` INT NOT NULL,
  -- `artist_id` INT NOT NULL; 
  INDEX `design_id_idx` (`design_id` ASC) VISIBLE,
  INDEX `tag_id_idx` (`design_tag_id` ASC) VISIBLE,
  -- INDEX `artist_id_idx` (`artist_id` ASC) VISIBLE,
  PRIMARY KEY (`design_tag_id`, `design_id`),-- , `artist_id`),
  CONSTRAINT `design_id`
    FOREIGN KEY (`design_id`)
    REFERENCES `mydb`.`design` (`design_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `tag_id`
    FOREIGN KEY (`design_tag_id`)
    REFERENCES `mydb`.`tags` (`tag_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
  -- CONSTRAINT `artist_id`
--     FOREIGN KEY (`artist_id`)
--     REFERENCES `mydb`.`design` (`designer_artist_id`)
--     ON DELETE NO ACTION
--     ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`artist_assist`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`artist_assist` (
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
    REFERENCES `mydb`.`artist` (`artist_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`order`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`order` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `order_date` DATE NOT NULL,
  `delivery_date` DATE NOT NULL,
  `delivery_status` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`order_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`shopping_cart`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`shopping_cart` (
  `cart_id` INT NOT NULL AUTO_INCREMENT,
  -- `user_id` INT NOT NULL,
  `grand_total` INT ZEROFILL NULL,
  `total_items` INT ZEROFILL NULL,
  PRIMARY KEY (`cart_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`product`
-- -----------------------------------------------------
-- whatever customer selects go into the cart items , so no need to have an seperate entity
CREATE TABLE IF NOT EXISTS `mydb`.`product` (
  `product_id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(45) NOT NULL,
  `image` BLOB NOT NULL,
  `price` INT NOT NULL,
  `sales_count` INT ZEROFILL NULL,
  `dimensions` VARCHAR(4) NOT NULL,
  `sales_revenue` INT ZEROFILL NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE INDEX `title_UNIQUE` (`title` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`cart_items`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`cart_items` (
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
    REFERENCES `mydb`.`product` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `design_item_id`
    FOREIGN KEY (`design_item_id`)
    REFERENCES `mydb`.`design` (`design_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `shopping_cart_id`
    FOREIGN KEY (`shopping_cart_id`)
    REFERENCES `mydb`.`shopping_cart` (`cart_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`review`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`review` (
  `review_id` INT NOT NULL AUTO_INCREMENT,
  `reviewer_customer_id` INT NOT NULL,
  `review_description` VARCHAR(45) NOT NULL,
  `review_date` DATE NOT NULL,
  PRIMARY KEY (`review_id`),
  INDEX `user_id_idx` (`reviewer_customer_id` ASC) VISIBLE,
  CONSTRAINT `reviewer_customer_id`
    FOREIGN KEY (`reviewer_customer_id`)
    REFERENCES `mydb`.`customer` (`customer_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`report`
-- -----------------------------------------------------



CREATE TABLE IF NOT EXISTS `mydb`.`report` (
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
    REFERENCES `mydb`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `reported_design_id`
    FOREIGN KEY (`reported_design_id`)
    REFERENCES `mydb`.`design` (`design_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`admin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`admin` (
  `admin_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`admin_id`))
ENGINE = InnoDB;




-- -----------------------------------------------------
-- Table `mydb`.`view_history`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`view_history` (
  `history_order_id` INT NOT NULL,
  `customer_id` INT NOT NULL,
  PRIMARY KEY (`customer_id`, `history_order_id`),
  CONSTRAINT `history_order_id`
    FOREIGN KEY (`history_order_id`)
    REFERENCES `mydb`.`order` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `history_customer_id`
    FOREIGN KEY (`customer_id`)
    REFERENCES `mydb`.`customer` (`customer_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`carry`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`carry` (
  `carry_user_id` INT NOT NULL,
  `carry_cart_id` INT NOT NULL,
  PRIMARY KEY (`carry_user_id`, `carry_cart_id`),
  INDEX `carry_customer_id_idx` (`carry_cart_id` ASC) VISIBLE,
  CONSTRAINT `carry_user_id`
    FOREIGN KEY (`carry_user_id`)
    REFERENCES `mydb`.`customer` (`customer_user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `carry_customer_id`
    FOREIGN KEY (`carry_cart_id`)
    REFERENCES `mydb`.`shopping_cart` (`cart_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`checkout`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`checkout` (
  `checkout_order_id` INT NOT NULL,
  `checkout_cart_id` INT NOT NULL,
  PRIMARY KEY (`checkout_order_id`, `checkout_cart_id`),
  INDEX `checkout_cart_id_idx` (`checkout_cart_id` ASC) VISIBLE,
  CONSTRAINT `checkout_order_id`
    FOREIGN KEY (`checkout_order_id`)
    REFERENCES `mydb`.`order` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `checkout_cart_id`
    FOREIGN KEY (`checkout_cart_id`)
    REFERENCES `mydb`.`shopping_cart` (`cart_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`relates_to`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`relates_to` (
  `related_review_id` INT NOT NULL,
  `related_design_id` INT NOT NULL,
  PRIMARY KEY (`related_review_id`, `related_design_id`),
  INDEX `related_design_id_idx` (`related_design_id` ASC) VISIBLE,
  CONSTRAINT `related_review_id`
    FOREIGN KEY (`related_review_id`)
    REFERENCES `mydb`.`review` (`review_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `related_design_id`
    FOREIGN KEY (`related_design_id`)
    REFERENCES `mydb`.`design` (`design_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Populating `mydb`.`user`
-- -----------------------------------------------------
-- Populate user table
INSERT INTO `mydb`.`user` (`email_id`, `password`, `username`, `address`, `account_status`, `full_name`, `registration_date`, `last_login_date`, `account_type`) VALUES
('rahul@example.com', 'pass123', 'rahul_gupta', '123 Nehru Road, Mumbai, India', 'logged_in', 'Rahul Gupta', '2024-02-01', '2024-02-10', 'customer'),
('priya@example.com', 'securepass', 'priya_sharma', '456 Gandhi Lane, Delhi, India', 'logged_in', 'Priya Sharma', '2024-02-02', '2024-02-09', 'artist'),
('sandeep@example.com', 'password123', 'sandeep_kumar', '789 Patel Street, Bangalore, India', 'logged_out', 'Sandeep Kumar', '2024-02-03', '2024-02-08', 'customer'),
('ananya@example.com', 'password321', 'ananya_patel', '101 Nehru Road, Kolkata, India', 'logged_in', 'Ananya Patel', '2024-02-04', '2024-02-07', 'artist'),
('amit@example.com', 'pass123', 'amit_singh', '202 Gandhi Lane, Hyderabad, India', 'logged_in', 'Amit Singh', '2024-02-05', '2024-02-06', 'customer'),
('nisha@example.com', 'securepass', 'nisha_shah', '303 Patel Street, Chennai, India', 'logged_out', 'Nisha Shah', '2024-02-06', '2024-02-05', 'artist'),
('rohit@example.com', 'password123', 'rohit_sharma', '404 Nehru Road, Pune, India', 'logged_in', 'Rohit Sharma', '2024-02-07', '2024-02-04', 'customer'),
('divya@example.com', 'pass123', 'divya_joshi', '505 Gandhi Lane, Jaipur, India', 'logged_in', 'Divya Joshi', '2024-02-08', '2024-02-03', 'artist'),
('saurabh@example.com', 'password321', 'saurabh_mishra', '606 Nehru Road, Ahmedabad, India', 'logged_out', 'Saurabh Mishra', '2024-02-09', '2024-02-02', 'customer'),
('pooja@example.com', 'securepass', 'pooja_verma', '707 Patel Street, Lucknow, India', 'logged_in', 'Pooja Verma', '2024-02-10', '2024-02-01', 'artist'),
('gaurav@example.com', 'pass123', 'gaurav_agarwal', '808 Gandhi Lane, Chandigarh, India', 'logged_out', 'Gaurav Agarwal', '2024-02-11', '2024-02-10', 'customer'),
('meera@example.com', 'password123', 'meera_sharma', '909 Nehru Road, Bhopal, India', 'logged_in', 'Meera Sharma', '2024-02-12', '2024-02-09', 'artist'),
('vikram@example.com', 'securepass', 'vikram_singh', '1010 Patel Street, Indore, India', 'logged_out', 'Vikram Singh', '2024-02-13', '2024-02-08', 'customer'),
('neha@example.com', 'pass123', 'neha_jain', '1111 Gandhi Lane, Surat, India', 'logged_in', 'Neha Jain', '2024-02-14', '2024-02-07', 'artist'),
('raj@example.com', 'password321', 'raj_kumar', '1212 Nehru Road, Varanasi, India', 'logged_out', 'Raj Kumar', '2024-02-15', '2024-02-06', 'customer'),
('rinku@example.com', 'securepass', 'rinku_sharma', '1313 Patel Street, Nagpur, India', 'logged_in', 'Rinku Sharma', '2024-02-16', '2024-02-05', 'artist'),
('sumit@example.com', 'pass123', 'sumit_gupta', '1414 Gandhi Lane, Patna, India', 'logged_out', 'Sumit Gupta', '2024-02-17', '2024-02-04', 'customer'),
('tanya@example.com', 'password123', 'tanya_singh', '1515 Nehru Road, Ranchi, India', 'logged_in', 'Tanya Singh', '2024-02-18', '2024-02-03', 'artist'),
('akash@example.com', 'securepass', 'akash_sharma', '1616 Patel Street, Raipur, India', 'logged_out', 'Akash Sharma', '2024-02-19', '2024-02-02', 'customer'),
('anu@example.com', 'pass123', 'anu_kumar', '1717 Gandhi Lane, Jaipur, India', 'logged_in', 'Anu Kumar', '2024-02-20', '2024-02-01', 'artist'),
('anil@example.com', 'password321', 'anil_yadav', '1818 Nehru Road, Allahabad, India', 'logged_out', 'Anil Yadav', '2024-02-21', '2024-02-10', 'customer'),
('rekha@example.com', 'securepass', 'rekha_sharma', '1919 Patel Street, Guwahati, India', 'logged_in', 'Rekha Sharma', '2024-02-22', '2024-02-09', 'artist'),
('avinash@example.com', 'pass123', 'avinash_singh', '2020 Gandhi Lane, Coimbatore, India', 'logged_out', 'Avinash Singh', '2024-02-23', '2024-02-08', 'customer'),
('meenakshi@example.com', 'password123', 'meenakshi_patel', '2121 Nehru Road, Kochi, India', 'logged_in', 'Meenakshi Patel', '2024-02-24', '2024-02-07', 'artist'),
('sahil@example.com', 'securepass', 'sahil_sharma', '2222 Patel Street, Thiruvananthapuram, India', 'logged_out', 'Sahil Sharma', '2024-02-25', '2024-02-06', 'customer'),
('sonali@example.com', 'pass123', 'sonali_gupta', '2323 Gandhi Lane, Pune, India', 'logged_in', 'Sonali Gupta', '2024-02-26', '2024-02-05', 'artist'),
('pradeep@example.com', 'password321', 'pradeep_kumar', '2424 Nehru Road, Chennai, India', 'logged_out', 'Pradeep Kumar', '2024-02-27', '2024-02-04', 'customer'),
('shivani@example.com', 'securepass', 'shivani_sharma', '2525 Patel Street, Bengaluru, India', 'logged_in', 'Shivani Sharma', '2024-02-28', '2024-02-03', 'artist'),
('sunil@example.com', 'pass123', 'sunil_yadav', '2626 Gandhi Lane, Mumbai, India', 'logged_out', 'Sunil Yadav', '2024-02-29', '2024-02-02', 'customer'),
('monika@example.com', 'password123', 'monika_patel', '2727 Nehru Road, Delhi, India', 'logged_in', 'Monika Patel', '2024-03-01', '2024-02-01', 'artist');

-- -----------------------------------------------------
-- Populating `mydb`.`customer`
-- -----------------------------------------------------
INSERT INTO `mydb`.`customer` (`customer_user_id`, `shipping_address`, `payment_information`) VALUES
(1, '123 Nehru Road, Mumbai, India', 'Credit Card'),
(3, '789 Patel Street, Bangalore, India', 'PayPal'),
(5, '202 Gandhi Lane, Hyderabad, India', 'Credit Card'),
(7, '404 Nehru Road, Pune, India', 'Google Pay'),
(9, '606 Nehru Road, Ahmedabad, India', 'Credit Card'),
(11, '808 Gandhi Lane, Chandigarh, India', 'PayPal'),
(13, '909 Nehru Road, Bhopal, India', 'Credit Card'),
(15, '1010 Patel Street, Indore, India', 'Google Pay'),
(17, '1111 Gandhi Lane, Surat, India', 'Credit Card'),
(19, '1212 Nehru Road, Varanasi, India', 'PayPal'),
(21, '1313 Patel Street, Nagpur, India', 'Credit Card'),
(23, '1414 Gandhi Lane, Patna, India', 'Google Pay'),
(25, '1515 Nehru Road, Ranchi, India', 'Credit Card'),
(27, '1616 Patel Street, Raipur, India', 'PayPal'),
(29, '1717 Gandhi Lane, Jaipur, India', 'Credit Card');

-- Populate artist table
INSERT INTO `mydb`.`artist` (`artist_user_id`, `payment_information`) VALUES
(2, 'Bank Transfer'),
(4, 'PayPal'),
(6, 'Credit Card'),
(8, 'Bank Transfer'),
(10, 'PayPal'),
(12, 'Credit Card'),
(14, 'Bank Transfer'),
(16, 'PayPal'),
(18, 'Credit Card'),
(20, 'Bank Transfer');

-- Populate design table
INSERT INTO `mydb`.`design` (`designer_artist_id`, `title`, `description`, `image`, `creation_date`, `price`, `sales_count`, `views_count`, `sales_revenue`) VALUES
(2, 'Floral Bliss', 'Beautiful floral design', 'image1.jpg', '2024-02-01', 50, 20, 100, 500),
(2, 'Serenity', 'Tranquil landscape design', 'image2.jpg', '2024-02-02', 60, 30, 150, 600),
(4, 'Abstract Chaos', 'Vibrant abstract design', 'image3.jpg', '2024-02-03', 70, 40, 200, 700),
(4, 'Ocean Dreams', 'Calming ocean-inspired design', 'image4.jpg', '2024-02-04', 80, 50, 250, 800),
(6, 'Cityscape', 'Dynamic city skyline design', 'image5.jpg', '2024-02-05', 90, 60, 300, 900),
(6, 'Wildlife Wonder', 'Captivating wildlife design', 'image6.jpg', '2024-02-06', 100, 70, 350, 1000),
(8, 'Sunset Glow', 'Warm sunset-themed design', 'image7.jpg', '2024-02-07', 110, 80, 400, 1100),
(8, 'Celestial Symphony', 'Ethereal celestial design', 'image8.jpg', '2024-02-08', 120, 90, 450, 1200),
(10, 'Vintage Vibes', 'Nostalgic vintage design', 'image9.jpg', '2024-02-09', 130, 100, 500, 1300),
(10, 'Modern Minimalism', 'Sleek modern design', 'image10.jpg', '2024-02-10', 140, 110, 550, 1400);

-- Populate tags table
INSERT INTO `mydb`.`tags` (`tag_name`, `description`, `usage_count`) VALUES
('Nature', 'Designs inspired by nature', 0),
('Abstract', 'Abstract art designs', 0),
('Cityscape', 'Designs depicting cityscapes', 0),
('Floral', 'Designs featuring floral elements', 0),
('Ocean', 'Designs inspired by the ocean', 0),
('Wildlife', 'Designs showcasing wildlife', 0),
('Sunset', 'Designs capturing sunset scenes', 0),
('Vintage', 'Vintage-themed designs', 0),
('Modern', 'Modern and minimalist designs', 0),
('Celestial', 'Designs featuring celestial elements', 0);

-- Populate design_tags table
INSERT INTO `mydb`.`design_tags` (`design_tag_id`, `design_id`) VALUES
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

-- Populate artist_assist table
INSERT INTO `mydb`.`artist_assist` (`request_date`, `description`, `request_status`, `request_closure_date`, `request_artist_id`) VALUES
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

-- Populate order table
INSERT INTO `mydb`.`order` (`order_date`, `delivery_date`, `delivery_status`) VALUES
('2024-02-01', '2024-02-10', 'shipped'),
('2024-02-02', '2024-02-11', 'shipped'),
('2024-02-03', '2024-02-12', 'processing'),
('2024-02-04', '2024-02-13', 'processing'),
('2024-02-05', '2024-02-14', 'pending'),
('2024-02-06', '2024-02-15', 'pending'),
('2024-02-07', '2024-02-16', 'delivered'),
('2024-02-08', '2024-02-17', 'delivered'),
('2024-02-09', '2024-02-18', 'shipped'),
('2024-02-10', '2024-02-19', 'shipped');

-- Repopulate shopping_cart table
INSERT INTO `mydb`.`shopping_cart` (`grand_total`, `total_items`) VALUES
(160, 3),
(80, 1),
(100, 2),
(135, 4),
(120, 2),
(55, 1),
(80, 2),
(145, 3),
(180, 2),
(190, 5);

-- Repopulate product table
INSERT INTO `mydb`.`product` (`title`, `image`, `price`, `sales_count`, `dimensions`, `sales_revenue`) VALUES
('Canvas Print', 'canvas_print.jpg', 50, 10, '16x20', 500),
('T-Shirt', 'tshirt.jpg', 20, 5, 'S, M, L, XL', 100),
('Mug', 'mug.jpg', 15, 15, 'Standard', 225),
('Phone Case', 'phone_case.jpg', 25, 20, 'Various', 500),
('Poster', 'poster.jpg', 30, 8, '18x24', 240),
('Notebook', 'notebook.jpg', 10, 12, 'A5', 120),
('Pillow', 'pillow.jpg', 35, 18, 'Standard', 630),
('Tote Bag', 'tote_bag.jpg', 25, 10, 'Standard', 250),
('Mousepad', 'mousepad.jpg', 12, 25, 'Standard', 300),
('Coaster Set', 'coaster_set.jpg', 18, 30, 'Set of 4', 540);

-- Repopulate cart_items table
INSERT INTO `mydb`.`cart_items` (`shopping_cart_id`, `product_item_id`, `quantity`, `price`, `design_item_id`) VALUES
(1, 1, 2, 100, 1),
(1, 3, 1, 30, 2),
(2, 2, 1, 20, 3),
(3, 5, 2, 40, 4),
(3, 7, 1, 25, 5),
(3, 8, 1, 35, 6),
(4, 4, 1, 15, 7),
(5, 6, 1, 10, 8),
(6, 10, 1, 18, 9),
(7, 9, 2, 24, 10);

-- Repopulate report table with reports of copyright infringements
INSERT INTO `mydb`.`report` (`report_date`, `report_description`, `reporter_user_id`, `reported_design_id`) VALUES
('2024-02-01', 'Copyright violation', 2, 1),
('2024-02-02', 'Copyright violation', 4, 3),
('2024-02-03', 'Copyright violation', 6, 5),
('2024-02-04', 'Copyright violation', 8, 7),
('2024-02-05', 'Copyright violation', 10, 9),
('2024-02-06', 'Copyright violation', 12, 11),
('2024-02-07', 'Copyright violation', 14, 13),
('2024-02-08', 'Copyright violation', 16, 15),
('2024-02-09', 'Copyright violation', 18, 17),
('2024-02-10', 'Copyright violation', 20, 19);

-- Repopulate view_history table
INSERT INTO `mydb`.`view_history` (`history_order_id`, `customer_id`) VALUES
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

-- Existing data in the review table
INSERT INTO `mydb`.`review` (`reviewer_customer_id`, `review_description`, `review_date`) VALUES
(1, 'Great product, fast delivery!', '2024-02-01'),
(3, 'Excellent quality, very satisfied!', '2024-02-02'),
(5, 'Good experience overall, would recommend.', '2024-02-03'),
(7, 'Product exactly as described, thank you!', '2024-02-04'),
(9, 'Beautiful design, love it!', '2024-02-05'),
(11, 'Fast shipping, thank you!', '2024-02-06'),
(13, 'Impressed with the quality, will buy again.', '2024-02-07'),
(15, 'Highly recommended, great customer service!', '2024-02-08'),
(17, 'Very happy with my purchase, thank you!', '2024-02-09'),
(19, 'Unique designs, excellent value.', '2024-02-10');

-- Populate carry table
INSERT INTO `mydb`.`carry` (`carry_user_id`, `carry_cart_id`) VALUES
(1, 1),
(3, 2),
(5, 3),
(7, 4),
(9, 5),
(11, 6),
(13, 7),
(15, 8),
(17, 9),
(19, 10);

-- Populate checkout table
INSERT INTO `mydb`.`checkout` (`checkout_order_id`, `checkout_cart_id`) VALUES
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

-- Populate relates_to table
INSERT INTO `mydb`.`relates_to` (`related_review_id`, `related_design_id`) VALUES
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

--Populate admin table
INSERT INTO `mydb`.`admin` (`username`, `password`) VALUES 
('admin1', 'admin123'),
('admin2', 'admin111'),
('admin3', 'admin012'),
('admin4', 'admin123456'),
('admin5', 'admin98765');

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
