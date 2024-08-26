-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES CONSTRUCTOR
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

/*
	Method to add new store schedule.
    It verifies on insert:
    - opening time < closing time
    - no overlap with an already existing schedule
*/
CREATE PROCEDURE AddNewStoreSchedule (
	IN new_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    IN new_StoreID INTEGER,
    IN new_OpeningTime TIME,
    IN new_ClosingTime TIME	
)
BEGIN
	CALL ValidateStoreScheduleConstruct (new_DayOfWeek, new_StoreID, new_OpeningTime, new_ClosingTime);
    
	INSERT INTO storeschedule (DayOfWeek, StoreID, OpeningTime, ClosingTime)
	VALUES (new_DayOfWeek, new_StoreID, new_OpeningTime, new_ClosingTime);
END$$
  

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES GETTERS (SELF-EXPLANATORY) 
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetFullSchedule (
	IN param_StoreID INTEGER
)
BEGIN
	SELECT *
    FROM storeschedule
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE GetScheduleOfDay (
    IN param_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
	IN param_StoreID INTEGER
)
BEGIN
	SELECT *
    FROM storeschedule
    WHERE StoreID = param_StoreID AND DayOfWeek = param_DayOfWeek;
END$$

CREATE PROCEDURE GetScheduleOfOpeningTime (
	IN param_StoreID INTEGER,
    IN param_OpeningTime TIME
)
BEGIN
	SELECT *
    FROM storeschedule
    WHERE StoreID = param_StoreID AND OpeningTime = param_OpeningTime;
END$$

CREATE PROCEDURE GetScheduleOfClosingTime (
	IN param_StoreID INTEGER,
    IN param_ClosingTime TIME
)
BEGIN
	SELECT *
    FROM storeschedule
    WHERE StoreID = param_StoreID AND ClosingTime = param_ClosingTime;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES SETTERS (SELF-EXPLANATORY) [uses validation to verify]
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE SetNewSchedule (   -- [ASSUMES CHANGING SCHEDULE FOR SAME STORE, SAME DAY]
	IN param_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    IN param_StoreID INTEGER,
    IN param_OpeningTime TIME,
    IN param_ClosingTime TIME,
    IN new_OpeningTime TIME,
    IN new_ClosingTime TIME	
)
BEGIN
	CALL ValidateStoreScheduleUpdate (param_DayOfWeek, param_StoreID, new_OpeningTime, new_ClosingTime, param_OpeningTime, param_ClosingTime);
    
    UPDATE storeschedule
    SET OpeningTime = new_OpeningTime, ClosingTime = new_ClosingTime
    WHERE DayOfWeek = param_DayOfWeek AND StoreID = param_StoreID AND OpeningTime = param_OpeningTime AND ClosingTime = param_ClosingTime;
END$$

CREATE PROCEDURE SetNewDay (
    IN param_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    IN param_StoreID INTEGER,
    IN param_OpeningTime TIME,
    IN param_ClosingTime TIME,
    IN new_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
)
BEGIN
    CALL ValidateStoreScheduleUpdate(new_DayOfWeek, param_StoreID, param_OpeningTime, param_ClosingTime, param_OpeningTime, param_ClosingTime);
    
    UPDATE storeschedule
    SET DayOfWeek = new_DayOfWeek
    WHERE StoreID = param_StoreID AND DayOfWeek = param_DayOfWeek AND OpeningTime = param_OpeningTime AND ClosingTime = param_ClosingTime;
END$$

CREATE PROCEDURE SetNewOpeningTime (
    IN param_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    IN param_StoreID INTEGER,
    IN param_OpeningTime TIME,
    IN param_ClosingTime TIME,
    IN new_OpeningTime TIME
)
BEGIN
    CALL ValidateStoreScheduleUpdate(param_DayOfWeek, param_StoreID, new_OpeningTime, param_ClosingTime, param_OpeningTime, param_ClosingTime);
    
    UPDATE storeschedule
    SET OpeningTime = new_OpeningTime
    WHERE DayOfWeek = param_DayOfWeek AND StoreID = param_StoreID AND OpeningTime = param_OpeningTime AND ClosingTime = param_ClosingTime;
END$$

