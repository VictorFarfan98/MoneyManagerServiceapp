## Update Team Actions SPs to save logs ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_Save`(
    pTitle nvarchar(256),
    pParentTeamId INT,
    pCreatedBy INT,
    pLeaderId INT,
    pSpecialistId INT
    )
BEGIN
    DECLARE varDataRoleId INT UNSIGNED;
    DECLARE varTeamId INT UNSIGNED;

    INSERT INTO Team(Title, ParentTeamId, CreatedBy, CreatedAt, `Status`)
    VALUES
    (pTitle, pParentTeamId, pCreatedBy, NOW(), 1);

    SET varTeamId =(SELECT LAST_INSERT_ID());

    INSERT INTO TeamProfile(TeamId, SpecialistId, AccountabilityDay, AccountabilityTime, `Status`)
    VALUES
    (varTeamId, pSpecialistId, 1, '8:00:00', 1);

    IF pLeaderId IS NOT NULL THEN 
        INSERT INTO UserDataRole(UserId, DataRoleId, TeamId, CreatedAt, `Status`)
        VALUES (pLeaderId, 1, varTeamId, NOW(), 1);
    END IF;

    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (1, varTeamId, null, null, null, null, null, null, null, pCreatedBy);

    select varTeamId TeamId;

END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_Update`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_Update`(
    pTeamId INT,
    pTitle nvarchar(256),
    pParentTeamId INT,
    pSpecialistId INT
    )
BEGIN
	DECLARE varCreatedBy INT;
    
    UPDATE Team SET Title = pTitle, ParentTeamId = pParentTeamId WHERE Id = pTeamId;

    UPDATE TeamProfile SET SpecialistId = pSpecialistId WHERE TeamId = pTeamId;

    SET varCreatedBy = (SELECT CreatedBy FROM Team WHERE Id=pTeamId);
    ## EventType - TeamId - WIGId - PredictiveId - TrackingId -Tracking WIG - Tracking Predictive - CommitmentId - CommitmentTrackingId - CreatedBy ##
    CALL Log_Save (2, pTeamId, null, null, null, null, null, null, null, varCreatedBy);

    select pTeamId TeamId;

END$$

DELIMITER ;