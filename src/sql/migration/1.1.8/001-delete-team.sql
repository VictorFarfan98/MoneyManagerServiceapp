## Add Team delete functionality ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_Delete`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_Delete`(
    pTeamId INT    
    )
BEGIN
	DECLARE varCreatedBy INT;
    
    UPDATE Team SET `Status` = 0 WHERE Id = pTeamId;

    UPDATE TeamProfile SET `Status` = 0 WHERE TeamId = pTeamId;

    SET varCreatedBy = (SELECT CreatedBy FROM Team WHERE Id=pTeamId);
    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (3, pTeamId, null, null, null, null, null, null, null, varCreatedBy);

    SELECT 'Team deleted correctly.' as Success;

END$$

DELIMITER ;