use ${DB_MAIN};
DROP PROCEDURE IF EXISTS User_Save;

DELIMITER $$
CREATE PROCEDURE `User_Save`(
	pFirstName nvarchar(32), 
	pLastName nvarchar(32), 
	pPicture nvarchar(256),
    pNickname nvarchar(32),
    pEmail nvarchar(32),
	pExtId nvarchar(32),
	pProvider nvarchar(16),
    pRoleId INT)
BEGIN
	DECLARE varUserId INT UNSIGNED;
    DECLARE varProfileId INT UNSIGNED;
    DECLARE varRoleId INT UNSIGNED;
    
    SET varUserId = (select UserId from User where ExtId=pExtId and Provider=pProvider);
    IF varUserId is null then
		INSERT INTO `User` (Email, Password, Provider, ExtId, CreatedAt, Status)
        VALUES (pEmail, null,pProvider, pExtId, NOW(), 10);
        SET varUserId =(SELECT LAST_INSERT_ID());

		INSERT INTO UserProfile (UserId, Currency, FirstName, LastName, Picture, ExtNickName)
        VALUES (varUserId, 'GTQ', pFirstName, pLastName, pPicture, pNickname );

        INSERT INTO UserRole(UserId, RoleId, CreatedAt, `Status`)
        VALUES (varUserId, pRoleId, NOW(), 1);
    ELSE
		SET varProfileId = (select Id from UserProfile where UserId=varUserId);
        IF varProfileId IS NULL THEN 
			INSERT INTO UserProfile (UserId, Currency, FirstName, LastName, Picture, ExtNickName )
			VALUES (UserId, 'GTQ', pFirstName, pLastName, pPicture, pNickname);
        ELSE
			UPDATE UserProfile
				set FirstName = pFirstName,
					LastName = pLastName,
                    Picture = pPicture,
                    ExtNickName = pNickname
			WHERE Id=varProfileId;
        END IF;


        SET varRoleId = (select Id from UserRole where UserId=varUserId);
        IF varRoleId IS NULL THEN 
			INSERT INTO UserRole(UserId, RoleId, CreatedAt, `Status`)
            VALUES (varUserId, pRoleId, NOW(), 1);
        ELSE
            UPDATE UserRole SET RoleId = pRoleId WHERE UserId=varUserId;
        END IF;
    END IF;
    
    select varUserId UserId;
END $$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `User_Get`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `User_Get`(
    pUserId INT,
    pEmail nvarchar(32),
    pExtId nvarchar(32),
	pProvider nvarchar(16)
    )
BEGIN
    SELECT 
    u.UserId id,
    u.Email email,
    u.ExtId extId,
    u.Provider `provider`,
    u.Status `status`,
    up.FirstName firstName,
    up.LastName lastName,
    up.ExtNickName extNickName,
    up.Picture picture
    FROM User u 
    JOIN UserProfile up ON (u.UserId = up.Id)
    WHERE (
        (pEmail IS NULL OR LOWER(u.Email) = LOWER(pEmail))
        AND
        (pUserId IS NULL OR u.UserId = pUserId)
        AND
        (pExtId IS NULL OR u.ExtId = pExtId)
        AND
        (pProvider IS NULL OR u.Provider = pProvider)
    );
END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_Save`(
    pTitle nvarchar(256),
    pParentTeamId INT,
    pCreatedBy INT,
    pLeaderId INT
    )
BEGIN
    DECLARE varDataRoleId INT UNSIGNED;
    DECLARE varTeamId INT UNSIGNED;

    INSERT INTO Team(Title, ParentTeamId, CreatedBy, CreatedAt, `Status`)
    VALUES
    (pTitle, pParentTeamId, pCreatedBy, NOW(), 1);

    SET varTeamId =(SELECT LAST_INSERT_ID());

    IF pLeaderId IS NOT NULL THEN 
        INSERT INTO UserDataRole(UserId, DataRoleId, TeamId, CreatedAt, `Status`)
        VALUES (pLeaderId, 1, varTeamId, NOW(), 1);
    END IF;

    select varTeamId TeamId;

END$$

DELIMITER ;


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

        
    END IF;

    select 'Role Assigned' message;

END$$

DELIMITER ;