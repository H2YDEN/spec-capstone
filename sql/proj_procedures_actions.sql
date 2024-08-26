-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES ACTIONS
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$


CREATE PROCEDURE VerifyLogin (
	IN param_Username VARCHAR(50),
    IN param_LoginPassword VARCHAR(255),
    OUT isValidLogin BOOLEAN
)
BEGIN
	IF EXISTS (
		SELECT 1
        FROM users
        WHERE Username = param_Username AND LoginPassword = param_LoginPassword
    ) THEN
		SET isValidLogin = TRUE;
    ELSE
		SET isValidLogin = FALSE;
	END IF;
END$$


CREATE PROCEDURE SignUp (
	IN param_Username VARCHAR(50),
    IN param_LoginPassword VARCHAR(255),
    IN param_Email VARCHAR(255),
    IN param_SecurityQ TEXT,
    IN param_SecurityQAnswer TEXT
)
BEGIN
	CALL AddNewUser(TRUE, param_Username, param_LoginPassword, param_Email, param_SecurityQ, param_SecurityQAnswer, NULL);
END$$


CREATE PROCEDURE ForgotPassword (
	IN param_Username VARCHAR(50),
    OUT return_SecurityQ TEXT
)
BEGIN
	SELECT SecurityQ
    INTO return_SecurityQ
    FROM users
    WHERE Username = param_Username
    LIMIT 1;
    
    IF return_SecurityQ IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'No such user exists.';
	END IF;
END$$


CREATE PROCEDURE ForgotUsername (
	IN param_Email VARCHAR(50),
    OUT return_SecurityQ TEXT
)
BEGIN
	SELECT SecurityQ
    INTO return_SecurityQ
    FROM users
    WHERE Email = param_Email
    LIMIT 1;
    
	IF return_SecurityQ IS NULL THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'No such user exists.';
	END IF;
END$$

CREATE PROCEDURE VerifyAndReturnUsername (
	IN param_Email VARCHAR(255),
	IN param_SecurityQAnswer TEXT,
    OUT return_Username VARCHAR(50)
)
BEGIN
	SELECT Username
    INTO return_Username
    FROM users
    WHERE Email = param_Email AND SecurityQAnswer = param_SecurityQAnswer;
END$$

CREATE PROCEDURE VerifyAndReturnPassword (
	IN param_Username VARCHAR(50),
	IN param_SecurityQAnswer TEXT,
    OUT return_LoginPassword VARCHAR(255)
)
BEGIN
	SELECT LoginPassword
    INTO return_LoginPassword
    FROM users
    WHERE Username = param_Username AND SecurityQAnswer = param_SecurityQAnswer;
END$$

