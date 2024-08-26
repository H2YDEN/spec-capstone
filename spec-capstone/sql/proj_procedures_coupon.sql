-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add new product coupon.
    It verifies on insert:
    - enddate is not a past date
    - discounted price is not negative
*/
CREATE PROCEDURE AddNewCoupon (
    IN new_ProductID INTEGER,
    IN new_EndDate DATE,
    IN new_DiscountedPrice DECIMAL(20,2)
)
BEGIN
	CALL ValidateCouponDetails(new_ProductID, new_EndDate, new_DiscountedPrice);
    
    INSERT INTO coupon (ProductID, EndDate, DiscountedPrice)
    VALUES (new_ProductID, new_EndDate, new_DiscountedPrice);
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetProductCoupon (
	IN param_ProductID INTEGER
)
BEGIN
	SELECT *
    FROM coupon
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetCouponByPrice (	
	IN param_CouponID INTEGER,
    IN param_DiscountedPrice DECIMAL(20,2),
    IN param_Operation CHAR(2)
)
BEGIN
	IF param_Operation IN ('>', '<', '=', '>=', '<=') THEN
		SET @SQL =  CONCAT (
			'SELECT *
             FROM coupon
             WHERE CouponID = ? AND DiscountedPrice ', param_Operation, ' ?');
             
		PREPARE stmt FROM @SQL;
        SET @couponID = param_CouponID;
        SET @discountedPrice = param_DiscountedPrice;
        
        EXECUTE stmt USING @couponID, @discountedPrice;
        
        DEALLOCATE PREPARE stmt;
	ELSE
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid comparison operator';
    END IF;
END$$



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS (SELF-EXPLANATORY) [uses validation to verify]
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE SetExistingCoupon (
	IN param_ProductID INTEGER,
	IN param_CouponID INTEGER,
	IN param_EndDate DATE,
    IN param_DiscountedPrice DECIMAL(20,2)
)
BEGIN
	CALL ValidateCouponDetails(param_ProductID, param_EndDate, param_DiscountedPrice);
    
    UPDATE coupon
    SET EndDate = param_EndDate, DiscountedPrice = param_DiscountedPrice
    WHERE CouponID = param_CouponID;
END$$

CREATE PROCEDURE SetEndDate (
	IN param_CouponID INTEGER,
    IN param_EndDate DATE
)
BEGIN
	CALL ValidateCouponDetails (NULL, param_EndDate, NULL);
    
	UPDATE coupon
    SET EndDate = param_EndDate
    WHERE CouponID = param_CouponID;
END$$

CREATE PROCEDURE TestSetPastDate (				-- method solely used for testing when a coupon is expired
	IN param_CouponID INTEGER,
    IN param_EndDate DATE
)
BEGIN
	UPDATE coupon
    SET EndDate = param_EndDate
    WHERE CouponID = param_CouponID;
END$$

CREATE PROCEDURE SetDiscountedPrice(
	IN param_ProductID INTEGER,
	IN param_CouponID INTEGER,
	IN param_DiscountedPrice DECIMAL(20,2)
)
BEGIN
	CALL ValidateCouponDetails (param_ProductID, NULL, param_DiscountedPrice);
    
	UPDATE coupon
    SET DiscountedPrice = param_DiscountedPrice
    WHERE CouponID = param_CouponID;
END$$






-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DELETE (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE DeleteCouponByCouponID (
	IN param_CouponID INTEGER
)
BEGIN
	DELETE FROM coupon
	WHERE CouponID = param_CouponID;
END$$

CREATE PROCEDURE DeleteCouponByProductID (
	IN param_ProductID INTEGER
)
BEGIN
	DELETE FROM coupon 
	WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE DeleteCouponByPrice (
    IN param_ProductID INTEGER,
    IN param_TargetPrice DECIMAL(20,2),
    IN param_Operation CHAR(2)
)
BEGIN
	CALL ValidateCouponDetails(NULL, NULL, param_TargetPrice);
	IF param_Operation IN ('>', '<', '=', '>=', '<=') THEN
		SET @SQL = CONCAT(
			'DELETE FROM coupon
			 WHERE ProductID = ? AND DiscountedPrice ', param_Operation, ' ?');
		PREPARE stmt FROM @SQL;
		SET @productID = param_ProductID;
		SET @discountedPrice = param_TargetPrice;
		
		EXECUTE stmt USING @productID, @discountedPrice;
		
		DEALLOCATE PREPARE stmt;
	ELSE
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid comparison operator';
    END IF;
END$$



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidateCouponDetails (
	IN param_ProductID INTEGER,
    IN param_EndDate DATE,
    IN param_DiscountedPrice DECIMAL(20,2)
)
BEGIN
	DECLARE currentPrice DECIMAL(20,2);
    SELECT Price
    INTO currentPrice
    FROM product
    WHERE ProductID = param_ProductID;
    
    IF param_EndDate IS NOT NULL AND param_EndDate < CURDATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'End date cannot have passed already.';
    END IF;
    
	IF param_DiscountedPrice IS NOT NULL AND param_DiscountedPrice < 0.00 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Price cannot be negative.';
    END IF;
    
	IF param_DiscountedPrice IS NOT NULL AND param_DiscountedPrice >= currentPrice THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Discounted price cannot be the same or greater than current pricing.';
    END IF;
END$$

DELIMITER ;