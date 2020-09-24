## Update SP so it only retrieves teams with status > 0 ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_GetAll`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_GetAll` ()
BEGIN
SELECT 
t.Id as `id`,
t.Title as `title`,
pt.Id as `parentTeamId`,
pt.Title as `parentTeamTitle` 
FROM Team t
LEFT JOIN Team pt ON t.ParentTeamId = pt.Id
WHERE t.Status > 0
ORDER BY t.Id;
END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_GetHierarchyByUserId`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_GetHierarchyByUserId` (
	pUserId INT
)
BEGIN
DECLARE varRoleId INT;
    DECLARE varDataRoleId INT;
    DECLARE varTeamId INT;
    DECLARE n INT DEFAULT 0;
	DECLARE i INT DEFAULT 0;
    
    ## Select User Role
    SELECT RoleId FROM UserRole WHERE UserId = pUserId LIMIT 1 INTO varRoleId;
    
    DROP TABLE IF EXISTS tmpTeamList;
    CREATE TEMPORARY TABLE tmpTeamList (UserId INT, TeamId INT, Title NVARCHAR(256), DataRoleId INT, RoleId INT);
	
    
    IF varRoleId <= 2 OR  varRoleId = 4 THEN 
		# If the user is an admin or a Guest, get all teams
        INSERT INTO tmpTeamList(UserId, TeamId, Title, RoleId) SELECT pUserId, Id, Title, varRoleId FROM Team WHERE `Status` > 0;
	ELSE
		# If it''s a common user
        INSERT INTO tmpTeamList(UserId, TeamId, Title, DataRoleId, RoleId) 
        SELECT pUserId, t.Id, t.Title, udr.DataRoleId, varRoleId FROM UserDataRole udr JOIN Team t ON udr.TeamId = t.Id
        WHERE udr.UserId = pUserId AND t.Status > 0 AND udr.Status > 0;
        
        SELECT COUNT(*) FROM tmpTeamList INTO n;
		SET i=0;
		WHILE i<n DO 
			# Select the current team
			SELECT DataRoleId, TeamId FROM tmpTeamList LIMIT i,1 INTO varDataRoleId, varTeamId;
            
            #If the Role in the team is leader it''s able to see the team''s children
            IF varDataRoleId = 1 OR varDataRoleId is null THEN
				INSERT INTO tmpTeamList(UserId, TeamId, Title, RoleId, DataRoleId) 
                SELECT pUserId, Id, Title, varRoleId, null FROM Team WHERE ParentTeamId = varTeamId AND `Status` > 0;
            END IF;
		  SET i = i + 1;
          ## Calculate the N of the array
          SELECT COUNT(*) FROM tmpTeamList INTO n;
		END WHILE;
    END IF;
END$$

DELIMITER ;