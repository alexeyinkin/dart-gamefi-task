DROP TABLE IF EXISTS LiquidityPool;

CREATE TABLE LiquidityPool(
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    projectId BIGINT UNSIGNED,
    chainId BIGINT UNSIGNED NOT NULL,
    dexId BIGINT UNSIGNED NOT NULL,
    address0 VARCHAR(255) NOT NULL,
    address1 VARCHAR(255) NOT NULL,
    is0Usd TINYINT NOT NULL,
    is1Usd TINYINT NOT NULL,
    projectAddress VARCHAR(255),
    otherAddress VARCHAR(255),
    pairAddress VARCHAR(255) NOT NULL,
    blockCreated BIGINT UNSIGNED,
    dateTimeCreated BIGINT UNSIGNED,
    blockFirstLiquidity BIGINT UNSIGNED,
    dateTimeFirstLiquidity BIGINT UNSIGNED
);

INSERT INTO LiquidityPool (
    id,
    projectId,
    chainId,
    dexId,
    address0,
    address1,
    is0Usd,
    is1Usd,
    projectAddress,
    otherAddress,
    pairAddress,
    blockCreated,
    dateTimeCreated,
    blockFirstLiquidity,
    dateTimeFirstLiquidity,
    UNIQUE(chainId, address0, address1)
) VALUES (
    1,
    null,
    56,
    1,
    LOWER('0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c'),
    LOWER('0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56'),
    0,
    1,
    null,
    null,
    LOWER('0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16'),
    6817417,
    1619187570,
    6817417,
    1619187570
);

ALTER TABLE LiquidityPool ADD CONSTRAINT fk_LiquidityPool_projectId FOREIGN KEY (projectId) REFERENCES Project(id) ON DELETE CASCADE;
