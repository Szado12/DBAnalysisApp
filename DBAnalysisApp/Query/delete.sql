DELETE FROM ORDER_DETAILS 
WHERE ORDER_ID IN
                (
                SELECT ORDER_ID 
                FROM 
                    ORDERS O,
                    (SELECT 
                        CLIENT_ID, 
                        MAX(REALISATION_DATE) 
                    FROM ORDERS 
                    GROUP BY CLIENT_ID 
                    HAVING ADD_MONTHS(MAX(REALISATION_DATE),60) < SYSDATE
                    ) C,
                    EMPLOYEES EMPL 
                WHERE O.CLIENT_ID=C.CLIENT_ID
                AND EMPL.EMPLOYEE_ID=O.SELLER_ID
                AND EMPL.IS_ARCHIVED='1');
                 
DELETE FROM ORDERS 
WHERE ORDER_ID IN 
                 (
                 SELECT ORDER_ID 
                FROM 
                    ORDERS O,
                    (SELECT 
                        CLIENT_ID, 
                        MAX(REALISATION_DATE) 
                    FROM ORDERS 
                    GROUP BY CLIENT_ID 
                    HAVING ADD_MONTHS(MAX(REALISATION_DATE),60) < SYSDATE
                    ) C,
                    EMPLOYEES EMPL 
                WHERE O.CLIENT_ID=C.CLIENT_ID
                AND EMPL.EMPLOYEE_ID=O.SELLER_ID
                AND EMPL.IS_ARCHIVED='1');
