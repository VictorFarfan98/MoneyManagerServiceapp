USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_Internal_GetByUserId`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_Internal_GetByUserId` (
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
    CREATE TEMPORARY TABLE tmpTeamList (TeamId INT, DataRoleId INT, RoleId INT);
	
    
    IF varRoleId <= 2 OR  varRoleId = 4 THEN 
		# If the user is an admin or a Guest, get all teams
        INSERT INTO tmpTeamList(TeamId, RoleId) SELECT Id, varRoleId FROM Team;
	ELSE
		# If it''s a common user
        INSERT INTO tmpTeamList(TeamId, DataRoleId, RoleId) SELECT TeamId, DataRoleId, varRoleId FROM UserDataRole WHERE UserId = pUserId;
        
        SELECT COUNT(*) FROM tmpTeamList INTO n;
		SET i=0;
		WHILE i<n DO 
			# Select the current team
            
			SELECT DataRoleId, TeamId FROM tmpTeamList LIMIT i,1 INTO varDataRoleId, varTeamId;
            
            #If the Role in the team is leader it''s able to see the team''s children
            IF varDataRoleId = 1 THEN
				INSERT INTO tmpTeamList(TeamId, DataRoleId, RoleId) SELECT Id, varDataRoleId, varRoleId FROM Team WHERE ParentTeamId = varTeamId;
            END IF;
		  SET i = i + 1;
          ## Calculate the N of the array
          SELECT COUNT(*) FROM tmpTeamList INTO n;
		END WHILE;
    END IF;
END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_GetAllByUserId`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_GetAllByUserId` (
	pUserId INT
)
BEGIN
	CALL Team_GetHierarchyByUserId(pUserId);
	
    # Select the final list
    SELECT 
    UserId as userId,
    TeamId as teamId,
    Title as title,
    IF(Min(IFNULL(DataRoleId, -1)) = -1, null, Min(IFNULL(DataRoleId, -1))) as dataRoleId,
    RoleId AS roleId
    FROM tmpTeamList
    GROUP BY UserId, TeamId, Title, RoleId;
    
END$$

DELIMITER ;


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
    WHERE udr.UserId = pUserId;
    
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
    DECLARE varHasPermission BIT DEFAULT 0;
    DECLARE n INT DEFAULT 0;
    DECLARE varTeamId INT DEFAULT 0;
    DECLARE varDataRoleId INT DEFAULT 0;
    DECLARE varRoleId INT;


    ## Select User Role
    SELECT RoleId FROM UserRole WHERE UserId = pUserId LIMIT 1 INTO varRoleId;
	
    ## If is admin o super admin
    IF varRoleId <= 2 THEN
        SET varHasPermission = 1;
	ELSE
        ## Get all teams of the user
        CALL Team_Internal_GetByUserId(pUserId);
	
        IF pAction = 'read' THEN 
            #Read WIG of team
            IF pTeamId IS NULL THEN
                SELECT COUNT(*) FROM tmpTeamList t JOIN WIG w ON t.TeamId = w.TeamId  WHERE w.Id = pWIGId INTO n;
            ELSE
                SELECT COUNT(*) FROM tmpTeamList t WHERE TeamId  = pTeamId INTO n;
            END IF;

            IF n > 0 THEN
                SET varHasPermission = 1;
            END IF;

        ELSEIF pAction = 'update' OR pAction = 'delete' OR pAction = 'create' OR pAction = 'track' THEN 
            IF pAction = 'create' THEN
                SELECT TeamId FROM tmpTeamList WHERE teamId = pTeamId INTO varTeamId;
            ELSE
                SELECT w.TeamId FROM tmpTeamList t JOIN WIG w ON t.TeamId = w.TeamId  WHERE w.Id = pWIGId LIMIT 1 INTO varTeamId;
            END IF;

            IF varTeamId > 0 THEN
                ## Select User Data Role
                SELECT DataRoleId FROM UserDataRole WHERE UserId = pUserId AND TeamId = varTeamId LIMIT 1 INTO varDataRoleId;
                
                IF pAction = 'track' AND varDataRoleId > 0 THEN
                    # All team members
                    SET varHasPermission = 1;
                ELSEIF varDataRoleId = 1 OR varDataRoleId = 2 THEN
                    # Leader or coleader
                    SET varHasPermission = 1;
                END IF;

            END IF;
        END IF;
    END IF;
	
    # Select the final result
    SELECT (varHasPermission + 0) as hasPermission;

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
    DECLARE varHasPermission BIT DEFAULT 0;
    DECLARE varRoleId INT;
	DECLARE varWIGId INT DEFAULT 0;
    DECLARE varTeamId INT DEFAULT 0;

    ## Select User Role
    SELECT RoleId FROM UserRole WHERE UserId = pUserId LIMIT 1 INTO varRoleId;
	
    ## If is admin o super admin
    IF varRoleId <= 2 THEN
        SET varHasPermission = 1;
        SELECT (varHasPermission + 0) as hasPermission;
	ELSE
    # Select the final result
        IF pAction = 'create' THEN
                SELECT TeamId FROM WIG WHERE Id = pWIGId LIMIT 1 INTO varTeamId;
                CALL WIG_Authorize(pUserId, pAction, null, varTeamId);
            ELSE

                IF pPredictiveId IS NOT NULL THEN
				    ## Select Predictive WIG
				    SELECT WIGId FROM Predictive WHERE Id = pPredictiveId LIMIT 1 INTO varWIGId;
                    CALL WIG_Authorize(pUserId, pAction, varWIGId, null);
                ELSE
                    CALL WIG_Authorize(pUserId, pAction, pWIGId, null);
                END IF;
            END IF;
    END IF;
    
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
    DECLARE varHasPermission BIT DEFAULT 0;
    DECLARE varRoleId INT;
    DECLARE varObjectId INT DEFAULT 0;
    DECLARE varAxisTypeId INT DEFAULT 0;

    ## Select User Role
    SELECT RoleId FROM UserRole WHERE UserId = pUserId LIMIT 1 INTO varRoleId;
	
    ## If is admin o super admin
    IF varRoleId <= 2 THEN
        SET varHasPermission = 1;
        SELECT (varHasPermission + 0) as hasPermission;
	ELSE
    # Select the final result
        IF pAction = 'read' THEN
				## Select Object and type
				SELECT ObjectId, AxisTypeId FROM Axis WHERE Id = pAxisId LIMIT 1 INTO varObjectId, varAxisTypeId;
                
                IF varAxisTypeId = 10 OR varAxisTypeId = 20 THEN
					CALL WIG_Authorize(pUserId, pAction, varObjectId, null);
                ELSEIF varAxisTypeId = 30 OR varAxisTypeId = 40 THEN
					CALL Predictive_Authorize(pUserId, pAction, varObjectId, null);
                END IF;
                
            END IF;
    END IF;
    
END$$

DELIMITER ;

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
    DECLARE varHasPermission BIT DEFAULT 0;
    DECLARE n INT DEFAULT 0;
    DECLARE varDataRoleId INT DEFAULT 0;
    DECLARE varRoleId INT;


    ## Select User Role
    SELECT RoleId FROM UserRole WHERE UserId = pUserId LIMIT 1 INTO varRoleId;
	
    ## If is admin o super admin
    IF varRoleId <= 2 THEN
        SET varHasPermission = 1;
	ELSE
        ## Get all teams of the user
        CALL Team_Internal_GetByUserId(pUserId);
	
        IF pAction = 'read' THEN 
            IF pTeamId IS NULL THEN
                SET varHasPermission = 1;
            ELSE
                SELECT COUNT(*) FROM tmpTeamList t WHERE t.TeamId = pTeamId INTO n;

                IF n > 0 THEN
                    SET varHasPermission = 1;
                END IF;
            END IF;
        ELSEIF pAction = 'update' OR  pAction = 'addMember' OR  pAction = 'deleteMember' THEN 
            ## Select User Data Role
                SELECT DataRoleId FROM UserDataRole WHERE UserId = pUserId AND TeamId = pTeamId LIMIT 1 INTO varDataRoleId;
                
                IF varDataRoleId = 1 OR varDataRoleId = 2 THEN
                    # Leader or coleader
                    SET varHasPermission = 1;
                END IF;
        END IF;
    END IF;
	
    # Select the final result
    SELECT (varHasPermission + 0) as hasPermission;

END$$

DELIMITER ;



USE `${DB_MAIN}`;
DROP procedure IF EXISTS `WIG_GetByTeamIdAndYear`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_GetByTeamIdAndYear`(
    pTeamId INT,
    pYear INT
)
BEGIN
    SELECT DISTINCT
    w.Id as id,
    CONCAT(w.Verb, ' ', w.What) as `name`,
    w.Verb as verb,
    w.What as what,
    w.Description as description, 
    w.Year as year,
    a1.Id as `axisId1`,
    a1.X as `x1`,
    a1.Y as `y1`,
    a1.DisplayName as `displayName1`,
    a1.dataTypeId as dataTypeId1,
    a2.Id as `axisId2`,
    a2.X as `x2`,
    a2.Y as `y2`,
    a2.DisplayName as `displayName2`,
    a2.dataTypeId as dataTypeId2,
    IF(a2.Id IS NOT NULL, 2, 1) `axesNumber`
    FROM 
    WIG w
    INNER JOIN Team t ON (w.TeamId = t.Id) 
    INNER JOIN Axis a1 ON (w.Id = a1.ObjectId AND a1.AxisTypeId = 10)
    LEFT OUTER JOIN
    Axis a2 ON (w.Id = a2.ObjectId AND a2.AxisTypeId = 20)
    WHERE (pYear IS NULL OR w.Year = pYear) AND w.Status = 1 AND t.Id = pTeamId;
END$$

DELIMITER ;

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
WHERE (pTeamId IS NULL OR pTeamId = udr.TeamId)
ORDER BY udr.DataRoleId ASC;
END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `User_GetAll`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `User_GetAll` ()
BEGIN
SELECT DISTINCT
u.UserId as `userId`,
up.FirstName as `firstName`,
up.LastName as `lastName`,
u.Email as `email`,
up.Picture as `picture`,
ur.RoleId as `roleId`
FROM User u 
JOIN UserProfile up ON u.UserId = up.UserId
JOIN UserRole ur ON u.UserId = ur.UserId;
END$$

DELIMITER ;

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
        INSERT INTO tmpTeamList(UserId, TeamId, Title, RoleId) SELECT pUserId, Id, Title, varRoleId FROM Team;
	ELSE
		# If it''s a common user
        INSERT INTO tmpTeamList(UserId, TeamId, Title, DataRoleId, RoleId) 
        SELECT pUserId, t.Id, t.Title, udr.DataRoleId, varRoleId FROM UserDataRole udr JOIN Team t ON udr.TeamId = t.Id
        WHERE udr.UserId = pUserId;
        
        SELECT COUNT(*) FROM tmpTeamList INTO n;
		SET i=0;
		WHILE i<n DO 
			# Select the current team
			SELECT DataRoleId, TeamId FROM tmpTeamList LIMIT i,1 INTO varDataRoleId, varTeamId;
            
            #If the Role in the team is leader it''s able to see the team''s children
            IF varDataRoleId = 1 OR varDataRoleId is null THEN
				INSERT INTO tmpTeamList(UserId, TeamId, Title, RoleId, DataRoleId) 
                SELECT pUserId, Id, Title, varRoleId, null FROM Team WHERE ParentTeamId = varTeamId;
            END IF;
		  SET i = i + 1;
          ## Calculate the N of the array
          SELECT COUNT(*) FROM tmpTeamList INTO n;
		END WHILE;
    END IF;
END$$

DELIMITER ;

