## Create necesary tables for saving logs ## 
USE `${DB_MAIN}`;

DROP TABLE IF EXISTS `EventObject`;
CREATE TABLE IF NOT EXISTS `EventObject`
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    `Name` NVARCHAR(100) NOT NULL, 
    `Description` NVARCHAR(255),    
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `EventType`;
CREATE TABLE IF NOT EXISTS `EventType`
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    `Name` NVARCHAR(100) NOT NULL, 
    `Description` NVARCHAR(255),    
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `Log`;
CREATE TABLE IF NOT EXISTS `Log`
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,    
    EventType INT UNSIGNED NOT NULL,
    EventObject INT UNSIGNED NOT NULL,
    EventName NVARCHAR(255),
    TeamId INT UNSIGNED,
    WIGId INT UNSIGNED,
    PredictiveId INT UNSIGNED,
    TrackingId INT UNSIGNED,
    CommitmentId INT UNSIGNED, 
    CommitmentTrackingId INT UNSIGNED,
    CreatedBy INT UNSIGNED NOT NULL,
    CreatedAt DATETIME NOT NULL, 
    PRIMARY KEY (Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE `Log`
ADD CONSTRAINT Log_TeamId_fk
FOREIGN KEY (TeamId) REFERENCES Team(Id);

ALTER TABLE `Log`
ADD CONSTRAINT Log_WIGId_fk
FOREIGN KEY (WIGId) REFERENCES WIG(Id);

ALTER TABLE `Log`
ADD CONSTRAINT Log_PredictiveId_fk
FOREIGN KEY (PredictiveId) REFERENCES Predictive(Id);

ALTER TABLE `Log`
ADD CONSTRAINT Log_TrackingId_fk
FOREIGN KEY (TrackingId) REFERENCES Tracking(Id);

ALTER TABLE `Log`
ADD CONSTRAINT Log_CommitmentId_fk
FOREIGN KEY (CommitmentId) REFERENCES Commitment(Id);

ALTER TABLE `Log`
ADD CONSTRAINT Log_CommitmentTrackingId_fk
FOREIGN KEY (CommitmentTrackingId) REFERENCES CommitmentTracking(Id);

ALTER TABLE `Log`
ADD CONSTRAINT Log_CreatedBy_fk
FOREIGN KEY (CreatedBy) REFERENCES User(UserId);

INSERT INTO EventObject (`Name`, `Description`)
VALUES
('Equipo', 'TeamId en el que se disparó un evento'),
('MCI', 'WIGId en la que se disparó un evento'),
('Predictiva', 'PredictiveId en la que se disparó un evento'),
('Rastreo', 'TrackingId en el que se disparó un evento'),
('Rastreo MCI', 'TrackingId en el que se disparó un evento'),
('Rastreo Predictiva', 'TrackingId en el que se disparó un evento'),
('Compromiso', 'CommitmentId en el que se disparó un evento'),
('Rastreo Compromiso', 'CommitmentId en el que se disparó un evento');

INSERT INTO EventType (`Name`, `Description`)
VALUES
('Creó', 'Evento que se dispara en la insercion de un nuevo elemento en la base de datos'),
('Modificó', 'Evento que se dispara al modificar un elemento en la base de datos'),
('Eliminó', 'Evento que se dispara al eliminar un elemento de la base de datos');
