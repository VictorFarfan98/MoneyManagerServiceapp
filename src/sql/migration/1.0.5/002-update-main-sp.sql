USE `${DB_MAIN}`;
DROP procedure IF EXISTS `sp_get_range_table`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `sp_get_range_table`(
IN `count` INT, 
IN target CHAR(255)
)
BEGIN
	# Variables
    DECLARE v1 INT Default 1;
    
    # Dropping table
	SET @sql := CONCAT('DROP TABLE IF EXISTS ', target);
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	# Creating table
	SET @sql := CONCAT('CREATE TEMPORARY TABLE ', target, ' (Id INT)');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
    
    
    WHILE v1 <= `count` DO
		SET @sql := CONCAT('INSERT INTO ', target, ' VALUES (', v1 , ')');
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		SET v1 = v1 + 1;
	END WHILE;
		
END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `WIG_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_Save`(
    pUserId INT,
    pVerb nvarchar(256),
    pWhat nvarchar(256),
    pYear INT,
    pDescription nvarchar(256),
    pX1 DECIMAL(16,3),
    pY1 DECIMAL(16,3),
    pDisplayName1 nvarchar(256),
    pDataTypeId1 INT,
    pX2 DECIMAL(16,3),
    pY2 DECIMAL(16,3),
    pDisplayName2 nvarchar(256),
    pDataTypeId2 INT,
    pTeamId INT
)
BEGIN
    DECLARE varWIGId INT UNSIGNED;
    DECLARE varAxisId INT UNSIGNED;
    DECLARE varProfileId INT UNSIGNED;
    DECLARE varDir INT UNSIGNED;
    DECLARE varMonthlyGoal DECIMAL(16,3);

    DECLARE varWIGs INT;
    DECLARE varMessage nvarchar(256);

    ## Change quantity logic here ##
    SET varWIGs = (SELECT Count(*) FROM WIG WHERE `Status` = 1 AND Year = pYear AND TeamId = pTeamId);

    IF varWIGs < 3 THEN 
        INSERT INTO `WIG` (Verb, What, Year, Description, CreatedAt, Status, CreatedBy, TeamId)
        VALUES (pVerb, pWhat, pYear, pDescription, NOW(), 1, pUserId, pTeamId);
        SET varWIGId =(SELECT LAST_INSERT_ID());

        IF pX1 <= pY1 THEN
            SET varDir = 1;

            SET varMonthlyGoal = 0;
            IF pY1 != 0 THEN
                SET varMonthlyGoal = pY1 / 12;
            END IF;
        ELSE
            SET varDir = 0;

            SET varMonthlyGoal = (pX1 - pY1) / 12;
        END IF; 

        CALL sp_get_range_table(12, 'tmp_periods');

	    INSERT INTO Axis (ObjectId, X, Y, DisplayName, Dir, `Default`, CreatedAt, `Status`, DataTypeId, AxisTypeId)
        VALUES (varWIGId, pX1, pY1, pDisplayName1, varDir, 1, NOW(), 1, pDataTypeId1, 10);

        SET varAxisId =(SELECT LAST_INSERT_ID());

        INSERT INTO PeriodGoal(Period, Y, AxisId, Status)
        SELECT Id, 
        IF(varDir = 1, Id * varMonthlyGoal, pX1 - Id * varMonthlyGoal), 
        varAxisId, 
        1 FROM tmp_periods;

        IF(pX2 IS NOT NULL) THEN
            IF pX2 <= pY2 THEN
                SET varDir = 1;

                SET varMonthlyGoal = 0;
                IF pY2 != 0 THEN
                    SET varMonthlyGoal = pY2 / 12;
                END IF;
            ELSE
                SET varDir = 0;

                SET varMonthlyGoal = (pX2 - pY2) / 12;
            END IF; 

            INSERT INTO Axis (ObjectId, X, Y, DisplayName, Dir, `Default`, CreatedAt, `Status`, DataTypeId, AxisTypeId)
            VALUES (varWIGId, pX2, pY2, pDisplayName2, varDir, 0, NOW(), 1, pDataTypeId2, 20);

            SET varAxisId =(SELECT LAST_INSERT_ID());

            INSERT INTO PeriodGoal(Period, Y, AxisId, Status)
            SELECT Id, 
            IF(varDir = 1, Id * varMonthlyGoal, pX2 - Id * varMonthlyGoal), 
            varAxisId, 
            1 FROM tmp_periods;
        END IF;

        SELECT varWIGId WIGId;
    ELSE
        SET varMessage = (SELECT `Value` FROM `${DB_CONFIG}`.ProjectParameters WHERE `Name` = 'App-WIG-Validation-Message');
		SELECT varMessage as Error, 409 as ErrorCode;
    END IF;
