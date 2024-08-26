-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add new address.
    It verifies on insert:
    - no empty streetname
    - no empty city name
    - no empty state name
    - zipcode adheres to formatting
*/
CREATE PROCEDURE AddNewAddress (
	IN new_StreetName VARCHAR(255),
    IN new_City VARCHAR(100),
    IN new_State VARCHAR(255),
    IN new_ZipCode CHAR(10)
)
BEGIN
	CALL ValidateAddressDetails (new_StreetName, new_City, new_State, new_ZipCode);   -- check null and formatting before searching
    
    INSERT INTO address (StreetName, City, State, ZipCode)
    VALUES (new_StreetName, new_City, new_State, new_ZipCode);
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetAddressByID (
	IN param_AddressID INTEGER
)
BEGIN
	SELECT *
    FROM address
    WHERE AddressID = param_AddressID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE SetAddress (
    IN param_StreetName VARCHAR(255),
    IN param_City VARCHAR(100),
    IN param_State VARCHAR(100),
    IN param_ZipCode CHAR(10),
    OUT return_AddressID INTEGER
)
BEGIN
	CALL ValidateAddressDetails (param_StreetName, param_City, param_State, param_ZipCode);   -- check null and formatting before searching
     
    SELECT AddressID
    INTO return_AddressID																		-- if address already exists on file, return ID
    FROM address
    WHERE StreetName = param_StreetName
      AND City = param_City
      AND State = param_State
      AND ZipCode = param_ZipCode
	LIMIT 1;

    IF return_AddressID IS NULL THEN															-- if address doesn't then make a new address and return the newly made ID
		CALL AddNewAddress(param_StreetName, param_City, param_State, param_ZipCode);
        SET return_AddressID = LAST_INSERT_ID();
    END IF;
END$$



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidateAddressDetails (
	IN param_StreetName VARCHAR(255),
	IN param_City VARCHAR(100),
    IN param_State VARCHAR(100),
    IN param_ZipCode CHAR(10)
)
BEGIN
	IF param_StreetName IS NULL OR param_StreetName = "" THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Street name cannot be empty or null.';
	END IF;
	IF param_City IS NULL OR param_City = "" THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'City name cannot be empty or null.';
	END IF;
	IF param_State IS NULL OR param_State = "" THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'State name cannot be empty or null.';
	END IF;
	IF param_ZipCode IS NULL OR param_ZipCode NOT REGEXP '^[0-9]{3,5}(-[0-9]{4})?$' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Provided zipcode doesn\'t follow correct formatting or was null.';
	END IF;
END$$


DELIMITER ;