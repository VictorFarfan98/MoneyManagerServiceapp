USE `${DB_MAIN}`;
DROP TABLE IF EXISTS `Role`;

CREATE TABLE IF NOT EXISTS `Role`
(
    Id INT UNSIGNED NOT NULL,
    Title NVARCHAR(32) NOT NULL,
    `Description` NVARCHAR(128) NOT NULL,
    CreatedAt DATETIME NOT NULL,
    `Status` SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS UserRole;

CREATE TABLE IF NOT EXISTS UserRole
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    UserId INT UNSIGNED NOT NULL,
    RoleId INT UNSIGNED NOT NULL,
    CreatedAt DATETIME NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE UserRole
ADD CONSTRAINT UserRole_UserId_fk 
FOREIGN KEY (UserId) REFERENCES User(UserId);

ALTER TABLE UserRole
ADD CONSTRAINT UserRole_RoleId_fk 
FOREIGN KEY (RoleId) REFERENCES `Role`(Id);

DROP TABLE IF EXISTS DataRole;

CREATE TABLE IF NOT EXISTS DataRole
(
    Id INT UNSIGNED NOT NULL,
    Title NVARCHAR(32) NOT NULL,
    `Description` NVARCHAR(128) NOT NULL,
    CreatedAt DATETIME NOT NULL,
    `Status` SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS UserDataRole;

CREATE TABLE IF NOT EXISTS UserDataRole
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    UserId INT UNSIGNED NOT NULL,
    DataRoleId INT UNSIGNED NOT NULL,
    TeamId INT UNSIGNED NOT NULL,
    CreatedAt DATETIME NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE UserDataRole
ADD CONSTRAINT UserDataRole_UserId_fk 
FOREIGN KEY (UserId) REFERENCES User(UserId);

ALTER TABLE UserDataRole
ADD CONSTRAINT UserDataRole_DataRoleId_fk 
FOREIGN KEY (DataRoleId) REFERENCES DataRole(Id);

ALTER TABLE UserDataRole
ADD CONSTRAINT UserDataRole_TeamId_fk 
FOREIGN KEY (TeamId) REFERENCES Team(Id);


INSERT INTO `Role` (Id, Title, `Description`, CreatedAt, Status) 
VALUES 
(1, 'SuperAdmin', 'Super administrator, having access to all the features of the application', NOW(), 1),
(2, 'Admin', 'Administrator', NOW(), 1),
(3, 'User', 'Application user, having access to the standard features', NOW(), 1),
(4, 'Guest', 'Guest User', NOW(), 1);


INSERT INTO DataRole (Id, Title, `Description`, CreatedAt, Status) 
VALUES 
(1, 'Leader', 'Leader of a Team', NOW(), 1),
(2, 'Co-Leader', 'Co-Leader of a Team', NOW(), 1),
(3, 'Partaker', 'Member of a Team', NOW(), 1);
