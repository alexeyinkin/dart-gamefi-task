SELECT
    t.*,
    lpt.*,
    lplt.*,
    lpst.*
FROM
    `Transaction` t
    INNER JOIN LiquidityPoolTransaction lpt ON lpt.id = t.id
    LEFT JOIN LiquidityPoolLiquidityTransaction lplt ON lplt.id = t.id
    LEFT JOIN LiquidityPoolSwapTransaction lpst ON lpst.id = t.id
WHERE
    t.chainId = ? AND
    t.`block` BETWEEN ? AND ?
ORDER BY
    t.`block`,
    t.`index`
