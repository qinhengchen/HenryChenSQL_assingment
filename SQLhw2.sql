/*1.What is a result set?
 A result set is the output of a query. 

2.What is the difference between Union and Union All?
The only difference between Union and Union All is that Union extracts the rows that are being specified in the query 
while Union All extracts all the rows including the duplicates (repeated values) from both the queries.

3.What are the other Set Operators SQL Server has?
union, union all, intersect and except 

4.What is the difference between Union and Join?
Both joins and unions can be used to combine data from one or more tables into a single result. They both go about this is different ways.
Whereas a join is used to combine columns from different tables, the union is used to combine rows.

5.What is the difference between INNER JOIN and FULL JOIN?
Inner join returns only the matching rows between both the tables, non-matching rows are eliminated. 
Full Join or Full Outer Join returns all rows from both the tables (left & right tables), including non-matching rows from both the tables.

6.What is difference between left join and outer join
Left Outer Join: Returns all the rows from the LEFT table and matching records between both the tables. Right Outer Join: Returns all the rows from the RIGHT table and matching records between both the tables. 
Full Outer Join: It combines the result of the Left Outer Join and Right Outer Join.

7.What is cross join?
A cross join is a type of join that returns the Cartesian product of rows from the tables in the join. In other words, 
it combines each row from the first table with each row from the second table.

8.What is the difference between WHERE clause and HAVING clause?
WHERE Clause is used to filter the records from the table based on the specified condition.
HAVING Clause is used to filter record from the groups based on the specified condition.

--9.Can there be multiple group by columns?
--yes*/


--1.How many products can you find in the Production.Product table?

select count(distinct(name))
from Production.Product
--2.Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory.
--The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.

select count(name)
from Production.Product
where name in
(select name from
Production.Product
where ProductSubcategoryID is Not null)

--3.How many Products reside in each SubCategory? Write a query to display the results with the following titles.
--ProductSubcategoryID CountedProducts
select ProductSubcategoryID, count(ProductID) as CountedProducts
from Production.Product
group by ProductSubcategoryID
having ProductSubcategoryID is Not null

--4.How many products that do not have a product subcategory. 
select ProductSubcategoryID, count(ProductID) as CountedProducts
from Production.Product
group by ProductSubcategoryID
having ProductSubcategoryID is  null

--5.Write a query to list the sum of products quantity in the Production.ProductInventory table.

select sum(quantity) 
from Production.ProductInventory
--6.Write a query to list the sum of products in the Production.ProductInventory table 
-- and LocationID set to 40 and limit the result to include just summarized quantities less than 100.
select ProductID, sum(quantity) as Thesum
from Production.ProductInventory
where LocationID = 40
group by ProductID
having sum(quantity)<100 
--7.Write a query to list the sum of products with the shelf information in the Production.ProductInventory table 
-- and LocationID set to 40 and limit the result to include just summarized quantities less than 100

select shelf, ProductID,sum(quantity) as TheSum
from Production.ProductInventory
where LocationID = 40
group by ProductID, SHELF
having sum(quantity)<100 

--8.Write the query to list the average quantity for products 
-- where column LocationID has the value of 10 from the table Production.ProductInventory table.

select ProductID,AVG(quantity) 
from Production.ProductInventory
where LocationID = 10
group by ProductID

--9.Write query  to see the average quantity  of  products by shelf  from the table Production.ProductInventory
select shelf, ProductID,AVG(quantity) TheAvg
from Production.ProductInventory
group by ProductID,shelf

--10.Write query  to see the average quantity  of  products by shelf 
--excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory

select shelf, ProductID,AVG(quantity) TheAvg
from Production.ProductInventory
where shelf in
(select shelf from Production.ProductInventory
where shelf != 'N/A')

group by ProductID,shelf
--11.List the members (rows) and average list price in the Production.Product table. 
--This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null.

select color, class,count(* )as thecount, avg(ListPrice)AvgPrice
FROM Production.Product
WHERE ProductID in
(select ProductID from Production.Product
where Color is not null and class is not null )
group by Color , Class

--12.  Write a query that lists the country and province names from 
-- person. CountryRegion and person. StateProvince tables. 
--Join them and produce a result set similar to the following. 
select * FROM person.CountryRegion
SELECT * FROM person. StateProvince
select pc.name,ps.name
from person.CountryRegion as pc
inner join 
person. StateProvince as ps
on pc.CountryRegionCode = ps.CountryRegionCode

