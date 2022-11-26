SELECT
    E.FIRST_NAME,
    E.LAST_NAME,
    E1.EMPL_COUNT,
    ORDERS_COUNT,
    AVG_ORDER_PRICE,
    ROUND(ORDERS_COUNT/E1.EMPL_COUNT,2) "ORDERS COUNT PER EMPLOYEE",
    ROUND("7DAYS"/ORDERS_COUNT *100,2) "% OF ORDERS WITH DELIVERY TIME -7 DAYS",
    ROUND("7-14DAYS"/ORDERS_COUNT *100,2) "% OF ORDERS WITH DELIVERY TIME 7-14 DAYS",
    ROUND("14-30DAYS"/ORDERS_COUNT *100,2) "% OF ORDERS WITH DELIVERY TIME 14-30 DAYS",
    ROUND("30DAYS"/ORDERS_COUNT *100,2) "% OF ORDERS WITH DELIVERY TIME 30+ DAYS"
FROM
    EMPLOYEES E,
    (
        SELECT
            MANAGER_ID,
            COUNT(*) EMPL_COUNT
        FROM
            EMPLOYEES
        WHERE MANAGER_ID IS NOT NULL AND IS_ARCHIVED = '0'
        GROUP BY
            MANAGER_ID
    ) E1,
    (SELECT MNG_ID,
            AVG(AVG_ORDER_PRICE) AVG_ORDER_PRICE,
            SUM(ORDERS_COUNT) ORDERS_COUNT,
            SUM("7DAYS") "7DAYS",
            SUM("7-14DAYS") "7-14DAYS",
            SUM("14-30DAYS") "14-30DAYS",
            SUM("30DAYS") "30DAYS"
     FROM (
           SELECT 
                COUNT(*) ORDERS_COUNT,
                MANAGER_ID MNG_ID,
                AVG(OD.ORDER_PRICE) AVG_ORDER_PRICE,
                SUM(CASE WHEN O.REALISATION_DATE IS NOT NULL AND ORDER_DATE + 7 > O.REALISATION_DATE THEN 1
                          ELSE 0 END) "7DAYS",
                SUM(CASE WHEN ORDER_DATE + 7 < O.REALISATION_DATE AND ORDER_DATE + 14 >= O.REALISATION_DATE
                          THEN 1 ELSE 0 END) "7-14DAYS",
                SUM(CASE WHEN ORDER_DATE + 14 < O.REALISATION_DATE AND ORDER_DATE + 30 >= O.REALISATION_DATE
                          THEN 1 ELSE 0 END) "14-30DAYS",
                SUM(CASE WHEN ORDER_DATE + 30 < O.REALISATION_DATE THEN 1 ELSE 0 END) "30DAYS"                  
           FROM ORDERS O,
                EMPLOYEES EMP,
                (
                SELECT ORDER_ID, SUM(OD.AMOUNT*WT.PRICE) ORDER_PRICE 
                FROM ORDER_DETAILS OD, WOOD_TYPES WT 
                WHERE OD.WOOD_TYPE_ID=WT.WOOD_TYPE_ID 
                GROUP BY ORDER_ID
                ) OD
           WHERE 
                O.SELLER_ID=EMP.EMPLOYEE_ID
                AND OD.ORDER_ID=O.ORDER_ID
                AND IS_ARCHIVED = '0'
                AND MANAGER_ID IS NOT NULL
           GROUP BY MANAGER_ID)
     GROUP BY MNG_ID) AVG_DATA
WHERE
    E.EMPLOYEE_ID = E1.MANAGER_ID
    AND AVG_DATA.MNG_ID = E1.MANAGER_ID
ORDER BY ORDERS_COUNT/E1.EMPL_COUNT DESC;