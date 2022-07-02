SELECT
    *,
    r.halfPoolUsdValue / reserve0 AS price0,
    r.halfPoolUsdValue / reserve1 AS price1
FROM
    LiquidityPool lp
    INNER JOIN Reserves r ON r.liquidityPoolId = lp.id
WHERE
    lp.projectId = ?
ORDER BY
    lp.id,
    r.`block`;
