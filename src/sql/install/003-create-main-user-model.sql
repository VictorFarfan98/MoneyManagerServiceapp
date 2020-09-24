
use ${DB_MAIN};
CREATE TABLE IF NOT EXISTS User
(
    UserId INT UNSIGNED AUTO_INCREMENT NOT NULL,
    Email nvarchar(128),
    Password nvarchar(64),
    ExtId nvarchar(64) NOT NULL,
    Provider nvarchar(16) NOT NULL,
    CreatedAt DATETIME,
    Status SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY(UserId)
) 
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE User ADD UNIQUE User_unique_ext_id (ExtId, Provider);

CREATE TABLE IF NOT EXISTS UserProfile
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    UserId INT UNSIGNED NOT NULL,
    Currency NVARCHAR(16) NOT NULL,
    FirstName NVARCHAR(64) NOT NULL,
    LastName NVARCHAR(64) NOT NULL,
    Picture NVARCHAR(256) NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE UserProfile ADD COLUMN ExtNickName NVARCHAR(32) COMMENT "Nick name from provider";

ALTER TABLE UserProfile
ADD CONSTRAINT User_Profile_UserId_fk 
FOREIGN KEY (UserId) REFERENCES User(UserId);

ALTER TABLE UserProfile
ADD INDEX User_Profile_UserId_idx (UserId);

