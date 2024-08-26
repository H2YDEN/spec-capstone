-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INSERTING TEST DATA
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* INSERTING USERS */
CALL AddNewUser(TRUE, 'john_doe', 'password123', 'john@example.com', 'What is your pet\'s name?', 'Fluffy', '1990-05-15'); 					-- normal user
CALL AddNewUser(TRUE, 'jane_doe', 'securePass!@#', 'jane@example.com', 'What was your first car?', 'Honda', NULL); 							-- normal user
CALL AddNewUser(TRUE, 'partial_address_user', 'passWord456', 'partial@example.com', 'Mother\'s maiden name?', 'Smith', NULL); 				-- normal user
CALL AddNewUser(TRUE, 'valid_zip_user', 'zipPass789', 'zip@example.com', 'Favorite food?', 'Pizza', NULL); 									-- normal user
CALL AddNewUser(TRUE, 'nine_digit_zip', 'nineDigitPass', 'nine@example.com', 'Favorite book?', '1984', NULL); 								-- normal user
CALL AddNewUser(TRUE, 'three_digit_zip', 'threeDigitPass', 'three@example.com', 'Birth city?', 'New York', NULL); 							-- normal user
CALL AddNewUser(FALSE, 'inactive_user', 'inactivePass', 'inactive@example.com', 'Favorite song?', 'Imagine', NULL); 						-- edge case: inactive user
CALL AddNewUser(TRUE, 'empty_strings', 'emptyPass', 'empty@example.com', 'Dream job?', 'Astronaut', NULL); 									-- normal user
-- CALL AddNewUser(TRUE, 'future_dob', 'futurePass', 'future@example.com', 'Favorite movie?', 'Matrix', '2030-01-01'); 						-- edge case: check date of birth is not an invalid future date [Trigger constraint test]       **caught**	

									
/* SETTING USER'S ADDRESS */
CALL SetUserAddress(1, '123 Main St', 'Springfield', 'IL', '62704');		-- normal address
CALL SetUserAddress(2, 'idk', 'something', 'CA', '12345');					-- normal address
-- CALL SetUserAddress(3, NULL, 'Chicago', 'IL', NULL);						-- edge case: no real address was entered     	 **caught**     NULL not accepted
-- CALL SetUserAddress(4, NULL, NULL, NULL, '12345');						-- edge case: no real address was entered     	 **caught**
-- CALL SetUserAddress(5, NULL, NULL, NULL, '12345-6789');					-- edge case: no real address was entered     	 **caught**
-- CALL SetUserAddress(6, NULL, NULL, NULL, '123');							-- edge case: no real address was entered     	 **caught**
-- CALL SetUserAddress(7, NULL, NULL, NULL, NULL);							-- edge case: no real address was entered     	 **caught**
-- CALL SetUserAddress(8, NULL, NULL, NULL, NULL);							-- edge case: no real address was entered     	 **caught**
-- CALL SetUserAddress(9, '', '', '', '');								    -- edge case: no real address was entered     	 **caught**     empty not accepted


/* SETTING USER'S DOB */
CALL SetDateOfBirth(1, '2015-01-02');							-- normal address
CALL SetDateOfBirth(2, '2010-01-01');							-- normal address
CALL SetDateOfBirth(3, '2020-01-01');							-- normal address
-- CALL SetDateOfBirth(4, '2030-01-01');						-- edge case: check date of birth is not an invalid future date [Trigger constraint test]       **caught**	


/* INSERTING STORES */
CALL AddNewStore(1, TRUE, 'Best Electronics', '2015-03-25'); 					-- normal store
CALL AddNewStore(2, TRUE, 'Online Books', '2010-11-20'); 						-- normal store
CALL AddNewStore(4, TRUE, 'No Ratings Yet Store', '2021-07-15'); 				-- normal store
CALL AddNewStore(5, TRUE, 'Partial Address Store', '2018-06-15'); 				-- normal store
CALL AddNewStore(6, TRUE, 'Five Digit Zip Store', '2020-08-05'); 				-- normal store
CALL AddNewStore(7, TRUE, 'Nine Digit Zip Store', '2019-12-10'); 				-- normal store
CALL AddNewStore(7, TRUE, 'Three Digit Zip Store', '2017-04-22'); 				-- normal store
CALL AddNewStore(7, FALSE, 'Inactive Store', '2012-05-18'); 					-- edge case: inactive store
CALL AddNewStore(7, TRUE, 'Empty Strings Store', '2016-09-30'); 				-- normal store
-- CALL AddNewStore(7, TRUE, 'Future Store', '2030-01-01'); 						-- edge case: check date of establishment is not an invalid future date [Trigger constraint test]    	 **caught**


