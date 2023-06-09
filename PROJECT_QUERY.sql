--PROJECT CODE--
--ALL DATA FROM TABLES.
SELECT * FROM ORDER_DETAILS; 

SELECT * FROM CUSTOMER_PAYMENT; 

SELECT * FROM PRODUCT_STOCK;

SELECT * FROM VENDOR;

SELECT * FROM VENDOR_ORDER;

SELECT * FROM VENDOR_PAYMENT;

SELECT * FROM VENDOR_DETAILS;
--WHERE CLAUSE
SELECT * FROM ORDER_DETAILS 
WHERE WINE_QUANTITY = 1;

SELECT * FROM ORDER_DETAILS 
WHERE ORDER_DATE = '12-01-23';

SELECT * FROM PRODUCT_STOCK 
WHERE WINE_TYPE = 'RED WINE';

SELECT * FROM VENDOR_ORDER
WHERE QUANTITY = 50;

--BETWEEN AND OPERATOR
SELECT * 
FROM ORDER_DETAILS
WHERE ORDER_DATE BETWEEN '01-01-2022' AND '31-12-2022';

SELECT *
FROM CUSTOMER_PAYMENT
WHERE PAYMENT_DATE BETWEEN'01-01-2023' AND '31-01-2023';

SELECT * 
FROM PRODUCT_STOCK
WHERE WINE_PRICE BETWEEN 500 AND 1000;

SELECT *
FROM VENDOR_ORDER
WHERE PRICE BETWEEN 10000 AND 50000;

--ORDER BY CLAUSE
SELECT *
FROM ORDER_DETAILS
ORDER BY WINE_QUANTITY;

SELECT * 
FROM PRODUCT_STOCK
ORDER BY WINE_NAME;

SELECT * 
FROM VENDOR_ORDER
ORDER BY ORDER_DATE;

--SINGLE ROW FUNCTIONS
SELECT LENGTH(WINE_NAME)
FROM PRODUCT_STOCK;
 
SELECT LPAD(EMAIL,20,'*')
FROM VENDOR;

SELECT LPAD(PHONE_NUMBER,15,'*KFJ ')
FROM VENDOR;

--DATE FUNCTIONS
SELECT ROUND(MONTHS_BETWEEN(SYSDATE,ORDER_DATE),2) AS DIFFRENCE
FROM ORDER_DETAILS;

SELECT ADD_MONTHS(PAYMENT_DATE,2)
FROM CUSTOMER_PAYMENT;

SELECT NEXT_DAY(ORDER_DATE,5)
FROM VENDOR_ORDER;

SELECT NEXT_DAY(VP_DATE,'FRIDAY') 
FROM VENDOR_PAYMENT;

SELECT LAST_DAY(ORDER_DATE)
FROM VENDOR_ORDER;

--CONVERSION FUNCTIONS
SELECT TO_CHAR(ORDER_DATE,'DAY-MONTH-YEAR')
FROM ORDER_DETAILS;

SELECT TO_DATE(VP_DATE)
FROM VENDOR_PAYMENT;

--AGGREGATE FUNCTIONS
SELECT COUNT(PAYMENT_MODE)
FROM VENDOR_PAYMENT;

SELECT SUM(WINE_PRICE)
FROM PRODUCT_STOCK;

SELECT AVG(PRICE)
FROM VENDOR_ORDER;

SELECT MAX(QUANTITY)
FROM VENDOR_ORDER;

SELECT MIN(WINE_PRICE)
FROM PRODUCT_STOCK;

SELECT COUNT(*)
FROM ORDER_DETAILS;

SELECT COUNT(EMAIL)
FROM VENDOR
WHERE VD_ID = 100;

SELECT COUNT('rakesh@gmail.com')
FROM DUAL;

SELECT COUNT(DISTINCT(ORDER_DATE))
FROM ORDER_DETAILS;

--JOINS
SELECT *
FROM ORDER_DETAILS O JOIN VENDOR_ORDER V
ON(V.ORDER_DATE = V.ORDER_DATE);

