DROP TABLE IF EXISTS LiquidityPoolTransaction;

CREATE TABLE LiquidityPoolTransaction (
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
    liquidityPoolId BIGINT UNSIGNED NOT NULL,
    deadline BIGINT UNSIGNED NOT NULL,
    usdEquivalent DOUBLE
);

ALTER TABLE LiquidityPoolTransaction ADD CONSTRAINT fk_LiquidityPoolTransaction_id FOREIGN KEY (id) REFERENCES `Transaction`(id) ON DELETE CASCADE;
ALTER TABLE LiquidityPoolTransaction ADD CONSTRAINT fk_LiquidityPoolTransaction_liquidityPoolId FOREIGN KEY (liquidityPoolId) REFERENCES LiquidityPool (id) ON DELETE CASCADE;
