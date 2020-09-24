## Update SP to retrieve Team if Status > 0 ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_GetBySpecialist`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_GetBySpecialist` (
	pSpecialistId INT
)
BEGIN
    SELECT DISTINCT 
    t.Id as `teamId`,
    t.Title as `title`,
    t.ParentTeamId as `parentTeamId`,
    tp.SpecialistId as `specialistId`,
    tp.AccountabilityDay as `day`,
    tp.AccountabilityTime as `time`
    FROM Team t 
    JOIN TeamProfile tp ON t.Id = tp.TeamId
    LEFT OUTER JOIN Team pt ON t.ParentTeamId = pt.Id
    WHERE (tp.SpecialistId = pSpecialistId OR pSpecialistId IS NULL) AND t.Status > 0;
    
END$$

DELIMITER ;