--SUBQUERY
SELECT * 
FROM VENDOR_ORDER
WHERE ORDER_DATE IN (SELECT ORDER_DATE FROM ORDER_DETAILS);

SELECT * FROM VENDOR_ORDER
WHERE ORDER_DATE IN (SELECT ORDER_DATE FROM VENDOR_PAYMENT);

SELECT VO_ID,ORDER_DATE,QUANTITY FROM VENDOR_ORDER
UNION 
SELECT ORDER_ID,ORDER_DATE,WINE_QUANTITY FROM ORDER_DETAILS;

--view
CREATE OR REPLACE VIEW PROJECT_VIEW
AS 
SELECT V.VO_ID,V.WINE_NAME,V.ORDER_DATE,P.PAYMENT_MODE
FROM VENDOR_ORDER V JOIN VENDOR_PAYMENT P
ON(V.VO_ID = P.VO_ID);

SELECT * FROM PROJECT_VIEW;

--CASE
SELECT WINE_NAME,ORDER_DATE,PRICE,QUANTITY,
CASE
WHEN QUANTITY < 10 THEN 'POOR'
WHEN QUANTITY >10 AND QUANTITY <20 THEN 'GOOD'
WHEN QUANTITY >30 AND QUANTITY <50 THEN 'BETTER'
WHEN QUANTITY >50 AND QUANTITY <100 THEN 'BEST'
ELSE
'BRIAlLIANT PROFIT'
END AS PROFIT_ANALYSIS
FROM VENDOR_ORDER;

--INDEX
CREATE INDEX PROJECT_INDEX
ON
ORDER_DETAILS(WINE_NAME);

SAVEPOINT A;
--MERGE TABLE
--CREATE STRUCTURE OF SOURCE TABLE USING TARGET TABLE
CREATE TABLE ORD_DETAILS
AS
SELECT * FROM ORDER_DETAILS
WHERE 1=2;

SELECT * FROM ORD_DETAILS;

DROP TABLE ORD_DETAILS;

MERGE INTO ORD_DETAILS O
USING ORDER_DETAILS D
ON(D.ORDER_ID = O.ORDER_ID)

WHEN MATCHED THEN
UPDATE
SET
O.ORDER_DATE = D.ORDER_DATE,
O.WINE_NAME = D.WINE_NAME,
O.WINE_QUANTITY = D.WINE_QUANTITY

WHEN NOT MATCHED THEN
INSERT VALUES(D.ORDER_ID,D.ORDER_DATE,D.WINE_NAME,D.WINE_QUANTITY);

ROLLBACK TO SAVEPOINT A;

--WITH CLAUSE
--BY THE USING OF VENDOR_ORDER FIND OUT WHERE AVERAGE PRICE AND MAXIMUM PRICE IS SAME
WITH TEMP1
AS
(SELECT AVG(PRICE)AS AVERAGE_SALARY,WINE_NAME
FROM VENDOR_ORDER
GROUP BY WINE_NAME),
TEMP2
AS 
(SELECT MAX(PRICE) AS MAXIMUM_SALARY,WINE_NAME
FROM VENDOR_ORDER
GROUP BY WINE_NAME
)
SELECT T1.WINE_NAME,T1.AVERAGE_SALARY,T2.MAXIMUM_SALARY
FROM TEMP1 T1 JOIN TEMP2 T2
ON(T1.WINE_NAME = T2.WINE_NAME)
WHERE T1.AVERAGE_SALARY = T2.MAXIMUM_SALARY;

--CORELATED SUBQUERY
SELECT *
FROM VENDOR_ORDER V
WHERE EXISTS(
SELECT 1 FROM VENDOR_PAYMENT P
WHERE V.ORDER_DATE = P.VP_DATE);

--AGGREGATE FUNCTIONS
SELECT VO_ID,WINE_NAME,VD_ID,QUANTITY ,MAX(PRICE) OVER(PARTITION BY WINE_NAME)
FROM VENDOR_DETAILS;

