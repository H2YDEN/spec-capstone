-- Project uses a soft-delete mechanism. This is to maintain history of transactions where UserID, ProductID, StoreID can't just vanish as either party may want to retain the details.
-- UserID, ProductID, StoreID are auto incremented so there is no foreseeable situation where any will be changed(updated).
-- If a user is not active, that means they're permanantly deleted
-- If a store or product is not active, they still have the ability to reopen or relist
-- This means if a store or product is inactive, no changes to reviews
-- If a user is inactive, they're privacy and reviews are retained through anonymity but still kept to benefit products and stores.


-- create database Project;
-- use Project;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TABLES
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE address (
	AddressID				INTEGER 			AUTO_INCREMENT,									-- addresses are not to be deleted nor updated; if user or store updates their address, and it doesnt exist, a new one is made; their old one remains for transaction's reference
    StreetName 				VARCHAR(255) 		NOT NULL,										-- address must be entered in full (assumption)
    City 					VARCHAR(100) 		NOT NULL,
    State 					VARCHAR(100) 		NOT NULL,
    ZipCode 				CHAR(10) 			NOT NULL,		
    
    PRIMARY KEY (AddressID)
);

CREATE TABLE users(
	UserID 					INTEGER 			AUTO_INCREMENT,
    IsActive				BOOLEAN				NOT NULL				DEFAULT TRUE,		-- flag, soft delete mechanism
    Username 				VARCHAR(50) 		NOT NULL,									-- unique to all active users (inactive will be set to inactive user via procedure check constraints
    LoginPassword 			VARCHAR(255) 		NOT NULL,
    Email 					VARCHAR(255) 		NOT NULL				UNIQUE,
    SecurityQ 				TEXT 				NOT NULL,
    SecurityQAnswer			TEXT 				NOT NULL,
    DateOfBirth 			DATE 				NULL,										-- DOB can be N/A if user chooses not to specify
    AddressID				INTEGER				NULL,										-- user may add address later
    
    PRIMARY KEY (UserID),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID)
);

CREATE TABLE store (
	StoreID 				INTEGER 			AUTO_INCREMENT,
    OwnerID 				INTEGER				NOT NULL,
    IsActive				BOOLEAN				NOT NULL				DEFAULT TRUE,		-- flag, soft delete mechanism						
    StoreName 				VARCHAR(100)		NOT NULL,
    EstablishmentDate 		DATE 				NOT NULL,
	AddressID				INTEGER				NULL,										-- store may add address later or never if it is fully online business
    
    PRIMARY KEY (StoreID),
    FOREIGN KEY (OwnerID) REFERENCES users(UserID),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID)
);

CREATE TABLE storeschedule(
	DayOfWeek 				ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    StoreID					INTEGER				NOT NULL,
    OpeningTime				TIME 				NOT NULL,
    ClosingTime				TIME				NOT NULL,
    
    PRIMARY KEY (StoreID, DayOfWeek, OpeningTime, ClosingTime),
    FOREIGN KEY (StoreID) REFERENCES store(StoreID)											-- if store is no longer active, delete all its schedules; there will be no situation where a store gets a new ID, update is unnecessary
);

CREATE TABLE storereview(
	ReviewID				INTEGER 			AUTO_INCREMENT,
    StoreID					INTEGER				NOT NULL,	
    UserID					INTEGER				NOT NULL,
    PublishDate				DATE				NOT NULL,									-- this does not need an auto trigger date validation, it will get current date when review was added to DB
    StarRating				DECIMAL(2,1) 		NOT NULL,
    DescriptionText			TEXT				NULL,										-- a user can just leave a star rating, explanation is optional
    
    PRIMARY KEY (ReviewID),
    FOREIGN KEY (StoreID) REFERENCES store(StoreID),
    FOREIGN KEY (UserID) REFERENCES users(UserID),
    
    UNIQUE (StoreID, UserID)																-- each user can only leave one review per store
);

