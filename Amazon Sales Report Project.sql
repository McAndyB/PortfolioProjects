--Creating table--

Create Table SalesRep (
						Order_ID varchar not null,
						Order_Date date,
						Status varchar,
						Fullfilment varchar,
						Sales_Channel varchar,
						Ship_service_level varchar,
						Style varchar,
						SKU varchar,
						Category varchar,
						Quantity int,
						Currency varchar,
						Amount float,
						Ship_city varchar,
						Ship_state varchar,
						Ship_postal_code varchar,
					    Ship_country varchar,
						Promotion_ID varchar,
						B2B bool,
						Fullfiled_by varchar
					)
					
--Imporrting data from CSV file--

Copy SalesRep (
						Order_ID,
						Order_Date,
						Status,
						Fullfilment,
						Sales_Channel,
						Ship_service_level,
						Style,
						SKU,
						Category,
						Quantity,
						Currency,
						Amount,
						Ship_city,
						Ship_state,
						Ship_postal_code,
					    Ship_country,
						Promotion_ID,
						B2B,
						Fullfiled_by
						)
From 'C:\Users\Public\Documents\Amazon Sale Report.csv'
Delimiter ','
CSV Header;

--Preview Table--

Select * from SalesRep

--------------------------------------------Sales Analysis--------------------------------------------

--1.What is the total revenue generated per month?--

with t1 as (
			Select round(cast(sum(amount)as numeric),2) as March
			From SalesRep
			Where order_date between '2022-03-01' and '2022-03-31' and status = 'Shipped'
			),
	t2 as 	(
			Select round(cast(sum(amount)as numeric),2) as April
			From SalesRep
			Where order_date between '2022-04-01' and '2022-04-30' and status = 'Shipped'
			),
	t3 as	(	
			Select round(cast(sum(amount)as numeric),2) as May
				From SalesRep
			Where order_date between '2022-05-01' and '2022-05-31' and status = 'Shipped'
			),
	t4 as	(
			Select round(cast(sum(amount)as numeric),2) as June
			From SalesRep
			Where order_date between '2022-06-01' and '2022-06-30' and status = 'Shipped'
			)
Select t1.March,t2.April,t3.May,t4.June
From t1
	cross join t2 
	cross join t3 
	cross join t4 

--Insights : March has  8,4013.00    total revenue
--			 April has  18,211506.00 total revenue	
--			 May   has  16,530004.00 total revenue	
--			 June  has  15,498732.00 total revenue	
--Our Total revenue has been a decline over the past three months--

--2. What are the top 10 products by sales?--

Select SKU,round(cast(sum(amount) as numeric),2) as Total_Sales --rounded by 2 decimal places--
From SalesRep	
Where amount is not null and status = 'Shipped'
Group by SKU
Order by Total_Sales desc
Limit 10

-- 	  SKU		   Total Sales
--"J0230-SKD-M"	        423453.00
--"J0230-SKD-S"	        375556.00
--"SET268-KR-NP-XL"	256216.00
--"J0230-SKD-L"	        239106.00
--"SET268-KR-NP-S"	238542.00
--"SET268-KR-NP-L"	236494.00
--"J0230-SKD-XL"	217008.00
--"J0230-SKD-XS"	202070.00
--"JNE3405-KR-L"	168991.00
--"SET278-KR-NP-M"	160143.00

--3.What is the average order value?--

with t1 as (
			Select order_id,avg(amount) as AveperOrderId
			From SalesRep
			Where amount is not null
			Group by Order_id
			)
Select round(cast(avg(AveperOrderId)as numeric),2) as AveOderValue
From t1

--Insight : The Average Order Value is 649.75.

--4.What is the average sales during weekdays and weekends?--

