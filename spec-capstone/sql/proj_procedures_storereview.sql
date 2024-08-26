-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add new store review.
    It verifies on insert:
    - Star rating is between 0.0 and 5.0
    - If author is not entered properly, set to default 'Anonymous'
    - PublishDate is auto-set when review is posted
*/
CREATE PROCEDURE AddNewStoreReview (
	IN new_StoreID INTEGER,
    IN new_UserID INTEGER,
    IN new_StarRating DECIMAL(2,1),
    IN new_DescriptionText TEXT
)
BEGIN
	CALL ValidateStoreReviewDetails(new_StarRating);
        
	INSERT INTO storereview (StoreID, UserID, PublishDate, StarRating, DescriptionText)
	VALUES (new_StoreID, new_UserID, CURDATE(), new_StarRating, new_DescriptionText);
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetStoreReview (
	IN param_ReviewID INTEGER
)
BEGIN
	SELECT *
    FROM storereview
    WHERE ReviewID = param_ReviewID;
END$$

CREATE PROCEDURE GetReviewsByStoreID (
	IN param_StoreID INTEGER
)
BEGIN
	SELECT *
    FROM storereview
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE GetStoreReviewByUserID (
	IN param_UserID INTEGER
)
BEGIN
	SELECT *
    FROM storereview
    WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE GetStoreReviewContainingDescriptionText (
	IN param_Phrase TEXT
)
BEGIN
	SELECT *
    FROM storereview
    WHERE DescriptionText LIKE CONCAT('%', param_Phrase, '%');
END$$

CREATE PROCEDURE GetStoreReviewByRating (
	IN param_StarRating DECIMAL(2,1),
    IN param_Comparison ENUM ('>', '<', '=', '>=', '<=')
)
BEGIN
	SET @SQL = CONCAT('SELECT *
					   FROM storereview
                       WHERE StarRating ', param_Comparison, ' ?');
	PREPARE stmt FROM @SQL;
    SET @StarRating = param_StarRating;
    EXECUTE stmt USING @StarRating;
    DEALLOCATE PREPARE stmt;
END$$

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE SetStoreReviewStarRating (
	IN param_ReviewID INTEGER,
    IN param_StarRating DECIMAL(2,1)
)
BEGIN
	CALL ValidateStoreReviewDetails (NULL, param_StarRating);
    
	UPDATE storereview
	SET StarRating = param_StarRating
	WHERE ReviewID = param_ReviewID;
END$$

CREATE PROCEDURE SetStoreReviewDescriptionText (
	IN param_ReviewID INTEGER,
    IN param_DescriptionText TEXT
)
BEGIN
	UPDATE storereview
	SET DescriptionText = param_DescriptionText
	WHERE ReviewID = param_ReviewID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DELETE (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE DeleteStoreReview (
	IN param_ReviewID INTEGER
)
BEGIN
	DELETE FROM storereview
    WHERE ReviewID = param_ReviewID;
END$$

CREATE PROCEDURE DeleteStoreReviewByUserID (
	IN param_UserID INTEGER
)
BEGIN
	DELETE FROM storereview
    WHERE UserID = param_UserID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DERIVED ATTRIBUTES
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetAuthorOfStoreReview (
	IN param_ReviewID INTEGER,
    OUT return_Author VARCHAR(50)
)
BEGIN
	DECLARE TheUserID INTEGER;
    
	SELECT UserID
    INTO TheUserID
    FROM storereview
    WHERE ReviewID = param_ReviewID;
    
    SELECT Username
    INTO return_Author
    FROM users
    WHERE UserID = TheUserID;
END$$

/*
DROP PROCEDURE IF EXISTS `ValidateStoreReviewDetails`;
DELIMITER $$
*/
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidateStoreReviewDetails (
	IN param_StarRating DECIMAL(2,1)
)
BEGIN
	IF param_StarRating IS NOT NULL AND (param_StarRating < 0.0 OR param_StarRating > 5.0) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Star rating must be between 0.0 and 5.0.';
	END IF;
END$$


DELIMITER ;