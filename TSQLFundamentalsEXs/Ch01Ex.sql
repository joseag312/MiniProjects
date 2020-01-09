USE TSQLV4;

DROP TABLE IF EXISTS dbo.Employees;

CREATE TABLE dbo.Employees
(
    empid       INT             NOT NULL,
    firstname   VARCHAR(30)     NOT NULL,
    lastname    VARCHAR(30)     NOT NULL,
    hiredate    DATE            NOT NULL,
    mgrid       INT             NULL,
    ssn         VARCHAR(20)     NOT NULL,
    salary      MONEY           NOT NULL
);

ALTER TABLE dbo.Employees
    ADD CONSTRAINT  PK_Employees
    PRIMARY KEY(empid);

ALTER TABLE dbo.Employees
    ADD CONSTRAINT  UNQ_EMployees
    UNIQUE(ssn);

CREATE UNIQUE INDEX idx_ssn_notnull ON dbo.Employees(ssn) WHERE ssn IS NOT NULL;

IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;
--DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
    orderid     INT             NOT NULL,
    empid       INT             NOT NULL,
    custid      VARCHAR(10)     NOT NULL,
    orderts     DATETIME2       NOT NULL,
    qry         INT             NOT NULL,
    CONSTRAINT  PK_Orders       PRIMARY KEY(orderid)
);

ALTER TABLE dbo.Orders
    ADD CONSTRAINT FK_Orders_Employees
    FOREIGN KEY(empid)
    REFERENCES dbo.Employees(empid);

ALTER TABLE dbo.Employees
    ADD CONSTRAINT FK_Employees_Employees
    FOREIGN KEY(mgrid)
    REFERENCES dbo.Employees(empid);
--What happens with the employees when we perform a delete with the ON DELETE SET NULL Operation
--Having the PRIMARY KEY CONSTRAINT on empid.

ALTER TABLE dbo.Employees
    ADD CONSTRAINT CHK_Employees_salary
    CHECK(salary > 0.00);

ALTER TABLE dbo.Orders
    ADD CONSTRAINT DFT_Orders_orderts
    DEFAULT(SYSDATETIME()) FOR Orderts;

DROP TABLE IF EXISTS dbo.Orders, dbo.Employees