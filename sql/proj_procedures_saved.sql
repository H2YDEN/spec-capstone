-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add saved for later items.
    Already verified:
    - no null
    - foreign reference existing keys DB
    - date is current date DB
*/
CREATE PROCEDURE AddNewSaved (
    IN new_UserID INTEGER,
    IN new_ProductID INTEGER
)
BEGIN
    INSERT INTO saved (UserID, ProductID, DateAdded)
    VALUES (new_UserID, new_ProductID, CURDATE());
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DELETE (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE DeleteASavedItem (
	IN param_UserID INTEGER,
    IN param_ProductID INTEGER
)
BEGIN
	DELETE FROM saved
    WHERE UserID = param_UserID AND ProductID = param_ProductID;
END$$

CREATE PROCEDURE DeleteAllBasedOnDate (
	IN param_UserID INTEGER,
    IN param_ProductID INTEGER,
    IN param_DateSaved DATE,
    IN param_Operation CHAR(2)
)
BEGIN
	IF param_Comparison IN ('>', '<', '=', '>=', '<=') THEN
		SET @SQL = CONCAT(
			'DELETE FROM saved
			 WHERE UserID = ? AND ProductID = ? AND DateAdded ', param_Operation, ' ?');
		PREPARE stmt FROM @SQL;
		SET @user_id = param_UserID;
		SET @product_id = param_ProductID;
		SET @date_saved = param_DateSaved;
		
		EXECUTE stmt USING @user_id, @product_id, @date_saved;
		
		DEALLOCATE PREPARE stmt;
	ELSE
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid comparison operator';
    END IF;
END$$

CREATE PROCEDURE DeleteAllBetweenDates ( 			-- inclusive of end dates
	IN param_UserID INTEGER,
    IN param_ProductID INTEGER,
    IN param_DateFrom DATE,
    IN param_DateTo DATE
)
BEGIN
	DELETE FROM saved
    WHERE UserID = param_UserID
      AND ProductID = param_ProductID
      AND DateAdded >= param_DateFrom
      AND DateAdded <= param_DateTo;
END$$

CREATE PROCEDURE DeleteAll (
	IN param_UserID INTEGER
)
BEGIN
	DELETE FROM saved
    WHERE UserID = param_UserID;
END$$


DELIMITER ;



