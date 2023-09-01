--Data Cleaning Project Vihicle Sales DataSet--

------------------------------------------------------------------------------------
--Create Table--

Create Table DataSales (
			Order_id varchar(20) not null,
			Customer_id varchar(20),
			Customer_name varchar(50),
			Customer_Address varchar(250),
			Order_Date date,
			Ship_Date date,
			Ship_Mode varchar(20),
			Product_id varchar(20),
			Product_Name varchar(250),
			Category varchar(20),
			Sub_Category varchar(20),
			Sales float
			);
			

-------------------------------------------------------------------------------------

--Import Data from CSV file--

Copy DataSales (
			Order_id,
			Customer_id,
			Customer_name,
			Customer_Address,
			Order_Date,
			Ship_Date,
			Ship_Mode,
			Product_id,
			Product_Name,
			Category,
			Sub_Category,
			Sales
				)
From 'C:\Users\Public\Documents\SuperStoreDataSales.csv'
Delimiter ','
CSV Header;

-------------------------------------------------------------------------------------

--Split Customer Country Using Substring() into Column--

select Customer_address
from DataSales
--select the string to extract from customer address
select substring(Customer_address,1 ,position (','in Customer_address)-1) as country
from DataSales
--create new table extracted string
Alter Table DataSales
Add Country varchar(50)
--insert extracted string to the created tabel
Update DataSales
Set Country = substring(Customer_address,1 ,position (','in Customer_address)-1)

select * from DataSales

---------------------------------------------------------------------------------------------------


--Sparate Customer_Address into Colunms Using Split_Part()--

--select strings to be extracted
select 
		split_part(Customer_Address,',',2)as City,
		split_part(Customer_Address,',',3)as State,
		split_part(Customer_Address,',',4)as Postal_Code,
		split_part(Customer_Address,',',5)as Region
from DataSales
--create new table for extracted stings
Alter Table DataSales
Add City varchar(50),
Add	State varchar(50),
Add	Postal_Code varchar(50),
Add	Region varchar(50)
--insert extracted strings to the table
Update DataSales
Set City    	= split_part(Customer_Address,',',2),
    State		= split_part(Customer_Address,',',3),
    Postal_Code	= split_part(Customer_Address,',',4),
    Region      = split_part(Customer_Address,',',5)
	
select * from DataSales

------------------------------------------------------------------------------------------------------------

--Trim 'Class' in Ship_Mode Column--

Select ship_mode,
trim(trailing 'Class'from Ship_Mode)
from datasales

Update DataSales
set ship_mode = trim(trailing 'Class'from Ship_Mode)

select * from DataSales


------------------------------------------------------------------------------------------------------------

--Renaming "Same Day " to "Premuim" in ship_mode

Select Ship_mode 
from DataSales
Where Ship_mode = 'Same Day'

Update DataSales
set Ship_mode = 'Premuim'
Where Ship_mode = 'Same Day'

------------------------------------------------------------------------------------------------------------

--Find and delete duplicates

--1.Find the data of any duplicate values
select order_id,product_id,sales,count(*) from dataSales
group by  order_id,product_id,sales
having count(*)>1
--2.Create a temporary id Column with auto icreament feature
Alter Table DataSales
add id serial
--3.Find the id of the Data you found in step 1
select * from DataSales
where order_id = 'US-2015-150119' and product_id= 'FUR-CH-10002965' and sales ='281.372'
--4.Delete the Data
delete from DataSales
where id = '3269'
--5. Delete Temporary id Column
Alter table DataSales
Drop id

