## Create SP for retrieving logs ##
USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Log_GetLogs`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Log_GetLogs`(
    
)
BEGIN
    SELECT 
        l.Id as id,     
        et.Name as eventType,
        eo.Name as eventObject,
        l.EventName as eventName,
        l.CreatedAt as createdAt,    
        u.Email as `email`,
        up.FirstName as `firstName`,
        up.LastName as `lastName`
    FROM Log l
    INNER JOIN 
        User u ON (l.CreatedBy= u.UserId)
        JOIN UserProfile up ON u.UserId = up.UserId
        JOIN EventType et ON l.EventType = et.Id
        JOIN EventObject eo ON l.EventObject = eo.Id
	ORDER BY l.createdAt DESC;
END$$

DELIMITER ;