/* SETTING STORE'S ADDRESS */
CALL SetStoreAddress(1,'456 Market St', 'San Francisco', 'CA', '94105');		-- normal address
CALL SetStoreAddress(2,'yes', 'yes', 'FL', '12345');							-- normal address
-- CALL SetStoreAddress(3,NULL, NULL, NULL, NULL);								-- edge case: no real address was entered     	 **caught**
-- CALL SetStoreAddress(4,NULL, 'Los Angeles', 'CA', NULL);						-- edge case: no real address was entered     	 **caught**
-- CALL SetStoreAddress(5,NULL, NULL, NULL, '12345');							-- edge case: no real address was entered     	 **caught**
-- CALL SetStoreAddress(6,NULL, NULL, NULL, '12345-6789');						-- edge case: no real address was entered     	 **caught**
-- CALL SetStoreAddress(7,NULL, NULL, NULL, '123');								-- edge case: no real address was entered     	 **caught**
-- CALL SetStoreAddress(8,NULL, NULL, NULL, NULL);								-- edge case: no real address was entered     	 **caught**
-- CALL SetStoreAddress(9,'', '', '', '');										-- edge case: no real address was entered     	 **caught**
-- CALL SetStoreAddress(10, NULL, NULL, NULL, NULL);							-- edge case: no real address was entered     	 **caught**


/* INSERTING STORE SCHEDULES */
CALL AddNewStoreSchedule('Monday', 1, '09:00:00', '18:00:00');					-- normal store schedule
CALL AddNewStoreSchedule('Tuesday', 1, '09:00:00', '18:00:00');
CALL AddNewStoreSchedule('Wednesday', 1, '09:00:00', '18:00:00');
CALL AddNewStoreSchedule('Thursday', 1, '09:00:00', '18:00:00');
CALL AddNewStoreSchedule('Friday', 1, '09:00:00', '18:00:00');
CALL AddNewStoreSchedule('Saturday', 1, '10:00:00', '16:00:00');
CALL AddNewStoreSchedule('Sunday', 1, '11:00:00', '15:00:00');

CALL AddNewStoreSchedule('Monday', 2, '08:00:00', '20:00:00');					-- different weekday and weekend times
CALL AddNewStoreSchedule('Tuesday', 2, '08:00:00', '20:00:00');
CALL AddNewStoreSchedule('Wednesday', 2, '08:00:00', '20:00:00');
CALL AddNewStoreSchedule('Thursday', 2, '08:00:00', '20:00:00');
CALL AddNewStoreSchedule('Friday', 2, '08:00:00', '20:00:00');
CALL AddNewStoreSchedule('Saturday', 2, '09:00:00', '17:00:00');
CALL AddNewStoreSchedule('Sunday', 2, '09:00:00', '17:00:00');

CALL AddNewStoreSchedule('Monday', 3, '08:30:00', '17:30:00');					-- weekdays only
CALL AddNewStoreSchedule('Tuesday', 3, '08:30:00', '17:30:00');
CALL AddNewStoreSchedule('Wednesday', 3, '08:30:00', '17:30:00');
CALL AddNewStoreSchedule('Thursday', 3, '08:30:00', '17:30:00');
CALL AddNewStoreSchedule('Friday', 3, '08:30:00', '17:30:00');

CALL AddNewStoreSchedule('Saturday', 4, '10:00:00', '22:00:00');				-- weekends only
CALL AddNewStoreSchedule('Sunday', 4, '10:00:00', '22:00:00');

CALL AddNewStoreSchedule('Monday', 5, '09:00:00', '17:00:00');					-- different times throughout the week
CALL AddNewStoreSchedule('Tuesday', 5, '10:00:00', '18:00:00');
CALL AddNewStoreSchedule('Wednesday', 5, '09:30:00', '17:30:00');
CALL AddNewStoreSchedule('Thursday', 5, '10:30:00', '18:30:00');
CALL AddNewStoreSchedule('Friday', 5, '09:15:00', '16:15:00');
CALL AddNewStoreSchedule('Saturday', 5, '11:30:00', '15:30:00');
CALL AddNewStoreSchedule('Sunday', 5, '10:15:00', '21:45:00');

