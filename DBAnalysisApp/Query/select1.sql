SELECT 
    Y.YR "Year", 
    M.MON "Month", 
    ROUND(M.MonthPriceAvg, 2) "Average order price per month", 
    ROUND(M.MonthAmountAvg, 2) "Average order amount per month", 
    ROUND(M.MonthWeightAvg, 2) "Average order weight per month", 
    CASE WHEN M.MonthPriceAvg > Y.YearPriceAvg THEN 'TRUE' ELSE 'FALSE' END "Average order price per month higher than per year",
    CASE WHEN M.MonthAmountAvg > Y.YearAmountAvg THEN 'TRUE' ELSE 'FALSE' END "Average order amount per month higher than per year",
    CASE WHEN M.MonthWeightAvg > Y.YearWeightAvg THEN 'TRUE' ELSE 'FALSE' END "Average order weight per month higher than per year"
FROM 
    (
        SELECT 
            EXTRACT(YEAR FROM OrderDate) YR, 
            EXTRACT(MONTH FROM OrderDate) MON, 
            AVG(PriceSums) MonthPriceAvg,
            AVG(AmountSums) MonthAmountAvg, 
            AVG(WeightSums) MonthWeightAvg
        FROM
        (
            SELECT 
                O.ORDER_DATE OrderDate, 
                SUM(ROUND(OD.AMOUNT * WT.PRICE,1)) PriceSums, 
                SUM(OD.AMOUNT) AmountSums, 
                SUM(OD.AMOUNT * WT.DENSITY) WeightSums
            FROM 
                ORDERS O,
                ORDER_DETAILS OD,
                WOOD_TYPES WT 
            WHERE 
                O.ORDER_ID = OD.ORDER_ID
                AND OD.WOOD_TYPE_ID = WT.WOOD_TYPE_ID
                AND LOWER(O.COMMENTS) LIKE ('%regular customer%')
            GROUP BY O.ORDER_ID, O.ORDER_DATE
        )
        GROUP BY EXTRACT(YEAR FROM OrderDate), EXTRACT(MONTH FROM OrderDate)
        ORDER BY yr, mon DESC
    ) M,
    (
        SELECT 
            EXTRACT(YEAR FROM OrderDate) YR, 
            AVG(PriceSums) YearPriceAvg, 
            AVG(AmountSums) YearAmountAvg, 
            AVG(WeightSums) YearWeightAvg
        FROM
        (
            SELECT 
                O.ORDER_DATE OrderDate, 
                SUM(ROUND(OD.AMOUNT * WT.PRICE,1)) PriceSums, 
                SUM(OD.AMOUNT) AmountSums, 
                SUM(OD.AMOUNT * WT.DENSITY) WeightSums
            FROM 
                ORDERS O,
                ORDER_DETAILS OD,
                WOOD_TYPES WT 
            WHERE 
                O.ORDER_ID = OD.ORDER_ID
                AND OD.WOOD_TYPE_ID = WT.WOOD_TYPE_ID
                AND LOWER(O.COMMENTS) LIKE ('%regular customer%')
                AND WT.IS_ARCHIVED='0'
            GROUP BY O.ORDER_ID, O.ORDER_DATE
        )
        GROUP BY EXTRACT(YEAR FROM OrderDate)
    ) Y
WHERE 
    M.YR = Y.YR
ORDER BY 
    Y.YR DESC, M.MON DESC;