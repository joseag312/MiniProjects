USE TSQLV4;
GO

--Chapter 8:  Data modification

--1 Run the following code to create the dbo.Customers table in the TSQLV4 database:

DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers
(
    custid              INT             NOT NULL PRIMARY KEY,
    companyname         NVARCHAR(40)    NOT NULL,
    country             NVARCHAR(15)    NOT NULL,
    region              NVARCHAR(15)    NULL,
    city                NVARCHAR(15)    NOT NULL
);

SELECT * FROM dbo.Customers;

--1.1 Insert into the dbo.Customers table a row with the following information:
--      custid: 100
--      companyname: Coho Winery
--      country: USA
--      region: WA
--      city: Redmond

INSERT INTO dbo.Customers
VALUES (100, N'Coho Winery', N'USA', N'WA', N'Redmond');

SELECT * FROM dbo.Customers;

-- ERROR, Use EXISTS Statement or a subquery, this produces a cartesian product remember!
/*INSERT INTO dbo.Customers (custid, companyname, country, region, city)
SELECT  C.custid, 
        C.companyname, 
        C.country, 
        C.region, 
        C.city
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
        ON C.custid = O.custid;*/

INSERT INTO dbo.Customers (custid, companyname, country, region, city)
SELECT  C.custid, 
        C.companyname, 
        C.country, 
        C.region, 
        C.city
FROM Sales.Customers AS C
WHERE EXISTS (SELECT * FROM Sales.Orders AS O WHERE C.custid = O.custid);

SELECT * FROM dbo.Customers;

DROP TABLE IF EXISTS dbo.Orders;

SELECT  orderid
       ,custid
       ,empid
       ,orderdate
       ,requireddate
       ,shippeddate
       ,shipperid
       ,freight
       ,shipname
       ,shipaddress
       ,shipcity
       ,shipregion
       ,shippostalcode
       ,shipcountry
INTO dbo.Orders
FROM Sales.Orders
WHERE orderdate > '2014-01-01' AND orderdate < '2017-01-01';

--2 Delete from the dbo.Orders table orders that were placed before August 2014. Use the OUTPUT clause
--  to return the orderid and orderdate values of the deleted orders:

DELETE FROM dbo.Orders
OUTPUT  deleted.orderid,
        deleted.orderdate
WHERE orderdate < '2014-08-01'

--3 Delete from the dbo.Orders table orders placed by customers from Brazil

DELETE FROM O
FROM dbo.Orders AS O
  INNER JOIN Sales.Customers AS C
          ON O.custid = C.custid
WHERE C.country = N'Brazil'

DELETE FROM dbo.Orders 
WHERE EXISTS (  SELECT * 
                FROM Sales.Customers AS C 
                WHERE   dbo.Orders.custid = c.custid 
                   AND  c.country = N'Brazil'         );

MERGE INTO dbo.Orders AS O
USING (SELECT * FROM Sales.Customers AS C WHERE C.country = N'Brazil') AS SQ
ON O.custid = SQ.custid
WHEN MATCHED THEN
    DELETE;

--4 Run the following query against dbo.Customers, and notice that some rows have a null in the region column:

DROP TABLE IF EXISTS dbo.Customers

SELECT *
INTO dbo.Customers
FROM Sales.Customers AS C
WHERE EXISTS (SELECT * FROM Sales.Orders AS O WHERE C.custid = O.custid)

SELECT * FROM dbo.Customers

UPDATE dbo.Customers
SET region = N'<None>'
OUTPUT  inserted.custid AS custid,
        deleted.region  AS oldregion,
        inserted.region AS newregion
WHERE region IS NULL

--5 Update all orders in the dbo.Orders table that were placed by United Kingdom customers, and set their shipcountry,
--  shipregion, and shipcity values to the country, region, and city values of the corresponding customers

UPDATE dbo.Orders
SET shipcountry = C.country,
    shipregion  = C.region,
    shipcity    = C.city
FROM dbo.Orders AS O
INNER JOIN dbo.Customers AS C
        ON O.custid = C.custid
WHERE C.country = N'UK';

WITH myCTE AS 
(
SELECT  newcountry      = C.country
       ,oldcountry      = O.shipcountry
       ,newregion       = C.region
       ,oldregion       = O.shipregion
       ,newcity         = C.city
       ,oldcity         = O.shipcity
FROM dbo.Orders AS O
INNER JOIN dbo.Customers AS C
        ON O.custid = C.custid
WHERE C.country = N'UK'
)
UPDATE myCTE
SET oldcountry = newcountry, oldregion = newregion, oldcity = newcity;

--6 Run the following code to create the tables Orders and OrderDetails and populate them with data:

USE TSQLV4;

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

CREATE TABLE dbo.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES dbo.Orders(orderid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

--  Write and test the T-SQL code that is required to truncate both tables and make sure your code runs
--  successfully.

ALTER TABLE dbo.OrderDetails
DROP CONSTRAINT FK_OrderDetails_Orders

TRUNCATE TABLE dbo.OrderDetails
TRUNCATE TABLE dbo.Orders

ALTER TABLE dbo.OrderDetails
ADD CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid) 
    REFERENCES dbo.Orders(orderid)


DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders, dbo.Customers