CALL AddNewStoreSchedule('Monday', 6, '00:00:00', '23:59:59');					-- open 24/7
CALL AddNewStoreSchedule('Tuesday', 6, '00:00:00', '23:59:59');
CALL AddNewStoreSchedule('Wednesday', 6, '00:00:00', '23:59:59');
CALL AddNewStoreSchedule('Thursday', 6, '00:00:00', '23:59:59');
CALL AddNewStoreSchedule('Friday', 6, '00:00:00', '23:59:59');
CALL AddNewStoreSchedule('Saturday', 6, '00:00:00', '23:59:59');
CALL AddNewStoreSchedule('Sunday', 6, '00:00:00', '23:59:59');

CALL AddNewStoreSchedule('Monday', 8, '09:00:00', '12:00:00');	
-- CALL AddNewStoreSchedule('Monday', 7, '18:00:00', '09:00:00');				-- edge case: opening time must be < closing time [check constraint test]    		**caught**			
-- CALL AddNewStoreSchedule('Monday', 8, '11:00:00', '15:00:00');				-- edge case: adding a conflicting schedule [trigger constraint test]    			**caught**


/* INSERTING STORE REVIEWS */
CALL AddNewStoreReview(1, 1, 4.5, 'Great store with excellent service.'); 		-- normal review
CALL AddNewStoreReview(1, 2, 3.8, NULL); 										-- test optional null description (no description)
CALL AddNewStoreReview(2, 4, 0.0, NULL); 										-- test min star rating 0.0
CALL AddNewStoreReview(2, 5, 5.0, 'Outstanding experience!'); 					-- test max star rating 5.0
CALL AddNewStoreReview(4, 7, 3.0, ''); 											-- normal review
-- CALL AddNewStoreReview(4, NULL, 2.5, 'Review from a deleted user.'); 		-- edge case null userID deleted user											**caught**
CALL AddNewStoreReview(5, 7, 4.7, 'Very long description. Very long description. Very long description. Very long description. Very long description. Very long description. Very long description. Very long description. Very long description.');
-- CALL AddNewStoreReview(1, 3, 6.0, NULL); 									-- edge case: invalid rating [check constraint test]    						**caught**
-- CALL AddNewStoreReview(2, 5, 4.2, NULL); 									-- edge case: user reviewed the same store twice [unique constraint test]    	**caught**


/* INSERTING PRODUCTS */
CALL AddNewProduct(1, 1, TRUE, 19.99, 'Product A', 'Description of Product A', 'product_a.png', 5, '2023-01-01'); 		-- normal product
CALL AddNewProduct(1, 2, TRUE, 29.99, 'Product B', 'Description of Product B', NULL, 5, '2023-02-01'); 					-- test optional image (no image)
CALL AddNewProduct(3, 5, TRUE, 0.00, 'Product E', NULL, NULL, 100, '2023-05-01'); 										-- test allowing price of 0.00, free product
CALL AddNewProduct(3, 6, TRUE, 49.99, 'Product F', NULL, NULL, 25, '2023-06-01'); 										-- test optional description and image (no description, no image)
CALL AddNewProduct(4, 7, TRUE, 59.99, 'Product H', NULL, NULL, 30, '2025-01-01'); 										-- test future release date
CALL AddNewProduct(5, 7, FALSE, 24.99, 'Product I', NULL, NULL, 15, '2023-08-01'); 										-- test inactive product
-- CALL AddNewProduct(2, 4, TRUE, 15.00, 'Product D', NULL, NULL, -1, '2023-04-01'); 									-- edge case: stock quantity -1, invalid quantity [check constraint test]    	**caught**


/* INSERTING PRODUCT REVIEWS */
CALL AddNewProductReview(1, 1, 4.5, 'Great product with excellent quality.');			-- normal review
CALL AddNewProductReview(1, 2, 3.8, NULL);													-- optional null description
CALL AddNewProductReview(2, 4, 0.0, NULL);													-- test min star rating 0.0									
CALL AddNewProductReview(2, 5, 5.0, 'Outstanding product!');								-- test max star rating 5.0
CALL AddNewProductReview(4, 7, 3.0, '');													-- normal review
-- CALL AddNewProductReview(4, NULL, 2.5, 'Review from a deleted user.');			-- test null userID deleted user											**caught**
CALL AddNewProductReview(5, 7, 4.7, 'Very long description. Very long description. Very long description. Very long description. Very long description. Very long description. Very long description. Very long description. Very long description.');
-- CALL AddNewProductReview(2, 5, 4.2, NULL);												-- edge case: user reviewed the same product twice [unique constraint test]    	**caught**
-- CALL AddNewProductReview(1, 3, 6.0, NULL);												-- edge case: invalid rating [check constraint test]    							**caught**


