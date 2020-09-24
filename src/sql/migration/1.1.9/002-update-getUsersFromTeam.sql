## Update get users from team functionality ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `User_GetByTeamId`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `User_GetByTeamId`(
    pTeamId INT    
    )
BEGIN
	SELECT DISTINCT
        u.UserId as `userId`,
        up.FirstName as `firstName`,
        up.LastName as `lastName`,
        u.Email as `email`,
        up.Picture as `picture`,
        ur.RoleId as `roleId`,
        udr.DataRoleId as `dataRoleId`,
        udr.TeamId as `teamId`
        FROM User u 
        JOIN UserProfile up ON u.UserId = up.UserId
        JOIN UserRole ur ON u.UserId = ur.UserId
        LEFT JOIN UserDataRole udr ON u.UserId = udr.UserId
        WHERE (pTeamId IS NULL OR pTeamId = udr.TeamId) AND udr.Status > 0
        ORDER BY udr.DataRoleId ASC;

END$$

DELIMITER ;


