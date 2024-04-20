USE ImaginInk;

-- Non-Conflicting Transactions

-- 1. Two customers add the same items to their respective carts
--    Non-conflicting since they read the same rows but write on independent rows
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

-- 2. Adding a customer's review for a product that they have ordered, while another customer reports that design
--    Non-conflicting transactions since they operate on independent rows
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

-- 3. A customer adds items to their cart, while the admin tries to view design analytics
--    Non-conflicting since the sales count is not updated till the order has been placed, avoiding a read-write conflict
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

-- 4. The artist requests for assistance using the artist assist tool and uploads a design
--    Non-conflicting transactions since they do not affect the same data
START TRANSACTION;
INSERT INTO ImaginInk.artist_assist (request_date, description, request_status, request_closure_date, artist_id) VALUES
('2020-01-01', 'Unable to add tags', 'pending', NULL, 2);
COMMIT;

START TRANSACTION;
INSERT INTO ImaginInk.design (artist_id, title, description, image, creation_date, price, sales_count, views_count) VALUES
(2, 'Concrete Jungle', 'A cityscape of a bustling metropolis', 'concrete_jungle.jpg', '2020-01-01', 50, 0, 0);
COMMIT;

-- Conflicting Transactions

-- 5. Two customers add the same items to their cart and place the order at the same time.
--    Both the transactions would trigger a query to update the sales count of the designs and products
--    LAST_INSERT_ID() could also be modified by the other transaction
--    Conflict would occur if the transactions were not executed serially
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

-- 6. Deleting the artist triggers a query to delete all their designs as well as remove them from the carts
--    Not executing these commands serially may allow the customer to add the deleted designs to their cart, causing conflict
START TRANSACTION;
UPDATE ImaginInk.user
SET account_status = 'deleted'
WHERE user_id = 2;
COMMIT;

START TRANSACTION;
INSERT INTO ImaginInk.cart_items (cart_id, product_id, design_id, quantity, price) VALUES
(16, 1, 1, 100, 1);
COMMIT;