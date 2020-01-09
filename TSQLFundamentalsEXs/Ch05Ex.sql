USE TSQLV4;
GO

--Chapter 5:  Table expressions

--1
/*
SELECT  orderid
       ,orderdate
       ,custid
       ,empid
       ,endofyear = DATEFROMPARTS(YEAR(orderdate), 12, 31)
FROM Sales.Orders
WHERE orderdate <> endofyear;

The problem with this query is that in the WHERE statement, we refer to the endofyear column alias when it
hasn't been created yet. Viable options would be to apply the filter directly to the WHERE statement,
using the query as a subquery and then referring to the column alias and using a correlated subquery

*/

--Apply the filter directly

SELECT  orderid
       ,orderdate
       ,custid
       ,empid
       ,endofyear = DATEFROMPARTS(YEAR(orderdate), 12, 31)
FROM Sales.Orders
WHERE orderdate <> DATEFROMPARTS(YEAR(orderdate), 12, 31);

--Use the query as a subquery and then apply the filter

SELECT  SQ.orderid
       ,SQ.orderdate
       ,SQ.custid
       ,SQ.empid
FROM
(
        SELECT  orderid
               ,orderdate
               ,custid
               ,empid
               ,endofyear = DATEFROMPARTS(YEAR(orderdate), 12, 31)
        FROM Sales.Orders
) SQ
WHERE SQ.orderdate <> SQ.endofyear

--Using a correlated query

SELECT  O1.orderid
       ,O1.orderdate
       ,O1.custid
       ,O1.empid
FROM Sales.Orders O1
WHERE O1.orderdate <> ( SELECT DATEFROMPARTS(YEAR(O2.orderdate), 12, 31)
                    FROM Sales.Orders O2
                    WHERE O2.orderid = O1.orderid)

/*
Query execution plan shows that both for using a subquery and applying the filter directly, we obtaing the
same execution plan, a clustered index scan followed by a filter; whereas in the correlated query the database
engine finds it suitable to compute a join following the clustered index scan for both que outer and inner query.
*/

--2-1 Write a query that returns the maximum value in the orderdate column for each employee

SELECT  empid
       ,maxorderdate = MAX(orderdate)
FROM Sales.Orders
GROUP BY empid

--2-2 Encapsulate the query from Ex 2-1 in a derived table. Write a join query between the derived table and the
--    orders table to return the orders with the maximum orderdate for each employee

--NOTE You can filter since the INNER JOIN FILTER, as shown in query NO 2.

SELECT  O1.empid
       ,O1.maxorderdate
       ,O2.orderid
       ,O2.custid
FROM   (SELECT  empid
               ,maxorderdate = MAX(orderdate)
        FROM Sales.Orders
        GROUP BY empid) O1
        INNER JOIN Sales.Orders O2
                ON O1.empid = O2.empid
WHERE O1.maxorderdate = O2.orderdate

SELECT  O1.empid
       ,O1.maxorderdate
       ,O2.orderid
       ,O2.custid
FROM   (SELECT  empid
               ,maxorderdate = MAX(orderdate)
        FROM Sales.Orders
        GROUP BY empid) O1
        INNER JOIN Sales.Orders O2
                ON O1.empid = O2.empid
               AND O1.maxorderdate = O2.orderdate

--3-1 Write a query that calculates a row number for each order based on orderdate, orderid ordering

SELECT  orderid
       ,orderdate
       ,custid
       ,empid
       ,rownum = DENSE_RANK() OVER (ORDER BY orderdate, orderid)
FROM Sales.Orders

--3-2 Write a query that returns rows with row numbers 11 through 20 based on the row number definition in exercise 3-1

SELECT  orderid
       ,orderdate
       ,custid
       ,empid
       ,rownum
FROM (SELECT orderid
            ,orderdate
            ,custid
            ,empid
            ,rownum = DENSE_RANK() OVER (ORDER BY orderdate, orderid)
     FROM Sales.Orders) SQ
