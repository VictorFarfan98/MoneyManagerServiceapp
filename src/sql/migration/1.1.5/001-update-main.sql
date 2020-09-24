## Fix WIG chart slope so it starts at the X axis value ##
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
    pLevel1_1 DECIMAL(16,3),
    pLevel2_1 DECIMAL(16,3),
    pLevel3_1 DECIMAL(16,3),
    pDisplayName1 nvarchar(256),
    pDataTypeId1 INT,
    pX2 DECIMAL(16,3),
    pY2 DECIMAL(16,3),
    pLevel1_2 DECIMAL(16,3),
    pLevel2_2 DECIMAL(16,3),
    pLevel3_2 DECIMAL(16,3),
    pDisplayName2 nvarchar(256),
    pDataTypeId2 INT,
    pTeamId INT
)
BEGIN
    DECLARE varWIGId INT UNSIGNED;
    DECLARE varAxisId INT UNSIGNED;
    DECLARE varProfileId INT UNSIGNED;
    DECLARE varDir INT UNSIGNED;
    DECLARE varMonthlyLimit4 DECIMAL(16,3);
    DECLARE varMonthlyLimit3 DECIMAL(16,3);
    DECLARE varMonthlyLimit2 DECIMAL(16,3);
    DECLARE varMonthlyLimit1 DECIMAL(16,3);

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

            SET varMonthlyLimit4 = 0;
            SET varMonthlyLimit3 = 0;
            SET varMonthlyLimit2 = 0;
            SET varMonthlyLimit1 = 0;
            IF pY1 != 0 THEN
                SET varMonthlyLimit4 = (pY1 - pX1) / 12;
                SET varMonthlyLimit3 = (pLevel3_1 - pX1) / 12;
                SET varMonthlyLimit2 = (pLevel2_1 - pX1) / 12;
                SET varMonthlyLimit1 = (pLevel1_1 - pX1) / 12;
            END IF;
        ELSE
            SET varDir = 0;
            SET varMonthlyLimit4 = (pX1 - pY1) / 12;
            SET varMonthlyLimit3 = (pX1 - pLevel3_1) / 12;
            SET varMonthlyLimit2 = (pX1 - pLevel2_1) / 12;
            SET varMonthlyLimit1 = (pX1 - pLevel1_1) / 12;
        END IF; 

        CALL sp_get_range_table(12, 'tmp_periods');

	    INSERT INTO Axis (ObjectId, X, Y, DisplayName, Dir, `Default`, CreatedAt, `Status`, DataTypeId, AxisTypeId)
        VALUES (varWIGId, pX1, pY1, pDisplayName1, varDir, 1, NOW(), 1, pDataTypeId1, 10);

        SET varAxisId =(SELECT LAST_INSERT_ID());

        INSERT INTO AxisProfile(AxisId, Level1, Level2, Level3, Level4)
        VALUES (varAxisId, pLevel1_1, pLevel2_1, pLevel3_1, pY1);

        INSERT INTO PeriodGoal(Period, Level4, Level3, Level2, Level1, AxisId, Status)
        SELECT Id, 
        IF(varDir = 1, pX1 + Id * varMonthlyLimit4, pX1 - Id * varMonthlyLimit4),
        IF(varDir = 1, pX1 + Id * varMonthlyLimit3, pX1 - Id * varMonthlyLimit3),
        IF(varDir = 1, pX1 + Id * varMonthlyLimit2, pX1 - Id * varMonthlyLimit2),
        IF(varDir = 1, pX1 + Id * varMonthlyLimit1, pX1 - Id * varMonthlyLimit1),
        varAxisId, 
        1 FROM tmp_periods;

        IF(pX2 IS NOT NULL) THEN
            IF pX2 <= pY2 THEN
                SET varDir = 1;

                SET varMonthlyLimit4 = 0;
                SET varMonthlyLimit3 = 0;
                SET varMonthlyLimit2 = 0;
                SET varMonthlyLimit1 = 0;
                IF pY2 != 0 THEN
                    SET varMonthlyLimit4 = pY2 / 12;
                    SET varMonthlyLimit3 = pLevel3_2 / 12;
                    SET varMonthlyLimit2 = pLevel2_2 / 12;
                    SET varMonthlyLimit1 = pLevel1_2 / 12;
                END IF;
            ELSE
                SET varDir = 0;

                SET varMonthlyLimit4 = (pX2 - pY2) / 12;
                SET varMonthlyLimit3 = (pX2 - pLevel3_2) / 12;
                SET varMonthlyLimit2 = (pX2 - pLevel2_2) / 12;
                SET varMonthlyLimit1 = (pX2 - pLevel1_2) / 12;
            END IF; 

            INSERT INTO Axis (ObjectId, X, Y, DisplayName, Dir, `Default`, CreatedAt, `Status`, DataTypeId, AxisTypeId)
            VALUES (varWIGId, pX2, pY2, pDisplayName2, varDir, 0, NOW(), 1, pDataTypeId2, 20);

            SET varAxisId =(SELECT LAST_INSERT_ID());

            INSERT INTO AxisProfile(AxisId, Level1, Level2, Level3, Level4)
            VALUES (varAxisId, pLevel1_2, pLevel2_2, pLevel3_2, pY2);

            INSERT INTO PeriodGoal(Period, Level4, Level3, Level2, Level1, AxisId, Status)
            SELECT Id, 
            IF(varDir = 1, pX2 + Id * varMonthlyLimit4, pX2 - Id * varMonthlyLimit4),
            IF(varDir = 1, pX2 + Id * varMonthlyLimit3, pX2 - Id * varMonthlyLimit3),
            IF(varDir = 1, pX2 + Id * varMonthlyLimit2, pX2 - Id * varMonthlyLimit2),
            IF(varDir = 1, pX2 + Id * varMonthlyLimit1, pX2 - Id * varMonthlyLimit1),
            varAxisId, 
            1 FROM tmp_periods;
        END IF;

        SELECT varWIGId WIGId;

        ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
        CALL Log_Save (1, null, varWIGId, null, null, null, null, null, null, pUserId);
    ELSE
        SET varMessage = (SELECT `Value` FROM `${DB_CONFIG}`.ProjectParameters WHERE `Name` = 'App-WIG-Validation-Message');
		SELECT varMessage as Error, 409 as ErrorCode;
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
    pLevel1_1 DECIMAL(16,3),
    pLevel2_1 DECIMAL(16,3),
    pLevel3_1 DECIMAL(16,3),
    pDisplayName1 nvarchar(256),
    pDataTypeId1 INT,
    pX2 DECIMAL(16,3),
    pY2 DECIMAL(16,3),
    pLevel1_2 DECIMAL(16,3),
    pLevel2_2 DECIMAL(16,3),
    pLevel3_2 DECIMAL(16,3),
    pDisplayName2 nvarchar(256),
    pDataTypeId2 INT
)
BEGIN
    DECLARE varAxisId INT UNSIGNED;
    DECLARE varDir INT UNSIGNED;
    DECLARE varMonthlyLimit4 DECIMAL(16,3);
    DECLARE varMonthlyLimit3 DECIMAL(16,3);
    DECLARE varMonthlyLimit2 DECIMAL(16,3);
    DECLARE varMonthlyLimit1 DECIMAL(16,3);
    
    DECLARE varUserId INT;

    UPDATE `WIG` SET Verb = pVerb, What = pWhat, `Description` = pDescription 
    WHERE Id = pWIGId;

    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pWIGId AND AxisTypeId = 10);

    IF pX1 <= pY1 THEN
        SET varDir = 1;

        SET varMonthlyLimit4 = 0;
        SET varMonthlyLimit3 = 0;
        SET varMonthlyLimit2 = 0;
        SET varMonthlyLimit1 = 0;
        IF pY1 != 0 THEN
            SET varMonthlyLimit4 = (pY1 - pX1) / 12;
            SET varMonthlyLimit3 = (pLevel3_1 - pX1) / 12;
            SET varMonthlyLimit2 = (pLevel2_1 - pX1) / 12;
            SET varMonthlyLimit1 = (pLevel1_1 - pX1) / 12;
        END IF;
    ELSE
        SET varDir = 0;
        SET varMonthlyLimit4 = (pX1 - pY1) / 12;
        SET varMonthlyLimit3 = (pX1 - pLevel3_1) / 12;
        SET varMonthlyLimit2 = (pX1 - pLevel2_1) / 12;
        SET varMonthlyLimit1 = (pX1 - pLevel1_1) / 12;
    END IF; 

    CALL sp_get_range_table(12, 'tmp_periods');

    UPDATE `Axis` SET X = pX1, Y = pY1, DisplayName = pDisplayName1, DataTypeId = pDataTypeId1, Dir = varDir
    WHERE Id = varAxisId;

    UPDATE AxisProfile SET Level1 = pLevel1_1, Level2 = pLevel2_1, Level3 = pLevel3_1, Level4 = pY1
    WHERE AxisId = varAxisId;

    DELETE FROM PeriodGoal WHERE AxisId = varAxisId;

    INSERT INTO PeriodGoal(Period, Level4, Level3, Level2, Level1, AxisId, Status)
    SELECT Id, 
    IF(varDir = 1, pX1 + Id * varMonthlyLimit4, pX1 - Id * varMonthlyLimit4),
    IF(varDir = 1, pX1 + Id * varMonthlyLimit3, pX1 - Id * varMonthlyLimit3),
    IF(varDir = 1, pX1 + Id * varMonthlyLimit2, pX1 - Id * varMonthlyLimit2),
    IF(varDir = 1, pX1 + Id * varMonthlyLimit1, pX1 - Id * varMonthlyLimit1),
    varAxisId, 
    1 FROM tmp_periods;

    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pWIGId AND AxisTypeId = 20);

    IF(varAxisId IS NOT NULL) THEN
        IF pX2 <= pY2 THEN
            SET varDir = 1;

            SET varMonthlyLimit4 = 0;
            SET varMonthlyLimit3 = 0;
            SET varMonthlyLimit2 = 0;
            SET varMonthlyLimit1 = 0;
            IF pY2 != 0 THEN
                SET varMonthlyLimit4 = pY2 / 12;
                SET varMonthlyLimit3 = pLevel3_2 / 12;
                SET varMonthlyLimit2 = pLevel2_2 / 12;
                SET varMonthlyLimit1 = pLevel1_2 / 12;
            END IF;
        ELSE
            SET varDir = 0;

            SET varMonthlyLimit4 = (pX2 - pY2) / 12;
            SET varMonthlyLimit3 = (pX2 - pLevel3_2) / 12;
            SET varMonthlyLimit2 = (pX2 - pLevel2_2) / 12;
            SET varMonthlyLimit1 = (pX2 - pLevel1_2) / 12;
        END IF; 

        UPDATE `Axis` SET X = pX2, Y = pY2, DisplayName = pDisplayName2, DataTypeId = pDataTypeId2, Dir = varDir
        WHERE Id = varAxisId;

        UPDATE AxisProfile SET Level1 = pLevel1_2, Level2 = pLevel2_2, Level3 = pLevel3_2, Level4 = pY2
        WHERE AxisId = varAxisId;

        DELETE FROM PeriodGoal WHERE AxisId = varAxisId;

        INSERT INTO PeriodGoal(Period, Level4, Level3, Level2, Level1, AxisId, Status)
        SELECT Id, 
        IF(varDir = 1, pX2 + Id * varMonthlyLimit4, pX2 - Id * varMonthlyLimit4),
        IF(varDir = 1, pX2 + Id * varMonthlyLimit3, pX2 - Id * varMonthlyLimit3),
        IF(varDir = 1, pX2 + Id * varMonthlyLimit2, pX2 - Id * varMonthlyLimit2),
        IF(varDir = 1, pX2 + Id * varMonthlyLimit1, pX2 - Id * varMonthlyLimit1),
        varAxisId, 
        1 FROM tmp_periods;
    END IF;

    SET varUserId = (SELECT CreatedBy FROM WIG WHERE Id=pWIGId);
    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (2, null, pWIGId, null, null, null, null, null, null, varUserId);

    SELECT 'WIG successfully updated.' as Success;
END$$

DELIMITER ;