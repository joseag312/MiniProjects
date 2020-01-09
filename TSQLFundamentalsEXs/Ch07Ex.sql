USE TSQLV4;
GO

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
    orderid     INT         NOT NULL,
    orderdate   DATE        NOT NULL,
    empid       INT         NOT NULL,
    custid      VARCHAR(5)  NOT NULL,
    qty         INT         NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
  (30001, '20140802', 3, 'A', 10),
  (10001, '20141224', 2, 'A', 12),
  (10005, '20141224', 1, 'B', 20),
  (40001, '20150109', 2, 'A', 40),
  (10006, '20150118', 1, 'C', 14),
  (20001, '20150212', 2, 'B', 12),
  (40005, '20160212', 3, 'A', 10),
  (20002, '20160216', 1, 'C', 20),
  (30003, '20160418', 2, 'B', 15),
  (30004, '20140418', 3, 'C', 22),
  (30007, '20160907', 3, 'D', 30);

SELECT * FROM dbo.Orders

--Chapter 7:  Beyond the fundamentals of querying

--1 Write a query against the dbo.Orders table that computes both a rank and a dense rank for each customer
--  order, partitioned by custid and ordered by qty

SELECT  custid
       ,orderid
       ,qty
       ,RANK() OVER (PARTITION BY custid order by qty)
       ,DENSE_RANK() OVER (PARTITION BY custid order by qty)
FROM dbo.Orders

--2 Earlier in the chapter in the section "Ranking window functions", I provided the following query against
--  the Sales.OrderValues view to return distinct values and their associated row numbers:

/* 
SELECT val, ROW_NUMBER() OVER (ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;
*/

--  Can you think of an alternative way to achieve the same task?

SELECT  SQ.val
       ,rownum = 1 + (SELECT COUNT(*) 
                      FROM      (SELECT val
                                 FROM Sales.OrderValues
                                 GROUP BY val) AS SQ2 
                      WHERE SQ2.val < SQ.val)
FROM 
    (SELECT val
     FROM Sales.OrderValues
     GROUP BY val) AS SQ

--3 Write a query against the dbo.Orders table that computes for each customer order both the difference between
--  the current order quantity and the customer's previous order quantity and the difference between the current
--  order quantity and the customer's next order quantity.

SELECT  custid
       ,orderid
       ,qty
       ,diffprev = qty - LAG(qty) OVER (PARTITION BY custid ORDER BY custid, orderdate)
       ,diffnext = qty - LEAD(qty) OVER (PARTITION BY custid ORDER BY custid, orderdate)
FROM dbo.Orders

--4 Write a query against the dbo.Orders table that returns a row for each employee, a column for each order
--  year, and the count of orders for each employee and order year.

SELECT  empid
       ,cnt2014 = SUM(CASE WHEN YEAR(orderdate) = 2014 THEN 1 ELSE 0 END)
       ,cnt2015 = SUM(CASE WHEN YEAR(orderdate) = 2015 THEN 1 ELSE 0 END)
       ,cnt2016 = SUM(CASE WHEN YEAR(orderdate) = 2016 THEN 1 ELSE 0 END) 
FROM dbo.Orders
GROUP BY empid
ORDER BY empid

SELECT  empid
       ,[2014] AS cnt2014
       ,[2015] AS cnt2015
       ,[2016] AS cnt2016
FROM       (SELECT empid, YEAR(orderdate) AS orderyear, qty
            FROM dbo.Orders) AS O
  PIVOT (COUNT(qty) FOR orderyear IN ([2014], [2015], [2016])) AS P


--5 Run the following code to create and populate the EmpYearOrders table

USE TSQLV4;

DROP TABLE IF EXISTS dbo.EmpYearOrders;

CREATE TABLE dbo.EmpYearOrders
(
    empid INT NOT NULL
        CONSTRAINT PK_EmpYearOrders PRIMARY KEY,
    cnt2014 INT NULL,
    cnt2015 INT NULL,
    cnt2016 INT NULL,
);

INSERT INTO dbo.EmpYearOrders(empid, cnt2014, cnt2015, cnt2016)
    SELECT  empid
           ,[2014] AS cnt2014
           ,[2015] AS cnt2015
           ,[2016] AS cnt2016
    FROM (SELECT    empid
                   ,orderyear = YEAR(orderdate)
          FROM dbo.Orders) AS D
    PIVOT (COUNT(orderyear)
        FOR orderyear IN([2014], [2015], [2016])) AS P;

