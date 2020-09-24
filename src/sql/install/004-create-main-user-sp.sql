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
	pProvider nvarchar(16))
BEGIN
	DECLARE varUserId INT UNSIGNED;
    DECLARE varProfileId INT UNSIGNED;
    
    SET varUserId = (select UserId from User where ExtId=pExtId and Provider=pProvider);
    IF varUserId is null then
		INSERT INTO `User` (Email, Password, Provider, ExtId, CreatedAt, Status)
        VALUES (pEmail, null,pProvider, pExtId, NOW(), 10);
        SET varUserId =(SELECT LAST_INSERT_ID());

		INSERT INTO UserProfile (UserId, Currency, FirstName, LastName, Picture, ExtNickName)
        VALUES (varUserId, 'GTQ', pFirstName, pLastName, pPicture, pNickname );
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
        
    END IF;
    
    select varUserId UserId;
END $$