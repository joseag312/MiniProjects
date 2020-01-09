USE TSQLV4
GO

--Chapter 4:  Subqueries

--1
SELECT  o1.orderid
       ,o1.orderdate
       ,o1.custid
       ,o1.empid
FROM    Sales.Orders o1
WHERE   orderdate = (SELECT MAX(o2.orderdate) FROM Sales.Orders o2)

--2 Write a query that returns all orders placed by the customer(s) who placed the highest number of orders. Note that more than one customer might have the same n...


--Get the result set without ordering by results in the subqueries
--Is it okay to use the order by clause in a multivalued subquery in order to filter results?
SELECT  o1.custid
       ,o1.orderid
       ,o1.orderdate
       ,o1.empid
FROM    Sales.Orders o1
WHERE   o1.custid IN (SELECT    o3.custid 
                      FROM      (   SELECT o2.custid
                                          ,ordercount = COUNT(o2.custid) 
                                    FROM  Sales.Orders o2
                                    GROUP BY o2.custid
                                ) o3 
                      WHERE     o3.ordercount = (  SELECT   MAX(ordercount) 
                                                   FROM     (SELECT o4.custid
                                                                   ,ordercount = COUNT(o4.custid)
                                                              FROM Sales.Orders o4 
                                                              GROUP BY o4.custid) o5
                                                )
                                )

SELECT  o1.custid
       ,o1.orderid
       ,o1.orderdate
       ,o1.empid
FROM    Sales.Orders o1
WHERE   o1.custid IN (  SELECT TOP 1 WITH TIES custid
                        FROM Sales.Orders o1
                        GROUP BY o1.custid
                        ORDER BY COUNT(*) DESC
                     )
SELECt  *
FROM    SAles.Orders a
        INNER JOIN (
            SELECT  custid
            FROM    Sales.Orders
            GROUP BY custid
            HAVING  COUNT(orderid) = (SELECT  MAX(cnt)
                                      FROM    (SELECT COUNT(orderid) AS cnt
                                               FROM    Sales.Orders
                                               GROUP BY custid) a)
                    ) b
        ON b.custid = a.custid


--3
SELECT E.empid
      ,E.firstName
      ,E.lastname
FROM   HR.Employees AS E
WHERE E.Empid NOT IN (  SELECT    O.empid
                    FROM      Sales.Orders O
                    WHERE     O.orderdate > '2016-05-01')

--4
SELECT DISTINCT C.country 
FROM            Sales.Customers C
WHERE           C.country NOT IN (SELECT E.country FROM HR.Employees E) 

--5

SELECT  O1.custid
       ,O1.orderid
       ,O1.orderdate
       ,O1.empid
FROM Sales.Orders O1
WHERE O1.orderdate = (SELECT MAX(O2.orderdate)
                      FROM Sales.Orders O2
                      WHERE O1.custid = O2.custid)
ORDER BY O1.custid

--6 Write a query that returns customers who placed orders in 2015 but not 2016

SELECT DISTINCT O1.custid
               ,C.companyname
FROM            Sales.Orders O1
                LEFT JOIN Sales.Customers C
                       ON O1.custid = C.custid
WHERE YEAR(orderdate) = 2015
      AND O1.custid NOT IN (SELECT O2.custid 
                            FROM Sales.Orders O2
                            WHERE YEAR(O2.orderdate) = 2016)

SELECT  C.custid
       ,C.companyname
FROM Sales.Customers AS C
WHERE EXISTS            (SELECT O.custid
                         FROM Sales.Orders AS O
                         WHERE     O.custid = C.custid
                                   AND YEAR(O.orderdate) = 2015)
      AND NOT EXISTS    (SELECT O.custid
                         FROM Sales.Orders AS O
                         WHERE     O.custid = C.custid
                                   AND YEAR(O.orderdate) = 2016)

--7 Write a query that returns customers who ordered product 12

SELECT  C.custid
       ,C.companyname
FROM    Sales.Customers C
WHERE EXISTS        (SELECT *
                     FROM Sales.Orders AS O
                     LEFT JOIN Sales.OrderDetails AS OD
                            ON O.orderid = OD.orderid
                     WHERE  O.custid = C.custid
                     AND    OD.productid = 12)
--Recursive exists damnn
SELECT  C.custid
       ,C.companyname
FROM    Sales.Customers C
WHERE EXISTS        (SELECT *
                     FROM Sales.Orders AS O
                     WHERE O.custid = C.custid
                           AND EXISTS (SELECT *
                                 FROM Sales.OrderDetails AS OD
                                 WHERE O.orderid = OD.orderid
                                       AND productid =12))

--8 Write a query that calculates a running-total quantity for each customer and month
SELECT  custid
       ,ordermonth
       ,qty
       ,runqty = SUM(qty) OVER (PARTITION BY custid ORDER BY ordermonth)
FROM Sales.CustOrders
ORDER BY custid

SELECT  custid
       ,ordermonth
       ,qty
       ,runqty = (SELECT SUM(qty) FROM Sales.CustOrders CO2 WHERE CO1.custid = CO2.custid AND CO2.ordermonth <= CO1.ordermonth)
FROM Sales.CustOrders CO1
ORDER BY custid

--9 Explain the difference between IN and EXISTS

/*
The IN operator checks whether the value is in a certain list and returns true if it finds a match, also, if a NULL value is
in the way, the NOT IN operator would return unknown if a value is not found (nxFALSE OR UNKNOWN yields unknown)

The EXISTS operator checks whether or not a value exists in a set of values as well, discarding NULLs altogether. But NOT
EXISTS returns true if a value is not found (two-valued logic) when there's a NULL in the set data.
*/

--10 Write a query that returns for each order the number of days that passed since the same customer's previous order,
--   to determine the recency among orders, use orderdate as the primary sort element and orderid as the tiebreaker

SELECT  custid
       ,orderdate
       ,orderid
       ,diff = DATEDIFF(dd, LAG(orderdate) OVER (PARTITION BY custid ORDER BY orderdate, orderid), orderdate)
FROM Sales.Orders

SELECT  custid
       ,orderdate
       ,orderid
       ,previousdate = DATEDIFF(dd, (SELECT MAX(O2.Orderdate) FROM Sales.Orders O2 WHERE O2.custid = O1.custid AND O2.orderdate < O1.orderdate), orderdate)
FROM Sales.Orders O1
ORDER BY custid, orderdate