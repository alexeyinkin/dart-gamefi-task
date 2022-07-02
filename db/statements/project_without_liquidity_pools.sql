SELECT p.*
FROM
    Project p
    LEFT JOIN LiquidityPool lp ON p.id = lp.projectId
WHERE
    lp.id IS NULL;