--13.Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables 
--and list the countries filter them by Germany and Canada. 
--Join them and produce a result set similar to the following.

select pc.name,ps.name
from person.CountryRegion as pc
inner join 
person. StateProvince as ps
on pc.CountryRegionCode = ps.CountryRegionCode
where pc.name in ('Germany' , 'Canada')





--14.List all Products that has been sold at least once in last 25 years.

select  distinct (p.ProductName)
from orders as o
inner join [Order Details] as od
on o.OrderID = od.OrderID
inner join products as p
on p.ProductID = od.ProductID
WHERE year(getdate())- year(o.OrderDate) <=25
order by p.ProductName

--15.List top 5 locations (Zip Code) where the products sold most.


select top 5 ShipPostalCode from(
select  o.ShipPostalCode, sum(od.Quantity) as num
from orders as o
inner join [Order Details] as od
on o.OrderID = od.OrderID
inner join products as p
on p.ProductID = od.ProductID
group by o.ShipPostalCode
) as cte
where ShipPostalCode is not null
order by num desc


--16.List top 5 locations (Zip Code) where the products sold most in last 25 years.

select top 5 ShipPostalCode from(
select  o.ShipPostalCode, sum(od.Quantity) as num
from orders as o
inner join [Order Details] as od
on o.OrderID = od.OrderID
inner join products as p
on p.ProductID = od.ProductID
where year(getdate())- year(o.OrderDate) <=25
group by o.ShipPostalCode
) as cte
where ShipPostalCode is not null
order by num desc


--17. List all city names and number of customers in that city.     

select city,count(CustomerID) from customers
group by city

--18.List city names which have more than 2 customers, and number of customers in that city 

select city,count(CustomerID) from customers
group by city
having count(CustomerID)> 2


--19.List the names of customers who placed orders after 1/1/98 with order date.
select c.CompanyName, o.OrderDate
from customers as c
inner join orders as o
on c.CustomerID = o.CustomerID
where o.OrderDate >= '1998-1-1'

--20.List the names of all customers with most recent order dates 
select c.CompanyName, max(o.OrderDate)
from customers as c
inner join orders as o
on c.CustomerID = o.CustomerID
group by c.CompanyName

--21.Display the names of all customers  along with the  count of products they bought 
select c.CompanyName,COUNT(p.productID)
from customers as c
inner join orders as o on c.CustomerID = o.CustomerID 
inner join [Order Details] as od on o.OrderID = od.OrderID
inner join Products as p on od.ProductID = p.ProductID
GROUP BY C.CompanyName
order by 1

--22.Display the customer ids who bought more than 100 Products with count of products.
select c.CustomerID,COUNT(p.productID) AS totalnum
from customers as c
inner join orders as o on c.CustomerID = o.CustomerID 
inner join [Order Details] as od on o.OrderID = od.OrderID
inner join Products as p on od.ProductID = p.ProductID
GROUP BY C.CustomerID
having COUNT(p.productID) > 100
order by 1

--23.List all of the possible ways that suppliers can ship their products. Display the results as below
select distinct s.CompanyName, sp.CompanyName
from Suppliers as s
inner join Products as p on s.SupplierID = p.SupplierID 
inner join [Order Details] as od on od.ProductID = p.ProductID
inner join Orders as o on o.OrderID = od.OrderID
inner join Shippers as sp on sp.ShipperID = o.ShipVia
order by 1

--24.Display the products order each day. Show Order date and Product Name.

select o.OrderDate, p.ProductName
from Products p
inner join [Order Details] as od on od.ProductID = p.ProductID
inner join Orders as o on o.OrderID = od.OrderID
order by 1
--25.Displays pairs of employees who have the same job title.
select distinct e1.EmployeeID,e2.EmployeeID
from Employees as e1
inner join Employees as e2
on e1.Title = e2.Title and e1.EmployeeID != e2.EmployeeID

--26.Display all the Managers who have more than 2 employees reporting to them.

select  e1.EmployeeID,count(*)
from Employees as e1
inner join Employees as e2
on e1.EmployeeID = e2.ReportsTo 
group by e1.EmployeeID
having count(*)>2

--27.Display the customers and suppliers by city. The results should have the following columns
select * from Customers
select * from Suppliers
Select * from [Customer and Suppliers by City]

select city, companyname, ContactName,(case when 1=1 then 'Customers' end)as relationship
from Customers
union
select city, companyname, ContactName,(case when 1=1 then 'Suppliers' end)as relationship
from Suppliers


select * from [Customer and Suppliers by City]