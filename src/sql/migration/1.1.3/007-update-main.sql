## Update Tracking SPs to save logs ##
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

    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (1, null, null, null, varTrackingId, null, null, null, null, pUserId);

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

    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (1, null, null, null, null, varTrackingId1, null, null, null, pUserId);

    SELECT varTrackingId1 AS TrackingId1, varTrackingId2 AS TrackingId2 ;
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

    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (1, null, null, null, null, null, varTrackingId1, null, null, pUserId);

    SELECT varTrackingId1 AS TrackingId1, varTrackingId2 AS TrackingId2 ;
END$$

DELIMITER ;