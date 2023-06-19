--------------------------------NO.1-------------------------------------------------------------------------------
--Retrieve information about the products with colour values except null, red, silver/black, white and list price between
--£75 and £750. Rename the column StandardCost to Price. Also, sort the results in descending order by list price. 
SELECT *
FROM Production.product
WHERE color NOT IN ('Red', 'White', 'Silver/Black', '')
 AND (ListPrice BETWEEN 75 AND 750)
ORDER BY ListPrice DESC

--------------------------------NO.2-------------------------------------------------------------------------------
--Find all the male employees born between 1962 to 1970 and with hire date greater than 2001 and female employees
--born between 1972 and 1975 and hire date between 2001 and 2002. 
SELECT *
FROM HumanResources.Employee
WHERE (Gender = 'M' AND YEAR(BirthDate) BETWEEN 1962 AND 1970 AND YEAR(HireDate) > 2001)
OR (Gender = 'F' AND YEAR(BirthDate) BETWEEN 1972 AND 1975 AND YEAR(HireDate) BETWEEN 2001 AND 2002)

--------------------------------NO.3-------------------------------------------------------------------------------
--Create a list of 10 most expensive products that have a product number beginning with ‘BK’. Include only the product
--ID, Name and colour. 
SELECT TOP (10) ProductID, Name, Color
FROM Production.Product
WHERE ProductNumber LIKE 'BK%'
ORDER BY ListPrice DESC

--------------------------------NO.4-------------------------------------------------------------------------------
--Create a list of all contact persons, where the first 4 characters of the last name are the same as the first four characters
--of the email address. Also, for all contacts whose first name and the last name begin with the same characters, create
--a new column called full name combining first name and the last name only. Also provide the length of the new
--column full name.
SELECT LastName,FirstName,EmailAddress, CONCAT(FirstName,' ',LastName) AS FullName, LEN(CONCAT(FirstName,' ',LastName)) AS LenOfFullName
FROM Person.EmailAddress AS PE
INNER JOIN Person.Person AS PP
ON PE.BusinessEntityID  = PP.BusinessEntityID
WHERE (Left(LastName,4) = LEFT(EmailAddress,4)) AND (LEFT(FirstName,1) = LEFT(LastName,1))

--------------------------------NO.5-------------------------------------------------------------------------------
--Return all product subcategories that take an average of 3 days or longer to manufacture. 
SELECT PROSUB.ProductSubcategoryID,DaysToManufacture,PROSUB.Name
FROM Production.Product AS PROP
INNER JOIN Production.ProductSubcategory AS PROSUB
ON PROP.ProductSubcategoryID  = PROSUB.ProductSubcategoryID
WHERE DaysToManufacture >= 3
ORDER BY PROSUB.Name

--------------------------------NO.6-------------------------------------------------------------------------------
--Create a list of product segmentation by defining criteria that places each item in a predefined segment as follows. If
--price gets less than £200 then low value. If price is between £201 and £750 then mid value. If between £750 and £1250
--then mid to high value else higher value. Filter the results only for black, silver and red color products. 
SELECT ProductID,ListPrice,Color, Name,
CASE 
WHEN ListPrice < 200 THEN 'Low Value'
WHEN ListPrice  BETWEEN 201 AND 750 THEN 'Mid Value'
WHEN ListPrice  BETWEEN 750 AND 1250 THEN 'Mid To High Value'
ELSE 'Higher Value'
END AS ProductSegmentation
FROM Production.Product
WHERE Color IN ('Black','Silver','Red')
ORDER BY ListPrice DESC

--SELECT JobTitle, COUNT(JobTitle) AS EmployeePerJobtitleCount
--FROM HumanResources.Employee
--GROUP BY JobTitle

--------------------------------NO.7-------------------------------------------------------------------------------
--How many Distinct Job title is present in the Employee table?
SELECT COUNT(DISTINCT JobTitle) AS unique_job_title_count
FROM HumanResources.Employee;

--------------------------------NO.8-------------------------------------------------------------------------------
--Use employee table and calculate the ages of each employee at the time of hiring. 
SELECT *,YEAR(BirthDate) AS BirthYear,YEAR(HireDate) as HireYear,BusinessEntityID,
((YEAR(HireDate))- (YEAR(BirthDate))) as AgeOf_Employment
FROM HumanResources.Employee
ORDER BY AgeOf_Employment

