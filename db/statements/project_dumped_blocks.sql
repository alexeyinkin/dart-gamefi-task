SELECT
    p.id,
    p.title,
    p.symbol,
    (
        SELECT CAST(MAX(`block`) AS SIGNED)
        FROM
            LiquidityPool lp
            INNER JOIN Reserves r ON r.liquidityPoolId = lp.id
        WHERE
            lp.projectId = p.id
    ) - CAST(p.firstLiquidityBlock AS SIGNED) AS maxReservesBlock,
    (
        SELECT MAX(`block`)
        FROM
            LiquidityPool lp
            INNER JOIN Reserves r ON r.liquidityPoolId = lp.id
        WHERE
            lp.projectId = p.id
    ) AS maxReservesBlockAbs,
    (
        SELECT CAST(MIN(`block`) AS SIGNED)
        FROM
            LiquidityPool lp
            INNER JOIN LiquidityPoolTransaction lpt ON lpt.liquidityPoolId = lp.id
            INNER JOIN `Transaction` t ON t.id = lpt.id
        WHERE
            lp.projectId = p.id
    ) - CAST(p.firstLiquidityBlock AS SIGNED) AS minTxBlock,
    (
        SELECT CAST(MAX(`block`) AS SIGNED)
        FROM
            LiquidityPool lp
            INNER JOIN LiquidityPoolTransaction lpt ON lpt.liquidityPoolId = lp.id
            INNER JOIN `Transaction` t ON t.id = lpt.id
        WHERE
            lp.projectId = p.id
    ) - CAST(p.firstLiquidityBlock AS SIGNED) AS maxTxBlock,
    (
        SELECT MAX(`block`)
        FROM
            LiquidityPool lp
            INNER JOIN LiquidityPoolTransaction lpt ON lpt.liquidityPoolId = lp.id
            INNER JOIN `Transaction` t ON t.id = lpt.id
        WHERE
            lp.projectId = p.id
    ) AS maxTxBlockAbs
FROM
    Project p
WHERE
    p.status IN ('past', 'dumped', 'analyzed')
