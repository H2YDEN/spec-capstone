-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add new product review.
    It verifies on insert:
    - Star rating is between 0.0 and 5.0
    - If author is not entered properly, set to default 'Anonymous'
	- PublishDate is auto-set when review is posted
*/
CREATE PROCEDURE AddNewProductReview (
	IN new_ProductID INTEGER,
    IN new_UserID INTEGER,
    IN new_StarRating DECIMAL(2,1),
    IN new_DescriptionText TEXT
)
BEGIN
	CALL ValidateProductReviewDetails(new_StarRating);
    
	INSERT INTO productreview (ProductID, UserID, PublishDate, StarRating, DescriptionText)
	VALUES (new_ProductID, new_UserID, CURDATE(), new_StarRating, new_DescriptionText);
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetProductReview (
	IN param_ReviewID INTEGER
)
BEGIN
	SELECT *
    FROM productreview
    WHERE ReviewID = param_ReviewID;
END$$

CREATE PROCEDURE GetReviewsByProductID (
	IN param_ProductID INTEGER
)
BEGIN
	SELECT *
    FROM productreview
    WHERE ProductID = param_ProductID;
END$$

CREATE PROCEDURE GetProductReviewByUserID (
	IN param_UserID INTEGER
)
BEGIN
	SELECT *
    FROM productreview
    WHERE UserID = param_UserID;
END$$

CREATE PROCEDURE GetProductReviewContainingDescriptionText (
	IN param_Phrase TEXT
)
BEGIN
	SELECT *
    FROM productreview
    WHERE DescriptionText LIKE CONCAT('%', param_Phrase, '%');
END$$

CREATE PROCEDURE GetReviewByRating (
	IN param_StarRating DECIMAL(2,1),
    IN param_Comparison CHAR(2)
)
BEGIN
	 IF param_Comparison IN ('>', '<', '=', '>=', '<=') THEN
		SET @SQL = CONCAT('SELECT *
						   FROM productreview
						   WHERE StarRating ', param_Comparison, ' ?');
		PREPARE stmt FROM @SQL;
		SET @StarRating = param_StarRating;
		EXECUTE stmt USING @StarRating;
		DEALLOCATE PREPARE stmt;
	ELSE	
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid comparison operator';
	END IF;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE SetProductReviewStarRating (
	IN param_ReviewID INTEGER,
    IN param_StarRating DECIMAL(2,1)
)
BEGIN
	CALL ValidateProductReviewDetails (NULL, param_StarRating);
    
	UPDATE productreview
	SET StarRating = param_StarRating
	WHERE ReviewID = param_ReviewID;
END$$

CREATE PROCEDURE SetProductReviewDescriptionText (
	IN param_ReviewID INTEGER,
    IN param_DescriptionText TEXT
)
BEGIN
	UPDATE productreview
	SET DescriptionText = param_DescriptionText
	WHERE ReviewID = param_ReviewID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DELETE (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE DeleteProductReview (
	IN param_ReviewID INTEGER
)
BEGIN
	DELETE FROM productreview
    WHERE ReviewID = param_ReviewID;
END$$

CREATE PROCEDURE DeleteProductReviewByUserID (
	IN param_UserID INTEGER
)
BEGIN
	DELETE FROM productreview
    WHERE UserID = param_UserID;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DERIVED ATTRIBUTES
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetAuthorOfProductReview (
	IN param_ReviewID INTEGER,
    OUT return_Author VARCHAR(50)
)
BEGIN
	DECLARE TheUserID INTEGER;
    
	SELECT UserID
    INTO TheUserID
    FROM productreview
    WHERE ReviewID = param_ReviewID;
    
    SELECT Username
    INTO return_Author
    FROM users
    WHERE UserID = TheUserID;
END$$

/*
DROP PROCEDURE IF EXISTS `ValidateProductReviewDetails`;
DELIMITER $$
*/
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidateProductReviewDetails (
	IN param_StarRating DECIMAL(2,1)
)
BEGIN
	IF param_StarRating IS NOT NULL AND (param_StarRating < 0.0 OR param_StarRating > 5.0) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Star rating must be between 0.0 and 5.0.';
	END IF;
END$$


DELIMITER ;