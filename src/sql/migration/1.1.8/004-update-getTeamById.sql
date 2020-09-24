## Update SP to retrieve team if status is > 0 ##
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
    t.ParentTeamId as `parentTeamId`,
    tp.SpecialistId as `specialistId`,
    tp.AccountabilityDay as `day`,
    tp.AccountabilityTime as `time`
    FROM Team t LEFT OUTER JOIN Team pt
    ON t.ParentTeamId = pt.Id
    JOIN TeamProfile tp ON t.Id = tp.TeamId
    WHERE t.Id = pTeamId AND t.Status > 0;
    
END$$

DELIMITER ;