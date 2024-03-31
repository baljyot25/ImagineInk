USE imaginink;

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

DELIMITER //
CREATE TRIGGER trg_add_design_tag AFTER INSERT ON ImaginInk.design_tags
FOR EACH ROW
BEGIN
    UPDATE ImaginInk.tag
    SET usage_count = usage_count + 1
    WHERE tag_id = NEW.tag_id;
END //

DELIMITER //
CREATE TRIGGER trg_remove_design_tag AFTER DELETE ON ImaginInk.design_tags
FOR EACH ROW
BEGIN
    UPDATE ImaginInk.tag
    SET usage_count = usage_count - 1
    WHERE tag_id = OLD.tag_id;
END //

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