Drop table if exists temp_table;
Create temp table temp_table (
				 order_date date,amount float,day_num int,month_num int,month_name varchar			
			     )
			Insert into temp_table
						(
						  select order_date,amount,
						         extract(dow from order_date)   as Day_num,
						         extract(month from order_date) as month_num,
						         to_char(order_date,'Month')    as Month_name
						  From SalesRep
						)
			select * from temp_table
		with t1 as (
					Select month_num,month_name,avg(amount) as weekend_sales
					From temp_table
					Where day_num = 0 or day_num =6
					group by month_num,month_name
		   		   ),
 			 t2 as (
				        Select month_num,month_name,avg(amount) as weekday_sales
	                                From temp_table
					Where day_num <> 0 or day_num <> 6
					group by month_num,month_name
		  			)
	select t2.month_name,
		   round(cast(weekend_sales as numeric),2)as Weekend_avgsales,
		   round(cast(t2.weekday_sales as numeric),2) as Weekday_avgsales
    from t1 
		full join t2
		using (month_num)	
		order by month_num
--Insights--	
--        	Montht Name     Weekends Avgerage Sales 	Weekdays Average Sales
--	          March			 0				 627.68
--	          April		      630.04				 626.00
--	           May	 	      664.76				 663.36
--	          June  	      661.40	                         661.48

--------------------------------------------Customer Analysis--------------------------------------------

--1.What are the Top Cities / States for Sales?--

select * from Salesrep

Select Ship_city,round(cast(sum(amount)as numeric),2)as Total_sales
From SalesRep
Where amount is not null and status = 'Shipped'
Group by Ship_city
Order by Total_Sales desc

Select Ship_state,round(cast(sum(amount)as numeric),2)as Total_sales
From SalesRep
Where amount is not null and status = 'Shipped'
Group by Ship_state
Order by Total_Sales desc

--Insights--
-- The top Cities for sales are BENGALURU     with 4,723,666.00 total sales followed by
-- 			        HYDERABAD     with 3,253,248.00  total sales
--				MUMBAI        with 2,437,985.00  total sales
-- 				NEW DELHI     with 2,347,957.00  total sales and
-- 			        CHENNAI       with 2,074,972.00  total sales
--The top States for sales are  MAHARASHTRA   with 8,743,630.00 total sales followed by
--			        KARNATAKA     with 7,094,688.00  total sales
--				TELANGANA     with 4,506,844.000  total sales
--				TAMIL NADU    with 4,293,145.00 total sales and 
--				UTTAR PRADESH with 4,239,078.00 total sales

--2.Are there any trends in order cancellations and RTS?

with t1 as (
select  extract(month from order_date)as Month_num,
        count (distinct order_id) as Total_orders
from salesrep
group by month_num
order by month_num
           ),
	t2 as (
select 
       extract(month from order_date)as Month_num,
	   count (distinct Order_id) as total_cancellations
from salesrep
where status = 'Cancelled'
group by month_num
order by month_num
           ),
	t3 as (
select  extract(month from order_date)as Month_num,
        count (distinct order_id) as Total_RTS
from salesrep
Where Status = 'Shipped - Returned to Seller'
group by month_num
order by month_num
           )
    select t1.month_num,Total_Orders,t2.total_cancellations,t3.Total_RTS,
	       round(t2.total_cancellations*100.00/total_orders ,2) as C_percentage,
		   round(t3.Total_RTS*100.00/total_orders ,2)as RTS_percentage
	from t1
	    join t2
		using (month_num)
		join t3
		using (month_num)
     

--Result--
--      Month  Total Orders   Total Cancellations   Cancellation Percentage     Total RTS  RTS Percentage
--      March	   158                18                     11.39%                 1            0.63%
--      April	  45,858             6,726                   14.67%                849           1.85%                        
--      May       39,221             5,484                   13.98%                661           1.69%                 
--      June      35,141             4,957                   14.11%                340           0.97%
--Insights--
--As per the data showed we have a declining number of order cancellation and RTS in the past 3 months
            --but in Cancellation percentage, there are only slightly changes --
			
