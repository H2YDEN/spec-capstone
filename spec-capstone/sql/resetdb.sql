DROP TABLE IF EXISTS
purchases,
transactions,
saved,
cart,
coupon,
productreview,
product,
storereview,
storeschedule,
store,
users,
address;


DROP PROCEDURE IF EXISTS `AddNewAddress`; -- 
DROP PROCEDURE IF EXISTS `AddNewUser`;  -- 
DROP PROCEDURE IF EXISTS `AddNewStore`; -- 
DROP PROCEDURE IF EXISTS `AddNewStoreSchedule`;
DROP PROCEDURE IF EXISTS `AddNewStoreReview`;
DROP PROCEDURE IF EXISTS `AddNewProduct`;
DROP PROCEDURE IF EXISTS `AddNewProductReview`;
DROP PROCEDURE IF EXISTS `AddNewCoupon`;
DROP PROCEDURE IF EXISTS `AddToCart`;
DROP PROCEDURE IF EXISTS `AddNewSaved`;
DROP PROCEDURE IF EXISTS `AddNewTransaction`; -- 
DROP PROCEDURE IF EXISTS `AddNewPurchase`;

DROP PROCEDURE IF EXISTS `Checkout`;
DROP PROCEDURE IF EXISTS `ValidateCartStock`;



/*
SELECT * FROM users u LEFT JOIN address a ON u.AddressID = a.AddressID
SELECT * FROM store s LEFT JOIN address a ON s.AddressID = a.AddressID
SELECT * FROM storeschedule;
SELECT * FROM storereview s LEFT JOIN users u ON s.UserID = u.UserID
SELECT * FROM product;
SELECT * FROM productreview p LEFT JOIN users u ON p.UserID = u.UserID
SELECT * FROM coupon;
SELECT * FROM cart c LEFT JOIN product p ON c.ProductID = p.ProductID
SELECT * FROM saved;
SELECT * FROM transactions t LEFT JOIN address a ON t.AddressID = a.AddressID LEFT JOIN users u ON t.BuyerID = u.UserID
SELECT * FROM purchases;
*/


