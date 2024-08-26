-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add new product.
    It verifies on insert:
    - stock quantity must be >= 0
    - price must be >= 0
*/
CREATE PROCEDURE AddNewProduct (
	IN new_StoreID INTEGER,
    IN new_UserID INTEGER,
    IN new_IsActive BOOLEAN,
    IN new_Price DECIMAL(20,2),
    IN new_ProductName VARCHAR(100),
    IN new_ProductDescription TEXT,
    IN new_ProductImage VARCHAR(255),
    IN new_StockQuantity INTEGER,
    IN new_releaseDate date
)
BEGIN
	CALL ValidateProductDetails (new_StockQuantity, new_Price);
    
	INSERT INTO product (StoreID, UserID, IsActive, Price, ProductName, ProductDescription, ProductImage, StockQuantity, ReleaseDate)
	VALUES (new_StoreID, new_UserID, new_IsActive, new_Price, new_ProductName, new_ProductDescription, new_ProductImage, new_StockQuantity, new_releaseDate);
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetProductDetails (
	IN param_ProductID INTEGER,
    OUT return_StoreID INTEGER,
    OUT return_UserID INTEGER,
    OUT return_IsActive BOOLEAN,
    OUT return_Price DECIMAL(20,2),
    OUT return_ProductName VARCHAR(100),
    OUT return_ProductDescription TEXT,
    OUT return_ProductImage VARCHAR(255),
    OUT return_StockQuantity INTEGER,
    OUT return_ReleaseDate date
)
BEGIN
	SELECT *
    INTO return_StoreID, return_UserID, return_IsActive, return_Price, return_ProductName, return_ProductDescription, return_ProductImage, return_StockQuantity, return_ReleaseDate
    FROM product
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductSeller (
	IN param_ProductID INTEGER,
    OUT return_StoreID INTEGER
)
BEGIN
	SELECT StoreID
    INTO return_StoreID
    FROM product
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductBuyer (
	IN param_ProductID INTEGER,
    OUT return_UserID INTEGER
)
BEGIN
	SELECT UserID
    INTO return_UserID
	FROM product
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductIsActive(
	IN param_ProductID INTEGER,
    OUT return_IsActive BOOLEAN
)
BEGIN
	SELECT IsActive
    INTO return_IsActive
	FROM product
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductPrice(
	IN param_ProductID INTEGER,
    OUT return_Price DECIMAL(20,2)
)
BEGIN
	SELECT Price
    INTO return_Price
	FROM product
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductName(
	IN param_ProductID INTEGER,
	OUT return_ProductName VARCHAR(100)
)
BEGIN
	SELECT ProductName
    INTO return_ProductName
	FROM product
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductDescription(
	IN param_ProductID INTEGER,
	OUT return_ProductDescription TEXT
)
BEGIN
	SELECT ProductDescription
    INTO return_ProductDescription
	FROM product
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductImagePath(
	IN param_ProductID INTEGER,
    OUT return_ProductImage VARCHAR(255)
)
BEGIN
	SELECT ProductImage
    INTO return_ProductImage
	FROM product
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductStockQuantity(
	IN param_ProductID INTEGER,
    OUT return_StockQuantity INTEGER
)
BEGIN
	SELECT StockQuantity
    INTO return_StockQuantity
	FROM product
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductReleaseDate(
	IN param_ProductID INTEGER,
	OUT return_ReleaseDate date
)
BEGIN
	SELECT ReleaseDate
    INTO return_ReleaseDate
	FROM product
    WHERE ProductID = param_ProductID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE SetProductDetails (
	IN param_ProductID INTEGER,
	IN new_StoreID INTEGER,
    IN new_UserID INTEGER,
    IN new_IsActive BOOLEAN,
    IN new_Price DECIMAL(20,2),
    IN new_ProductName VARCHAR(100),
    IN new_ProductDescription TEXT,
    IN new_ProductImage VARCHAR(255),
    IN new_StockQuantity INTEGER,
    IN new_ReleaseDate date
)
BEGIN
	CALL ValidateProductDetails (new_StockQuantity, new_Price);
    
	UPDATE product
    SET
        StoreID = new_StoreID,
        UserID = new_UserID,
        IsActive = new_IsActive,
        Price = new_Price,
        ProductName = new_ProductName,
        ProductDescription = new_ProductDescription,
        ProductImage = new_ProductImage,
        StockQuantity = new_StockQuantity,
        ReleaseDate = new_ReleaseDate
        
	WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE SetProductStoreID (
    IN param_ProductID INTEGER,
    IN new_StoreID INTEGER
)
BEGIN
    UPDATE product
    SET StoreID = new_StoreID
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE SetProductUserID (
    IN param_ProductID INTEGER,
    IN new_UserID INTEGER
)
BEGIN
    UPDATE product
    SET UserID = new_UserID
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE SetProductIsActive (						-- soft delete mechanism = sets inactive = close product
    IN param_ProductID INTEGER,
    IN new_IsActive BOOLEAN
)
BEGIN
    IF (new_IsActive = FALSE) THEN
		UPDATE product
		SET IsActive = new_IsActive, StockQuantity = 0
		WHERE ProductID = param_ProductID;
	ELSE
		UPDATE product
		SET IsActive = new_IsActive
		WHERE ProductID = param_ProductID;
	END IF;
