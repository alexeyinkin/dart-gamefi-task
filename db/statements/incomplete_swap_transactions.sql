SELECT t.*, lpt.*, lpst.*
FROM
    `Transaction` t
    LEFT JOIN `LiquidityPoolTransaction` lpt ON lpt.id = t.id
    LEFT JOIN `LiquidityPoolSwapTransaction` lpst ON lpst.id = t.id
WHERE
    (lpt.id IS NULL OR lpst.id IS NULL) AND
    t.`function` IN (
        'swapETHForExactTokens',
        'swapExactETHForTokens',
        'swapExactETHForTokensSupportingFeeOnTransferTokens',
        'swapExactTokensForETH',
        'swapExactTokensForETHSupportingFeeOnTransferTokens',
        'swapExactTokensForTokens',
        'swapExactTokensForTokensSupportingFeeOnTransferTokens',
        'swapTokensForExactETH',
        'swapTokensForExactTokens'
    );
