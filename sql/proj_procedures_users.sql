-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$   

/*
	Method to add new user.
    [Calls validation method] to verify:
    - date of birth is not a future date
    - ensures username select is unique
    - ensures email selected is unique
    - ensures security question isn't empty
    - ensures security question answer isn't empty
*/
CREATE PROCEDURE AddNewUser (
	IN new_IsActive BOOLEAN,
    IN new_Username VARCHAR(50),
    IN new_LoginPassword VARCHAR(255),
    IN new_Email VARCHAR(255),
    IN new_SecurityQ TEXT,
    IN new_SecurityQAnswer TEXT,
    IN new_DateOfBirth DATE
)
BEGIN
	CALL ValidateUserDetailsConstruct(new_Username, new_Email, new_SecurityQ, new_SecurityQAnswer, new_DateOfBirth);				-- make sure to validate all information before adding
   
	INSERT INTO users (IsActive, Username, LoginPassword, Email, SecurityQ, SecurityQAnswer, DateOfBirth, AddressID)
	VALUES (new_IsActive, new_Username, new_LoginPassword, new_Email, new_SecurityQ, new_SecurityQAnswer, new_DateOfBirth, NULL);
END$$
-- DELIMITER ;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetUser (
	IN param_UserID INTEGER,
    OUT return_IsActive BOOLEAN,
	OUT return_Username VARCHAR(50),
    OUT return_LoginPassword VARCHAR(255),
    OUT return_Email VARCHAR(255),
    OUT return_SecurityQ TEXT,
    OUT return_SecurityQAnswer TEXT,
    OUT return_DateOfBirth DATE,
    OUT return_StreetName VARCHAR(255),
    OUT return_City VARCHAR(100),
    OUT return_State VARCHAR(100),
    OUT return_ZipCode CHAR(10)
)
BEGIN 
	SELECT u.IsActive, u.Username, u.LoginPassword, u.Email, u.SecurityQ, u.SecurityAnswer, u.DateOfBirth, a.StreetName, a.City, a.State, a.ZipCode 
    INTO return_IsActive, return_Username, return_LoginPassword, return_Email, return_SecurityQ, return_SecurityQAnswer, return_DateOfBirth, return_StreetName, return_City, return_State, return_ZipCode
    FROM users u
    JOIN address a ON u.AddressID = a.AddressID
    WHERE UserID = param_UserID;
END;

CREATE PROCEDURE GetUserIsActive (
	IN param_UserID INTEGER,
	OUT return_IsActive BOOLEAN
)
BEGIN 
	SELECT IsActive 
    INTO return_IsActive
    FROM users
    WHERE UserID = param_UserID;
END;

CREATE PROCEDURE GetUsername (
	IN param_UserID INTEGER,
	OUT return_Username VARCHAR(50)
)
BEGIN 
	SELECT Username 
    INTO return_Username
    FROM users
    WHERE UserID = param_UserID;
END;

CREATE PROCEDURE GetUserLoginPassword (
	IN param_UserID INTEGER,
    OUT return_LoginPassword VARCHAR(255)
)
BEGIN 
	SELECT LoginPassword 	
    INTO return_LoginPassword
    FROM users
    WHERE UserID = param_UserID;
END;

CREATE PROCEDURE GetUserEmail (
	IN param_UserID INTEGER,
    OUT return_Email VARCHAR(255)
)
BEGIN 
	SELECT Email 	
    INTO return_Email
    FROM users
    WHERE UserID = param_UserID;
END;

CREATE PROCEDURE GetUserSecurityQ (
	IN param_UserID INTEGER,
    OUT return_SecurityQ TEXT
)
BEGIN 
	SELECT SecurityQ 	
    INTO return_SecurityQ
    FROM users
    WHERE UserID = param_UserID;
END;

CREATE PROCEDURE GetUserSecurityQAnswer (
	IN param_UserID INTEGER,
    OUT return_SecurityQAnswer TEXT
)
BEGIN 
	SELECT SecurityQAnswer 	
    INTO return_SecurityQAnswer
    FROM users
    WHERE UserID = param_UserID;
END;

