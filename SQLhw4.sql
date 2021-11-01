/*
1.What is View? What are the benefits of using views?
Views can provide advantages over tables: Views can represent a subset of the data contained in a table. 
Consequently, a view can limit the degree of exposure of the underlying tables to the outer world:
a given user may have permission to query the view, while denied access to the rest of the base table.

2.Can data be modified through views?
If the view contains joins between multiple tables, you can only insert and update one table in the view, and you can't delete rows. You can't directly modify data in views based on union queries. 
You can't modify data in views that use GROUP BY or DISTINCT statements

3.What is stored procedure and what are the benefits of using it?
4.What is the difference between view and stored procedure?
5.What is the difference between stored procedure and functions?
6.Can stored procedure return multiple result sets?
7.Can stored procedure be executed as part of SELECT Statement? Why?
8.What is Trigger? What types of Triggers are there?
9.What is the difference between Trigger and Stored Procedure?
*/

--1.Create a view named “view_product_order_[your_last_name]”, 
-- list all products and total ordered quantity for that product.

create view view_product_order_Chen
as
select p.ProductName, sum(od.Quantity) as total
from products as p
inner join [Order Details] as od
on p.ProductID = od.ProductID
group by p.ProductName

--2.Create a stored procedure “sp_product_order_quantity_[your_last_name]” 
-- that accept product id as an input and total quantities of order as output parameter.

/*
select * from Products
select p.ProductID,sum(od.Quantity)
from products p
inner join [Order Details] as od
on p.ProductID = od.ProductID
group by p.ProductID
order by 1
*/

alter PROC sp_product_order_quantity_chen
@pid int
AS
begin
return (select sum(od.Quantity)
from products p
inner join [Order Details] as od
on p.ProductID = od.ProductID
group by p.ProductID
having p.ProductID = @pid
)
end

begin
DECLARE @Return int
EXEC @Return = sp_product_order_quantity_chen  @pid = 1
print @Return
end


--3.Create a stored procedure “sp_product_order_city_[your_last_name]”
--that accept product name as an input and top 5 cities that ordered most that product combined 
--with the total quantity of that product ordered from that city as output.
select * from Products
create proc sp_product_order_city_chen
@pname varchar(50)
as
begin
select top 5 o.ShipCity, sum(od.Quantity)
from Orders as o
inner join [Order Details] as od
on o.OrderID = od.OrderID
inner join Products as p
on od.ProductID = p.ProductID
where p.ProductName = @pname
group by o.ShipCity
order by 2 desc
end

exec sp_product_order_city_chen @pname = 'Chai' 
exec sp_product_order_city_chen @pname = 'Chang' 

--4.Create 2 new tables “people_your_last_name” “city_your_last_name”.
--City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. 
--People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}.
--Remove city of Seattle.
--If there was anyone from Seattle, put them into a new city “Madison”. 
--Create a view “Packers_your_name” lists all people from Green Bay.
--If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.

drop table city_chen
drop table people_chen
CREATE TABLE city_chen(
Id int PRIMARY KEY,
city varchar(20)
)
CREATE TABLE people_chen(
Id int PRIMARY KEY,
name varchar(20),
city int FOREIGN KEY REFERENCES city_chen(Id)
)

insert into city_chen values(1,'Seattle')
insert into city_chen values(2,'Green Bay')

insert into people_chen values(1,'Aaron Rodgers',2)
insert into people_chen values(2,'Russell Wilson',1)
insert into people_chen values(3,'Jody Nelson',2)

select * from city_chen
select * from people_chen

update city_chen
set city = 'Madison'
where city = 'Seattle'

create view Packers_your_name
as 
select p.Id, p.name
from people_chen p
inner join city_chen as c
on c.id =p.city 
where c.city = 'Green Bay'
select * from Packers_your_name
--5.Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name”
--and fill it with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
select * from Employees
select EmployeeID from Employees
where month(BirthDate) = 2

create proc sp_birthday_employees_chen

as
begin
select * into birthday_employees_chen
from Employees
where month(BirthDate) = 2
end

exec sp_birthday_employees_chen

select * from birthday_employees_chen
--6

select *
from A left join B on A.id = B.id
where B.id is null
union all
select *
from B left join A on A.id = B.id
where A.id is null