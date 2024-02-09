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
-- Table `mydb`.`manage_designs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`manage_designs` (
  `managing_admin_id` INT NOT NULL,
  PRIMARY KEY (`managing_admin_id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
