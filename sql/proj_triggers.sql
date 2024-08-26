-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER set_user_stores_inactive 
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
	IF (OLD.IsActive != NEW.IsActive AND NEW.IsActive = FALSE) THEN
		UPDATE store
        SET IsActive = FALSE
        WHERE OwnerID = NEW.UserID;
	END IF;
END$$

CREATE TRIGGER set_store_products_inactive 
AFTER UPDATE ON store
FOR EACH ROW
BEGIN
	IF (OLD.IsActive != NEW.IsActive AND NEW.IsActive = FALSE) THEN
		UPDATE product
        SET IsActive = FALSE, StockQuantity = 0
        WHERE StoreID = NEW.StoreID;
	END IF;
END$$

DELIMITER ;

