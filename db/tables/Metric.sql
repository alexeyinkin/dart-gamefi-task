DROP TABLE IF EXISTS Metric;

CREATE TABLE Metric(
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
    title VARCHAR(255) NOT NULL
);

INSERT INTO Metric(id, title) VALUES (1, '0 Block Buy Count');
INSERT INTO Metric(id, title) VALUES (2, '-2 Hours Buy Attempt Unique Addresses');
INSERT INTO Metric(id, title) VALUES (3, '0 Block X');
INSERT INTO Metric(id, title) VALUES (4, '3 Blocks X');
INSERT INTO Metric(id, title) VALUES (5, '6 Blocks X');
INSERT INTO Metric(id, title) VALUES (6, '10% Stop Loss Block');
INSERT INTO Metric(id, title) VALUES (7, '3 Blocks After 10% Stop Loss X');
INSERT INTO Metric(id, title) VALUES (8, 'Initial Half Pool USD Value');
INSERT INTO Metric(id, title) VALUES (9, '0 Block Half Pool USD Value');
INSERT INTO Metric(id, title) VALUES (10, '1 Block X');
INSERT INTO Metric(id, title) VALUES (11, '2 Blocks X');
INSERT INTO Metric(id, title) VALUES (12, '4 Blocks X');
INSERT INTO Metric(id, title) VALUES (13, '5 Blocks X');
