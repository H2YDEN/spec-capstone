-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add newly purchased items.
    It verifies on insert:
    - quantity purchased must be > 0
    It automatically:
	- adds the price of current product listed
*/
CREATE PROCEDURE AddNewPurchase (
	IN new_TransactionID INTEGER,
    IN new_ProductID INTEGER,
    IN new_Quantity INTEGER
)
BEGIN
	DECLARE currentProductPrice DECIMAL(20, 2);
    
    CALL ValidatePurchaseQuantity (new_Quantity);
    
	SELECT Price
    INTO currentProductPrice
	FROM product
	WHERE new_ProductID = ProductID;
    
	INSERT INTO purchases (TransactionID, ProductID, PriceAtTheTime, Quantity)
	VALUES (new_TransactionID, new_ProductID, currentProductPrice, new_Quantity);
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetFullTransaction (
	IN param_TransactionID INTEGER
)
BEGIN
	SELECT *
    FROM purchases
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE GetQuantityOfAProduct (
    IN param_TransactionID INTEGER,
    IN param_ProductID INTEGER,
    OUT return_Quantity INTEGER
)
BEGIN
    SELECT Quantity
    INTO return_Quantity
    FROM purchases
    WHERE TransactionID = param_TransactionID AND ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetNumberOfDistinctProducts (
	IN param_TransactionID INTEGER,
    OUT return_Total_Distinct INTEGER
)
BEGIN
    SELECT COUNT(DISTINCT ProductID)
    INTO return_Total_Distinct
    FROM purchases
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE GetTotalQuantityOfProducts (
	IN param_TransactionID INTEGER,
    OUT return_Total_Quantity INTEGER
)
BEGIN
	SELECT SUM(Quantity)
    INTO return_Total_Quantity
    FROM purchases
    WHERE TransactionID = param_TransactionID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidatePurchaseQuantity (
	IN param_Quantity INTEGER
)
BEGIN
	IF param_Quantity IS NOT NULL AND param_Quantity <= 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Quantity cannot be 0 or less.';
	END IF;
END$$


DELIMITER ;