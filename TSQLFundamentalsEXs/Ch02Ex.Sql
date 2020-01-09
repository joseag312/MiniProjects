USE TSQLV4
GO

--Chapter 2:  Single query exercises

--1
SELECT  orderid
       ,orderdate
       ,custid
       ,empid
FROM Sales.Orders
WHERE orderdate >= '20150601' AND orderdate < '20150630';

--2
SELECT  orderid
       ,orderdate
       ,custid
       ,empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);

--Use DATE DIFF
SELECT      empid
           ,orderdate
           ,custid
FROM    Sales.Orders
WHERE   orderdate = DATEADD(month, DATEDIFF(month, '18991231', orderdate), '18991231');

--3
SELECT  empid   
       ,firstname
       ,lastname
FROM HR.Employees
WHERE (LEN(lastname) - LEN(REPLACE(lastname, 'e', ''))) >= 2;

SELECT  empid
       ,firstname
       ,lastname
FROM HR.Employees
WHERE lastname LIKE '%e%e%';

--4
SELECT  orderid
       ,totalvalue = SUM(unitprice*qty)
FROM Sales.OrderDetails
GROUP by orderid
HAVING SUM(unitprice*qty) > 10000.00
ORDER BY totalvalue DESC;

--5
SELECT name, description
FROM sys.fn_helpcollations()
WHERE name LIKE '%Latin%';

SELECT  empid
       ,lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_BIN LIKE '[a-z]%';

SELECT empid, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%';

--6
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20160501'
GROUP BY empid;

SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20160501'

--The where clause is a row filter whereas the having clause is a group filter,
--the first query shows the amount of orders by employee before May 05, 2016,
--but the second query shows amount of orders by employees who didn't have an
--order before May 05, 2016

--7
SELECT TOP 3    shipcountry
               ,avgfreight      =   AVG(freight)
FROM Sales.Orders
WHERE orderdate BETWEEN '20150101' AND '20151231'
GROUP BY shipcountry
ORDER BY AVG(freight) DESC

--8

SELECT  custid
       ,orderdate
       ,orderid
       ,rownum = ROW_NUMBER() OVER (PARTITION BY custid ORDER BY orderdate, orderid)
FROM Sales.Orders

--9

SELECT  empid
       ,firstname
       ,lastname
       ,titleofcourtesy
       ,gender  =   CASE
                      WHEN titleofcourtesy IN (N'Ms.', N'Mrs.') THEN 'Female'
                      WHEN titleofcourtesy  = N'Mr.' THEN 'Male'
                      ELSE 'Unknown'
                    END
FROM HR.Employees
ORDER BY empid

SELECT  empid
       ,firstname
       ,lastname
       ,titleofcourtesy
       ,gender  =   CASE titleofcourtesy
                      WHEN  N'Ms.'  THEN 'Female'
                      WHEN  N'Mrs.' THEN 'Female'
                      WHEN  N'Mr.'  THEN 'Male'
                      ELSE  'Unknown'
                    END
FROM HR.Employees
ORDER BY empid

--10
SELECT custid 
      ,region
FROM Sales.Customers
ORDER BY CASE WHEN region IS NULL THEN 1
              ELSE 0
         END


--Chapter 3: Joins

--1
