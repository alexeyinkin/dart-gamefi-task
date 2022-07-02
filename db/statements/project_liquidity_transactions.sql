SELECT
    t.*,
    lpt.*,
    lplt.*
FROM
    Project p
    INNER JOIN LiquidityPool lp ON lp.projectId = p.id
    INNER JOIN LiquidityPoolTransaction lpt ON lpt.liquidityPoolId = lp.id
    INNER JOIN `Transaction` t ON t.id = lpt.id
    INNER JOIN LiquidityPoolLiquidityTransaction lplt ON lplt.id = t.id
WHERE
    p.id = ?
ORDER BY
    t.`block`,
    t.`index`