WHERE rownum BETWEEN 11 AND 20

--4 Write a solution using a recursive CTE that returns the management chain leading to Patricia Doyle (empid = 9)
--  I additionaly added a TVF for calling such function.

USE TSQLV4;
DROP FUNCTION IF EXISTS dbo.GetChainofcmd;
GO

CREATE FUNCTION dbo.GetChainofcmd
    (@empid AS INT) RETURNS TABLE
AS
RETURN
WITH Chainofcmd AS 
(
SELECT  empid
       ,mgrid
       ,firstname
       ,lastname
FROM HR.Employees
WHERE empid = @empid

UNION ALL

SELECT  C.empid
       ,C.mgrid
       ,C.firstname
       ,C.lastname
FROM Chainofcmd as P
     INNER JOIN HR.Employees AS C
             ON P.mgrid = C.empid
)
SELECT empid, mgrid, firstname, lastname
FROM Chainofcmd
GO

SELECT  empid
       ,mgrid
       ,firstname
       ,lastname
FROM dbo.GetChainofcmd(9) AS C;

--5-1 Create a view that returns the total quantity for each employee and year

DROP VIEW IF EXISTS Sales.VEmpOrders;
GO

CREATE VIEW Sales.VEmpOrders
AS

SELECT  O.empid
       ,orderyear = YEAR(orderdate)
       ,qty = SUM(OD.qty)
FROM Sales.Orders O
INNER JOIN Sales.OrderDetails OD
        ON O.orderid = OD.orderid
GROUP BY O.empid, YEAR(orderdate);
GO

SELECT * FROM Sales.VEmpOrders ORDER BY empid, orderyear

--5-2 Write a query agains Sales.VEmpOrders that returns the running total quantity for each employee and year

SELECT  empid
       ,orderyear
       ,qty
       ,runqty = SUM(qty) OVER (PARTITION BY empid ORDER BY empid, orderyear)
FROM Sales.VEmpOrders

--6-1 Create an inline TVF that accepts as inputs a supplied ID (@supid AS INT) and a requested number of
--    products (@n as INT). The function should return @n products with the highest unit prices that are
--    supplied by the specified supplier ID:

DROP FUNCTION IF EXISTS Production.TopProducts;
GO

CREATE FUNCTION Production.TopProducts
    (@supid AS INT
    ,@n     AS INT)
RETURNS TABLE
AS
RETURN
SELECT TOP (@n) productid
               ,productname
               ,unitprice
FROM Production.Products
WHERE supplierid = @supid
ORDER BY unitprice DESC;
GO

CREATE PROC tonto
AS
SELECT 1
EXEC ('CREATE OR ALTER PROC tonto2 AS SELECT 2')
GO

SELECT  *  FROM Production.TopProducts(5, 2);

--6-2 Using the CROSS APPLY operator and the fucntion you created in Ex 6-1, return the two most expensive
--    products for each supplier:

SELECT TOP 10 * FROM Production.TopProducts(5, 2)
SELECT TOP 10 * FROM Production.Suppliers
SELECT  S.supplierid
       ,S.companyname
       ,TP.productid
       ,TP.productname
       ,TP.unitprice
FROM Production.Suppliers S
CROSS APPLY (   SELECT  productid
                       ,productname
                       ,unitprice
                FROM Production.TopProducts(S.supplierid, 2)) TP

SELECT  S.supplierid
       ,S.companyname
       ,TP.productid
       ,TP.productname
       ,TP.unitprice
FROM Production.Suppliers S
CROSS APPLY Production.TopProducts(S.supplierid, 2) TP


SELECT  S.supplierid
       ,S.companyname
       ,TP.productid
       ,TP.productname
       ,TP.unitprice
FROM    Production.Suppliers S
        CROSS APPLY (
                        SELECT  TOP 2
                                productid
                                ,productname
                                ,unitprice
                        FROM    Production.Products
                        WHERE   supplierid = S.supplierid
                        ORDER BY unitprice DESC
                    ) TP