DROP TABLE IF EXISTS ProjectMetricValue;

CREATE TABLE ProjectMetricValue(
    projectId BIGINT UNSIGNED NOT NULL,
    metricId BIGINT UNSIGNED NOT NULL,
    value DOUBLE,
    PRIMARY KEY (projectId, metricId)
);
