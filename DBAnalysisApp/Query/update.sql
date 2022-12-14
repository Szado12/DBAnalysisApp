INSERT INTO 
    EMPLOYEES
SELECT 
    (
    SELECT 
        MAX(EMPLOYEE_ID) 
    FROM EMPLOYEES
    ) + S.ID, 
    E.FIRST_NAME, 
    E.LAST_NAME, 
    E.EMAIL, 
    E.HIRE_DATE, 
    E.FIRE_DATE, 
    E.SALARY*1.05, 
    E.PHONE_NUMBER, 
    E.IS_ARCHIVED, 
    E.MANAGER_ID, 
    E.SELLER_ADDRESS_ID, 
    E.EMPLOYEE_ID,
    E.CONTRACT_TYPE
FROM 
    EMPLOYEES E,
    (
    SELECT 
        (ROW_NUMBER() OVER(PARTITION BY 1 ORDER BY LAST_MONTH/LAST_LAST_MONTH DESC)) ID, 
        SELLER_ID
    FROM (
        SELECT 
            O.SELLER_ID SELLER_ID,
            AVG(CASE WHEN O.ORDER_DATE >= TRUNC(ADD_MONTHS(SYSDATE, -1),'MM') AND O.ORDER_DATE <= LAST_DAY(ADD_MONTHS(SYSDATE,-1)) THEN ROUND(OD.AMOUNT * WT.PRICE,1) ELSE 0 END ) LAST_MONTH,
            AVG(CASE WHEN O.ORDER_DATE >= TRUNC(ADD_MONTHS(SYSDATE, -2),'MM') AND O.ORDER_DATE <= LAST_DAY(ADD_MONTHS(SYSDATE,-2)) THEN ROUND(OD.AMOUNT * WT.PRICE,1) ELSE 0 END ) LAST_LAST_MONTH
        FROM 
            ORDERS O,
            ORDER_DETAILS OD,
            WOOD_TYPES WT,
            CLIENTS C
        WHERE
            O.ORDER_ID = OD.ORDER_ID
            AND OD.WOOD_TYPE_ID = WT.WOOD_TYPE_ID
            AND O.CLIENT_ID = C.CLIENT_ID
            AND C.CLIENT_TYPE = 'MEDIUM BUSINESS'
        GROUP BY O.SELLER_ID
    )
    WHERE 
        (CASE WHEN LAST_LAST_MONTH = 0 THEN 0 ELSE LAST_MONTH/LAST_LAST_MONTH END) > 0
    ORDER BY 
        LAST_MONTH/LAST_LAST_MONTH DESC
    FETCH FIRST 20 ROWS ONLY
    ) S
WHERE
    E.EMPLOYEE_ID = S.SELLER_ID;  
UPDATE EMPLOYEES 
SET IS_ARCHIVED = '1' 
WHERE EMPLOYEE_ID IN 
    (
    SELECT 
        SELLER_ID
    FROM (
        SELECT 
            O.SELLER_ID SELLER_ID,
            AVG(CASE WHEN O.ORDER_DATE >= TRUNC(ADD_MONTHS(SYSDATE, -1),'MM') AND O.ORDER_DATE <= LAST_DAY(ADD_MONTHS(SYSDATE,-1)) THEN ROUND(OD.AMOUNT * WT.PRICE,1) ELSE 0 END ) LAST_MONTH,
            AVG(CASE WHEN O.ORDER_DATE >= TRUNC(ADD_MONTHS(SYSDATE, -2),'MM') AND O.ORDER_DATE <= LAST_DAY(ADD_MONTHS(SYSDATE,-2)) THEN ROUND(OD.AMOUNT * WT.PRICE,1) ELSE 0 END ) LAST_LAST_MONTH
        FROM 
            ORDERS O,
            ORDER_DETAILS OD,
            WOOD_TYPES WT,
            CLIENTS C
        WHERE
            O.ORDER_ID = OD.ORDER_ID
            AND OD.WOOD_TYPE_ID = WT.WOOD_TYPE_ID
            AND O.CLIENT_ID = C.CLIENT_ID
            AND C.CLIENT_TYPE = 'MEDIUM BUSINESS'
        GROUP BY O.SELLER_ID
    )
    WHERE 
        (CASE WHEN LAST_LAST_MONTH = 0 THEN 0 ELSE LAST_MONTH/LAST_LAST_MONTH END) > 0
    ORDER BY 
        LAST_MONTH/LAST_LAST_MONTH DESC
    FETCH FIRST 20 ROWS ONLY
    );