--------------------------------NO.9-------------------------------------------------------------------------------
--How many employees will be due a long service award in the next 5 years, if long service is 20 years?
SELECT *,
 CAST(DATEDIFF(DD, BirthDate, HireDate) / 365.25 AS INT) AS age_at_employment
FROM HumanResources.Employee
ORDER BY age_at_employment;
SELECT COUNT(*) AS long_service_award_winner 
FROM HumanResources.Employee
WHERE CAST(DATEDIFF(DD,HireDate,(DATEADD(YEAR,5,GetDate())))/365.25  as INT)= 20

---------------------------------NO.10-------------------------------------------------------------------------------
--How many more years does each employee have to work before reaching sentiment, if sentiment age is 65? 
SELECT  *,CAST(DATEDIFF(DD,BirthDate,HireDate)/365.25  as INT) AS HireAge,
65-(CAST(DATEDIFF(DD,BirthDate,HireDate)/365.25  as INT)) as YearsOfWorkBeforeSentinent
FROM HumanResources.Employee
ORDER BY YearsOfWorkBeforeSentinent


---------------------------------NO.11-------------------------------------------------------------------------------
--Implement new price policy on the product table base on the colour of the item
--If white increase price by 8%, If yellow reduce price by 7.5%, If black increase price by 17.2%. If multi, silver,
--silver/black or blue take the square root of the price and double the value. Column should be called Newprice. For
--each item, also calculate commission as 37.5% of newly computed list price.

SELECT Color, Name,ListPrice,

CASE
    WHEN Color = 'White' THEN ListPrice +(ListPrice * .08)
    WHEN Color = 'Yellow' THEN ListPrice - (ListPrice * .075)
	WHEN Color = 'Black' THEN ListPrice + (ListPrice * .172)
	WHEN Color IN ('Multi','Silver','Silver/Black','Blue') THEN  (SQRT(ABS(ListPrice)))*2    
ELSE ListPrice

END  AS NewPrice,
(CASE
	WHEN Color = 'White' THEN ListPrice +(ListPrice * .08)
	WHEN Color = 'Yellow' THEN ListPrice - (ListPrice * .075)
	WHEN Color = 'Black' THEN ListPrice + (ListPrice * .172)
	WHEN Color IN ('Multi','Silver','Silver/Black','Blue') THEN  (SQRT(ABS(ListPrice)))*2    
ELSE ListPrice
END ) * .375 as Commission
FROM Production.Product
WHERE Color IS NOT NULL AND ListPrice <> 0
ORDER BY NewPrice 

---------------------------------NO.12-------------------------------------------------------------------------------
--Print the information about all the Sales.Person and their sales quota. For every Sales person you should provide their
--FirstName, LastName, HireDate, SickLeaveHours and Region where they work. 

SELECT FirstName,LastName,SalesQuota,HireDate, SickLeaveHours,SST.Name,CountryRegionCode
FROM HumanResources.Employee AS HE
INNER JOIN Sales.SalesPerson AS SS
ON HE.BusinessEntityID = SS.BusinessEntityID
INNER JOIN Person.Person as PP
ON PP.BusinessEntityID = SS.BusinessEntityID
INNER JOIN Sales.SalesTerritoryHistory AS SSTH
ON SSTH.BusinessEntityID = SS.BusinessEntityID
INNER JOIN Sales.SalesTerritory as SST
ON SST.TerritoryID = SSTH.TerritoryID
ORDER BY FirstName

---------------------------------NO.13-------------------------------------------------------------------------------
--Using adventure works, write a query to extract the following information.
-- Product name
-- Product category name
-- Product subcategory name
-- Sales person
-- Revenue
-- Month of transaction
-- Quarter of transaction
-- Region 