--GIVE RANKING PRICEWISE
SELECT *
FROM(
SELECT VO_ID,WINE_NAME,VD_ID,QUANTITY ,PRICE,DENSE_RANK()
OVER(ORDER BY PRICE) AS RNK
FROM VENDOR_DETAILS);

SELECT *
FROM(
SELECT VO_ID,WINE_NAME,VD_ID,QUANTITY ,PRICE,ROW_NUMBER()
OVER(ORDER BY PRICE) AS RNK
FROM VENDOR_DETAILS);

SELECT *
FROM(
SELECT VO_ID,WINE_NAME,VD_ID,QUANTITY ,PRICE,RANK()
OVER(ORDER BY PRICE) AS RNK
FROM VENDOR_DETAILS);

--FIVE THIRD RANKED PRICE
SELECT *
FROM(
SELECT VO_ID,WINE_NAME,VD_ID,QUANTITY ,PRICE,DENSE_RANK()
OVER(ORDER BY PRICE) AS RNK
FROM VENDOR_DETAILS)
WHERE RNK = 3;

--GIVE FIRST THREE RANKED PRICE OF WINE
SELECT *
FROM(
SELECT VO_ID,WINE_NAME,VD_ID,QUANTITY ,PRICE,DENSE_RANK()
OVER(ORDER BY PRICE) AS RNK
FROM VENDOR_DETAILS) 
WHERE RNK <=3;

--PLSQL QUERIES
--CURSOR
SET SERVEROUTPUT ON
DECLARE
CURSOR PROJECT_CURSOR IS
SELECT ORDER_ID,ORDER_DATE,WINE_NAME,WINE_QUANTITY
FROM ORDER_DETAILS;

O_ID ORDER_DETAILS.ORDER_ID%TYPE;
ORD_DATE ORDER_DETAILS.ORDER_DATE%TYPE;
WNAME ORDER_DETAILS.WINE_NAME%TYPE;
WQUANTITY ORDER_DETAILS.WINE_QUANTITY%TYPE;

BEGIN
OPEN PROJECT_CURSOR;
LOOP
FETCH PROJECT_CURSOR INTO O_ID,ORD_DATE,WNAME,WQUANTITY;
DBMS_OUTPUT.PUT_LINE(O_ID||' '||ORD_DATE||' '||WNAME||' '||WQUANTITY);
EXIT WHEN PROJECT_CURSOR%NOTFOUND;
END LOOP;
CLOSE PROJECT_CURSOR;
END;

--JOINS IN CURSOR
SET SERVEROUTPUT ON
DECLARE
CURSOR PROJECT_CURSOR1 IS
SELECT V.VD_ID,V.VD_NAME,V.ADDRESS,D.VO_ID,D.WINE_NAME,P.VP_ID,P.VP_DATE
FROM VENDOR V JOIN VENDOR_DETAILS D
ON(V.VD_ID = D.VD_ID)
JOIN VENDOR_PAYMENT P
ON(D.VO_ID = P.VO_ID);

V_ID VENDOR.VD_ID%TYPE;
V_NAME VENDOR.VD_NAME%TYPE;
CITY VENDOR.ADDRESS%TYPE;
ORDER_ID VENDOR_DETAILS.VO_ID%TYPE;
WNAME VENDOR_DETAILS.WINE_NAME%TYPE;
P_ID VENDOR_PAYMENT.VP_ID%TYPE;
P_DATE VENDOR_PAYMENT.VP_DATE%TYPE;

BEGIN
OPEN PROJECT_CURSOR1;
LOOP
FETCH PROJECT_CURSOR1 INTO V_ID,V_NAME,CITY,ORDER_ID,WNAME,P_ID,P_DATE;
DBMS_OUTPUT.PUT_LINE(V_ID||' '||V_NAME||' '||CITY||' '||ORDER_ID||' '||WNAME||' '||P_ID||' '||P_DATE);
EXIT WHEN PROJECT_CURSOR1%NOTFOUND;
END LOOP;
CLOSE PROJECT_CURSOR1;
END;

