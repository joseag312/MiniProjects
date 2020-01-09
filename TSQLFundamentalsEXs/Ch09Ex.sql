USE TSQLV4;
GO

--Chapter 9:  Temporal tables

--1 In this excercise, you create a system-versioned temporal table and identify it in SSMS.

--1.1 Create a system-versioned temporal table called Departments with and associated history table called 
--    DepartmentsHistory in the database TSQLV4. The table should have the following columns: deptid INT,
--    deptname VARCHAR(25), and mgrid INT, all disallowing NULLs. Also include columns called validfrom
--    validto that define the validity period of the row. Define those with precision zero (1 second), and
--    make them hidden.

CREATE TABLE dbo.Departments
(
    deptid              INT                                     NOT NULL
        CONSTRAINT PK_Departments PRIMARY KEY NONCLUSTERED,
    deptname            VARCHAR(25)                             NOT NULL,
    mgrid               INT                                     NOT NULL,
    validfrom           DATETIME2(0)
        GENERATED ALWAYS AS ROW START HIDDEN                    NOT NULL,
    validto             DATETIME2(0)
        GENERATED ALWAYS AS ROW END HIDDEN                      NOT NULL,
    PERIOD FOR SYSTEM_TIME (validfrom, validto),
    INDEX ix_Employees CLUSTERED (deptid, validfrom, validto)
)
WITH (SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.DepartmentsHistory));

--1.2 Browse the object tree in Object Explorer in SSMS, and identify the Departments table and its associated
--    history table.

--2 In this exercise, you'll modify data in the table called Departments. Note the point in time in UTC when you
--  submit each statement, and mark those as P1, P2, and so on. You can do so by invoking the SYSUTCDATETIME function
--  in the same batch in which you submit the modification. Another option is to query the Departments table and its
--  associated history table and to obtain the point int time from the validfrom and validto columns.

--2.1 Insert four rows to the table Departments with the following details, and note the time when you apply this insert
--    (call it P1):

INSERT INTO dbo.Departments (deptid, deptname, mgrid)
VALUES 
    (1, 'HR', 7),
    (2, 'IT', 5),
    (3, 'Sales', 11),
    (4, 'Marketing', 13)

SELECT SYSUTCDATETIME()

-- P1 = 2020-01-07 03:42:20.2179408

--2.2 In one transaction, update the name of department 3 to SAles and Marketing and delete department 4. Call the point in time
--    when the transaction starts P2:

BEGIN TRAN

UPDATE dbo.Departments
SET deptname = 'Sales and Marketing'
WHERE deptid = 3;

DELETE FROM dbo.Departments
WHERE deptid = 4;

SELECT SYSUTCDATETIME();

COMMIT TRAN

-- P2 = 2020-01-07 03:42:31.6971284

--2.3 Update the manager ID of department 3 to 13. Call the point in time when you apply this update P2.

SELECT SYSUTCDATETIME();

UPDATE dbo.Departments
SET mgrid = 13
WHERE deptid = 3;

-- P3 = 2020-01-07 03:42:45.5454508

--3 In this excercise, you'll query data from the table Departmens.

--3.1 Query the current state of the table Departments:

SELECT  *
FROM dbo.Departments;

--3.2 Query the state of the table Departments at a point in time after P2 and before P3:

SELECT *
FROM dbo.Departments
FOR SYSTEM_TIME AS OF '2020-01-07 03:27:53.0254683'

--3.3 Query the state of the table Departments in the period between P2 and P3. Be explicit
--    about the column names in the SELECT list, and include the validfrom and validto columns

SELECT deptid, deptname, mgrid, validfrom, validto
FROM dbo.Departments
FOR SYSTEM_TIME BETWEEN '2020-01-07 03:42:31.6971284' AND '2020-01-07 03:42:45.5454508'


--4 Drop the table Departments and its associated history table.

IF OBJECT_ID(N'dbo.Departments', N'U') IS NOT NULL
BEGIN
  IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Departments', N'U'), N'TableTemporalType') = 2
    ALTER TABLE dbo.Departments SET ( SYSTEM_VERSIONING = OFF );
  DROP TABLE IF EXISTS dbo.DepartmentsHistory, dbo.Departments;
END;