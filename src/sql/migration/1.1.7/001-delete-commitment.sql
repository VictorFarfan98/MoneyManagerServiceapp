## Add SP to delete Commitments ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Commitment_Delete`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Commitment_Delete`(    
    pCommitmentId INT    
)
BEGIN
    DECLARE varUserId INT;

    #Status
    #0. Deleted
    #1. Working
    #2. Reached
    #3. Closed
    
    UPDATE Commitment 
        SET `Status`=0,
        ChangedAt=NOW()
        WHERE Id=pCommitmentId;    

    SET varUserId = (SELECT CreatedBy FROM Commitment WHERE Id=pCommitmentId);    
        
    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (3, null, null, null, null, null, null, pCommitmentId, null, varUserId);

    SELECT 'Commitment deleted correctly.' as Success;
END$$

DELIMITER ;