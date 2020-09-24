## Allow user Email to be updated ##
USE ${DB_MAIN};
DROP PROCEDURE IF EXISTS User_Update;

DELIMITER $$
CREATE PROCEDURE `User_Update`(
    pUserId INT,
    pEmail nvarchar(32),
	pFirstName nvarchar(32), 
	pLastName nvarchar(32),
    pRoleId INT)
BEGIN
    DECLARE varRoleId INT UNSIGNED;

    UPDATE UserProfile
	    set FirstName = pFirstName,
		    LastName = pLastName        
	WHERE UserId=pUserId;

    UPDATE User
        set Email = pEmail
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