CREATE PROCEDURE Checkout (
    IN param_UserID INTEGER,
    IN param_LastFourDigits CHAR(4),
    IN param_CardHolderName VARCHAR(50),
    IN param_StreetName VARCHAR(255),
    IN param_City VARCHAR(100),
    IN param_State VARCHAR(100),
    IN param_ZipCode CHAR(10)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur_ProductID INTEGER;
    DECLARE cur_Quantity INTEGER;
    DECLARE cur_Price DECIMAL(20,2);
    DECLARE cur_DiscountedPrice DECIMAL(20,2);
    DECLARE totalCost DECIMAL(20,2) DEFAULT 0.0;
    DECLARE transID INTEGER;

    DECLARE cartCursor CURSOR FOR 																-- get a list of all products in user's cart, should include their quantity, product's price and any available coupons
        SELECT c.ProductID, c.Quantity, p.Price, 
               IFNULL(co.DiscountedPrice, p.Price) AS DiscountedPrice							-- make sure if there is no discounted coupon price going on, retain the original current price
        FROM cart c
        JOIN product p ON c.ProductID = p.ProductID
        LEFT JOIN coupon co ON c.ProductID = co.ProductID AND co.EndDate >= CURDATE()
        WHERE c.UserID = param_UserID;															-- check and make sure coupon is not expired
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;										-- when finished traversing, exit


    START TRANSACTION;																			-- start a transaction because if something goes wrong, we want to revert all changes since we're doing multiple operations at once
    
    CALL AddNewTransaction(param_UserID, param_LastFourDigits, param_CardHolderName, totalCost, param_StreetName, param_City, param_State, param_ZipCode);				-- first make a temporary transaction entry in the table, cost will be updated later
    SET transID = LAST_INSERT_ID();																																		-- get the transactionID for products in the cart to all reference

    OPEN cartCursor;																					-- access the list of items in user's cart
    cart_loop: LOOP																						-- start a loop and traverse through each item
        FETCH cartCursor INTO cur_ProductID, cur_Quantity, cur_Price, cur_DiscountedPrice;					-- fetch next product from the list
        IF done THEN																						-- if there is no more to fetch, exit the loop
            LEAVE cart_loop;
        END IF;
	
        SET totalCost = totalCost + (cur_DiscountedPrice * cur_Quantity);								-- first calculate and update the total cost

        INSERT INTO purchases (TransactionID, ProductID, Quantity, PriceAtTheTime)						-- add this item into the purchases table for record, tied under this transaction's ID
        VALUES (transID, cur_ProductID, cur_Quantity, cur_DiscountedPrice);								

        UPDATE product																					-- since item has been purchased, update the stock available for the product's page
        SET StockQuantity = StockQuantity - cur_Quantity
        WHERE ProductID = cur_ProductID;
        IF (SELECT StockQuantity FROM product WHERE ProductID = cur_ProductID) <= 0 THEN				-- if the new stock quantity for the product is 0, sold out; set the product as inactive since there's no more to sell
            UPDATE product
            SET IsActive = FALSE
            WHERE ProductID = cur_ProductID;
        END IF;
    END LOOP;																		-- end the loop once all items are fetched
    CLOSE cartCursor;																-- close access to the list of items in user's cart since we're done using it

    UPDATE transactions																-- after total cost has been calculated of all products, update the temporary transaction with the up-to-date total
    SET TotalCost = totalCost
    WHERE TransactionID = transID;
    COMMIT;																			-- if no errors, commit the transaction and set all operation changes

    DELETE FROM cart 																-- since user has emptied their cart from buying all, we can remove all instances of the user from cart table
    WHERE UserID = param_UserID;
    
END$$

CREATE PROCEDURE ValidateCartStock (
    IN param_UserID INTEGER,
    OUT is_valid BOOLEAN
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur_ProductID INTEGER;
    DECLARE cur_Quantity INTEGER;
    DECLARE cur_StockQuantity INTEGER;

    DECLARE stockCursor CURSOR FOR 														-- get a list of stock quantities for all items in user's cart
        SELECT c.ProductID, c.Quantity, p.StockQuantity
        FROM cart c
        JOIN product p ON c.ProductID = p.ProductID
        WHERE c.UserID = param_UserID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET is_valid = TRUE;																-- set a boolean value to indicate if there are any items with a quantity requested greater than what is available

    OPEN stockCursor;																	-- access the list of item quantities from user's cart
    stock_loop: LOOP																	-- start a loop
        FETCH stockCursor INTO cur_ProductID, cur_Quantity, cur_StockQuantity;			-- fetch the next item
        IF done THEN																	-- exit the loop if no more items in list to traverse
            LEAVE stock_loop;
        END IF;

        IF cur_StockQuantity < cur_Quantity OR cur_Quantity <= 0 THEN					-- compare the quantity requested to the quantity currently available under the product's page (if any product is 0 quantity, do not proceed with checking out, have user reevaluate their cart first)
            SET is_valid = FALSE;														-- if quantity requested > available then set boolean to false since it is invalid and exit the loop early
            LEAVE stock_loop;
        END IF;
    END LOOP;																			-- if no more items then exit loop, is_valid remains true without issue
    CLOSE stockCursor;																	-- close access to the list since we're done using it
END$$

CREATE PROCEDURE AdjustCartQuantities (
    IN param_UserID INTEGER
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur_ProductID INTEGER;
    DECLARE cur_Quantity INTEGER;
    DECLARE cur_StockQuantity INTEGER;

    DECLARE stockCursor CURSOR FOR  														-- get a list of stock quantities for all items in user's cart
        SELECT c.ProductID, c.Quantity, p.StockQuantity
        FROM cart c
        JOIN product p ON c.ProductID = p.ProductID
        WHERE c.UserID = param_UserID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN stockCursor;																		-- access the list of item quantities from user's cart
    stock_loop: LOOP																		-- start a loop
        FETCH stockCursor INTO cur_ProductID, cur_Quantity, cur_StockQuantity;				-- fetch the next item
        IF done THEN																		-- exit the loop if no more items in list to traverse
            LEAVE stock_loop;
        END IF;

        IF cur_StockQuantity < cur_Quantity THEN											-- check the quantity requested and quantity currently available under the product's page
            UPDATE cart																		-- if the requested quantity > available then set the requested quantity to the available maximum quantity
            SET Quantity = cur_StockQuantity
            WHERE UserID = param_UserID AND ProductID = cur_ProductID;
        END IF;
    END LOOP;																				-- end loop when every item has been checked
    CLOSE stockCursor;																		-- close access to the list since we're done using it
END$$


CREATE PROCEDURE GetCartTotalPrice (
    IN param_UserID INTEGER,
    OUT totalPrice DECIMAL(20,2)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;															-- declare variables to update and get details
    DECLARE cur_ProductID INTEGER;
    DECLARE cur_Quantity INTEGER;
    DECLARE cur_DiscountedPrice DECIMAL(20,2);
    
    DECLARE cartCursor CURSOR FOR															-- retrieve all products along with their discounted prices if applicable
        SELECT c.ProductID, c.Quantity, 
               IFNULL(co.DiscountedPrice, p.Price) AS DiscountedPrice
        FROM cart c
        JOIN product p ON c.ProductID = p.ProductID
        LEFT JOIN coupon co ON c.ProductID = co.ProductID AND co.EndDate >= CURDATE()
        WHERE c.UserID = param_UserID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;									

    SET totalPrice = 0.0;																	-- begin counting up the total price now that discounts and pricing has been configured

    OPEN cartCursor;																		-- open the list we just received and iterate through each tuple
    cart_loop: LOOP
        FETCH cartCursor INTO cur_ProductID, cur_Quantity, cur_DiscountedPrice;				-- get the next product
        IF done THEN
            LEAVE cart_loop;
        END IF;

        SET totalPrice = totalPrice + (cur_DiscountedPrice * cur_Quantity);					-- add to the total the product's quantity times the price(discounted if applicable)
    END LOOP;
    CLOSE cartCursor;
    
END$$

DELIMITER ;