END$$

CREATE PROCEDURE SetProductPrice (
    IN param_ProductID INTEGER,
    IN new_Price DECIMAL(20,2)
)
BEGIN
    CALL ValidateProductDetails(NULL, new_Price);
    
    UPDATE product
    SET Price = new_Price
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE SetProductName (
    IN param_ProductID INTEGER,
    IN new_ProductName VARCHAR(100)
)
BEGIN
    UPDATE product
    SET ProductName = new_ProductName
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE SetProductDescription (
    IN param_ProductID INTEGER,
    IN new_ProductDescription TEXT
)
BEGIN
    UPDATE product
    SET ProductDescription = new_ProductDescription
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE SetProductImage (
    IN param_ProductID INTEGER,
    IN new_ProductImage VARCHAR(255)
)
BEGIN
    UPDATE product
    SET ProductImage = new_ProductImage
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE SetProductStockQuantity (
    IN param_ProductID INTEGER,
    IN new_StockQuantity INTEGER
)
BEGIN
    CALL ValidateProductDetails(new_StockQuantity, NULL);
    
    UPDATE product
    SET StockQuantity = new_StockQuantity
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE SetProductReleaseDate (
    IN param_ProductID INTEGER,
    IN new_ReleaseDate DATE
)
BEGIN
    UPDATE product
    SET ReleaseDate = new_ReleaseDate
    WHERE ProductID = param_ProductID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DERIVED ATTRIBUTES
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetProductAge (
	IN param_ProductID INTEGER,
    OUT return_age INTEGER
)
BEGIN
	DECLARE birthdate DATE;
    
	SELECT ReleaseDate
    INTO birthdate
    FROM product
    WHERE ProductID = param_ProductID;
    
    SET return_age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
END$$

CREATE PROCEDURE GetNumberOfProductReviews (
	IN param_ProductID INTEGER,
    OUT return_count INTEGER
)
BEGIN
	SELECT COUNT(ProductID)
    INTO return_count
    FROM productreview
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductRating (
    IN param_ProductID INTEGER,
    OUT return_Rating DECIMAL(2,1)
)
BEGIN
    SELECT AVG(r.StarRating)
    INTO return_Rating
    FROM productreview r
    WHERE r.ProductID = param_ProductID;
END$$

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidateProductDetails (
	IN param_StockQuantity INTEGER,
	IN param_Price DECIMAL(20,2)
)
BEGIN
	IF param_StockQuantity IS NOT NULL AND param_StockQuantity < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'There cannot be a negative stock quantity.';
	END IF;
    
    IF param_Price IS NOT NULL AND param_Price < 0.00 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'There cannot be a negative price tag.';
	END IF;
END$$





DELIMITER ;