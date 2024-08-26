-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

/*
	Method to add new transaction.
    It verifies on insert:
    - last 4 digits of payment card recorded in format
    - total price cannot be negative
    - zip code (mandatory) follows formatting
    - DateOfPurchase is auto-set when purchase is made
*/
CREATE PROCEDURE AddNewTransaction (
	IN new_BuyerID INTEGER,
    IN new_LastFourDigits CHAR(4),
    IN new_CardHolderName VARCHAR(50),
    IN new_TotalCost DECIMAL(20,2),
    IN new_StreetName VARCHAR(255),
    IN new_City VARCHAR(100),
    IN new_State VARCHAR(100),
    IN new_ZipCode CHAR(10)
)
BEGIN
	DECLARE var_AddressID INT;
    
	CALL ValidateTransactionDetails (new_LastFourDigits, new_CardHolderName, new_TotalCost, new_ZipCode);
    CALL SetAddress(new_StreetName, new_City, new_State, new_ZipCode, var_AddressID);
    
	INSERT INTO transactions (BuyerID, LastFourDigits, CardHolderName, TotalCost, DateOfPurchase, AddressID)
	VALUES (new_BuyerID, new_LastFourDigits, new_CardHolderName, new_TotalCost, CURDATE(), var_AddressID);
END$$

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetTransactionDetails (
    IN param_TransactionID INTEGER,
    OUT return_BuyerID INTEGER,
    OUT return_LastFourDigits CHAR(4),
    OUT return_CardHolderName VARCHAR(50),
    OUT return_TotalCost DECIMAL(20,2),
    OUT return_DateOfPurchase DATE,
    OUT return_StreetName VARCHAR(255),
    OUT return_City VARCHAR(100),
    OUT return_State VARCHAR(100),
    OUT return_ZipCode CHAR(10)
)
BEGIN
    SELECT BuyerID, LastFourDigits, CardHolderName, TotalCost, DateOfPurchase, StreetName, City, State, ZipCode
    INTO return_BuyerID, return_LastFourDigits, return_CardHolderName, return_TotalCost, return_DateOfPurchase, return_StreetName, return_City, return_State, return_ZipCode
    FROM transactions
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE GetTransactionBuyerID (
    IN param_TransactionID INTEGER,
    OUT return_BuyerID INTEGER
)
BEGIN
    SELECT BuyerID
    INTO return_BuyerID
    FROM transactions
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE GetTransactionLastFourDigits (
    IN param_TransactionID INTEGER,
    OUT return_LastFourDigits CHAR(4)
)
BEGIN
    SELECT LastFourDigits
    INTO return_LastFourDigits
    FROM transactions
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE GetTransactionCardHolderName (
    IN param_TransactionID INTEGER,
    OUT return_CardHolderName VARCHAR(50)
)
BEGIN
    SELECT CardHolderName
    INTO return_CardHolderName
    FROM transactions
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE GetTransactionTotalCost (
    IN param_TransactionID INTEGER,
    OUT return_TotalCost DECIMAL(20,2)
)
BEGIN
    SELECT TotalCost
    INTO return_TotalCost
    FROM transactions
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE GetTransactionDateOfPurchase (
    IN param_TransactionID INTEGER,
    OUT return_DateOfPurchase DATE
)
BEGIN
    SELECT DateOfPurchase
    INTO return_DateOfPurchase
    FROM transactions
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE GetTransactionAddress (
	IN param_TransactionID INTEGER,
    OUT return_StreetName VARCHAR(255),
    OUT return_City VARCHAR(100),
    OUT return_State VARCHAR(100),
    OUT return_ZipCode CHAR(10)
)
BEGIN 
	SELECT a.StreetName, a.City, a.State, a.ZipCode		
    INTO return_StreetName, return_City, return_State, return_ZipCode
    FROM transactions t
    JOIN address a ON t.AddressID = a.AddressID
    WHERE t.TransactionID = param_TransactionID;
END;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE SetTransactionDetails (			-- date should be set automatic when new transcation is created
	IN param_TransactionID INTEGER,
	IN new_BuyerID INTEGER,
    IN new_LastFourDigits CHAR(4),
    IN new_CardHolderName VARCHAR(50),
    IN new_TotalCost DECIMAL(20,2),
    IN new_StreetName VARCHAR(255),
    IN new_City VARCHAR(100),
    IN new_State VARCHAR(100),
    IN new_ZipCode CHAR(10)
)
BEGIN
	UPDATE transactions
    SET
		BuyerID = new_BuyerID,
        LastFourDigits = new_LastFourDigits,
        CardHolderName = new_CardHolderName,
        TotalCost = new_TotalCost,
        StreetName = new_StreetName,
        City = new_City,
        State = new_State,
        ZipCode = new_ZipCode
	WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE SetTransactionBuyerID (
    IN param_TransactionID INTEGER,
    IN new_BuyerID INTEGER
)
BEGIN
    UPDATE transactions
    SET BuyerID = new_BuyerID
    WHERE TransactionID = param_TransactionID;
END$$


CREATE PROCEDURE SetTransactionLastFourDigits (
    IN param_TransactionID INTEGER,
    IN new_LastFourDigits CHAR(4)
)
BEGIN
    CALL ValidateTransactionDetails(new_LastFourDigits, NULL, NULL, NULL);
    
    UPDATE transactions
    SET LastFourDigits = new_LastFourDigits
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE SetTransactionCardHolderName (
    IN param_TransactionID INTEGER,
    IN new_CardHolderName VARCHAR(50)
)
BEGIN
    CALL ValidateTransactionDetails(NULL, new_CardHolderName, NULL, NULL);
    
    UPDATE transactions
    SET CardHolderName = new_CardHolderName
    WHERE TransactionID = param_TransactionID;
END$$

CREATE PROCEDURE SetTransactionTotalCost (
    IN param_TransactionID INTEGER,
    IN new_TotalCost DECIMAL(20,2)
)
BEGIN
    CALL ValidateTransactionDetails(NULL, NULL, new_TotalCost, NULL);
    
    UPDATE transactions
    SET TotalCost = new_TotalCost
    WHERE TransactionID = param_TransactionID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidateTransactionDetails (
	IN param_LastFourDigits CHAR(4),
    IN param_CardHolderName VARCHAR(50),
    IN param_TotalCost DECIMAL(20,2),
    IN param_ZipCode CHAR(10)
)
BEGIN
	IF param_LastFourDigits IS NOT NULL AND param_LastFourDigits NOT REGEXP '^[0-9]{4}$' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Invalid formatting for card\'s last four digits.';
	END IF;
    IF param_CardHolderName IS NOT NULL AND param_CardHolderName = "" THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Card holder\'s name may not be empty.';
	END IF;
	IF param_TotalCost IS NOT NULL AND param_TotalCost < 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'There cannot be a negative price total.';
	END IF;
	IF param_ZipCode IS NOT NULL AND param_ZipCode NOT REGEXP '^[0-9]{3,5}(-[0-9]{4})?$' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Provided zipcode doesn\'t follow correct formatting.';
	END IF;
END$$













DELIMITER ;