SELECT *
FROM dbo.EmpYearOrders;

--  Write a query against the EmpYearOrders table that unpivots the data, returning a row for each
--  employee and order year with the number of orders. Exclude rows in which the number of orders is
--  0 (in this example, employee 3 in the year 2015)

SELECT  empid
       ,orderyear
       ,numorders
FROM dbo.EmpYearOrders O
CROSS APPLY (VALUES (2014, cnt2014), (2015, cnt2015), (2016, cnt2016)) AS C(orderyear, numorders)
WHERE numorders <> 0;

--  Now write it prettily pls

SELECT  empid
       ,orderyear
       ,numorders
FROM dbo.EmpYearOrders AS O
  CROSS APPLY (VALUES(2014, cnt2014),
                     (2015, cnt2015),  
                     (2016, cnt2016)) AS C(orderyear,numorders)
WHERE numorders <> 0;

SELECT empid, numorders, orderyear
FROM dbo.EmpYearOrders
  UNPIVOT (numorders FOR orderyear IN (cnt2014, cnt2015, cnt2016)) AS U
WHERE numorders <> 0;

--6 Write a query against the dbo.Orders table that returns the total quantities for each of the
--  following (employee, customer, and orderyear), (employee and order year), and (customer and 
--  orderyear). Include a result column in the output that uniquely identifies the grouping set
--  with which the current row is associated.

SELECT *
FROM dbo.Orders

SELECT  groupingset = 0
       ,empid
       ,custid
       ,orderyear = YEAR(orderdate)
       ,sumqty = SUM(qty)
FROM dbo.Orders
GROUP BY empid, custid, YEAR(orderdate)

UNION ALL

SELECT  groupingset = 1
       ,empid
       ,custid  = NULL
       ,orderyear = YEAR(orderdate)
       ,sumqty = SUM(qty)
FROM dbo.Orders
GROUP BY empid, YEAR(orderdate)

UNION ALL

SELECT  groupingset = 2
       ,empid = NULL
       ,custid
       ,orderyear = YEAR(orderdate)
       ,sumqty = SUM(qty)
FROM dbo.Orders
GROUP BY custid, YEAR(orderdate)

SELECT  empid
       ,custid
       ,orderyear = YEAR(orderdate)
       ,sumqty = SUM(qty)
FROM dbo.Orders
GROUP BY
    GROUPING SETS
    (
        (empid, custid, YEAR(orderdate)),
        (custid, YEAR(orderdate)),
        (empid, YEAR(orderdate))
    )


SELECT  empid
       ,custid
       ,orderyear = YEAR(orderdate)
       ,sumqty = SUM(qty)
FROM dbo.Orders
GROUP BY CUBE (empid, custid, YEAR(orderdate))

EXCEPT

SELECT  empid
       ,custid
       ,orderyear = YEAR(orderdate)
       ,sumqty = SUM(qty)
FROM dbo.Orders
GROUP BY
    GROUPING SETS
    (
        (empid, custid, YEAR(orderdate)),
        (custid, YEAR(orderdate)),
        (empid, YEAR(orderdate))
    );


SELECT  empid
       ,custid
       ,orderyear = YEAR(orderdate)
       ,sumqty = SUM(qty)
FROM dbo.Orders
GROUP BY ROLLUP (YEAR(orderdate), empid, custid)

INTERSECT

SELECT  empid
       ,custid
       ,orderyear = YEAR(orderdate)
       ,sumqty = SUM(qty)
FROM dbo.Orders
GROUP BY
    GROUPING SETS
    (
        (empid, custid, YEAR(orderdate)),
        (custid, YEAR(orderdate)),
        (empid, YEAR(orderdate))
    );

SELECT  groupingset = GROUPING_ID(empid, custid, YEAR(orderdate))
       ,empid
       ,custid
       ,orderyear = YEAR(orderdate)
       ,sumqty = SUM(qty)
FROM dbo.Orders
GROUP BY
    GROUPING SETS
    (
        (empid, custid, YEAR(orderdate)),
        (custid, YEAR(orderdate)),
        (empid, YEAR(orderdate))
    )

DROP TABLE IF EXISTS dbo.Orders
DROP TABLE IF EXISTS dbo.EmpYearOrders
