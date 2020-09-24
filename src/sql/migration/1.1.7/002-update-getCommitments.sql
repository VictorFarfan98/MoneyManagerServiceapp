## Update SP to retrieve only commitments with status > 0 ##
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
    c.forwhen as `when`,
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
    c.forwhen as `when`,
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
    WHERE w.TeamId = pTeamId AND c.IsExternal = 0 AND c.Status > 0
    ORDER BY c.CreatedAt DESC;
END$$

DELIMITER ;