CREATE TABLE product(
	ProductID				INTEGER 			AUTO_INCREMENT,
	StoreID					INTEGER				NOT NULL,
    UserID					INTEGER				NOT NULL,
    IsActive				BOOLEAN				NOT NULL				DEFAULT TRUE,		-- flag, soft delete mechanism
    Price					DECIMAL(20,2)		NOT NULL,
    ProductName				VARCHAR(100)		NOT NULL,
    ProductDescription		TEXT				NULL,
    ProductImage			VARCHAR(255)		NULL,                                       -- adding product image is optional (add default "no image" icon?)
    StockQuantity			INTEGER				NOT NULL,
    ReleaseDate				DATE				NOT NULL,									-- this does not need an auto trigger date validation, some products might be officially released in future (preorder product)
    
    PRIMARY KEY (ProductID),
	FOREIGN KEY (StoreID) REFERENCES store(StoreID),
    FOREIGN KEY (UserID) REFERENCES users(UserID)
);

CREATE TABLE productreview(
	ReviewID				INTEGER 			AUTO_INCREMENT,
    ProductID				INTEGER				NOT NULL,
    UserID					INTEGER				NOT NULL,
    PublishDate				DATE				NOT NULL,									-- this does not need an auto trigger date validation, it will get current date when review was added to DB	
    StarRating				DECIMAL(2,1) 		NOT NULL,
    DescriptionText			TEXT				NULL,										-- a user can just leave a star rating, explanation is optional
    
    PRIMARY KEY (ReviewID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID),
    FOREIGN KEY (UserID) REFERENCES users(UserID),
    
    UNIQUE (ProductID, UserID)																-- each user can only leave one review per product
);

CREATE TABLE coupon(
	CouponID				INTEGER 			AUTO_INCREMENT,
	ProductID				INTEGER				NOT NULL				UNIQUE,
    EndDate					DATE				NOT NULL,
    DiscountedPrice			DECIMAL(20,2)		NOT NULL,
    
    PRIMARY KEY (CouponID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE cart(
	UserID					INTEGER				NOT NULL,
    ProductID				INTEGER				NOT NULL,
    DateAdded				DATE 				NOT NULL,
    Quantity				INTEGER				NOT NULL,
    
    PRIMARY KEY (UserID, ProductID),
    FOREIGN KEY (UserID) REFERENCES users(UserID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE saved(
	UserID					INTEGER				NOT NULL,
    ProductID				INTEGER				NOT NULL,
    DateAdded				DATE				NOT NULL,
    
    PRIMARY KEY (UserID, ProductID),
    FOREIGN KEY (UserID) REFERENCES users(UserID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE transactions(
	TransactionID			INTEGER 			AUTO_INCREMENT,
    BuyerID					INTEGER				NOT NULL,
    LastFourDigits			CHAR(4)				NOT NULL,
    CardHolderName			VARCHAR(50)			NOT NULL,
    TotalCost				DECIMAL(20,2)		NOT NULL,
    DateOfPurchase			DATE				NOT NULL,									-- this does not need an auto trigger date validation, it will get current date when transaction was added to DB	
	AddressID				INTEGER				NOT NULL,									-- address details cannot be N/A for obvious reasons, needs to ship somewhere
    
	PRIMARY KEY (TransactionID),
    FOREIGN KEY (BuyerID) REFERENCES users(UserID),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID)
);

CREATE TABLE purchases(
	TransactionID			INTEGER				NOT NULL,
    ProductID				INTEGER				NOT NULL,
    PriceAtTheTime			DECIMAL(20,2)		NOT NULL,
    Quantity				INTEGER				NOT NULL,
    
    PRIMARY KEY (TransactionID, ProductID),
	FOREIGN KEY (TransactionID) REFERENCES transactions(TransactionID),						-- transactions are a history log, under no circumstances shall they be deleted
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);