CREATE PROCEDURE GetUserDateOfBirth (
    IN param_UserID INTEGER,
    OUT return_DateOfBirth DATE
)
BEGIN 
    SELECT DateOfBirth 
    INTO return_DateOfBirth
    FROM users
    WHERE UserID = param_UserID;
END;

CREATE PROCEDURE GetUserAddress (
	IN param_UserID INTEGER,
    OUT return_StreetName VARCHAR(255),
    OUT return_City VARCHAR(100),
    OUT return_State VARCHAR(100),
    OUT return_ZipCode CHAR(10)
)
BEGIN 
	SELECT a.StreetName, a.City, a.State, a.ZipCode		
    INTO return_StreetName, return_City, return_State, return_ZipCode
    FROM users u
    JOIN address a ON u.AddressID = a.AddressID
    WHERE u.UserID = param_UserID;
END;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS (SELF-EXPLANATORY) [uses validation to verify]
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE SetUserIsActive (
	IN param_UserID INTEGER
)
BEGIN
	UPDATE users
	SET IsActive = TRUE
	WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE SetUserInActive (
	IN param_UserID INTEGER
)
BEGIN
	UPDATE users
	SET Username = 'inactive_user', IsActive = FALSE	-- update user profile
	WHERE UserID = param_UserID;
    
	DELETE FROM cart									-- delete all products in cart if user goes inactive
	WHERE UserID = param_UserID;
    
	DELETE FROM saved									-- delete all products in saved list if user goes inactive
	WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE SetUsername (
	IN param_UserID INTEGER,
    IN new_Username VARCHAR(50)
)
BEGIN
	CALL ValidateUserDetailsUpdate(param_UserID, new_Username, NULL, NULL, NULL, NULL);			-- validate username uniqueness
    
	UPDATE users
	SET Username = new_Username
	WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE SetLoginPassword (
	IN param_UserID INTEGER,
    IN new_LoginPassword VARCHAR(255)
)
BEGIN
	UPDATE users
	SET LoginPassword = new_LoginPassword
    WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE SetEmail (
	IN param_UserID INTEGER,
    IN new_Email VARCHAR(255)
)
BEGIN
	CALL ValidateUserDetailsUpdate(param_UserID, NULL, new_Email, NULL, NULL, NULL);			-- validate email uniqueness
    
	UPDATE users
	SET Email = new_Email
	WHERE UserID = param_UserID;
END$$
	
CREATE PROCEDURE SetSecurityQ (
	IN param_UserID INTEGER,
    IN new_SecurityQ TEXT 				
)
BEGIN
	CALL ValidateUserDetailsUpdate(param_UserID, NULL , NULL, new_SecurityQ, NULL, NULL);			-- validate security Q is not empty
    
	UPDATE users
	SET SecurityQ = new_SecurityQ
    WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE SetSecurityQAnswer (
	IN param_UserID INTEGER,
    IN new_SecurityQAnswer TEXT 				
)
BEGIN
	CALL ValidateUserDetailsUpdate(param_UserID, NULL , NULL, NULL, new_SecurityQAnswer, NULL);			-- validate security Q Answer is not empty
    
	UPDATE users
	SET SecurityQAnswer = new_SecurityQAnswer
    WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE SetDateOfBirth (
	IN param_UserID INTEGER,
    IN new_DateOfBirth DATE 				
)
BEGIN
	CALL ValidateUserDetailsUpdate(param_UserID, NULL , NULL, NULL, NULL, new_DateOfBirth);			-- validate DOB is not a future date
    
	UPDATE users
	SET DateOfBirth = new_DateOfBirth
    WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE SetUserAddress (
	IN param_UserID INTEGER,
    IN new_StreetName VARCHAR(255) ,
    IN new_City VARCHAR(100) ,
	IN new_State VARCHAR(100),
    IN new_ZipCode CHAR(10) 
)
BEGIN
	DECLARE var_AddressID INT;
	CALL ValidateUserDetailsUpdate(param_UserID, NULL , NULL, NULL, NULL, NULL);
    CALL SetAddress(new_StreetName, new_City, new_State, new_ZipCode, var_AddressID);

	UPDATE users
	SET AddressID = var_AddressID			
    WHERE UserID = param_UserID;
