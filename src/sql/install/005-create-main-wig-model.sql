
use ${DB_MAIN};

DROP TABLE IF EXISTS DataType;

CREATE TABLE IF NOT EXISTS DataType
(
    Id INT UNSIGNED NOT NULL,
    Title NVARCHAR(32) NOT NULL,
    UsesSign BIT NOT NULL,
    Symbol NVARCHAR(16),
    MaxDecPlaces SMALLINT UNSIGNED NOT NULL,
    CreatedAt DATETIME NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS AxisType;

CREATE TABLE IF NOT EXISTS AxisType
(
    Id INT UNSIGNED NOT NULL,
    Title NVARCHAR(32) NOT NULL,
    MeasurementRate NVARCHAR(16),
    CreatedAt DATETIME NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS Team
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    Title NVARCHAR(256) NOT NULL,
    ParentTeamId INT UNSIGNED,
    CreatedBy INT UNSIGNED NOT NULL,
    CreatedAt DATETIME NOT NULL,
    `Status` SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;


ALTER TABLE Team
ADD CONSTRAINT Team_ParentTeamId_fk 
FOREIGN KEY (ParentTeamId) REFERENCES Team(Id);

ALTER TABLE Team
ADD CONSTRAINT Team_CreatedBy_fk 
FOREIGN KEY (CreatedBy) REFERENCES User(UserId);

DROP TABLE IF EXISTS WIG;

CREATE TABLE IF NOT EXISTS WIG
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    `Verb` NVARCHAR(256) NOT NULL,
    `What` NVARCHAR(256) NOT NULL,
    Year INT UNSIGNED NOT NULL,
    Description NVARCHAR(256),
    CreatedAt DATETIME NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    CreatedBy INT UNSIGNED NOT NULL,
    TeamId INT UNSIGNED NOT NULL,
    PRIMARY KEY(Id)
) 
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE WIG
ADD CONSTRAINT WIG_CreatedBy_fk 
FOREIGN KEY (CreatedBy) REFERENCES User(UserId);

ALTER TABLE WIG
ADD CONSTRAINT WIG_TeamId_fk 
FOREIGN KEY (TeamId) REFERENCES `Team`(Id);

DROP TABLE IF EXISTS Axis;

CREATE TABLE IF NOT EXISTS Axis
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    `X` DECIMAL(16,3) NOT NULL,
    `Y` DECIMAL(16,3) NOT NULL,
    DisplayName NVARCHAR(256) NULL,
    Dir BIT NOT NULL,
    `Default` BIT NOT NULL,
    CreatedAt DATETIME NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    ObjectId INT UNSIGNED,
    DataTypeId INT UNSIGNED NOT NULL,
    AxisTypeId INT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE Axis
ADD CONSTRAINT Axis_DataTypeId_fk 
FOREIGN KEY (DataTypeId) REFERENCES DataType(Id);

ALTER TABLE Axis
ADD CONSTRAINT Axis_AxisTypeId_fk 
FOREIGN KEY (AxisTypeId) REFERENCES AxisType(Id);

ALTER TABLE Axis
ADD INDEX Axis_ObjectId_idx (ObjectId);

DROP TABLE IF EXISTS Predictive;

CREATE TABLE IF NOT EXISTS Predictive
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    Verb NVARCHAR(256) NOT NULL,
    `What` NVARCHAR(256) NOT NULL,
    Focus NVARCHAR(256) NOT NULL,
    Quality NVARCHAR(256) NULL,
    `Description` NVARCHAR(256) NULL,
    CreatedAt DATETIME NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    WIGId INT UNSIGNED NOT NULL,
    CreatedBy INT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE Predictive
ADD CONSTRAINT Predictive_CreatedBy_fk 
FOREIGN KEY (CreatedBy) REFERENCES User(UserId);

ALTER TABLE Predictive
ADD CONSTRAINT Predictive_WIGId_fk 
FOREIGN KEY (WIGId) REFERENCES WIG(Id);

ALTER TABLE Predictive
ADD INDEX Predictive_WIGId_idx (WIGId);


DROP TABLE IF EXISTS Tracking;

CREATE TABLE IF NOT EXISTS Tracking
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    GoalAchived DECIMAL(16,3) NOT NULL,
    Y DECIMAL(16,3) NOT NULL,
    `Period` INT NOT NULL,
    Commentary NVARCHAR(256),
    CreatedAt DATETIME NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    CreatedBy INT UNSIGNED NOT NULL,
    AxisId INT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE Tracking
ADD CONSTRAINT Tracking_AxisId_fk 
FOREIGN KEY (AxisId) REFERENCES Axis(Id);

ALTER TABLE Tracking
ADD CONSTRAINT Tracking_CreatedBy_fk 
FOREIGN KEY (CreatedBy) REFERENCES User(UserId);

INSERT INTO DataType (Id, Title, UsesSign, Symbol, MaxDecPlaces, CreatedAt, Status) 
VALUES 
(1, 'Decimal', 1, NULL, 3, NOW(), 1),
(2, 'Percentage', 1, NULL, 2, NOW(), 1);

INSERT INTO AxisType (Id, Title, MeasurementRate, CreatedAt, Status) 
VALUES 
(10, 'WIG Main', 'Monthy', NOW(), 1),
(20, 'WIG Other', 'Monthy', NOW(), 1),
(30, 'Predictive Main', 'Weekly', NOW(), 1),
(40, 'Predictive Other', 'Weekly', NOW(), 1);
