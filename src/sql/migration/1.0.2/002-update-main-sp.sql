USE `${DB_MAIN}`;
DROP procedure IF EXISTS `sp_parse_json`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `sp_parse_json`(IN jsonToParse TEXT, IN target CHAR(255))
BEGIN
	# Variables
    DECLARE i INT Default 0;
    DECLARE tableName TEXT DEFAULT 'tmpParse';
	DECLARE fieldName TEXT DEFAULT 'variable';

	# Dropping table
	SET @sql := CONCAT('DROP TABLE IF EXISTS ', tableName);
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	# Creating table
	SET @sql := CONCAT('CREATE TEMPORARY TABLE ', tableName, ' (', fieldName, ' VARCHAR(1000))');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
    
    IF jsonToParse IS NOT NULL AND jsonToParse != '' AND jsonToParse != '[]' THEN
		SET @length = JSON_LENGTH(jsonToParse);
        
        simple_loop: LOOP
			IF i=@length THEN
				LEAVE simple_loop;
			END IF;
			
            # Get value from json
            SET @vars := CONCAT("('", JSON_UNQUOTE(JSON_EXTRACT(jsonToParse, concat('$[',i,']'))), "')");
            
            # Inserting values
			SET @sql := CONCAT('INSERT INTO ', tableName, ' VALUES ', @vars);
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
            
            SET i=i+1;
		END LOOP simple_loop;
	ELSE
		# Insert null value if empty
        SET @sql := CONCAT('INSERT INTO ', tableName, ' VALUES (NULL)');
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END IF;
    
	# Returning record set, or inserting into optional target
	IF target IS NULL THEN
		SET @sql := CONCAT('SELECT TRIM(`', fieldName, '`) AS `', fieldName, '` FROM ', tableName);
	ELSE
		SET @sql := CONCAT('INSERT INTO ', target, ' SELECT DISTINCT TRIM(`', fieldName, '`) FROM ', tableName);
	END IF;

	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
		
END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Commitment_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Commitment_Save`(
    pUserId INT,
    pWIGId INT,
    pTitle nvarchar(500),
    pAssignedToArray nvarchar(256),
    pDependencyUser INT
)
BEGIN
    DECLARE varUserId INT DEFAULT 0;
    DECLARE varId INT DEFAULT 0;
    DECLARE varHasDependency BIT DEFAULT 0;
    DECLARE n INT DEFAULT 0;
	DECLARE i INT DEFAULT 0;

    ## Set dependency variable
    IF pDependencyUser IS NULL THEN
        SET varHasDependency = 0;
    ELSE
        SET varHasDependency = 1;
    END IF;

	###########	Drop temporary tables if exist ###########
	
	# List of users
    DROP TABLE IF EXISTS t_tmp_users;
    
    # Filters for users
    CREATE TEMPORARY TABLE t_tmp_users (userId INT PRIMARY KEY);
    
    # Filters for users
    CALL `sp_parse_json`(pAssignedToArray, 't_tmp_users');


    SELECT COUNT(*) FROM t_tmp_users INTO n;
	SET i=0;
	WHILE i<n DO 
	    # Select the current user
		SELECT userId FROM t_tmp_users LIMIT i,1 INTO varUserId;
            
        #Insert the commitment for the user
        INSERT INTO Commitment(Title, CreatedAt, ChangedAt, Status, WIGId, CreatedBy, AssignedTo, HasDependency)
        VALUES
        (pTitle, NOW(), NOW(), 1, pWIGId, pUserId, varUserId, varHasDependency);

        SET varId =(SELECT LAST_INSERT_ID());

        IF varHasDependency THEN
            #Insert the commitment for the dependency
            INSERT INTO Commitment(Title, CreatedAt, ChangedAt, Status, WIGId, CreatedBy, AssignedTo, HasDependency, CreatedFrom, IsExternal)
            VALUES
            (pTitle, NOW(), NOW(), 1, pWIGId, pUserId, pDependencyUser, 0, varId, 1);
        END IF;

		SET i = i + 1;
	END WHILE;

    SELECT varId CommitmentId;

END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `CommitmentTracking_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `CommitmentTracking_Save`(
    pUserId INT,
    pCommitmentId INT,
    pCommentary nvarchar(512),
    pStatus INT
)
BEGIN
    #Status
    #1. Working
    #2. Reached
    #3. Closed
    DECLARE varTrackingId INT UNSIGNED;
    
    INSERT INTO `CommitmentTracking` (CommitmentId, Commentary, CreatedAt, Status, CreatedBy)
    VALUES (pCommitmentId, pCommentary, NOW(), pStatus, pUserId);
    SET varTrackingId =(SELECT LAST_INSERT_ID());

    # Change the status of the commitment only if the bit is true
    IF(pStatus != 1) THEN
        UPDATE Commitment SET `Status` = pStatus, ChangedAt = NOW() WHERE Id = pCommitmentId OR CreatedFrom = pCommitmentId;
    END IF;

    SELECT varTrackingId TrackingId;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP PROCEDURE IF EXISTS `Commitment_GetByTeamId`;

