USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_Authorize`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_Authorize` (
	pUserId INT,
    pAction nvarchar(16),
    pTeamId INT
)
BEGIN
    
    ## Call authorize sp
    CALL Authorize(pTeamId, pUserId, pAction, 'Team');

END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `WIG_Authorize`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_Authorize` (
	pUserId INT,
    pAction nvarchar(16),
    pWIGId INT,
    pTeamId INT
)
BEGIN
    DECLARE varTeamId INT;

     IF pTeamId IS NOT NULL THEN
        SET varTeamId = pTeamId;
	ELSE
        ## Select Team
        SELECT TeamId FROM WIG WHERE Id = pWIGId LIMIT 1 INTO varTeamId;
    END IF;

    ## Call authorize sp
    CALL Authorize(varTeamId, pUserId, pAction, 'WIG');
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Predictive_Authorize`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Predictive_Authorize` (
	pUserId INT,
    pAction nvarchar(16),
    pPredictiveId INT,
    pWIGId INT
)
BEGIN
    DECLARE varTeamId INT;
    DECLARE varWIGId INT;

     IF pPredictiveId IS NOT NULL THEN
        ## Select WIG
        SELECT WIGId FROM Predictive WHERE Id = pPredictiveId LIMIT 1 INTO varWIGId;
	ELSE
        SET varWIGId = pWIGId;
    END IF;

    ## Select Team
    SELECT TeamId FROM WIG WHERE Id = varWIGId LIMIT 1 INTO varTeamId;

    ## Call authorize sp
    CALL Authorize(varTeamId, pUserId, pAction, 'Predictive');
    
END$$

DELIMITER ;





USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Axis_Authorize`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Axis_Authorize` (
	pUserId INT,
    pAction nvarchar(16),
    pAxisId INT
)
BEGIN
    DECLARE varObjectId INT DEFAULT 0;
    DECLARE varAxisTypeId INT DEFAULT 0;


    ## Select Object and type
    SELECT ObjectId, AxisTypeId FROM Axis WHERE Id = pAxisId LIMIT 1 INTO varObjectId, varAxisTypeId;
    
    # If the object is a wig
    IF varAxisTypeId = 10 OR varAxisTypeId = 20 THEN
	    CALL WIG_Authorize(pUserId, pAction, varObjectId, null);
    ELSEIF varAxisTypeId = 30 OR varAxisTypeId = 40 THEN
	    CALL Predictive_Authorize(pUserId, pAction, varObjectId, null);
    END IF;
END$$

DELIMITER ;