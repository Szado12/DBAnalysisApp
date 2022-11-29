SELECT 
    A.CITY "City", 
    COUNT(O.ORDER_ID) "Count of orders", 
    SUM(ORD.ORDER_WEIGHT) "Sum of wood weight in orders" 
FROM 
    (
        SELECT 
            ORD.ORDER_ID, 
            SUM(AMOUNT*DENSITY) ORDER_WEIGHT
        FROM 
            ORDER_DETAILS ORD, 
            WOOD_TYPES WT,
            ORDERS O,
            CLIENTS C
        WHERE
            ORD.WOOD_TYPE_ID = WT.WOOD_TYPE_ID 
            AND O.ORDER_ID = ORD.ORDER_ID
            AND O.CLIENT_ID = C.CLIENT_ID
            AND C.CLIENT_TYPE = 'PRIVATE'
        GROUP BY 
            ORD.ORDER_ID 
        HAVING 
            SUM(AMOUNT*DENSITY)>25000
    ) ORD, 
    ORDERS O,
    ADDRESSES A,
    CLIENTS C
WHERE
    ORD.ORDER_ID = O.ORDER_ID 
    AND O.DELIVERY_ADDRESS_ID = A.ADDRESS_ID 
    AND O.CLIENT_ID = C.CLIENT_ID
    AND O.REALISATION_DATE IS NOT NULL 
    AND C.IS_ARCHIVED = '0'
GROUP BY 
    A.CITY
ORDER BY 
    SUM(ORD.ORDER_WEIGHT) DESC;