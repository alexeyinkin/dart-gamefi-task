DROP TABLE IF EXISTS Project;

CREATE TABLE Project(
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    launchpadId BIGINT UNSIGNED NOT NULL,
    chainId BIGINT UNSIGNED NOT NULL,
    idInLaunchpad VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    symbol VARCHAR(255) NOT NULL,
    dateTimeInserted BIGINT UNSIGNED,
    dateTimeUpdated BIGINT UNSIGNED,
    tokenAddress VARCHAR(255),
    dateTimePoolCreationEstimate BIGINT UNSIGNED,
    status VARCHAR(255) NOT NULL,
    firstLiquidityBlock BIGINT UNSIGNED,
    lockPid INT,
    presaleUsdPrice DOUBLE,
    initialDexUsdPrice DOUBLE,
    xAfterStopLoss DOUBLE,
    tradable TINYINT NOT NULL
);
