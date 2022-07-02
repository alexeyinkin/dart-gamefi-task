SELECT
    p.*,
    (SELECT MIN(dateTimeFirstLiquidity) FROM LiquidityPool lp WHERE lp.projectId = p.id) as dateTimeFirstLiquidity,
    l.title                                     AS launchpadTitle,
    zeroBlockBuyCount.value                     AS zeroBlockBuyCount,
    twoHoursBuyAttemptUniqueAddresses.value     AS twoHoursBuyAttemptUniqueAddresses,
    zeroBlockX.value                            AS zeroBlockX,
    threeBlocksX.value                          AS threeBlocksX,
    sixBlocksX.value                            AS sixBlocksX,
    tenPerCentStopLossBlock.value               AS tenPerCentStopLossBlock,
    threeBlocksAfterTenPerCentStopLossX.value   AS threeBlocksAfterTenPerCentStopLossX,
    initialHalfPoolUsdValue.value               AS initialHalfPoolUsdValue,
    zeroBlockHalfPoolUsdValue.value             AS zeroBlockHalfPoolUsdValue
FROM
    Project p
    INNER JOIN Launchpad l ON l.id = p.launchpadId
    LEFT JOIN ProjectMetricValue zeroBlockBuyCount                      ON (zeroBlockBuyCount.projectId = p.id                      AND zeroBlockBuyCount.metricId = 1)
    LEFT JOIN ProjectMetricValue twoHoursBuyAttemptUniqueAddresses      ON (twoHoursBuyAttemptUniqueAddresses.projectId = p.id      AND twoHoursBuyAttemptUniqueAddresses.metricId = 2)
    LEFT JOIN ProjectMetricValue zeroBlockX                             ON (zeroBlockX.projectId = p.id                             AND zeroBlockX.metricId = 3)
    LEFT JOIN ProjectMetricValue threeBlocksX                           ON (threeBlocksX.projectId = p.id                           AND threeBlocksX.metricId = 4)
    LEFT JOIN ProjectMetricValue sixBlocksX                             ON (sixBlocksX.projectId = p.id                             AND sixBlocksX.metricId = 5)
    LEFT JOIN ProjectMetricValue tenPerCentStopLossBlock                ON (tenPerCentStopLossBlock.projectId = p.id                AND tenPerCentStopLossBlock.metricId = 6)
    LEFT JOIN ProjectMetricValue threeBlocksAfterTenPerCentStopLossX    ON (threeBlocksAfterTenPerCentStopLossX.projectId = p.id    AND threeBlocksAfterTenPerCentStopLossX.metricId = 7)
    LEFT JOIN ProjectMetricValue initialHalfPoolUsdValue                ON (initialHalfPoolUsdValue.projectId = p.id                AND initialHalfPoolUsdValue.metricId = 8)
    LEFT JOIN ProjectMetricValue zeroBlockHalfPoolUsdValue              ON (zeroBlockHalfPoolUsdValue.projectId = p.id              AND zeroBlockHalfPoolUsdValue.metricId = 9)
WHERE
    p.status = 'analyzed'
;
