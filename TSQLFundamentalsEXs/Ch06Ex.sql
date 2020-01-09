USE TSQLV4;
GO

--Chapter 6:  Set operators

--1 Explain the difference between the UNION ALL and UNION operators. In what cases are the two
--  equivalent? When they are equivalent, which one should you use?

/*
The UNION ALL operator does not apply a distinct filter on the rows, whereas the UNION operator
does, meaning that after the sets are added, the UNION operator will discard duplicates, and the
UNION ALL won't.

You should use the UNION operator when you are trying to unify the results and the UNION ALL when 
attempting to preserve all data. By default also use UNION ALL to avoid performance penalties.
*/

--2 Write a query that generates a virtual auxiliary table of 10 numbers in the range 1 through
--  10 without using a looping construct. You do not need to guarantee any order of the rows in
--  the output of your solution.

SELECT 1 as n
UNION ALL
SELECT 2
UNION ALL
SELECT 3
UNION ALL
SELECT 4
UNION ALL
SELECT 5
UNION ALL
SELECT 6
UNION ALL
SELECT 7
UNION ALL
SELECT 8
UNION ALL
SELECT 9
UNION ALL
SELECT 10

--3 Write a query that returns customer and employee pairs that had order activity in January
--  2016 but not in February 2016

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '2016-01-01'
  AND orderdate < '2016-02-01'
EXCEPT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '2016-02-01'
  AND orderdate < '2016-03-01'

--4 Write a query that returns customer and employee pairs that had order activity in both January
--  2016 and February 2016

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '2016-01-01'
  AND orderdate < '2016-02-01'
INTERSECT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '2016-02-01'
  AND orderdate < '2016-03-01'

--5 Write a query that returns customer and employee pairs that had order activity in both January
-- 2016 and February 2016 but not in 2015.

(SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '2016-01-01'
  AND orderdate < '2016-02-01'

INTERSECT

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '2016-02-01'
  AND orderdate < '2016-03-01')

EXCEPT

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '2015-01-01'
  AND orderdate < '2016-01-01'

--6 You are given the following query

SELECT country, region, city
FROM HR.Employees

UNION ALL

SELECT country, region, city
FROM Production.Suppliers

--  You are asked to add logic to the query so that it guarantees that the rows from Employees are
--  returned in the output before the rows from Suppliers. Also, within each segment, the rows should
--  be sorted by country, region, and city

SELECT  SQ.country
       ,SQ.region
       ,SQ.city
FROM
(
            SELECT  country
                   ,region
                   ,city
                   ,segment = (SELECT 1)
            FROM HR.Employees
            UNION ALL
            SELECT  country
                   ,region
                   ,city
                   ,segment = (SELECT 2)
            FROM Production.Suppliers
) SQ
ORDER BY segment, country, region, city