--3. What is the distribution of B2B vs B2C customers?		

select b2b,count(distinct Order_id) as orders, 
       cast(round(count(distinct Order_id)*100.00/(select count(distinct Order_id)from salesrep),2) as decimal) as percentage
from salesrep
group by b2b

--   B2B         orders         percentage
--  false       119,584           99.34%
--  true          794             0.66%

--Data shows that B2C has 99.34% more than B2B that has only 0.66% of total orders

--------------------------------------------Product Analysis--------------------------------------------

--1. Which categories of products are most popular?

select count(distinct order_id) as Orders,category
from salesrep
group by category
order by orders desc

--Result--   Orders       category                 --Data shows that Set category has the most popular 
--           47,845         Set                      with it comes to number of orders with 47,845 orders
--           46,561        kurta                     and Dupatta has the least orders with only 2 orders.
--           14,994     Western Dress
--           10,155         Top
--            1,148     Ethnic Dress
--              897       Blouse
--              410       Bottom
--              144       Saree
--                2      Dupatta 

--2.Are there specific styles that are more popular than others?

select count(distinct order_id) as Orders,style
from salesrep
group by style
order by orders desc

--Data shows that "JNE3787" is the most popular style with 4,205 orders followed by "JNE3405" with 2,258 orders. 

--------------------------------------------Promotion Analysis--------------------------------------------

--1.Which promotion are most commonly used?

with t1 as(
           select count (distinct order_id) as Amazon_PLCC
           from salesrep
           where promotion_id  like 'Amazon%' or 
                 promotion_id  like 'Duplicate%'
           ),
     t2 as (
            select count (distinct order_id) as IN_Core_FreeShipping
            from salesrep
            where promotion_id  like 'IN Core%'
           ),
	t3 as (
           select count (distinct order_id) as VPC_Coupon
           from salesrep
           where promotion_id  like 'VPC%'
          )
select t1.Amazon_PLCC,t2.In_Core_FreeShipping,t3.VPC_Coupon
from t1
cross join t2
cross join t3

--Data shows that InCore Free Shipping is the most commonly used by customers with 42,252 Orders 
--followed by Amazon PLCC with 30,859 orders.

--2.How effective are the promotions?

with t1 as (
           Select count(distinct Order_id) as with_promo
           From salesrep
           Where promotion_id is not null
            ),
     t2 as (		
            Select count(distinct Order_id) as without_promo
            From salesrep
            Where promotion_id is null
            )
select t1.with_promo,concat(round(t1.with_promo*100.00/(select count(distinct order_id)from salesrep),2),'%') as with_promoPercentage,
       t2.without_promo,concat(round(t2.without_promo*100.00/(select count(distinct order_id)from salesrep),2),'%') as without_promoPercentage
from t1
cross join t2

--Data shows that 61.03% (73,464) of our total orders have promotions,
--and only 38.99% (46,937) of our total orders don't have promotions 
--Products with Promotions are more effective with 22.04% higher than products without promotions

--------------------------------------------Geographical Analysis--------------------------------------------

--1.What are the Key Markets(Cities/States) for Sales?

with April as (
               select Ship_city,count(distinct order_id)as orders
               from salesrep
               Where order_date between '2022-04-01' and '2022-04-30'
               group by Ship_city
               order by orders desc
                ),
	  May as     (
               select Ship_city,count(distinct order_id)as orders
               from salesrep
               Where order_date between '2022-05-01' and '2022-05-31'
               group by Ship_city
               order by orders desc
            ),
       June as (
              select Ship_city,count(distinct order_id)as orders
              from salesrep
              Where order_date between '2022-06-01' and '2022-06-30'
              group by Ship_city
              order by orders desc
               )
Select Ship_city,April.Orders as April,May.Orders as May,June.Orders as June
from April 
  Full join May  using (Ship_city)
  Full join June using (Ship_city)
