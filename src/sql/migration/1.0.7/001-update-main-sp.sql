USE `${DB_MAIN}`;
DROP procedure IF EXISTS `WIG_GetGoalsById`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `WIG_GetGoalsById`(
    pWIGId INT
    )
BEGIN
    SELECT
        g1.Period as `period1`,
        g1.AxisId as `axisId1`,
        g1.Y as `goal1`,
        a1.X as `x1`,
        a1.Y as `y1`,
        a1.DisplayName as `displayName1`,
        (a1.Dir + 0) as dir1,
        a1.DataTypeId as `dataTypeId1`,
        a1.AxisTypeId as `axisTypeId1`,
        g2.Period as `period2`,
        g2.AxisId as `axisId2`,
        g2.Y as `goal2`,
        a2.X as `x2`,
        a2.Y as `y2`,
        a2.DisplayName as `displayName2`,
        (a2.Dir + 0) as dir2,
        a2.DataTypeId as `dataTypeId2`,
        a2.AxisTypeId as `axisTypeId2`
    FROM 
    WIG w
    INNER JOIN
    Axis a1 ON (w.Id = a1.ObjectId AND a1.AxisTypeId = 10)
    INNER JOIN
    PeriodGoal g1 ON g1.AxisId = a1.Id
    LEFT OUTER JOIN
    Axis a2 ON (w.Id = a2.ObjectId AND a2.AxisTypeId = 20)
    LEFT OUTER JOIN
    PeriodGoal g2 ON g2.AxisId = a2.Id
    WHERE w.Id = pWIGId;

END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Axis_GetGoalsById`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Axis_GetGoalsById`(
    pAxisId INT
    )
BEGIN
    SELECT 
        pg.Period as `period`,
        pg.AxisId as `axisId`,
        pg.Y as `goal`,
        a.X as `x`,
        a.Y as `y`,
        a.DisplayName as `displayName`,
        (a.Dir + 0) as dir,
        a.DataTypeId as `dataTypeId`,
        a.AxisTypeId as `axisTypeId`
    FROM PeriodGoal pg
    JOIN Axis a ON pg.AxisId = a.Id
    WHERE pg.AxisId = pAxisId;

END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Axis_SavePeriodGoals`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Axis_SavePeriodGoals`(
    pAxisId INT,
    pGoals nvarchar(1024)
)
BEGIN

	###########	Drop temporary tables if exist ###########
	
	# List of users
    DROP TABLE IF EXISTS t_tmp_goals;
    
    # Filters for users
    CREATE TEMPORARY TABLE t_tmp_goals (Y DECIMAL(16,3));
    
    # Filters for users
    CALL `sp_parse_json`(pGoals, 't_tmp_goals');

    # Revove Data
    DELETE FROM PeriodGoal Where AxisId = pAxisId;

    # Insert data
    SET @row_number = 0;

    INSERT INTO PeriodGoal (Period, AxisId, Y, Status)
    SELECT 
    (@row_number:=@row_number + 1), 
    pAxisId,
    Y,
    1
    FROM
    t_tmp_goals;

END$$

DELIMITER ;


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
		SET @sql := CONCAT('INSERT INTO ', target, ' SELECT TRIM(`', fieldName, '`) FROM ', tableName);
	END IF;

	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
		
END$$

DELIMITER ;