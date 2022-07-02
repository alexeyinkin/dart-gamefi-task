DROP TABLE IF EXISTS `Transaction`;

CREATE TABLE `Transaction` (
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    chainId BIGINT UNSIGNED NOT NULL,
    `hash` VARCHAR(255) NOT NULL,
    `block` BIGINT UNSIGNED,
    `dateTime` BIGINT UNSIGNED,
    `index` BIGINT UNSIGNED,
    status TINYINT NOT NULL,
    gasPriceWei BIGINT UNSIGNED,
    `from` VARCHAR(255) NOT NULL,
    `to` VARCHAR(255) NOT NULL,
    `function` VARCHAR(255),
    `input` BLOB NOT NULL,
    nonce BIGINT UNSIGNED,
    valueDouble DOUBLE NOT NULL,
    UNIQUE(`hash`)
);
