DROP TABLE IF EXISTS LiquidityPoolLiquidityTransaction;

CREATE TABLE LiquidityPoolLiquidityTransaction(
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
    amount0Double DOUBLE NOT NULL,
    amount1Double DOUBLE NOT NULL
);

ALTER TABLE LiquidityPoolLiquidityTransaction ADD CONSTRAINT fk_LiquidityPoolLiquidityTransaction_id FOREIGN KEY (id) REFERENCES `Transaction` (id) ON DELETE CASCADE;
