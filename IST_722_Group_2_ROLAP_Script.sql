/****** Object:  Database ist722_hhkhan_ob2_dw    Script Date: 1/11/22 4:48:16 PM ******/
/*
Kimball Group, The Microsoft Data Warehouse Toolkit
Generate a database from the datamodel worksheet, version: 4

You can use this Excel workbook as a data modeling tool during the logical design phase of your project.
As discussed in the book, it is in some ways preferable to a real data modeling tool during the inital design.
We expect you to move away from this spreadsheet and into a real modeling tool during the physical design phase.
The authors provide this macro so that the spreadsheet isn't a dead-end. You can 'import' into your
data modeling tool by generating a database using this script, then reverse-engineering that database into
your tool.

Uncomment the next lines if you want to drop and create the database
*/
/*
DROP DATABASE ist722_hhkhan_ob2_dw
GO
CREATE DATABASE ist722_hhkhan_ob2_dw
GO
ALTER DATABASE ist722_hhkhan_ob2_dw
SET RECOVERY SIMPLE
GO
*/
USE ist722_hhkhan_ob2_dw
;
IF EXISTS (SELECT Name from sys.extended_properties where Name = 'Description')
    EXEC sys.sp_dropextendedproperty @name = 'Description'
EXEC sys.sp_addextendedproperty @name = 'Description', @value = 'Default description - you should change this.'
;

-- Create a schema to hold user views (set schema name on home page of workbook).
-- It would be good to do this only if the schema doesn't exist already.
--GO
--CREATE SCHEMA group_two
--GO

/* Drop table group_two.FactOrderFulfillment */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'group_two.FactOrderFulfillment') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE group_two.FactOrderFulfillment 
;

/* Create table group_two.FactOrderFulfillment */
CREATE TABLE group_two.FactOrderFulfillment (
   [ProductKey]  int   NOT NULL
,  [CustomerKey]  int   NOT NULL
,  [CarrierID]  nvarchar(50)    NOT NULL
,  [OrderDateKey]  int   NOT NULL
,  [ShippedDateKey]  int   NULL
,  [OrderID]  int   NOT NULL
,  [OrderToShipLagInDays]  int   NULL
, CONSTRAINT [PK_group_two.FactOrderFulfillment] PRIMARY KEY NONCLUSTERED (OrderID, ProductKey)
) ON [PRIMARY]
;

/* Drop table group_two.DimDate */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'group_two.DimDate') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE group_two.DimDate 
;

/* Create table group_two.DimDate */
CREATE TABLE group_two.DimDate (
   [DateKey]  int NOT NULL
,  [Date]  datetime   NULL
,  [FullDateUSA]  nchar(11)   NOT NULL
,  [DayOfWeek]  tinyint   NOT NULL
,  [DayName]  nchar(10)   NOT NULL
,  [DayOfMonth]  tinyint   NOT NULL
,  [DayOfYear]  int   NOT NULL
,  [WeekOfYear]  tinyint   NOT NULL
,  [MonthName]  nchar(10)   NOT NULL
,  [MonthOfYear]  tinyint   NOT NULL
,  [Quarter]  tinyint   NOT NULL
,  [QuarterName]  nchar(10)   NOT NULL
,  [Year]  int   NOT NULL
,  [IsWeekday]  bit  DEFAULT 0 NOT NULL
, CONSTRAINT [PK_group_two.DimDate] PRIMARY KEY CLUSTERED 
( [DateKey] )
) ON [PRIMARY]
;

INSERT INTO group_two.DimDate (DateKey, Date, FullDateUSA, DayOfWeek, DayName, DayOfMonth, DayOfYear, WeekOfYear, MonthName, MonthOfYear, Quarter, QuarterName, Year, IsWeekday)
VALUES (-1, '', 'Unk date', 0, 'Unk date', 0, 0, 0, 'Unk month', 0, 0, 'Unk qtr', 0, 0)
;

