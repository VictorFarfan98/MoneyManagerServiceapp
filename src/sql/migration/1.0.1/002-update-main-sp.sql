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
    DECLARE varProfileId INT UNSIGNED;
    DECLARE varDir INT UNSIGNED;

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
        ELSE
            SET varDir = 0;
        END IF; 

	    INSERT INTO Axis (ObjectId, X, Y, DisplayName, Dir, `Default`, CreatedAt, `Status`, DataTypeId, AxisTypeId)
        VALUES (varWIGId, pX1, pY1, pDisplayName1, varDir, 1, NOW(), 1, pDataTypeId1, 10);

        IF(pX2 IS NOT NULL) THEN
            IF pX2 <= pY2 THEN
                SET varDir = 1;
            ELSE
                SET varDir = 0;
            END IF; 

            INSERT INTO Axis (ObjectId, X, Y, DisplayName, Dir, `Default`, CreatedAt, `Status`, DataTypeId, AxisTypeId)
            VALUES (varWIGId, pX2, pY2, pDisplayName2, varDir, 0, NOW(), 1, pDataTypeId2, 20);
        END IF;

        SELECT varWIGId WIGId;
    ELSE
        SET varMessage = (SELECT `Value` FROM `${DB_CONFIG}`.ProjectParameters WHERE `Name` = 'App-WIG-Validation-Message');
		SELECT varMessage as Error, 409 as ErrorCode;
    END IF;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Tracking_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Tracking_Save`(
    pUserId INT,
    pAxisId INT,
    pGoalAchived DECIMAL(16,3),
    pPeriod INT,
    pCommentary nvarchar(256)
)
BEGIN
    DECLARE varTrackingId INT UNSIGNED;
    DECLARE varGoal DECIMAL(16,3);

    SET varGoal = (SELECT Y FROM Axis WHERE Id = pAxisId);
    
    INSERT INTO `Tracking` (Y, GoalAchived, Period, Commentary, CreatedAt, Status, CreatedBy, AxisId)
    VALUES (varGoal, pGoalAchived, pPeriod, pCommentary, NOW(), 1, pUserId, pAxisId);
    SET varTrackingId =(SELECT LAST_INSERT_ID());

    SELECT varTrackingId TrackingId;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Tracking_WIG_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Tracking_WIG_Save`(
    pUserId INT,
    pWIGId INT,
    pGoalAchived1 DECIMAL(16,3),
    pCommentary1 nvarchar(256),
    pGoalAchived2 DECIMAL(16,3),
    pCommentary2 nvarchar(256),
    pPeriod INT
)
BEGIN
    DECLARE varAxisId INT UNSIGNED;
    DECLARE varGoal DECIMAL(16,3);
    DECLARE varTrackingId1 INT UNSIGNED;
    DECLARE varTrackingId2 INT UNSIGNED;

    ## Creating the main axis
    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pWIGId AND AxisTypeId = 10);

    SET varGoal = (SELECT Y FROM Axis WHERE Id = varAxisId);
    
    INSERT INTO `Tracking` (Y, GoalAchived, Period, Commentary, CreatedAt, Status, CreatedBy, AxisId)
    VALUES (varGoal, pGoalAchived1, pPeriod, pCommentary1, NOW(), 1, pUserId, varAxisId);
    SET varTrackingId1 =(SELECT LAST_INSERT_ID());

    ## Creating the second axis
    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pWIGId AND AxisTypeId = 20);

    IF(varAxisId IS NOT NULL) THEN
        SET varGoal = (SELECT Y FROM Axis WHERE Id = varAxisId);
    
        INSERT INTO `Tracking` (Y, GoalAchived, Period, Commentary, CreatedAt, Status, CreatedBy, AxisId)
        VALUES (varGoal, pGoalAchived2, pPeriod, pCommentary2, NOW(), 1, pUserId, varAxisId);
        SET varTrackingId2 =(SELECT LAST_INSERT_ID());
    END IF;

    SELECT varTrackingId1 AS TrackingId1, varTrackingId2 AS TrackingId2 ;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `WIG_GetAxes`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_GetAxes`(
    pWIGId INT
)
BEGIN
    SELECT Id AS id, DataTypeId as dataTypeId, AxisTypeId AS axisTypeId, X as x, Y as y
    FROM Axis 
    WHERE ObjectId = pWIGId AND ( AxisTypeId = 10 OR AxisTypeId = 20) ORDER BY AxisTypeId ASC;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Predictive_GetAxes`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Predictive_GetAxes`(
    pPredictiveId INT
)
BEGIN
    SELECT Id AS id, DataTypeId as dataTypeId, AxisTypeId AS axisTypeId, X as x, Y as y
    FROM Axis 
    WHERE ObjectId = pPredictiveId AND ( AxisTypeId = 30 OR AxisTypeId = 40) ORDER BY AxisTypeId ASC;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Tracking_GetByAxisId`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Tracking_GetByAxisId`(
    pAxisId INT
)
BEGIN
    SELECT
        t.Id as `id`,
        t.`Period` as `period`,
        t.Y as y,
        t.GoalAchived as `goalAchived`,
        IF(a.Dir ,t.GoalAchived - t.Y, t.Y - t.GoalAchived) as `difference`,
        (a.Dir + 0) as dir,
        a.DataTypeId as `dataTypeId`,
        DATE_FORMAT(t.CreatedAt, '%Y-%m-%d') as `createdAt`,
        t.Commentary as `commentary`
    FROM Tracking t
    INNER JOIN Axis a ON (t.AxisId = a.Id)
    WHERE t.AxisId = pAxisId
    ORDER BY t.CreatedAt DESC;

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
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Axis_GetById`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Axis_GetById`(
    pAxisId INT
)
BEGIN
    SELECT DISTINCT
    a.Id as `id`,
    a.X as `x`,
    a.Y as `y`,
    a.DataTypeId as dataTypeId,
    a.AxisTypeId as axisTypeId,
    a.DisplayName as `displayName`,
    a.ObjectId as objectId
    FROM 
    Axis a
    WHERE a.Id = pAxisId;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `WIG_Delete`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_Delete`(
    pWIGId INT
)
BEGIN
    UPDATE `WIG` SET Status = 0
    WHERE Id = pWIGId;

    SELECT 'WIG deleted correctly.' as Success;
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
    a1.DataTypeId as dataTypeId1,
    a1.DisplayName as `displayName1`,
    a2.Id as `axisId2`,
    a2.X as `x2`,
    a2.Y as `y2`,
    a2.dataTypeId as dataTypeId2,
    a2.DisplayName as `displayName2`,
    w.Status as `status`,
    IF(a2.Id IS NOT NULL, 2, 1) `axesNumber`
    FROM 
    WIG w
    INNER JOIN
    Axis a1 ON (w.Id = a1.ObjectId AND a1.AxisTypeId = 10)
    LEFT OUTER JOIN
    Axis a2 ON (w.Id = a2.ObjectId AND a2.AxisTypeId = 20)
    WHERE w.Id = pWIGId;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `WIG_GetByUserIdAndYear`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_GetByUserIdAndYear`(
    pUserId INT,
    pYear INT
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
    a1.DisplayName as `displayName1`,
    a1.dataTypeId as dataTypeId1,
    a2.Id as `axisId2`,
    a2.X as `x2`,
    a2.Y as `y2`,
    a2.DisplayName as `displayName2`,
    a2.dataTypeId as dataTypeId2,
    IF(a2.Id IS NOT NULL, 2, 1) `axesNumber`
    FROM 
    WIG w
    INNER JOIN
    Axis a1 ON (w.Id = a1.ObjectId AND a1.AxisTypeId = 10)
    LEFT OUTER JOIN
    Axis a2 ON (w.Id = a2.ObjectId AND a2.AxisTypeId = 20)
    WHERE (pYear IS NULL OR w.Year = pYear) AND w.Status = 1;
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
        INSERT INTO Predictive (Verb, What, Focus, Quality, `Description`, CreatedAt, `Status`, WIGId, CreatedBy)
        VALUES (pVerb, pWhat, pFocus, pQuality, pDescription, NOW(), 1, pWIGId, pUserId);
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
DROP procedure IF EXISTS `Tracking_PredictiveSave`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Tracking_PredictiveSave`(
    pUserId INT,
    pPredictiveId INT,
    pGoalAchived1 DECIMAL(16,3),
    pCommentary1 nvarchar(256),
    pGoalAchived2 DECIMAL(16,3),
    pCommentary2 nvarchar(256),
    pPeriod INT
)
BEGIN
    DECLARE varAxisId INT UNSIGNED;
    DECLARE varGoal DECIMAL(16,3);
    DECLARE varTrackingId1 INT UNSIGNED;
    DECLARE varTrackingId2 INT UNSIGNED;

    ## Getting the main axis
    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pPredictiveId AND AxisTypeId = 30);

    SET varGoal = (SELECT Y FROM Axis WHERE Id = varAxisId);
    
    INSERT INTO `Tracking` (Y, GoalAchived, Period, Commentary, CreatedAt, Status, CreatedBy, AxisId)
    VALUES (varGoal, pGoalAchived1, pPeriod, pCommentary1, NOW(), 1, pUserId, varAxisId);
    SET varTrackingId1 =(SELECT LAST_INSERT_ID());

    ## Getting the second axis
    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pPredictiveId AND AxisTypeId = 40);

    IF(varAxisId IS NOT NULL) THEN
        SET varGoal = (SELECT Y FROM Axis WHERE Id = varAxisId);
    
        INSERT INTO `Tracking` (Y, GoalAchived, Period, Commentary, CreatedAt, Status, CreatedBy, AxisId)
        VALUES (varGoal, pGoalAchived2, pPeriod, pCommentary2, NOW(), 1, pUserId, varAxisId);
        SET varTrackingId2 =(SELECT LAST_INSERT_ID());
    END IF;

    SELECT varTrackingId1 AS TrackingId1, varTrackingId2 AS TrackingId2 ;
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

    UPDATE `WIG` SET Verb = pVerb, What = pWhat, `Description` = pDescription 
    WHERE Id = pWIGId;

    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pWIGId AND AxisTypeId = 10);

    IF pX1 <= pY1 THEN
        SET varDir = 1;
    ELSE
        SET varDir = 0;
    END IF; 

    UPDATE `Axis` SET X = pX1, Y = pY1, DisplayName = pDisplayName1, DataTypeId = pDataTypeId1, Dir = varDir
    WHERE Id = varAxisId;

    SET varAxisId = (SELECT Id FROM Axis WHERE ObjectId = pWIGId AND AxisTypeId = 20);

    IF(varAxisId IS NOT NULL) THEN
        IF pX2 <= pY2 THEN
            SET varDir = 1;
        ELSE
            SET varDir = 0;
        END IF;

        UPDATE `Axis` SET X = pX2, Y = pY2, DisplayName = pDisplayName2, DataTypeId = pDataTypeId2, Dir = varDir
        WHERE Id = varAxisId;
    END IF;

    SELECT 'WIG successfully updated.' as Success;
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

    UPDATE `Predictive` SET Verb = pVerb, What = pWhat, Focus = pFocus, Quality = pQuality,
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
DROP procedure IF EXISTS `Predictive_Delete`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Predictive_Delete`(
    pPredictiveId INT
)
BEGIN
    UPDATE `Predictive` SET Status = 0
    WHERE Id = pPredictiveId;

    SELECT 'Predictive successfully deleted.' as Success;
END$$

DELIMITER ;