--FUNCTIONS
--FIND OUT WINE TYPE WISE AVERAGE PRICE OF WINE BY USING WINE_NAME
SET SERVEROUTPUT ON
CREATE OR REPLACE FUNCTION PROJECT_FUN (W_TYPE VARCHAR2)
RETURN NUMBER
AS
PF NUMBER;
BEGIN
SELECT ROUND(AVG(WINE_PRICE),2) AS AVERAGE_PRICE INTO PF
FROM PRODUCT_STOCK
WHERE WINE_TYPE = W_TYPE;
RETURN PF;
END;

SELECT WINE_NAME,PROJECT_FUN(WINE_TYPE)
FROM PRODUCT_STOCK
WHERE WINE_TYPE = 'RED WINE';

--FROM VENDOR FIND OUT WINE_NAME,PRICE,QUANTITY BY USING ORDER_DATE
SET SERVEROUTPUT ON
CREATE OR REPLACE FUNCTION PROJECT_FUNCTION (ORD_DATE DATE)
RETURN NUMBER 
AS PF2 NUMBER;

BEGIN
SELECT SUM(PRICE) AS TOTAL_PRICE INTO PF2
FROM VENDOR_ORDER
WHERE ORDER_DATE = ORD_DATE;

RETURN PF2;
END;

SELECT WINE_NAME,QUANTITY,PROJECT_FUNCTION(ORDER_DATE) AS TOTAL_SALARY
FROM VENDOR_ORDER
WHERE ORDER_DATE = '12-01-2023';

--IN FUNCTION FIND OUT ORDER_DATE,PRICE_QUANTITY BY USING OF WINE NAME
SET SERVEROUTPUT ON
CREATE OR REPLACE FUNCTION LKJ (V.WNAME VARCHAR2)
RETURN NUMBER
AS
MNB NUMBER;

BEGIN
SELECT V.VO_ID,V.ORDER_DATE,(P.WINE_PRICE * V.QUANTITY) AS TOTAL_PRICE --INTO MNB
FROM VENDOR_ORDER V JOIN PRODUCT_STOCK P
ON(V.WINE_NAME = P.WINE_NAME) 
WHERE V.WINE_NAME = V.WNAME;

RETURN MNB;
END;

--PROCEDURE
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE PROJECT_PROCEDURE (VENDOR_ID NUMBER)
IS
VENDOR_NAME VARCHAR2(20);
CITY VARCHAR2(20);
VENDOR_EMAIL VARCHAR2(20);
VENDOR_PHONE NUMBER;

BEGIN
SELECT VD_NAME,ADDRESS,EMAIL,PHONE_NUMBER INTO VENDOR_NAME,CITY,VENDOR_EMAIL,VENDOR_PHONE
FROM VENDOR
WHERE VD_ID = VENDOR_ID;
DBMS_OUTPUT.PUT_LINE(VENDOR_NAME||' '||CITY||' '||VENDOR_EMAIL||' '||VENDOR_PHONE);
END;

EXECUTE PROJECT_PROCEDURE(100);

--
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE PROJECT_PROCE (YR NUMBER)
AS
CURSOR BC IS
SELECT P_ID,ORDER_ID,PAYMENT_MODE,TO_CHAR(PAYMENT_DATE,'YYYY') AS YR
FROM CUSTOMER_PAYMENT
WHERE TO_CHAR(PAYMENT_DATE,'YYYY') = YR;

BEGIN
FOR I IN BC
LOOP
DBMS_OUTPUT.PUT_LINE(I.P_ID||' '||I.ORDER_ID||' '||I.PAYMENT_MODE);
END LOOP;
END;

EXECUTE PROJECT_PROCE(2022);

--EXCEPTION HANDLING
SET SERVEROUTPUT ON
DECLARE
WQUANTITY NUMBER := &QUANTITY;
WINE_QUANTITY NUMBER;
OUT_OF_STOCK EXCEPTION ;
BEGIN
IF WQUANTITY > 





