GO
UPDATE group_two.DimDate
SET Date = Null
WHERE DateKey = -1;
GO

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[group_two].[Date]'))
DROP VIEW [group_two].[Date]
GO
CREATE VIEW [group_two].[Date] AS 
SELECT [DateKey] AS [DateKey]
, [Date] AS [Date]
, [FullDateUSA] AS [FullDateUSA]
, [DayOfWeek] AS [DayOfWeek]
, [DayName] AS [DayName]
, [DayOfMonth] AS [DayOfMonth]
, [DayOfYear] AS [DayOfYear]
, [WeekOfYear] AS [WeekOfYear]
, [MonthName] AS [MonthName]
, [MonthOfYear] AS [MonthOfYear]
, [Quarter] AS [Quarter]
, [QuarterName] AS [QuarterName]
, [Year] AS [Year]
, [IsWeekday] AS [IsWeekday]
FROM group_two.DimDate
GO

/* Drop table group_two.DimProduct */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'group_two.DimProduct') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE group_two.DimProduct 
;

/* Create table group_two.DimProduct */
CREATE TABLE group_two.DimProduct (
   [ProductKey]  int IDENTITY  NOT NULL
,  [ProductID]  int   NOT NULL
,  [product_department]  varchar(20)   NOT NULL
,  [product_name]  varchar(200)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_group_two.DimProduct] PRIMARY KEY CLUSTERED 
( [ProductKey] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT group_two.DimProduct ON
;
INSERT INTO group_two.DimProduct (ProductKey, ProductID, product_department, product_name, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'Unk Department', 'Unk Product', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT group_two.DimProduct OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[group_two].[Product]'))
DROP VIEW [group_two].[Product]
GO
CREATE VIEW [group_two].[Product] AS 
SELECT [ProductKey] AS [ProductKey]
, [ProductID] AS [ProductID]
, [product_department] AS [product_department]
, [product_name] AS [product_name]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM group_two.DimProduct
GO

/* Drop table group_two.DimCustomer */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'group_two.DimCustomer') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE group_two.DimCustomer 
;

/* Create table group_two.DimCustomer */
CREATE TABLE group_two.DimCustomer (
   [CustomerKey]  int IDENTITY  NOT NULL
,  [CustomerID]  int   NOT NULL
,  [customer_city]  varchar(50)   NULL
,  [customer_state]  char(2)   NULL
,  [customer_zip]  varchar(10)   NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_group_two.DimCustomer] PRIMARY KEY CLUSTERED 
( [CustomerKey] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT group_two.DimCustomer ON
;
INSERT INTO group_two.DimCustomer (CustomerKey, CustomerID, customer_city, customer_state, customer_zip, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'Unknown City', 'ZZ', '00000-0000', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT group_two.DimCustomer OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[group_two].[Customer]'))
DROP VIEW [group_two].[Customer]
GO
CREATE VIEW [group_two].[Customer] AS 
SELECT [CustomerKey] AS [CustomerKey]
, [CustomerID] AS [CustomerID]
, [customer_city] AS [customer_city]
, [customer_state] AS [customer_state]
, [customer_zip] AS [customer_zip]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM group_two.DimCustomer
GO

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[group_two].[OrderFulfillment]'))
DROP VIEW [group_two].[OrderFulfillment]
GO
CREATE VIEW [group_two].[OrderFulfillment] AS 
SELECT [ProductKey] AS [ProductKey]
, [CustomerKey] AS [CustomerKey]
, [CarrierID]  AS  [CarrierID]
, [OrderDateKey] AS [OrderDateKey]
, [ShippedDateKey] AS [ShippedDateKey]
, [OrderID] AS [OrderID]
, [OrderToShipLagInDays] AS [OrderToShipLagInDays]
FROM group_two.FactOrderFulfillment
GO

ALTER TABLE group_two.FactOrderFulfillment ADD CONSTRAINT
   FK_group_two_FactOrderFulfillment_ProductKey FOREIGN KEY
   (
   ProductKey
   ) REFERENCES group_two.DimProduct
   ( ProductKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE group_two.FactOrderFulfillment ADD CONSTRAINT
   FK_group_two_FactOrderFulfillment_CustomerKey FOREIGN KEY
   (
   CustomerKey
   ) REFERENCES group_two.DimCustomer
   ( CustomerKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE group_two.FactOrderFulfillment ADD CONSTRAINT
   FK_group_two_FactOrderFulfillment_OrderDateKey FOREIGN KEY
   (
   OrderDateKey
   ) REFERENCES group_two.DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE group_two.FactOrderFulfillment ADD CONSTRAINT
   FK_group_two_FactOrderFulfillment_ShippedDateKey FOREIGN KEY
   (
   ShippedDateKey
   ) REFERENCES group_two.DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;