/* INSERTING INTO COUPON */
CALL AddNewCoupon(1, '2025-12-31', 10.00); 				-- normal case
CALL AddNewCoupon(2, '2025-06-30', 15.00);  			-- normal case
CALL AddNewCoupon(4, '2025-06-20', 3.00);  				-- normal case
-- CALL AddNewCoupon(1, '2025-12-31', 999999.99);		-- edge case: discounted price >= normal price				**caught**
-- CALL AddNewCoupon(4, '2023-01-01', 25.00);  			-- edge case: end date in the past							**caught**
-- CALL AddNewCoupon(5, '2024-12-31', -10.00);  		-- edge case: negative discounted price 					**caught**	

-- CALL TestSetPastDate(1, '2022-02-02');

/* INSERTING INTO CART */
CALL AddToCart(1, 1, 1);			-- normal item
CALL AddToCart(1, 2, 100);			-- normal item
CALL AddToCart(1, 1, 4);			-- edge case: duplicate product, add quantities [trigger constraint test]    						**caught**
CALL AddToCart(1, 4, 25);			-- normal item
CALL AddToCart(2, 1, 1);			-- normal item
CALL AddToCart(2, 2, 100);			-- normal item
CALL AddToCart(2, 1, 4);			-- edge case: duplicate product, add quantities [trigger constraint test]    						**caught**
CALL AddToCart(2, 4, 25);			-- normal item
-- CALL AddToCart(1, 2, -1);						-- edge case: adding negative quantity [check constraint test]    					**caught**
-- CALL AddToCart(1, 2, 0);						-- edge case: adding 0 quantity [check constraint test]    								**caught**


/* INSERTING TRANSACTIONS */
CALL AddNewTransaction(1, '1234', 'John Doe', 100.00, '123 Main St', 'Springfield', 'IL', '62704');			-- normal transaction
CALL AddNewTransaction(4, '1234', 'John Doe', 100.00, '123 Main St', 'Springfield', 'IL', '627');			-- test 3 digit zipcode (testing 3 digit format check clause)
-- CALL AddNewTransaction(2, '1234', 'Jane Doe', -10.00, '123 Main St', 'Springfield', 'IL', '62704');		-- edge case: test negative total cost [check constraint test]    	**caught**
-- CALL AddNewTransaction(3, '123', 'Alice Smith', 100.00, '123 Main St', 'Springfield', 'IL', '62704');		-- edge case: 3 digit card [check constraint test]    				**caught**
-- CALL AddNewTransaction(3, '1234', 'Alice Smith', 100.00, '123 Main St', 'Springfield', 'IL', '');			-- edge case: invalid zipcode [check constraint test]    			**caught**


/* INSERTING INTO SAVED */
CALL AddNewSaved(1, 1);			-- normal saved product
CALL AddNewSaved(1, 2);			-- normal saved product
CALL AddNewSaved(2, 1);			-- normal saved product
CALL AddNewSaved(2, 3);			-- normal saved product
-- CALL AddNewSaved(10000, 1);		-- edge case: user doesn't exist									**caught**    [key constraint]
-- CALL AddNewSaved(1, 10000);		-- edge case: product doesn't exist									**caught**    [key constraint]
-- CALL AddNewSaved(1, 1);			-- edge case: duplicate entry (same user, add same product)			**caught**    [key duplicate]


/* INSERTING PURCHASES */
CALL AddNewPurchase(1, 1, 2);			-- normal purchase log
CALL AddNewPurchase(1, 2, 3);			-- normal purchase log
CALL AddNewPurchase(2, 1, 1);			-- normal purchase log
-- CALL AddNewPurchase(1, 1, -1);			-- edge case: negative quantity [check constraint test]    	**caught**


