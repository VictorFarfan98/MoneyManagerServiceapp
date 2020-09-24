## Create SPs to save Logs ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Log_Save`;

DELIMITER $$

CREATE PROCEDURE `Log_Save`(    
    pEventType INT,        
    pTeamId INT,
    pWIGId INT,
    pPredictiveId INT,
    pTrackingId INT,
    pTrackingWIGId INT,
    pTrackingPredictiveId INT,
    pCommitmentId INT,
    pCommitmentTrackingId INT,
    pCreatedBy INT
)
BEGIN    
    DECLARE varEventObject INT UNSIGNED;
    DECLARE varEventName NVARCHAR(255);

    ## Choose the EventObject and EventName based on the incoming Team, WIG, Predictive or Tracking  ##
    IF pTeamId IS NOT NULL THEN  
        SET varEventObject = 1;
        SET varEventName = (SELECT Title FROM Team WHERE Id=pTeamId);
    ELSEIF pWIGId IS NOT NULL THEN
        SET varEventObject = 2;
        SET varEventName = (SELECT concat(`Verb`, ' ', `What`) wig FROM WIG WHERE Id=pWIGId);
    ELSEIF pPredictiveId IS NOT NULL THEN   
        SET varEventObject = 3;
        SET varEventName = (SELECT concat(`Verb`, ' ' , `What`) predictive FROM Predictive WHERE Id=pPredictiveId);
    ELSEIF pTrackingId IS NOT NULL THEN
        SET varEventObject = 4;
        SET varEventName = (SELECT DisplayName FROM Axis WHERE Id = (SELECT AxisId FROM Tracking WHERE Id = pTrackingId));
    ELSEIF pTrackingWIGId IS NOT NULL THEN
        SET varEventObject = 5;
        SET varEventName = (SELECT DisplayName FROM Axis WHERE Id = (SELECT AxisId FROM Tracking WHERE Id = pTrackingWIGId));
    ELSEIF pTrackingPredictiveId IS NOT NULL THEN
        SET varEventObject = 6;
        SET varEventName = (SELECT DisplayName FROM Axis WHERE Id = (SELECT AxisId FROM Tracking WHERE Id = pTrackingPredictiveId));
    ELSEIF pCommitmentId IS NOT NULL THEN
        SET varEventObject = 7;
        SET varEventName = (SELECT Title FROM Commitment WHERE Id = pCommitmentId);
    ELSEIF pCommitmentTrackingId IS NOT NULL THEN
        SET varEventObject = 8;
        SET varEventName = (SELECT Title FROM Commitment WHERE Id = (SELECT CommitmentId FROM CommitmentTracking WHERE Id = pCommitmentTrackingId));
    END IF;

    INSERT INTO Log (EventType, EventObject, EventName, TeamId, WIGId, PredictiveId, TrackingId, CommitmentId, CommitmentTrackingId, CreatedBy, CreatedAt)
    VALUES (pEventType, varEventObject, varEventName, pTeamId, pWIGId, pPredictiveId, pTrackingId, pCommitmentId, pCommitmentTrackingId, pCreatedBy, NOW());
    
END$$

DELIMITER ;