END$$

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DERIVED ATTRIBUTES
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetUserAge (
	IN param_UserID INTEGER,
    OUT return_age INTEGER
)
BEGIN
	DECLARE birthday DATE;
    
	SELECT DateOfBirth
    INTO birthday
    FROM users
    WHERE UserID = param_UserID;
    
    SET return_age = TIMESTAMPDIFF(YEAR, birthday, CURDATE());
END$$

/*
DROP PROCEDURE IF EXISTS `ValidateUserDetailsConstruct`;
DROP PROCEDURE IF EXISTS `ValidateUserDetailsUpdate`;
DELIMITER $$
*/
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Method is used to verify user's input information during sign up.
    It verifies:
	- date of birth is not a future date
    - zip code (if provided) follows formatting
    - ensures username select is unique
    - ensures email selected is unique
    - ensures security question isn't empty
    - ensures security question answer isn't empty
*/
CREATE PROCEDURE ValidateUserDetailsConstruct (
	IN new_Username VARCHAR(50),
    IN new_Email VARCHAR(255),
	IN new_SecurityQ TEXT,
    IN new_SecurityQAnswer TEXT,
    IN new_DateOfBirth DATE
)
BEGIN
	IF new_Username IS NOT NULL AND new_Username = 'inactive_user' THEN				-- let 'inactive_user' be the only non-unique username
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username is not allowed to be chosen.';
    END IF;
    
	IF new_Username IS NOT NULL AND EXISTS (										-- validate username uniqueness
		SELECT 1
        FROM users
        WHERE Username = new_Username
	) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username has already been taken.';
    END IF;
    
	IF new_Email IS NOT NULL AND EXISTS (											-- validate email uniqueness
		SELECT 1
        FROM users
        WHERE Email = new_Email
	) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An account with the provided email already exists.';
    END IF;
    
	IF new_SecurityQ IS NOT NULL AND new_SecurityQ = ""
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Security question cannot be empty.';
    END IF;
    
    IF new_SecurityQAnswer IS NOT NULL AND new_SecurityQAnswer = ""
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Security question\'s answer cannot be empty.';
    END IF;
    
    IF new_DateOfBirth IS NOT NULL AND new_DateOfBirth > CURDATE()					-- validate DOB is not a future date
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Date of birth may not be set in the future.';
    END IF;
END$$

/*
	Method is used to verify user's input information post sign up (updating in the future).
    It verifies:
	- date of birth is not a future date
    - zip code (if provided) follows formatting
    - ensures username select is unique
    - ensures email selected is unique
    - ensures security question isn't empty
    - ensures security question answer isn't empty
*/
CREATE PROCEDURE ValidateUserDetailsUpdate (
	IN param_UserID INTEGER,
	IN new_Username VARCHAR(50),
    IN new_Email VARCHAR(255),
    IN new_SecurityQ TEXT,
    IN new_SecurityQAnswer TEXT,
    IN new_DateOfBirth DATE
)
BEGIN
	IF new_Username IS NOT NULL AND new_Username = 'inactive_user' THEN				-- let 'inactive_user' be the only non-unique username
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username is not allowed to be chosen.';
    END IF;
    
	IF new_Username IS NOT NULL AND EXISTS (										-- validate username uniqueness for all else
		SELECT 1
        FROM users
        WHERE Username = new_Username AND UserID != param_UserID
	) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username has already been taken.';
    END IF;
    
	IF new_Email IS NOT NULL AND EXISTS (											-- validate email uniqueness
		SELECT 1
        FROM users
        WHERE Email = new_Email AND UserID != param_UserID
	) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An account with the provided email already exists.';
    END IF;
    
    IF new_SecurityQ IS NOT NULL AND new_SecurityQ = ""
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Security question cannot be empty.';
    END IF;
    
    IF new_SecurityQAnswer IS NOT NULL AND new_SecurityQAnswer = ""
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Security question\'s answer cannot be empty.';
    END IF;
    
    IF new_DateOfBirth IS NOT NULL AND new_DateOfBirth > CURDATE()					-- validate DOB is not a future date
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Date of birth may not be set in the future.';
    END IF;
END$$




DELIMITER ;