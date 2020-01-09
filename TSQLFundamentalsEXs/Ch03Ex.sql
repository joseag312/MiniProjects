USE TSQLV4
GO

--Chapter 3:  Joins

--1
SELECT  e.empid
       ,e.firstname
       ,e.lastname
       ,n.n
FROM    HR.Employees e
        CROSS JOIN dbo.Nums n
WHERE   n <= 5
ORDER BY n.n, e.empid


--1-2
SELECT  e.empid
       ,dt = DATEADD(day, n-1, CAST('20160612' AS DATE))
FROM    HR.Employees e
        CROSS JOIN dbo.Nums n
WHERE   n <= DATEDIFF(day,CAST('20160612' AS DATE), CAST('20160616' AS DATE)) + 1
ORDER BY empid, dt

--2
SELECT  Customers.custid
       ,Customers.companyname
       ,Orders.orderid
       ,Orders.orderdate
FROM    Sales.Customers
        INNER JOIN  Sales.Orders
                ON  Customers.custid = Orders.custid;


SELECT  C.custid
       ,C.companyname
       ,O.orderid
       ,O.orderdate
FROM    Sales.Customers AS C
        INNER JOIN  Sales.Orders AS O
                ON  C.custid = O.custid;

--3
SELECT  C.custid
       ,numorders   = COUNT(DISTINCT O.orderid)
       ,totalqty    = SUM(OD.qty)
FROM    Sales.Customers AS C
        LEFT JOIN   Sales.Orders AS O
               ON   C.custid = O.custid
        LEFT JOIN   Sales.OrderDetails AS OD
               ON   O.orderid = OD.orderid
--WHERE C.country = N'USA'
GROUP BY C.custid

SELECT  C.custid
       ,numorders   = COUNT(DISTINCT O.orderid)
       ,totalqty    = SUM(OD.qty)
FROM    Sales.Customers AS C
        INNER JOIN   Sales.Orders AS O
                ON   C.custid = O.custid
        INNER JOIN   Sales.OrderDetails AS OD
               ON   O.orderid = OD.orderid
--WHERE C.country = N'USA'
GROUP BY C.custid

SELECT  *
FROM    Sales.Customers a
WHERE   NOT EXISTS (SELECT  1
                    FROM    Sales.Orders
                    WHERE   custid = a.custid)

SELECT  *
FROM    Sales.Customers a
WHERE   a.custid NOT IN (SELECT  custid
                         FROM    Sales.Orders)

SELECT  a.*
FROM    Sales.Customers a
        LEFT JOIN Sales.Orders b
               ON b.custid = a.custid
WHERE   b.orderid IS NULL

--4
SELECT  C.custid
       ,C.companyname
       ,O.orderid
       ,O.orderdate
FROM    Sales.Customers C
        LEFT JOIN Sales.Orders O
               ON C.custid = O.custid

--5
SELECT  C.custid
       ,C.companyname
FROM    Sales.Customers C
        LEFT JOIN   Sales.Orders O
               ON   C.custid = O.custid
WHERE   O.orderid IS NULL

--6
SELECT  C.custid
       ,C.companyname
       ,O.orderid
       ,O.orderdate
FROM    Sales.Customers C
        INNER JOIN  Sales.Orders O
                ON  C.custid = O.custid
WHERE   O.orderdate = CAST('2016-02-12' AS DATE)

--7
SELECT  C.custid
       ,C.companyname
       ,O.orderid
       ,O.orderdate
FROM    Sales.Customers C
        LEFT JOIN  Sales.Orders O
               ON  C.custid = O.custid
              AND  O.orderdate = CAST('2016-02-12' AS DATE)

--8
--The where clause is processed after the FROM clause, therefore, the fact that orderid is a primary key
--and therefore not nullable, filtering applied by the where clause has no effect on the table and the outer join is treated as
--an inner join. The filtering conditions also remove rows which weren't placed in said date, or are nulls, which are filtered after
--putting the information from both tables together, which was never what we wanted in the first place

--9
SELECT  C.custid
       ,C.companyname
       ,HasOrderOn20160212 = CASE
                               WHEN o.orderdate = CAST('2016-02-12' AS DATE) THEN 'Yes'
                               ELSE 'No'
                             END
FROM    Sales.Customers C
        LEFT JOIN  Sales.Orders O
               ON  C.custid = O.custid
              AND  O.orderdate = CAST('2016-02-12' AS DATE);

--Todos los clientes que tienen al menos una orden en general, muestrame la cantidad de ordenes despues del 2016
SELECT  C.custid
       ,Ordendpsdel16 = COUNT(CASE 
                                WHEN O.orderdate >= '2016-01-01' THEN O.orderid
                                ELSE NULL
                              END)
FROM    Sales.Customers C
        INNER JOIN  Sales.Orders O
                ON  C.custid = O.custid
GROUP BY C.custid;

SELECT  C.custid
       ,Ordendpsdel16 = SUM(CASE 
                                WHEN O.orderdate >= '2016-01-01' THEN 1
                                ELSE 0
                              END)
FROM    Sales.Customers C
        INNER JOIN  Sales.Orders O
                ON  C.custid = O.custid
GROUP BY C.custid;





