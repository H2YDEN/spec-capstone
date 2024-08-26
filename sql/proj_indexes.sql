-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INDEXES
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- users
CREATE INDEX index_users_isactive ON users(IsActive);
CREATE INDEX index_users_username ON users(Username);
CREATE INDEX index_users_email ON users(Email);	

-- store
CREATE INDEX index_store_ownerid ON store(OwnerID);
CREATE INDEX index_store_isactive ON store(IsActive);
CREATE INDEX index_store_storename ON store(StoreName);

-- store schedule
CREATE INDEX index_storeschedule_storeid ON storeschedule(StoreID);		

-- store review
CREATE INDEX index_storereview_storeid ON storereview(StoreID);			
CREATE INDEX index_storereview_userid ON storereview(UserID);

-- product
CREATE INDEX index_product_productid ON product(ProductID);
CREATE INDEX index_product_storeid ON product(StoreID);					
CREATE INDEX index_product_userid ON product(UserID);
CREATE INDEX index_product_isactive ON product(IsActive);
CREATE INDEX index_product_price ON product(Price);

-- product review
CREATE INDEX index_productreview_productid ON productreview(ProductID);	
CREATE INDEX index_productreview_userid ON productreview(UserID);

-- coupon
CREATE INDEX index_coupon_productid ON coupon(ProductID);				

-- cart
CREATE INDEX index_cart_userid ON cart(UserID);							
CREATE INDEX index_cart_productid ON cart(ProductID);

-- saved
CREATE INDEX index_saved_userid ON saved(UserID);						
CREATE INDEX index_saved_productid ON saved(ProductID);

-- transactions
CREATE INDEX index_transactions_buyerid ON transactions(BuyerID);		

-- purchases
CREATE INDEX index_purchases_transactionid ON purchases(TransactionID);	
CREATE INDEX index_purchases_productid ON purchases(ProductID);