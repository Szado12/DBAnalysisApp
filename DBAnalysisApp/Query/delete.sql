DELETE FROM ORDER_DETAILS 
WHERE ORDER_ID IN
                (
                SELECT ORDER_ID 
                FROM 
                    ORDERS O,
                    (SELECT 
                        ORDERS.CLIENT_ID, 
                        MAX(REALISATION_DATE) 
                    FROM 
                        ORDERS,
                        CLIENTS
                    WHERE 
                        ORDERS.CLIENT_ID=CLIENTS.CLIENT_ID
                        AND CLIENTS.CLIENT_TYPE='PRIVATE'
                    GROUP BY ORDERS.CLIENT_ID
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
                        ORDERS.CLIENT_ID, 
                        MAX(REALISATION_DATE) 
                    FROM ORDERS,
                        CLIENTS
                    WHERE 
                        ORDERS.CLIENT_ID=CLIENTS.CLIENT_ID
                        AND CLIENTS.CLIENT_TYPE='PRIVATE' 
                    GROUP BY ORDERS.CLIENT_ID 
                    HAVING ADD_MONTHS(MAX(REALISATION_DATE),60) < SYSDATE
                    ) C,
                    EMPLOYEES EMPL 
                WHERE O.CLIENT_ID=C.CLIENT_ID
                AND EMPL.EMPLOYEE_ID=O.SELLER_ID
                AND EMPL.IS_ARCHIVED='1');