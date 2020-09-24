USE `${DB_MAIN}`;
DROP TABLE IF EXISTS Commitment;

CREATE TABLE IF NOT EXISTS Commitment
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    Title NVARCHAR(512) NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    WIGId INT UNSIGNED NOT NULL,
    CreatedBy INT UNSIGNED NOT NULL,
    AssignedTo INT UNSIGNED NOT NULL,
    CreatedFrom INT UNSIGNED,
    CreatedAt DATETIME NOT NULL,
    ChangedAt DATETIME NOT NULL,
    HasDependency BIT NOT NULL,
    IsExternal BIT NOT NULL DEFAULT 0,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE Commitment
ADD CONSTRAINT Commitment_CreatedFrom_fk 
FOREIGN KEY (CreatedFrom) REFERENCES Commitment(Id);

ALTER TABLE Commitment
ADD CONSTRAINT Commitment_CreatedBy_fk 
FOREIGN KEY (CreatedBy) REFERENCES User(UserId);

ALTER TABLE Commitment
ADD CONSTRAINT Commitment_AssignedTo_fk 
FOREIGN KEY (AssignedTo) REFERENCES User(UserId);

ALTER TABLE Commitment
ADD CONSTRAINT Commitment_WIGId_fk 
FOREIGN KEY (WIGId) REFERENCES WIG(Id);

ALTER TABLE Commitment
ADD INDEX Commitment_WIGId_idx (WIGId);

ALTER TABLE Commitment
ADD INDEX Commitment_AssignedTo_idx (AssignedTo);


DROP TABLE IF EXISTS CommitmentTracking;

CREATE TABLE IF NOT EXISTS CommitmentTracking
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    Commentary NVARCHAR(256),
    CreatedAt DATETIME NOT NULL,
    Status SMALLINT UNSIGNED NOT NULL,
    CreatedBy INT UNSIGNED NOT NULL,
    CommitmentId INT UNSIGNED NOT NULL,
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE CommitmentTracking
ADD CONSTRAINT CommitmentTracking_CommitmentId_fk 
FOREIGN KEY (CommitmentId) REFERENCES Commitment(Id);

ALTER TABLE CommitmentTracking
ADD CONSTRAINT CommitmentTracking_CreatedBy_fk 
FOREIGN KEY (CreatedBy) REFERENCES User(UserId);


