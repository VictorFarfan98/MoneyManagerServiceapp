## Update SP to not retrieve teams if UserDataRole Status is 0 ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_GetByUserId`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_GetByUserId` (
	pUserId INT
)
BEGIN
    SELECT DISTINCT 
    t.Title as `title`,
    udr.UserId as `userId`,
    udr.DataRoleId as `dataRoleId`,
    udr.TeamId as `teamId`
    FROM UserDataRole udr JOIN
    Team t ON udr.TeamId = t.Id
    WHERE udr.UserId = pUserId AND udr.Status > 0;
    
END$$

DELIMITER ;