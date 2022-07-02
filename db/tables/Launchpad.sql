DROP TABLE IF EXISTS Launchpad;

CREATE TABLE Launchpad(
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    intName VARCHAR(255) NOT NULL,
    dateTimeGrabbed BIGINT UNSIGNED
);

INSERT INTO Launchpad (id, title, intName, dateTimeGrabbed) VALUES (1, 'Auto-Grabbed', 'auto', 0);
INSERT INTO Launchpad (id, title, intName, dateTimeGrabbed) VALUES (2, 'Manual', 'manual', 0);
INSERT INTO Launchpad (id, title, intName, dateTimeGrabbed) VALUES (3, 'BSCPad', 'bscpad', 0);
INSERT INTO Launchpad (id, title, intName, dateTimeGrabbed) VALUES (4, 'GameFi', 'gamefi', 0);
