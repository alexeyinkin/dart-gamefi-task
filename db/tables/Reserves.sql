DROP TABLE IF EXISTS Reserves;

CREATE TABLE Reserves(
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    liquidityPoolId BIGINT UNSIGNED NOT NULL,
    `block` BIGINT UNSIGNED NOT NULL,
    `dateTime` BIGINT UNSIGNED NOT NULL,
    reserve0 DOUBLE NOT NULL,
    reserve1 DOUBLE NOT NULL,
    halfPoolUsdValue DOUBLE NOT NULL,
    UNIQUE(liquidityPoolId, `block`)
);

ALTER TABLE Reserves ADD CONSTRAINT fk_Reserves_liquidityPoolId FOREIGN KEY (liquidityPoolId) REFERENCES LiquidityPool(id) ON DELETE CASCADE;
