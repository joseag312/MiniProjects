--Dame una tabla que contenga las suma de las ventas del año presente y la suma de las ventas del siguiente año en cada fila, ademas de
--un porcentaje de crecimiento, un running total.

--Subquery
/*
SELECT  TotalSales = SUM(SalesAmount)
       ,TheYear = YEAR(Orderdate)
FROM    FactInternetSales
GROUP BY YEAR(Orderdate)
*/

--The upgraded subquey SQ
/*
SELECT  CurrentYear     = YEAR(F1.Orderdate)
       ,TotalSales      = SUM(F1.SalesAmount)
       ,AllSales        = (SELECT SUM(SalesAmount) FROM FactInternetSales)
       ,RunningTotal    = (SELECT SUM(SalesAmount) FROM FactInternetSales F2 WHERE YEAR(F2.Orderdate) <= YEAR(F1.Orderdate))
       ,NextYear        = YEAR(F1.Orderdate) + 1
       ,NxTotalSales    = (SELECT SUM(SalesAmount) FROM FactInternetSales F2 WHERE YEAR(F2.Orderdate) = (YEAR(F1.Orderdate) + 1))
FROM    FactInternetSales F1
GROUP BY YEAR(Orderdate)
ORDER BY YEAR(OrderDate)
*/
USE AdventureWorksDW2017
GO

SELECT  SQ.CurrentYear
       ,SQ.TotalSales
       ,SQ.AllSales
       ,PercentageSales = CAST(CAST((100 * SQ.TotalSales / SQ.AllSales) AS DECIMAL(5,2)) AS VARCHAR(6)) + '%'
       ,SQ.RunningTotal
       ,PercentageRT    = CAST(CAST((100 * SQ.RunningTotal / SQ.AllSales) AS DECIMAL(5,2)) AS VARCHAR(6)) + '%'
       ,SQ.NextYear
       ,SQ.NxTotalSales
FROM
(               SELECT  CurrentYear     = YEAR(F1.Orderdate)
                       ,TotalSales      = SUM(F1.SalesAmount)
                       ,AllSales        = (SELECT SUM(SalesAmount) FROM FactInternetSales)
                       ,RunningTotal    = (SELECT SUM(SalesAmount) FROM FactInternetSales F2 WHERE YEAR(F2.Orderdate) <= YEAR(F1.Orderdate))
                       ,NextYear        = YEAR(F1.Orderdate) + 1
                       ,NxTotalSales    = (SELECT SUM(SalesAmount) FROM FactInternetSales F2 WHERE YEAR(F2.Orderdate) = (YEAR(F1.Orderdate) + 1))
                FROM    FactInternetSales F1
                GROUP BY YEAR(Orderdate)
) SQ
ORDER BY SQ.CurrentYear

--Previous attempts

/*
SELECT  SUM(s1.SalesAmount) AS YearlySales
       ,s1Orderdate = YEAR(s1.Orderdate)
       ,S2.YearlySales
       ,S2.NextYear--SELECT *
FROM    FactInternetSales s1
        LEFT JOIN  (SELECT  SUM(SalesAmount) AS YearlySales
                           ,YEAR(Orderdate) AS NextYear
                     FROM FactInternetSales
                     GROUP BY YEAR(Orderdate)) s2
                ON   YEAR(s1.Orderdate) + 1 = s2.NextYear
GROUP BY YEAR(Orderdate)
        ,s2.NextYear
        ,s2.YearlySales
ORDER BY s1Orderdate

SELECT  a.TheYear
       ,a.TotalSales
       ,NextYear = LEAD(a.TheYear) OVER (ORDER BY a.TheYear ASC)
       ,TotalSales2 = LEAD(a.TotalSales) OVER (ORDER BY a.TheYear ASC)
FROM    (
            SELECT  TotalSales = SUM(SalesAmount)
                   ,TheYear = YEAR(Orderdate)
            FROM    FactInternetSales
            GROUP BY YEAR(Orderdate)
        ) a
ORDER BY a.TheYear
*/ 

