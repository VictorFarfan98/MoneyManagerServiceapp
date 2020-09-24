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
                SET varMonthlyLimit4 = pY1 / 12;
                SET varMonthlyLimit3 = pLevel3_1 / 12;
                SET varMonthlyLimit2 = pLevel2_1 / 12;
                SET varMonthlyLimit1 = pLevel1_1 / 12;
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
        IF(varDir = 1, Id * varMonthlyLimit4, pX1 - Id * varMonthlyLimit4),
        IF(varDir = 1, Id * varMonthlyLimit3, pX1 - Id * varMonthlyLimit3),
        IF(varDir = 1, Id * varMonthlyLimit2, pX1 - Id * varMonthlyLimit2),
        IF(varDir = 1, Id * varMonthlyLimit1, pX1 - Id * varMonthlyLimit1),
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
            IF(varDir = 1, Id * varMonthlyLimit4, pX2 - Id * varMonthlyLimit4),
            IF(varDir = 1, Id * varMonthlyLimit3, pX2 - Id * varMonthlyLimit3),
            IF(varDir = 1, Id * varMonthlyLimit2, pX2 - Id * varMonthlyLimit2),
            IF(varDir = 1, Id * varMonthlyLimit1, pX2 - Id * varMonthlyLimit1),
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
            SET varMonthlyLimit4 = pY1 / 12;
            SET varMonthlyLimit3 = pLevel3_1 / 12;
            SET varMonthlyLimit2 = pLevel2_1 / 12;
            SET varMonthlyLimit1 = pLevel1_1 / 12;
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
    IF(varDir = 1, Id * varMonthlyLimit4, pX1 - Id * varMonthlyLimit4),
    IF(varDir = 1, Id * varMonthlyLimit3, pX1 - Id * varMonthlyLimit3),
    IF(varDir = 1, Id * varMonthlyLimit2, pX1 - Id * varMonthlyLimit2),
    IF(varDir = 1, Id * varMonthlyLimit1, pX1 - Id * varMonthlyLimit1),
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
        IF(varDir = 1, Id * varMonthlyLimit4, pX2 - Id * varMonthlyLimit4),
        IF(varDir = 1, Id * varMonthlyLimit3, pX2 - Id * varMonthlyLimit3),
        IF(varDir = 1, Id * varMonthlyLimit2, pX2 - Id * varMonthlyLimit2),
        IF(varDir = 1, Id * varMonthlyLimit1, pX2 - Id * varMonthlyLimit1),
        varAxisId, 
        1 FROM tmp_periods;
    END IF;

    SELECT 'WIG successfully updated.' as Success;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `WIG_GetById`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_GetById`(
    pWIGId INT
)
BEGIN
    SELECT DISTINCT
    w.Id as id,
    CONCAT(w.Verb, ' ', w.What) as `name`,
    w.Verb as verb,
    w.What as what,
    w.Description as description, 
    w.Year as year,
    a1.Id as `axisId1`,
    a1.X as `x1`,
    a1.Y as `y1`,
    ap1.Level1 as level1_1,
    ap1.Level2 as level2_1,
    ap1.Level3 as level3_1,
    ap1.Level4 as level4_1,
    a1.DataTypeId as dataTypeId1,
    a1.DisplayName as `displayName1`,
    a2.Id as `axisId2`,
    a2.X as `x2`,
    a2.Y as `y2`,
    ap2.Level1 as level1_2,
    ap2.Level2 as level2_2,
    ap2.Level3 as level3_2,
    ap2.Level4 as level4_2,
    a2.dataTypeId as dataTypeId2,
    a2.DisplayName as `displayName2`,
    w.Status as `status`,
    IF(a2.Id IS NOT NULL, 2, 1) `axesNumber`
    FROM 
    WIG w
    INNER JOIN
    Axis a1 ON (w.Id = a1.ObjectId AND a1.AxisTypeId = 10)
    INNER JOIN 
    AxisProfile ap1 ON (a1.Id = ap1.AxisId)
    LEFT OUTER JOIN
    Axis a2 ON (w.Id = a2.ObjectId AND a2.AxisTypeId = 20)
    LEFT OUTER JOIN 
    AxisProfile ap2 ON (a2.Id = ap2.AxisId)
    WHERE w.Id = pWIGId;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Predictive_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Predictive_Save`(
    pWIGId INT,
    pUserId INT,
    pVerb nvarchar(256),
    pWhat nvarchar(256),
    pFocus nvarchar(256),
    pQuality nvarchar(256),
    pConsistency nvarchar(256),
    pDescription nvarchar(256),
    pGoal1 DECIMAL(16,3),
    pLevel21 DECIMAL(16,3),
    pDisplayName1 nvarchar(256),
    pDataTypeId1 INT,
    pDir1 BIT,
    pGoal2 DECIMAL(16,3),
    pLevel22 DECIMAL(16,3),
    pDisplayName2 nvarchar(256),
    pDataTypeId2 INT,
    pDir2 BIT
)
BEGIN
    DECLARE varPredictiveId INT UNSIGNED;
    DECLARE varPredictives INT;
    DECLARE varMessage nvarchar(256);

    ## Change quantity logic here ##
    SET varPredictives = (SELECT Count(*) FROM Predictive WHERE wigId = pWIGId AND `Status` = 1 );

    IF varPredictives < 3 THEN 
        INSERT INTO Predictive (Verb, What, Focus, Quality, Consistency, `Description`, CreatedAt, `Status`, WIGId, CreatedBy)
        VALUES (pVerb, pWhat, pFocus, pQuality, pConsistency, pDescription, NOW(), 1, pWIGId, pUserId);
        SET varPredictiveId =(SELECT LAST_INSERT_ID());

	    INSERT INTO Axis (ObjectId, X, Y, DisplayName, Dir, `Default`, CreatedAt, `Status`, DataTypeId, AxisTypeId)
        VALUES (varPredictiveId, pLevel21, pGoal1, pDisplayName1, pDir1, 1, NOW(), 1, pDataTypeId1, 30);

        IF(pGoal2 IS NOT NULL) THEN
            INSERT INTO Axis (ObjectId, X, Y, DisplayName, Dir, `Default`, CreatedAt, `Status`, DataTypeId, AxisTypeId)
            VALUES (varPredictiveId, pLevel22, pGoal2, pDisplayName2, pDir2, 0, NOW(), 1, pDataTypeId2, 40);
        END IF;

        SELECT varPredictiveId PredictiveId;
    ELSE
        SET varMessage = (SELECT `Value` FROM `${DB_CONFIG}`.ProjectParameters WHERE `Name` = 'App-Predictive-Validation-Message');
		SELECT varMessage as Error, 409 as ErrorCode;
    END IF;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Predictive_Update`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Predictive_Update`(
    pPredictiveId INT,
    pVerb nvarchar(256),
    pWhat nvarchar(256),
    pFocus nvarchar(256),
    pQuality nvarchar(256),
    pConsistency nvarchar(256),
    pDescription nvarchar(256),
    pX1 DECIMAL(16,3),
    pY1 DECIMAL(16,3),
    pDisplayName1 nvarchar(256),
    pDataTypeId1 INT,
    pDir1 INT,
    pX2 DECIMAL(16,3),
    pY2 DECIMAL(16,3),
    pDisplayName2 nvarchar(256),
    pDataTypeId2 INT,
    pDir2 INT
)
BEGIN
    DECLARE varAxisId INT UNSIGNED;

    UPDATE `Predictive` SET Verb = pVerb, What = pWhat, Focus = pFocus, Quality = pQuality, Consistency = pConsistency,
        `Description` = pDescription
    WHERE Id = pPredictiveId;

    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pPredictiveId AND AxisTypeId = 30);

    UPDATE `Axis` SET X = pX1, Y = pY1, DisplayName = pDisplayName1, DataTypeId = pDataTypeId1, Dir = pDir1
    WHERE Id = varAxisId;

    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pPredictiveId AND AxisTypeId = 40);

    IF(varAxisId IS NOT NULL) THEN
        UPDATE `Axis` SET X = pX2, Y = pY2, DisplayName = pDisplayName2, DataTypeId = pDataTypeId2, Dir = pDir2
        WHERE Id = varAxisId;
    END IF;

    SELECT 'Predictive successfully updated.' as Success;