END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Get_Dataset0`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Get_Dataset0`(
    pAxisId INT
)
BEGIN
    DECLARE varAxisTypeId INT UNSIGNED;

    SELECT AxisTypeId FROM Axis WHERE Id = pAxisId LIMIT 1 INTO varAxisTypeId;

    IF varAxisTypeId = 10 OR varAxisTypeId = 20 THEN
        SELECT
        t.GoalAchived as `goalAchived`,
        ROUND(pg.Y, 2)  as y,
        pg.Period as period,
        a.Id as axisId,
        a.X as x,
        a.AxisTypeId as axisTypeId,
        a.DataTypeId as dataTypeId,
        (a.Dir + 0) as dir,
        IF(a.Dir ,t.GoalAchived - t.Y, t.Y - t.GoalAchived) as `difference`
        FROM 
        PeriodGoal pg 
        INNER JOIN Axis a ON (pg.AxisId = a.Id AND a.Id = pAxisId)
        LEFT OUTER JOIN Tracking t ON (pg.Period = t.Period AND t.AxisId = a.Id)
        LEFT OUTER JOIN Tracking tp ON (t.Period = tp.Period AND t.AxisId = tp.AxisId ) AND t.CreatedAt < tp.CreatedAt
        WHERE tp.id IS NULL 
        ORDER BY pg.Period;
    ELSE
        SELECT
        t.GoalAchived as `goalAchived`,
        t.Y as y,
        t.Period as period,
        t.AxisId as axisId,
        a.X as x,
        a.AxisTypeId as axisTypeId,
        a.DataTypeId as dataTypeId,
        (a.Dir + 0) as dir,
        IF(a.Dir ,t.GoalAchived - t.Y, t.Y - t.GoalAchived) as `difference`
        FROM Tracking t
        INNER JOIN Axis a ON (t.AxisId = a.Id)
        LEFT OUTER JOIN Tracking tp ON (t.Period = tp.Period AND t.AxisId = tp.AxisId ) AND t.CreatedAt < tp.CreatedAt
        WHERE tp.id IS NULL and t.AxisId = pAxisId
        ORDER BY t.Period;

    END IF;

END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `WIG_Update`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_Update`(
    pWIGId INT,
    pVerb nvarchar(256),
    pWhat nvarchar(256),
    pDescription nvarchar(256),
    pX1 DECIMAL(16,3),
    pY1 DECIMAL(16,3),
    pDisplayName1 nvarchar(256),
    pDataTypeId1 INT,
    pX2 DECIMAL(16,3),
    pY2 DECIMAL(16,3),
    pDisplayName2 nvarchar(256),
    pDataTypeId2 INT
)
BEGIN
    DECLARE varAxisId INT UNSIGNED;
    DECLARE varDir INT UNSIGNED;
    DECLARE varMonthlyGoal DECIMAL(16,3);

    UPDATE `WIG` SET Verb = pVerb, What = pWhat, `Description` = pDescription 
    WHERE Id = pWIGId;

    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pWIGId AND AxisTypeId = 10);

    IF pX1 <= pY1 THEN
        SET varDir = 1;

        SET varMonthlyGoal = 0;
        IF pY1 != 0 THEN
            SET varMonthlyGoal = pY1 / 12;
        END IF;
    ELSE
        SET varDir = 0;
        SET varMonthlyGoal = (pX1 - pY1) / 12;
    END IF; 

    CALL sp_get_range_table(12, 'tmp_periods');

    UPDATE `Axis` SET X = pX1, Y = pY1, DisplayName = pDisplayName1, DataTypeId = pDataTypeId1, Dir = varDir
    WHERE Id = varAxisId;

    DELETE FROM PeriodGoal WHERE AxisId = varAxisId;

    INSERT INTO PeriodGoal(Period, Y, AxisId, Status)
    SELECT Id, 
    IF(varDir = 1, Id * varMonthlyGoal, pX1 - Id * varMonthlyGoal), 
    varAxisId, 
    1 FROM tmp_periods;

    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pWIGId AND AxisTypeId = 20);

    IF(varAxisId IS NOT NULL) THEN
        IF pX2 <= pY2 THEN
            SET varDir = 1;

            SET varMonthlyGoal = 0;
            IF pY2 != 0 THEN
                SET varMonthlyGoal = pY2 / 12;
            END IF;
        ELSE
            SET varDir = 0;

            SET varMonthlyGoal = (pX2 - pY2) / 12;
        END IF; 

        UPDATE `Axis` SET X = pX2, Y = pY2, DisplayName = pDisplayName2, DataTypeId = pDataTypeId2, Dir = varDir
        WHERE Id = varAxisId;

        DELETE FROM PeriodGoal WHERE AxisId = varAxisId;

        INSERT INTO PeriodGoal(Period, Y, AxisId, Status)
        SELECT Id, 
        IF(varDir = 1, Id * varMonthlyGoal, pX2 - Id * varMonthlyGoal), 
        varAxisId, 
        1 FROM tmp_periods;
    END IF;

    SELECT 'WIG successfully updated.' as Success;
END$$

DELIMITER ;