USE `${DB_MAIN}`;

CREATE TABLE IF NOT EXISTS RolePermissions
(
    Id INT UNSIGNED NOT NULL,
    `Resource` NVARCHAR(32) NOT NULL,
    `Action` NVARCHAR(32) NOT NULL,
    DataRoleId INT UNSIGNED,
    RoleId INT UNSIGNED,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE RolePermissions
ADD CONSTRAINT RolesPermissions_DataRoleId_fk 
FOREIGN KEY (DataRoleId) REFERENCES `DataRole`(Id);

ALTER TABLE RolePermissions
ADD CONSTRAINT RolesPermissions_RoleId_fk 
FOREIGN KEY (RoleId) REFERENCES `Role`(Id);

DELETE FROM RolePermissions;

INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (1,'Commitment','read',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (2,'Commitment','create',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (3,'Commitment','track',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (4,'Commitment','read',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (5,'Commitment','create',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (6,'Commitment','track',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (7,'Commitment','read',NULL,'4');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (8,'Commitment','read','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (9,'Commitment','create','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (10,'Commitment','track','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (11,'Commitment','read','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (12,'Commitment','create','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (13,'Commitment','track','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (14,'Commitment','read','3',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (15,'Commitment','create','3',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (16,'Commitment','track','3',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (17,'Predictive','create',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (18,'Predictive','read',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (19,'Predictive','update',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (20,'Predictive','delete',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (21,'Predictive','track',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (22,'Predictive','create',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (23,'Predictive','read',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (24,'Predictive','update',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (25,'Predictive','delete',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (26,'Predictive','track',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (27,'Predictive','read',NULL,'4');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (28,'Predictive','create','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (29,'Predictive','read','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (30,'Predictive','update','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (31,'Predictive','delete','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (32,'Predictive','track','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (33,'Predictive','create','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (34,'Predictive','read','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (35,'Predictive','update','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (36,'Predictive','delete','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (37,'Predictive','track','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (38,'Predictive','read','3',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (39,'Predictive','track','3',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (40,'Team','create',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (41,'Team','read',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (42,'Team','update',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (43,'Team','addMember',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (44,'Team','deleteMember',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (45,'Team','create',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (46,'Team','read',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (47,'Team','update',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (48,'Team','addMember',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (49,'Team','deleteMember',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (50,'Team','read',NULL,'4');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (51,'Team','read','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (52,'Team','update','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (53,'Team','addMember','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (54,'Team','deleteMember','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (55,'Team','read','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (56,'Team','update','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (57,'Team','addMember','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (58,'Team','deleteMember','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (59,'Team','read','3',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (60,'User','create',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (61,'User','read',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (62,'User','update',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (63,'User','delete',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (64,'User','create',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (65,'User','read',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (66,'User','update',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (67,'User','delete',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (68,'User','read',NULL,'3');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (69,'User','read',NULL,'4');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (70,'WIG','create',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (71,'WIG','read',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (72,'WIG','update',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (73,'WIG','delete',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (74,'WIG','track',NULL,'1');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (75,'WIG','create',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (76,'WIG','read',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (77,'WIG','update',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (78,'WIG','delete',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (79,'WIG','track',NULL,'2');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (80,'WIG','read',NULL,'4');
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (81,'WIG','create','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (82,'WIG','read','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (83,'WIG','update','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (84,'WIG','delete','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (85,'WIG','track','1',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (86,'WIG','create','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (87,'WIG','read','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (88,'WIG','update','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (89,'WIG','delete','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (90,'WIG','track','2',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (91,'WIG','read','3',NULL);
INSERT INTO RolePermissions (Id, `Resource`, `Action`, DataRoleId, RoleId) VALUES (92,'WIG','track','3',NULL);


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Authorize`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Authorize`(
	pTeamId INT,
    pUserId INT,
    pAction nvarchar(32),
    pResource nvarchar(32)
)
BEGIN

    DROP TABLE IF EXISTS auth_tmpTeamList;
    CREATE TEMPORARY TABLE auth_tmpTeamList(UserId INT, TeamId INT, DataRoleId INT, RoleId INT);

    CALL Team_GetHierarchyByUserId(pUserId);
	
    
    INSERT INTO auth_tmpTeamList(UserId, TeamId, DataRoleId, RoleId)
    SELECT 
    UserId as userId,
    TeamId as teamId,
    IF(Min(IFNULL(DataRoleId, -1)) = -1, null, Min(IFNULL(DataRoleId, -1))) as dataRoleId,
    RoleId AS roleId
    FROM tmpTeamList
    GROUP BY UserId, TeamId, RoleId;

	SELECT 
    IF(permission1.hasPermission + permission2.hasPermission = 0, 0, 1) `hasPermission`
    FROM
    (
    SELECT 
    IF(COUNT(1) = 0, 0, 1) `hasPermission`
    FROM
    RolePermissions rp 
    JOIN UserRole ur ON (rp.RoleId = ur.RoleId  and ur.UserId = pUserId)
    WHERE
    rp.Resource = pResource and rp.Action = pAction and ( pTeamId IS NULL)
    ) AS permission1
    
    JOIN
    
    (
    SELECT 
    IF(COUNT(1) = 0, 0, 1) `hasPermission`
    FROM
    RolePermissions rp
    JOIN auth_tmpTeamList atl ON 
    (
        rp.Resource = pResource and 
        rp.Action = pAction and 
        atl.TeamId = pTeamId and
        (atl.DataRoleId = rp.DataRoleId OR atl.RoleId = rp.RoleId)
    )
    WHERE
    rp.Resource = pResource and rp.Action = pAction and ( pTeamId IS NULL OR atl.TeamId = pTeamId)
    ) AS permission2
    ON (1=1);

END$$

DELIMITER ;