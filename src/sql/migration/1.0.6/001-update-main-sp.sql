USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_Update`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_Update`(
    pTeamId INT,
    pTitle nvarchar(256),
    pParentTeamId INT
    )
BEGIN
    UPDATE Team SET Title = pTitle, ParentTeamId = pParentTeamId WHERE Id = pTeamId;

    select pTeamId TeamId;

END$$

DELIMITER ;


USE ${DB_MAIN};
DROP PROCEDURE IF EXISTS User_Update;

DELIMITER $$
CREATE PROCEDURE `User_Update`(
    pUserId INT,
	pFirstName nvarchar(32), 
	pLastName nvarchar(32),
    pRoleId INT)
BEGIN
    DECLARE varRoleId INT UNSIGNED;

    UPDATE UserProfile
	    set FirstName = pFirstName,
		    LastName = pLastName
	WHERE UserId=pUserId;

    SET varRoleId = (select Id from UserRole where UserId=pUserId);
    IF varRoleId IS NULL THEN 
	    INSERT INTO UserRole(UserId, RoleId, CreatedAt, `Status`)
        VALUES (pUserId, pRoleId, NOW(), 1);
    ELSE
        UPDATE UserRole SET RoleId = pRoleId WHERE UserId=pUserId;
    END IF;
    
    select pUserId UserId;
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
    u.UserId userId,
    u.Email email,
    u.ExtId extId,
    u.Provider `provider`,
    u.Status `status`,
    up.FirstName firstName,
    up.LastName lastName,
    up.ExtNickName extNickName,
    up.Picture picture,
    ur.RoleId roleId
    FROM User u 
    JOIN UserProfile up ON (u.UserId = up.UserId)
    JOIN UserRole ur ON (ur.UserId = u.UserId)
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
DROP procedure IF EXISTS `Team_GetById`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_GetById` (
	pTeamId INT
)
BEGIN
    SELECT DISTINCT 
    t.Id as `teamId`,
    t.Title as `title`,
    t.ParentTeamId as `parentTeamId`
    FROM Team t LEFT OUTER JOIN Team pt
    ON t.ParentTeamId = pt.Id
    WHERE t.Id = pTeamId;
    
END$$

DELIMITER ;