CREATE PROCEDURE SetNewClosingTime (
    IN param_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    IN param_StoreID INTEGER,
    IN param_OpeningTime TIME,
    IN param_ClosingTime TIME,
    IN new_ClosingTime TIME
)
BEGIN
    CALL ValidateStoreScheduleUpdate(param_DayOfWeek, param_StoreID, param_OpeningTime, new_ClosingTime, param_OpeningTime, param_ClosingTime);
    
    UPDATE storeschedule
    SET ClosingTime = new_ClosingTime
    WHERE DayOfWeek = param_DayOfWeek AND StoreID = param_StoreID AND OpeningTime = param_OpeningTime AND ClosingTime = param_ClosingTime;
END$$


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DELETE [**of a single store**] (SELF-EXPLANATORY)
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE DeleteSpecificSchedule (
	IN param_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    IN param_StoreID INTEGER,
    IN param_OpeningTime TIME,
    IN param_ClosingTime TIME
)
BEGIN
	DELETE FROM storeschedule
    WHERE StoreID = param_StoreID AND DayOfWeek = param_DayOfWeek AND OpeningTime = param_OpeningTime AND ClosingTime = param_ClosingTime;
END$$

CREATE PROCEDURE DeleteAllSchedule (
	IN param_StoreID INTEGER
)
BEGIN
	DELETE FROM storeschedule
    WHERE StoreID = param_StoreID;
END$$

CREATE PROCEDURE DeleteScheduleDay (
	IN param_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    IN param_StoreID INTEGER
)
BEGIN
	DELETE FROM storeschedule
    WHERE StoreID = param_StoreID AND DayOfWeek = param_DayOfWeek;
END$$

CREATE PROCEDURE DeleteScheduleOpeningTime (
	IN param_StoreID INTEGER,
    IN param_OpeningTime TIME
)
BEGIN
	DELETE FROM storeschedule
    WHERE StoreID = param_StoreID AND OpeningTime = param_OpeningTime;
END$$

CREATE PROCEDURE DeleteScheduleClosingTime (
	IN param_StoreID INTEGER,
    IN param_ClosingTime TIME
)
BEGIN
	DELETE FROM storeschedule
    WHERE StoreID = param_StoreID AND ClosingTime = param_ClosingTime;
END$$

  
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURES DATA VALIDATION
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidateStoreScheduleConstruct (
	IN new_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
	IN new_StoreID INTEGER,
    IN new_OpeningTime TIME,
    IN new_ClosingTime TIME
)	
BEGIN
	IF new_OpeningTime >= new_ClosingTime THEN													-- validates if opening time is logically before closing
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Opening time must be before closing time.';
    END IF;
    
    IF EXISTS (																				-- validates if there is conflict in timing with another schedule of same store, same day
        SELECT 1		
        FROM storeschedule
        WHERE StoreID = new_StoreID AND DayOfWeek = new_DayOfWeek
        AND (
            (new_OpeningTime < ClosingTime AND new_OpeningTime > OpeningTime) OR 
            (new_ClosingTime < ClosingTime AND new_ClosingTime > OpeningTime) OR 
            (new_OpeningTime <= OpeningTime AND new_ClosingTime >= ClosingTime)
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Conflicting schedule times.';
    END IF;
END$$  

CREATE PROCEDURE ValidateStoreScheduleUpdate (
	IN new_DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    IN new_StoreID INTEGER,
    IN new_OpeningTime TIME,
    IN new_ClosingTime TIME,
    IN current_OpeningTime TIME,
    IN current_ClosingTime TIME	
)
BEGIN
	IF new_OpeningTime >= new_ClosingTime THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Opening time must be before closing time.';
    END IF;
    
    IF EXISTS (
		SELECT 1
        FROM storeschedule
        WHERE StoreID = new_StoreID AND DayOfWeek = new_DayOfWeek									-- look for stores with same ID and targeting same day of the week
        AND NOT (OpeningTime = current_OpeningTime AND ClosingTime = current_ClosingTime)			-- and among these stores select all EXCEPT the current one being changed
        AND (																						-- make sure this change reflects well with all selected schedules besides current one being changed
            (new_OpeningTime < ClosingTime AND new_OpeningTime > OpeningTime) OR 
            (new_ClosingTime < ClosingTime AND new_ClosingTime > OpeningTime) OR 
            (new_OpeningTime <= OpeningTime AND new_ClosingTime >= ClosingTime)
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Conflicting schedule times.';
    END IF;
END$$    
        
        
DELIMITER ;