## Update SP to add a User if it was already removed once ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_AddUser`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_AddUser`(
    pTeamId INT,
    pUserId INT,
    pDataRoleId INT
    )
BEGIN
    DECLARE varDataRoleId INT UNSIGNED;
    DECLARE varTeamId INT UNSIGNED;

    SET varDataRoleId = (select Id from UserDataRole where TeamId=pTeamId and DataRoleId=pDataRoleId and UserId=pUserId);
    IF varDataRoleId is null then

        SET varDataRoleId = (select Id from UserDataRole where TeamId=pTeamId and UserId=pUserId);

        #User is not a member of the team
        IF varDataRoleId is null then
            INSERT INTO UserDataRole(UserId, DataRoleId, TeamId, CreatedAt, `Status`)
            VALUES (pUserId, pDataRoleId, pTeamId, NOW(), 1);

            SET varDataRoleId =(SELECT LAST_INSERT_ID());
        ELSE
            #Change the role in the team to the selected one
            UPDATE UserDataRole SET DataRoleId = pDataRoleId WHERE (TeamId = pTeamId AND UserId = pUserId);
        END IF;
    ELSE

        UPDATE UserDataRole
            SET `Status` = 1
            WHERE Id=varDataRoleId;
        
    END IF;

    select 'Role Assigned' message;

END$$

DELIMITER ;