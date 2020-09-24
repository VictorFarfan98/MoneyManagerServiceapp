## Add User delete from Team functionality ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `User_DeleteFromTeam`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `User_DeleteFromTeam`(
    pTeamId INT,
    pUserId INT
    )
BEGIN    
    UPDATE UserDataRole
        SET `Status`=0
        WHERE UserId=pUserId AND TeamId=pTeamId;

    SELECT 'User removed from team correctly.' as Success;

END$$

DELIMITER ;