DELIMITER $$

USE `${DB_MAIN}`$$
CREATE PROCEDURE `Commitment_GetByTeamId`(
    pTeamId INT
)
BEGIN
    SELECT DISTINCT 
    c.Id as id, 
	c.WIGId as wigId, 
    c.Title as title,
    c.Status as `status`,
    c.CreatedAt as `createdAt`,
    c.ChangedAt as `changedAt`,
    u.Email as `email`,
    up.FirstName as `firstName`,
    up.LastName as `lastName`,
    (c.HasDependency + 0) as hasDependency
    FROM 
    Commitment c
    INNER JOIN WIG w ON c.WIGId = w.Id
    INNER JOIN User u ON (c.AssignedTo = u.UserId)
    JOIN UserProfile up ON u.UserId = up.UserId
    WHERE w.TeamId = pTeamId AND c.IsExternal = 0
    ORDER BY c.CreatedAt DESC;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP PROCEDURE IF EXISTS `Commitment_GetById`;

DELIMITER $$

USE `${DB_MAIN}`$$
CREATE PROCEDURE `Commitment_GetById`(
    pCommitmentId INT
)
BEGIN
    SELECT DISTINCT 
    c.Id as id, 
	c.WIGId as wigId, 
    c.Title as title,
    c.Status as `status`,
    c.CreatedAt as createdAt,
    c.ChangedAt as `changedAt`,
    u.Email as `email`,
    up.FirstName as `firstName`,
    up.LastName as `lastName`
    FROM 
    Commitment c
    INNER JOIN 
    User u ON (c.AssignedTo = u.UserId)
    JOIN UserProfile up ON u.UserId = up.UserId
    WHERE c.Id = pCommitmentId;
END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Commitment_Authorize`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Commitment_Authorize` (
	pUserId INT,
    pAction nvarchar(16),
    pCommitmentId INT,
    pTeamId INT
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
                SELECT WIGId FROM Commitment c JOIN WIG w ON c.WIGId = w.Id  WHERE w.TeamId = pTeamId LIMIT 1 INTO varWIGId;
                CALL WIG_Authorize(pUserId, 'track', varWIGId, null);
            ELSE
                IF pCommitmentId IS NOT NULL THEN
				    ## Select Commitment WIG
				    SELECT WIGId FROM Commitment WHERE Id = pCommitmentId LIMIT 1 INTO varWIGId;
                    CALL WIG_Authorize(pUserId, pAction, varWIGId, null);
                ELSE
                    CALL WIG_Authorize(pUserId, pAction, null, pTeamId);
                END IF;
            END IF;
    END IF;
    
END$$

DELIMITER ;


USE `${DB_MAIN}`;
DROP PROCEDURE IF EXISTS `Commitment_GetExternalByUser`;

DELIMITER $$

USE `${DB_MAIN}`$$
CREATE PROCEDURE `Commitment_GetExternalByUser`(
    pUserId INT
)
BEGIN
    SELECT DISTINCT 
    c.Id as id, 
    c.Title as title,
    c.Status as `status`,
    c.CreatedAt as `createdAt`,
    c.ChangedAt as `changedAt`,
    u.Email as `email`,
    up.FirstName as `firstName`,
    up.LastName as `lastName`,
    ou.Email as `creatorEmail`,
    oup.FirstName as `creatorFirstName`,
    oup.LastName as `creatorLastName`
    FROM 
    Commitment c
    INNER JOIN 
    User u ON (c.AssignedTo = u.UserId)
    JOIN UserProfile up ON u.UserId = up.UserId
    JOIN Commitment oc ON c.CreatedFrom = oc.Id
    JOIN User ou ON ou.UserId = oc.AssignedTo
    JOIN UserProfile oup ON ou.UserId = oup.UserId
    WHERE c.AssignedTo = pUserId AND c.IsExternal = 1
    ORDER BY c.CreatedAt DESC;
END$$

DELIMITER ;