/* CHECK OUT PROCEDURES */
/*
SET @is_valid = NULL;						-- CHECK IF CART QUANTITY IS VALID    0 = FALSE = NOT VALID; 1 = TRUE = VALID
CALL ValidateCartStock(1, @is_valid);
SELECT @is_valid;
CALL AdjustCartQuantities(1);				-- IF NOT VALID, OPTIONALLY ADJUST QUANTITY TO AVAILABLE STOCK
CALL Checkout(1, '1234', 'yes', '123 yes', 'yes', 'yes', '12345');

SET @is_valid = NULL;						-- CHECK IF CART QUANTITY IS VALID    0 = FALSE = NOT VALID; 1 = TRUE = VALID
CALL ValidateCartStock(2, @is_valid);
SELECT @is_valid;
CALL AdjustCartQuantities(2);				-- IF NOT VALID, OPTIONALLY ADJUST QUANTITY TO AVAILABLE STOCK
CALL Checkout(2, '1234', 'yes', '123 yes', 'yes', 'yes', '12345');  */			-- backend's job, as long as validatecartstock is NOT valid, we will NEVER call checkout procedure


/* TESTING SET INACTIVE */
/*
CALL SetUserInActive(1);			-- expect their username to change to inactive user, cart will be emptied, saved will be emptied of their selections
CALL SetUserInActive(2);			-- expected after running both cart and saved are empty, and both their reviews for store and product are IsActive = 0 and Username = 'inactive_user'
*/


/* TESTING DERIVED ATTRIBUTE PROCEDURES */
/*
SET @total = NULL;
CALL GetCartTotal(1, @total);
SELECT @total;						-- expected 4348.70
-- ----------------------------------------------------
SET @name = NULL;
CALL GetAuthorOfProductReview(1, @name);
SELECT @name						-- expected John Doe

SET @name = NULL;
CALL GetAuthorOfStoreReview(2, @name);
SELECT @name						-- expected Jane Doe
-- ----------------------------------------------------
SET @age = NULL;
CALL GetUserAge(5, @age);
SELECT @age							-- expected 9  / if not exist = return null
-- ----------------------------------------------------
SET @age = NULL;
CALL GetStoreAge(1, @age);
SELECT @age							-- expected 9

SET @numReview = NULL;
CALL GetNumberOfStoreReviews(1, @numReview);
SELECT @numReview					-- expected 2

SET @rating = NULL;
CALL GetStoreRating(1, @rating);
SELECT @rating						-- expected 4.2   (8.3/2 = 4.15 round up)
-- ----------------------------------------------------
SET @age = NULL;
CALL GetProductAge(1, @age);
SELECT @age							-- expected 1

SET @numReview = NULL;
CALL GetNumberOfProductReviews(1, @numReview);
SELECT @numReview					-- expected 2

SET @rating = NULL;
CALL GetProductRating(1, @rating);
SELECT @rating						-- expected 4.2   (8.3/2 = 4.15 round up)

-- TEST SIGN UP
CALL SignUp('yes', 'yes', 'yes', 'yes', 'yes');

-- TEST LOG IN
SET @isCorrect = NULL;	
CALL VerifyLogin('yes', 'yes', @isCorrect);
SELECT @isCorrect					-- expected 1 = true

SET @isCorrect = NULL;	
CALL VerifyLogin('yes', 'no', @isCorrect);
SELECT @isCorrect					-- expected 0 = false

-- TEST FORGOT DETAILS AND VERIFY
SET @securityQ = NULL;
CALL ForgotPassword('partial_address_use', @securityQ);
SELECT @securityQ					-- expected error message, user doesnt exist

SET @password = NULL;
CALL VerifyAndReturnPassword('partial_address_user', 'no', @password);
SELECT @password					-- expected password: NULL

SET @securityQ = NULL;
CALL ForgotUsername('partial@example.co', @securityQ);
SELECT @securityQ					-- expected error message, user doesnt exist

SET @username = NULL;
CALL VerifyAndReturnUsername('partial@example.com', 'no', @username);
SELECT @username					-- expected username: NULL

SET @securityQ = NULL;
CALL ForgotPassword('partial_address_user', @securityQ);
SELECT @securityQ					-- expected securityQ: 'Mother's maiden name?'

SET @password = NULL;
CALL VerifyAndReturnPassword('partial_address_user', 'Smith', @password);
SELECT @password					-- expected password: 'passWord456'

SET @securityQ = NULL;
CALL ForgotUsername('partial@example.com', @securityQ);
SELECT @securityQ					-- expected securityQ: 'Mother's maiden name?'

SET @username = NULL;
CALL VerifyAndReturnUsername('partial@example.com', 'Smith', @username);
SELECT @username					-- expected username: 'partial_address_user'
*/