use ${DB_MAIN};

CREATE TABLE IF NOT EXISTS TeamProfile
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    TeamId INT UNSIGNED NOT NULL,
    SpecialistId  INT UNSIGNED,
    AccountabilityDay INT NOT NULL,
    AccountabilityTime TIME NOT NULL,
    `Status` SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;


ALTER TABLE TeamProfile
ADD CONSTRAINT TeamProfile_TeamId_fk 
FOREIGN KEY (TeamId) REFERENCES Team(Id);

ALTER TABLE TeamProfile
ADD CONSTRAINT TeamProfile_SpecialistId_fk 
FOREIGN KEY (SpecialistId) REFERENCES User(UserId);

INSERT INTO TeamProfile(TeamId, AccountabilityDay, AccountabilityTime, Status)
SELECT Id, 1, '8:00:00', 1
FROM Team;


USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_Save`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_Save`(
    pTitle nvarchar(256),
    pParentTeamId INT,
    pCreatedBy INT,
    pLeaderId INT,
    pSpecialistId INT
    )
BEGIN
    DECLARE varDataRoleId INT UNSIGNED;
    DECLARE varTeamId INT UNSIGNED;

    INSERT INTO Team(Title, ParentTeamId, CreatedBy, CreatedAt, `Status`)
    VALUES
    (pTitle, pParentTeamId, pCreatedBy, NOW(), 1);

    SET varTeamId =(SELECT LAST_INSERT_ID());

    INSERT INTO TeamProfile(TeamId, SpecialistId, AccountabilityDay, AccountabilityTime, `Status`)
    VALUES
    (varTeamId, pSpecialistId, 1, '8:00:00', 1);

    IF pLeaderId IS NOT NULL THEN 
        INSERT INTO UserDataRole(UserId, DataRoleId, TeamId, CreatedAt, `Status`)
        VALUES (pLeaderId, 1, varTeamId, NOW(), 1);
    END IF;

    select varTeamId TeamId;

END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_Update`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_Update`(
    pTeamId INT,
    pTitle nvarchar(256),
    pParentTeamId INT,
    pSpecialistId INT
    )
BEGIN
    UPDATE Team SET Title = pTitle, ParentTeamId = pParentTeamId WHERE Id = pTeamId;

    UPDATE TeamProfile SET SpecialistId = pSpecialistId WHERE TeamId = pTeamId;

    select pTeamId TeamId;

END$$

DELIMITER ;

USE `${DB_MAIN}`;
DROP procedure IF EXISTS `Team_UpdateAccountability`;

DELIMITER $$
USE `${DB_MAIN}`$$
CREATE PROCEDURE `Team_UpdateAccountability`(
    pTeamId INT,
    pTime TIME,
    pDay INT
    )
BEGIN
    UPDATE TeamProfile SET AccountabilityTime = pTime, AccountabilityDay = pDay  WHERE TeamId = pTeamId;

    select pTeamId TeamId;

END$$

DELIMITER ;

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
    WHERE t.Id = pTeamId;
    
END$$

DELIMITER ;