SELECT PP.Name AS ProductName,PPC.Name AS ProductCategoryName, PPS.Name AS ProductSubCategoryName,
CONCAT(PERPE.FirstName,' ', PERPE.LastName) AS SalesPerson, SST.Name AS Region, 
DATENAME(MONTH,PTH.TransactionDate) AS MonthOfTransaction,
DATEPART(QUARTER,PTH.TransactionDate) AS QuarterOfTransaction, SUM(SSOD.OrderQty * SSOD.UnitPrice) AS Revenue
FROM HumanResources.Employee AS HE
INNER JOIN Sales.SalesPerson AS SSP
ON HE.BusinessEntityID = SSP.BusinessEntityID
INNER JOIN Person.Person AS PERPE
ON SSP.BusinessEntityID = PERPE.BusinessEntityID
INNER JOIN Sales.SalesTerritory AS SST
ON SSP.TerritoryID = SST.TerritoryID
INNER JOIN Sales.SalesOrderHeader AS SSOH
ON SST.TerritoryID = SSOH.TerritoryID
INNER JOIN Sales.SalesOrderDetail AS SSOD
ON SSOH.SalesOrderID = SSOD.SalesOrderID
INNER JOIN Production.TransactionHistory AS PTH
ON SSOD.ProductID = PTH.ProductID
INNER JOIN Production.Product AS PP
ON PTH.ProductID = PP.ProductID
INNER JOIN Production.ProductSubcategory AS PPS
ON PP.ProductSubcategoryID = PPS.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS PPC
ON PPS.ProductCategoryID = PPC.ProductCategoryID
GROUP BY  DATENAME(MONTH,PTH.TransactionDate),
PP.Name,
PPC.Name, PPS.Name,
CONCAT(PERPE.FirstName,' ', PERPE.LastName), SST.Name,
DATEPART(QUARTER,PTH.TransactionDate)

---------------------------------NO.14-------------------------------------------------------------------------------
--Display the information about the details of an order i.e. order number, order date, amount of order, which customer
--gives the order and which salesman works for that customer and how much commission he gets for an order.

SELECT  SSOH.SalesOrderNumber AS OrderNumber,SSOH.OrderDate,SSOH.TotalDue AS AmountOfOrder, 
SC.CustomerID,CONCAT(PERPE.FirstName,' ',PERPE.LastName) AS SalesMan,
TotalDue * CommissionPct AS CommissionForAnOrder
FROM Sales.SalesOrderDetail AS SSOD
INNER JOIN Sales.SalesOrderHeader AS SSOH
ON SSOD.SalesOrderID = SSOH.SalesOrderID
INNER JOIN Sales.Customer AS SC
ON SSOH.CustomerID = SC.CustomerID
INNER JOIN Sales.SalesPerson AS SSP
ON SC.TerritoryID = SSP.TerritoryID
INNER JOIN Person.Person AS PERPE
ON SSP.BusinessEntityID = PERPE.BusinessEntityID


---------------------------------NO.15-------------------------------------------------------------------------------
--For all the products calculate
--- Commission as 14.790% of standard cost,
--- Margin, if standard cost is increased or decreased as follows:
--Black: +22%,
--Red: -12%
--Silver: +15%
--Multi: +5%
--White: Two times original cost divided by the square root of cost
--For other colours, standard cost remains the same 

SELECT  Name as ProductName,Color,
CASE
WHEN Color = 'Black' THEN ListPrice-(StandardCost +(StandardCost * .22))
WHEN Color = 'Red' THEN ListPrice-(StandardCost -(StandardCost * .12))
WHEN Color = 'Silver' THEN ListPrice-(StandardCost +(StandardCost * .15))
WHEN Color = 'Multi' THEN ListPrice-(StandardCost +(StandardCost * .05))
WHEN Color = 'White' THEN ListPrice-((StandardCost * 2)/SQRT(ABS(StandardCost)))
ELSE ListPrice-StandardCost
END AS Margin,
StandardCost * .1479 AS Commission 
FROM Production.Product
WHERE StandardCost <> 0 AND Color IS NOT NULL
ORDER BY Color

---------------------------------NO.16-------------------------------------------------------------------------------
--Create a view to find out the top 5 most expensive products for each colour.

CREATE VIEW MostExpensiveProducts AS
SELECT Color,ListPrice,
ROW_NUMBER() OVER (PARTITION BY Color ORDER BY ListPrice DESC) AS RN
FROM Production.Product
SELECT * 
FROM MostExpensiveProducts
WHERE RN <=5




