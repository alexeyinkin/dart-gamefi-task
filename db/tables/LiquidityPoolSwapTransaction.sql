DROP TABLE IF EXISTS LiquidityPoolSwapTransaction;

CREATE TABLE LiquidityPoolSwapTransaction (
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
    fromToken VARCHAR(255) NOT NULL,
    toToken VARCHAR(255) NOT NULL,
    `amountInMaxDouble` DOUBLE NOT NULL,
    `amountInDouble` DOUBLE NOT NULL,
    `amountOutMinDouble` DOUBLE NOT NULL,
    `amountOutDouble` DOUBLE NOT NULL
);

ALTER TABLE LiquidityPoolSwapTransaction ADD CONSTRAINT fk_LiquidityPoolSwapTransaction_id FOREIGN KEY (id) REFERENCES `Transaction` (id) ON DELETE CASCADE;