END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP PROCEDURE IF EXISTS `Predictive_GetByWIGId`;

DELIMITER $$

USE `${DB_MAIN}`$$
CREATE PROCEDURE `Predictive_GetByWIGId`(
    pWIGId INT
)
BEGIN
    SELECT DISTINCT 
    p.Id as id, 
	p.WIGId as wigId, 
    p.Verb as verb,
    p.Focus as focus,
    p.What as what,
    p.Quality as quality,
    p.Consistency as consistency,
    p.Description as `description`,
    a1.Id as `axisId1`,
    a1.X as `x1`,
    a1.Y as `y1`,
    a1.DisplayName as `displayName1`,
    a1.dataTypeId as dataTypeId1,
    a2.Id as `axisId2`,
    a2.X as `x2`,
    a2.Y as `y2`,
    a2.DisplayName as `displayName2`,
    a2.dataTypeId as dataTypeId2,
    IF(a2.Id IS NOT NULL, 2, 1) `axesNumber`
    FROM 
    Predictive p
    INNER JOIN 
    Axis a1 ON (p.Id = a1.ObjectId AND a1.AxisTypeId = 30)
    LEFT OUTER JOIN
    Axis a2 ON (p.Id = a2.ObjectId AND a2.AxisTypeId = 40)
    WHERE p.WIGId = pWIGId AND p.Status = 1;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Predictive_GetById`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Predictive_GetById`(
    pPredictiveId INT
)
BEGIN
    SELECT DISTINCT 
    p.Id as id, 
	p.WIGId as wigId, 
    CONCAT(p.Verb, ' ', p.What, ' ', p.Focus, ' ', p.Quality) as `name`,
    p.Verb as verb,
    p.Focus as focus,
    p.What as what,
    p.Quality as quality,
    p.Consistency as consistency,
    p.Description as `description`,
    p.`Status` as `status`,
    a1.Id as `axisId1`,
    a1.X as `x1`,
    a1.Y as `y1`,
    a1.DisplayName as `displayName1`,
    a1.dataTypeId as dataTypeId1,
    (a1.Dir + 0) as dir1,
    a2.Id as `axisId2`,
    a2.X as `x2`,
    a2.Y as `y2`,
    a2.DisplayName as `displayName2`,
    a2.dataTypeId as dataTypeId2,
    (a2.Dir + 0) as dir2,
    IF(a2.Id IS NOT NULL, 2, 1) `axesNumber`
    FROM 
    Predictive p
    INNER JOIN 
    Axis a1 ON (p.Id = a1.ObjectId AND a1.AxisTypeId = 30)
    LEFT OUTER JOIN
    Axis a2 ON (p.Id = a2.ObjectId AND a2.AxisTypeId = 40)
    WHERE p.Id = pPredictiveId;
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
        ROUND(pg.Level4, 2) as level4,
        ROUND(pg.Level3, 2) as level3,
        ROUND(pg.Level2, 2) as level2,
        ROUND(pg.Level1, 2) as level1,
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
DROP procedure IF EXISTS `WIG_GetGoalsById`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_GetGoalsById`(
    pWIGId INT
    )
BEGIN
    SELECT
        g1.Period as `period1`,
        g1.AxisId as `axisId1`,
        g1.Level4 as `level4_1`,
        g1.Level3 as `level3_1`,
        g1.Level2 as `level2_1`,
        g1.Level1 as `level1_1`,
        a1.X as `x1`,
        a1.Y as `y1`,
        a1.DisplayName as `displayName1`,
        (a1.Dir + 0) as dir1,
        a1.DataTypeId as `dataTypeId1`,
        a1.AxisTypeId as `axisTypeId1`,
        g2.Period as `period2`,
        g2.AxisId as `axisId2`,
        g2.Level4 as `level4_2`,
        g2.Level3 as `level3_2`,
        g2.Level2 as `level2_2`,
        g2.Level1 as `level1_2`,
        a2.X as `x2`,
        a2.Y as `y2`,
        a2.DisplayName as `displayName2`,
        (a2.Dir + 0) as dir2,
        a2.DataTypeId as `dataTypeId2`,
        a2.AxisTypeId as `axisTypeId2`
    FROM 
    WIG w
    INNER JOIN
    Axis a1 ON (w.Id = a1.ObjectId AND a1.AxisTypeId = 10)
    INNER JOIN
    PeriodGoal g1 ON g1.AxisId = a1.Id
    LEFT OUTER JOIN
    Axis a2 ON (w.Id = a2.ObjectId AND a2.AxisTypeId = 20)
    LEFT OUTER JOIN
    PeriodGoal g2 ON g2.AxisId = a2.Id
    WHERE w.Id = pWIGId;

END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Axis_GetGoalsById`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Axis_GetGoalsById`(
    pAxisId INT
    )
BEGIN
    SELECT 
        pg.Period as `period`,
        pg.AxisId as `axisId`,
        pg.Level4 as `level4`,
        pg.Level3 as `level3`,
        pg.Level2 as `level2`,
        pg.Level1 as `level1`,
        a.X as `x`,
        a.Y as `y`,
        a.DisplayName as `displayName`,
        (a.Dir + 0) as dir,
        a.DataTypeId as `dataTypeId`,
        a.AxisTypeId as `axisTypeId`
    FROM PeriodGoal pg
    JOIN Axis a ON pg.AxisId = a.Id
    WHERE pg.AxisId = pAxisId;

END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Axis_SavePeriodGoals`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Axis_SavePeriodGoals`(
    pAxisId INT,
    pGoalsLevel4 nvarchar(1024),
    pGoalsLevel3 nvarchar(1024),
    pGoalsLevel2 nvarchar(1024),
    pGoalsLevel1 nvarchar(1024)
)
BEGIN

	###########	Drop temporary tables if exist ###########
	
	# List of goals
    DROP TABLE IF EXISTS t_tmp_goals1;
    DROP TABLE IF EXISTS t_tmp_goals2;
    DROP TABLE IF EXISTS t_tmp_goals3;
    DROP TABLE IF EXISTS t_tmp_goals4;
    
    CREATE TEMPORARY TABLE t_tmp_goals1 (Y DECIMAL(16,3));
    CREATE TEMPORARY TABLE t_tmp_goals2 (Y DECIMAL(16,3));
    CREATE TEMPORARY TABLE t_tmp_goals3 (Y DECIMAL(16,3));
    CREATE TEMPORARY TABLE t_tmp_goals4 (Y DECIMAL(16,3));
    
    # Filters for goals
    CALL `sp_parse_json`(pGoalsLevel1, 't_tmp_goals1');
    CALL `sp_parse_json`(pGoalsLevel2, 't_tmp_goals2');
    CALL `sp_parse_json`(pGoalsLevel3, 't_tmp_goals3');
    CALL `sp_parse_json`(pGoalsLevel4, 't_tmp_goals4');

    # Revove Data
    DELETE FROM PeriodGoal Where AxisId = pAxisId;

    # Insert data
    SET @row_number1 = 0;
    SET @row_number2 = 0;
    SET @row_number3 = 0;
    SET @row_number4 = 0;

    INSERT INTO PeriodGoal (Period, AxisId, Level4, Level3, Level2, Level1, Status)
    SELECT goal1.row_number, pAxisId, goal4.Y, goal3.Y, goal2.Y, goal1.Y, 1
        FROM
        (
            SELECT 
            (@row_number1:=@row_number1 + 1) as `row_number`, 
            Y as Y
            FROM
            t_tmp_goals1
        ) as goal1
        INNER JOIN
        (
            SELECT 
            (@row_number2:=@row_number2 + 1) as `row_number`, 
            Y as Y
            FROM
            t_tmp_goals2
        ) as goal2 ON (goal1.row_number = goal2.row_number)
        INNER JOIN
        (
            SELECT 
            (@row_number3:=@row_number3 + 1) as `row_number`, 
            Y as Y
            FROM
            t_tmp_goals3
        ) as goal3 ON (goal1.row_number = goal3.row_number)
        INNER JOIN
        (
            SELECT 
            (@row_number4:=@row_number4 + 1) as `row_number`, 
            Y as Y
            FROM
            t_tmp_goals4
        ) as goal4 ON (goal1.row_number = goal4.row_number);
    

END$$

DELIMITER ;