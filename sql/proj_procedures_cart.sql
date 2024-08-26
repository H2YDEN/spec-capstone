-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add item to cart. 
    It verifies on insert:
    - duplicate entries will stack quantities with existing entry
    - quantity purchased must be > 0
*/
CREATE PROCEDURE AddToCart (
    IN new_UserID INTEGER,
    IN new_ProductID INTEGER,
    IN new_Quantity INTEGER
)
BEGIN
	DECLARE existing_quantity INT;
    
	SELECT Quantity 
    INTO existing_quantity
    FROM cart
    WHERE UserID = new_UserID AND ProductID = new_ProductID;
    
    IF existing_quantity IS NOT NULL AND new_Quantity > 0 THEN			-- if duplicate, then update quantity of existing item
		UPDATE cart
        SET Quantity = existing_quantity + new_Quantity
        WHERE UserID = new_UserID AND ProductID = new_ProductID;
	ELSE																-- if non-duplicate, insert as normal if quantity is more than 0
		CALL ValidateQuantity (new_Quantity);
        
		INSERT INTO cart (UserID, ProductID, DateAdded, Quantity)
		VALUES (new_UserID, new_ProductID, CURDATE(), new_Quantity);
	END IF;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetAllCart (
	IN param_UserID INTEGER
)
BEGIN
	SELECT *
	FROM cart
	WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE GetQuantity (
	IN param_UserID INTEGER,
    IN param_ProductID INTEGER,
    OUT return_Quantity INTEGER
)
BEGIN
	SELECT Quantity
    INTO return_Quantity
    FROM cart
    WHERE UserID = param_UserID AND ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetDate (
	IN param_UserID INTEGER,
    IN param_ProductID INTEGER,
    OUT return_Date DATE
)
BEGIN
	SELECT DateAdded
    INTO return_Date
    FROM cart
    WHERE UserID = param_UserID AND ProductID = param_ProductID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE SetQuantity (
    IN new_UserID INTEGER,
    IN new_ProductID INTEGER,
    IN new_Quantity INTEGER
)
BEGIN
	CALL ValidateQuantity (new_Quantity);
    
    UPDATE cart
    SET Quantity = new_Quantity
    WHERE UserID = new_UserID AND ProductID = new_ProductID;
END$$

CREATE PROCEDURE AddQuantity (
    IN new_UserID INTEGER,
    IN new_ProductID INTEGER,
    IN new_Quantity INTEGER
)
BEGIN
	CALL ValidateQuantity (new_Quantity);
    
    UPDATE cart
    SET Quantity = Quantity + new_Quantity
    WHERE UserID = new_UserID AND ProductID = new_ProductID;
END$$

CREATE PROCEDURE SubtractQuantity (
    IN new_UserID INTEGER,
    IN new_ProductID INTEGER,
    IN new_Quantity INTEGER
)
BEGIN
	CALL ValidateQuantity (new_Quantity);
    
    UPDATE cart
    SET Quantity = Quantity - new_Quantity
    WHERE UserID = new_UserID AND ProductID = new_ProductID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DELETE (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE DeleteAllCart (
	IN param_UserID INTEGER
)
BEGIN
	DELETE FROM cart
    WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE DeleteCartItem (
	IN param_UserID INTEGER,
    IN param_ProductID INTEGER
)
BEGIN
	DELETE FROM cart
    WHERE UserID = param_UserID AND ProductID = param_ProductID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DERIVED ATTRIBUTES
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetCartTotal (
	IN param_UserID INTEGER,
    OUT return_total_cost DECIMAL(20,2)
)
BEGIN
	SELECT SUM(p.Price * c.Quantity)
    INTO return_total_cost
    FROM cart c
    JOIN product p on c.ProductID = p.ProductID
    WHERE c.UserID = param_UserID;
END$$

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidateQuantity (
	IN param_Quantity INTEGER
)
BEGIN
	IF param_Quantity IS NOT NULL AND param_Quantity <= 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Quantity cannot be 0 or less.';
	END IF;
END$$


DELIMITER ;