limit 10

--RESULT--
--  City        April    May    June            --The data shows that our top performing Cities are all declining 
--"BENGALURU"	3,818	3,353	3,271           --There is no emerging markets right now 
--"HYDERABAD"	2,536	2,490	2,377
--"MUMBAI"	2,160	1,884	1,606
--"NEW DELHI"	2,111	1,749	1,568
--"CHENNAI"	1,724	1,634	1,559
--"PUNE"        1,303	1,208	1,077
--"KOLKATA"   	  973     692	  576
--"GURUGRAM"	  660     602	  508
--"THANE"	  640	  551	  419
--"LUCKNOW"	  545	  448	  397

--------------------------------------------Return and Cancellation Analysis--------------------------------------------

--1.What is the return and cancellation rate?

select count(distinct order_id) as orders,status
from salesrep
group by status

with t1 as(
select count(distinct order_id) as total_orders
from salesrep
           ),
	 t2 as (	   
select count(distinct order_id) as Cancelled
from salesrep
where status = 'Cancelled'
            ),
	 t3 as (
select count(distinct order_id) as RTS
from salesrep
where status = 'Shipped - Rejected by Buyer'  or
      status = 'Shipped - Returned to Seller' or
      status = 'Shipped - Returning to Seller'
            )
select total_orders,t2.Cancelled,
       round(t2.Cancelled*100.00/t1.total_orders,2) as C_Percentage,
	   t3.RTS,
	   round(t3.RTS*100.00/t1.total_orders,2) as RTS_Percentage
from t1
Cross join t2
Cross join t3

--RESULT--
--total_orders    Cancelled     Cancelation    RTS         RTS  
--                              Percentage              Percentage
--120,378          17,185         14.28%      1,992       1.65%

--2.Are there specific products or categories that have a higher return rate?

with t1 as (
            select count(distinct order_id) as orders,sku
            from salesrep
            group by sku
            order by orders desc
           ),
	t2 as (
           select count(distinct order_id) as Returns,sku
           from salesrep
           where status = 'Shipped - Rejected by Buyer'  or
           status = 'Shipped - Returned to Seller' or
           status = 'Shipped - Returning to Seller'
           group by sku
           order by returns desc
           )
Select SKU,Orders,t2.returns,
       round(t2.returns*100.00/t1.Orders,2) as Return_rate
from t1
join t2 using (SKU)
Where t1.orders >=100
order by Return_rate desc,orders desc

--Results--
--   SKU            Orders         Returns    Retun Rate     --These are the Top 5 Product SKUs that have
--"J0003-SET-M"	        284	     19        	6.69           the highest return rate 
--"J0003-SET-XXL"	215	     13	        6.05           Note: These are only products that have more than a hundred orders
--"JNE3801-KR-XL"	117	      7	        5.98
--"J0003-SET-XL"	171	      9	        5.26
--"JNE3801-KR-XXL"	140	      7	        5.00

with t1 as (
            select count(distinct order_id) as orders,category
            from salesrep
            group by category
            order by orders desc
           ),
	t2 as (
            select count(distinct order_id) as Returns,category
            from salesrep
            where status = 'Shipped - Rejected by Buyer'  or
            status = 'Shipped - Returned to Seller'       or
            status = 'Shipped - Returning to Seller'
            group by category
            order by returns desc
           )
Select category,Orders,t2.returns,
       round(t2.returns*100.00/t1.Orders,2) as Return_rate
from t1
join t2 using (category)
order by Return_rate desc,orders desc

--Result--
--  Category         Orders     Returns   Return Rate      --These are the top 5 Categories that have 
--"Western Dress"	 14,994	      333	     2.22            the highest return rate 
--"Set"            	 47,845	      806	     1.68
--"kurta"	         46,561	      715	     1.54
--"Bottom"	            410	        6	     1.46
--"Ethnic Dress"	  1,148	       16	     1.39

