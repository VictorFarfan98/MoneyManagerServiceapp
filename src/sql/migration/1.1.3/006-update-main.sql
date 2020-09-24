## Update Commitment SPs to save logs ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Commitment_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Commitment_Save`(
    pUserId INT,
    pWIGId INT,
    pTitle nvarchar(500),
    pAssignedToArray nvarchar(256),
    pDependencyUser INT
)
BEGIN
    DECLARE varUserId INT DEFAULT 0;
    DECLARE varId INT DEFAULT 0;
    DECLARE varHasDependency BIT DEFAULT 0;
    DECLARE n INT DEFAULT 0;
	DECLARE i INT DEFAULT 0;

    ## Set dependency variable
    IF pDependencyUser IS NULL THEN
        SET varHasDependency = 0;
    ELSE
        SET varHasDependency = 1;
    END IF;

	###########	Drop temporary tables if exist ###########
	
	# List of users
    DROP TABLE IF EXISTS t_tmp_users;
    
    # Filters for users
    CREATE TEMPORARY TABLE t_tmp_users (userId INT PRIMARY KEY);
    
    # Filters for users
    CALL `sp_parse_json`(pAssignedToArray, 't_tmp_users');


    SELECT COUNT(*) FROM t_tmp_users INTO n;
	SET i=0;
	WHILE i<n DO 
	    # Select the current user
		SELECT userId FROM t_tmp_users LIMIT i,1 INTO varUserId;
            
        #Insert the commitment for the user
        INSERT INTO Commitment(Title, CreatedAt, ChangedAt, Status, WIGId, CreatedBy, AssignedTo, HasDependency)
        VALUES
        (pTitle, NOW(), NOW(), 1, pWIGId, pUserId, varUserId, varHasDependency);

        SET varId =(SELECT LAST_INSERT_ID());

        IF varHasDependency THEN
            #Insert the commitment for the dependency
            INSERT INTO Commitment(Title, CreatedAt, ChangedAt, Status, WIGId, CreatedBy, AssignedTo, HasDependency, CreatedFrom, IsExternal)
            VALUES
            (pTitle, NOW(), NOW(), 1, pWIGId, pUserId, pDependencyUser, 0, varId, 1);
        END IF;

		SET i = i + 1;
	END WHILE;

    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (1, null, null, null, null, null, null, varId, null, pUserId);

    SELECT varId CommitmentId;

END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `CommitmentTracking_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `CommitmentTracking_Save`(
    pUserId INT,
    pCommitmentId INT,
    pCommentary nvarchar(512),
    pStatus INT
)
BEGIN
    #Status
    #1. Working
    #2. Reached
    #3. Closed
    DECLARE varTrackingId INT UNSIGNED;
    
    INSERT INTO `CommitmentTracking` (CommitmentId, Commentary, CreatedAt, Status, CreatedBy)
    VALUES (pCommitmentId, pCommentary, NOW(), pStatus, pUserId);
    SET varTrackingId =(SELECT LAST_INSERT_ID());

    # Change the status of the commitment only if the bit is true
    IF(pStatus != 1) THEN
        UPDATE Commitment SET `Status` = pStatus, ChangedAt = NOW() WHERE Id = pCommitmentId OR CreatedFrom = pCommitmentId;
    END IF;

    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (1, null, null, null, null, null, null, null, varTrackingId, pUserId);

    SELECT varTrackingId TrackingId;
END$$

DELIMITER ;