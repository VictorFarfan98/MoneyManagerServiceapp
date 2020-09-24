use ${DB_CONFIG};

CREATE TABLE IF NOT EXISTS Project
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    Title nvarchar(512) NOT NULL,    
    CreatedAt DATETIME,
    Status SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY(Id)
) 
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE Project AUTO_INCREMENT =2;

CREATE TABLE IF NOT EXISTS ProjectParameters
(
    Id INT UNSIGNED AUTO_INCREMENT NOT NULL,
    ProjectId INT UNSIGNED NOT NULL,
    Name nvarchar(128) NOT NULL,
    Value TEXT NOT NULL,
    PRIMARY KEY(Id)
)
ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE ProjectParameters 
ADD CONSTRAINT ProjectParameters_ProjectId_fk 
FOREIGN KEY (ProjectId) REFERENCES Project (Id);

CREATE UNIQUE INDEX ProjectParameters_Name_Idx
ON ProjectParameters (Name);

INSERT INTO Project (Id, Title, CreatedAt, Status) VALUES (1,'Seguros Universales', NOW(), 10);

INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'db_version','1.0.0');
INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'service_version','1.0.0');
INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'uri_login_service','localhost:3001/api/v1');
INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'uri_stat_service','localhost:3002/api/v1');
INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'uri_admin_service','localhost:3003/api/v1');
INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'login_providers','facebook,google');

INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'su-alerts-email-from','sv@blackbox.gt');
INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'su-alerts-email-pw','bbs,25123');
INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'su-alerts-email-service','gmail');
INSERT INTO ProjectParameters (ProjectId, Name, Value) VALUES (1,'su-alerts-email-to','leonidasmenendez@gmail.com');

INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-JKSUri','https://alliedglobal-its.auth0.com/.well-known/jwks.json');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-audience','https://m4dx-api/');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-issuer','https://alliedglobal-its.auth0.com/');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'FB-Business-Id','842302695857187');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'FB-permittedTasks','["MANAGE", "ADVERTISE", "ANALYZE" ]');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-clientId','ChrA2LrjIYjizgpEzGxEVcMxuNVR45BN');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-clientSecret','F7wh_vm9kGGvx1qOhZv7xkZ-AL5YbgaJaoRaB0xJGzgURQ2RiUHvmyGFSA565Ccp');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-domain','alliedglobal-its.auth0.com');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-audienceManagement','https://alliedglobal-its.auth0.com/api/v2/');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-checkRemoteJwt','False');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-apiUserClientId','3F8k0W8EvJiO5Ox1kJASyqYrjljYlc59');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-apiUserSecret','bvCUWdactoSxixX-s7zlsjTFTjJnXD8saELoTUKuXxctKCFzxf8nowdIwJo4IFYu');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-SuperAdminId','rol_h91bTTGuZIiZAbKf');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-AdminId','rol_5cejQ8xhb06nrUC9');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-GuestId','rol_V4RMFLmV53rY99bs');
INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) VALUES (1,'Auth0-UserId','rol_qdkkcxm00yT8kVpM');

INSERT INTO ProjectParameters (ProjectId, `Name`, `Value`) 
VALUES 
(1,'App-WIG-Validation-Message',
'OOPS! Recuerda el principio de enfoque "Menos es más", segun la metodología 4DX solo podemos crear de 1 hasta 3 MCIs. Puedes ponerte en contacto con un especialista 4DX si tienes más dudas.'),
(1,'App-Predictive-Validation-Message',
'OOPS! Recuerda el principio de enfoque "Menos es más", segun la metodología 4DX solo podemos crear de 1 hasta 3 Predictivas. Puedes ponerte en contacto con un especialista 4DX si tienes más dudas.');


