-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add new store.
    It verifies on insert:
    - store name is not empty
	- establishment date is not a future date
*/
CREATE PROCEDURE AddNewStore (
	IN new_OwnerID INTEGER,
    IN new_IsActive BOOLEAN,
    IN new_StoreName VARCHAR(100),
    IN new_EstablishmentDate DATE
)
BEGIN
	CALL ValidateStoreDetails (new_StoreName, new_EstablishmentDate);
    
	INSERT INTO store (OwnerID, IsActive, StoreName, EstablishmentDate, AddressID)
	VALUES (new_OwnerID, new_IsActive, new_StoreName, new_EstablishmentDate, NULL);
END$$
    
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetStoreDetails (
    IN param_StoreID INTEGER,
    OUT return_OwnerID INTEGER,
    OUT return_IsActive BOOLEAN,
    OUT return_StoreName VARCHAR(100),
    OUT return_EstablishmentDate DATE,
    OUT return_StreetName VARCHAR(255),
    OUT return_City VARCHAR(100),
    OUT return_State VARCHAR(100),
    OUT return_ZipCode CHAR(10)
)
BEGIN 
    SELECT s.OwnerID, s.IsActive, s.StoreName, s.EstablishmentDate, a.StreetName, a.City, a.State, a.ZipCode
    INTO return_OwnerID, return_IsActive, return_StoreName, return_EstablishmentDate, return_StreetName, return_City, return_State, return_ZipCode
    FROM store s
    JOIN address a ON s.AddressID = a.AddressID
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE GetOwnerID (
    IN param_StoreID INTEGER,
    OUT return_OwnerID INTEGER
)
BEGIN 
    SELECT OwnerID
    INTO return_OwnerID
    FROM store
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE GetStoreIsActive (
    IN param_StoreID INTEGER,
    OUT return_IsActive BOOLEAN
)
BEGIN 
    SELECT IsActive
    INTO return_IsActive
    FROM store
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE GetStoreName (
    IN param_StoreID INTEGER,
    OUT return_StoreName VARCHAR(100)
)
BEGIN 
    SELECT StoreName
    INTO return_StoreName
    FROM store
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE GetStoreEstablishmentDate (
    IN param_StoreID INTEGER,
    OUT return_EstablishmentDate DATE
)
BEGIN 
    SELECT EstablishmentDate
    INTO return_EstablishmentDate
    FROM store
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE GetStoreAddress (
    IN param_StoreID INTEGER,
	OUT return_StreetName VARCHAR(255),
    OUT return_City VARCHAR(100),
    OUT return_State VARCHAR(100),
    OUT return_ZipCode CHAR(10)
)
BEGIN
    SELECT a.StreetName, a.City, a.State, a.ZipCode
    INTO return_StreetName, return_City, return_State, return_ZipCode
    FROM store s
    JOIN address a ON s.AddressID = a.AddressID
    WHERE s.StoreID = param_StoreID;
END$$   


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS (SELF-EXPLANATORY) [uses validation to verify]
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE SetStoreDetails (
    IN param_StoreID INTEGER,
    IN new_OwnerID INTEGER,
    IN new_IsActive BOOLEAN,
    IN new_StoreName VARCHAR(100),
    IN new_EstablishmentDate DATE,
    IN new_StreetName VARCHAR(255),
    IN new_City VARCHAR(100),
    IN new_State VARCHAR(100),
    IN new_ZipCode CHAR(10)
)
BEGIN
    CALL ValidateStoreDetails(new_StoreName, new_EstablishmentDate, new_ZipCode);
    
    UPDATE store
    SET 
        OwnerID = new_OwnerID,
        IsActive = new_IsActive,
        StoreName = new_StoreName,
        EstablishmentDate = new_EstablishmentDate,
        StreetName = new_StreetName,
        City = new_City,
        State = new_State,
        ZipCode = new_ZipCode
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE SetOwnerID (
	IN param_StoreID INTEGER,
    IN new_OwnerID INTEGER
)
BEGIN
	UPDATE store
    SET OwnerID = new_OwnerID
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE SetStoreIsActive (
	IN param_StoreID INTEGER,
    IN new_IsActive BOOLEAN
)
BEGIN
	UPDATE store
    SET IsActive = new_IsActive
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE SetStoreName (
	IN param_StoreID INTEGER,
    IN new_StoreName VARCHAR(100)
)
BEGIN
	CALL ValidateStoreDetails (new_StoreName, NULL, NULL);
    
	UPDATE store
    SET StoreName = new_StoreName
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE SetStoreEstablishmentDate (
	IN param_StoreID INTEGER,
    IN new_EstablishmentDate DATE
)
BEGIN
	CALL ValidateStoreDetails (NULL, new_EstablishmentDate, NULL);
    
	UPDATE store
    SET EstablishmentDate = new_EstablishmentDate
    WHERE StoreID = param_StoreID;
END$$


CREATE PROCEDURE SetStoreAddress (
	IN param_StoreID INTEGER,
    IN new_StreetName VARCHAR(255) ,
    IN new_City VARCHAR(100) ,
	IN new_State VARCHAR(100),
    IN new_ZipCode CHAR(10) 
)
BEGIN
	DECLARE var_AddressID INT;
    CALL SetAddress(new_StreetName, new_City, new_State, new_ZipCode, var_AddressID);

	UPDATE store
	SET AddressID = var_AddressID			
    WHERE StoreID = param_StoreID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DERIVED ATTRIBUTES
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetStoreAge (
	IN param_StoreID INTEGER,
    OUT return_age INTEGER
)
BEGIN
	DECLARE releaseDate DATE;
    
	SELECT EstablishmentDate
    INTO releaseDate
    FROM store
    WHERE StoreID = param_StoreID;
    
    SET return_age = TIMESTAMPDIFF(YEAR, releaseDate, CURDATE());
END$$
        
CREATE PROCEDURE GetNumberOfStoreReviews (
	IN param_StoreID INTEGER,
    OUT return_count INTEGER
)
BEGIN
	SELECT COUNT(StoreID)
    INTO return_count
    FROM storereview
    WHERE StoreID = param_StoreID;
END$$
        
CREATE PROCEDURE GetStoreRating (
    IN param_StoreID INTEGER,
    OUT return_Rating DECIMAL(2,1)
)
BEGIN
    SELECT AVG(r.StarRating)
    INTO return_Rating
    FROM storereview r
    WHERE r.StoreID = param_StoreID;
END$$    

-- DROP PROCEDURE IF EXISTS `ValidateStoreDetails`;
-- DELIMITER $$
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Method is used to verify user's input regarding their store information.
    It verifies:
    - their store name is not empty
    - the proclaimed establishment date is not a future date
    - the zip code follows a format
*/
CREATE PROCEDURE ValidateStoreDetails (
	IN new_StoreName VARCHAR(100),
    IN new_EstablishmentDate DATE
)
BEGIN
	IF new_StoreName IS NOT NULL AND new_StoreName = ""	THEN 											-- validate store name is not empty
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Store name cannot be empty.';
	END IF;
    
    IF new_EstablishmentDate IS NOT NULL AND new_EstablishmentDate > CURDATE() THEN						-- not expected to be updated, on sign up, date cannot be a future date
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Date of establishment may not be set in the future.';
	END IF;
END$$
        
        
        
        
        
        
        
        
        
        
DELIMITER ;