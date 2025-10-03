---Creating Database:
create database SalesStore;

---Creating Table:
create table sales_store(transaction_id varchar(10),
                         customer_id varchar(10),
						 customer_name varchar(30),
						 customer_age int,
						 gender varchar(10),
						 product_id varchar(5),
						 product_name varchar(15),
						 product_category varchar(15),
						 quantiy int,
						 prce numeric(7,2),
						 payment_mode varchar(15),
						 purchase_date date,
						 time_of_purchase time,
						 status varchar(10)
						 );

---Importing Data:
copy sales_store(transaction_id,
                 customer_id,
				 customer_name,
				 customer_age,
				 gender,
				 product_id,
				 product_name,
				 product_category,
				 quantiy,
				 prce,
				 payment_mode,
				 purchase_date,
				 time_of_purchase,
				 status)
from '‪C:\Users\MD DANISH KHAN\OneDrive\Desktop\sales.csv'
delimiter ','
csv header;

---Data Cleaning:
select * from sales_store;

create table sales_store_copy as
table sales_store;

select * from sales_store_copy;

---To check Duplicate Values:
select transaction_id,
       count(*)
from sales_store_copy
group by transaction_id
having count(*)>1;

with cte as(
select *,
       row_number()over(partition by transaction_id order by transaction_id) as row_num
from sales_store_copy)
select * from cte
where row_num>1;

---To Delete duplicate values of column transaction_id:
alter table sales_store_copy
add column serial_number serial;

delete from sales_store_copy
where serial_number in(93,38,4,232);

alter table sales_store_copy
drop column serial_number;


---Correction of headers:
select * from sales_store_copy;

alter table sales_store_copy 
rename column quantiy to quantity;

alter table sales_store_copy 
rename column prce to price;

---To Check Null values:
select * from sales_store_copy
where transaction_id is null
      or
	  customer_id is null
	  or
	  customer_name is null
	  or
	  customer_age is null
	  or
	  gender is null
	  or
	  product_id is null
	  or
	  product_name is null
	  or 
	  product_category is null
	  or
	  quantity is null
	  or
	  price is null
	  or
	  payment_mode is null
	  or 
	  purchase_date is null
	  or
	  time_of_purchase is null
	  or
	  status is null;
	  
---Treating null values:  
delete from sales_store_copy
where transaction_id is null;

select * from sales_store_copy
where customer_id='CUST1003';

update sales_store_copy
set customer_name='Mahika Saini',
    customer_age=35,
	gender='Male'
where transaction_id='TXN432798';

select * from sales_store_copy
where customer_name='Ehsaan Ram';

update sales_store_copy
set customer_id='CUST9494'
where transaction_id='TXN977900';

select * from sales_store_copy
where customer_name='Damini Raju';

update sales_store_copy
set customer_id='CUST1401'
where transaction_id='TXN985663';

---To Add Primary key:
alter table sales_store_copy
add constraint pk_transaction_id primary key(transaction_id);

---	To check description of table:
select * from information_schema.columns
where table_name='sales_store_copy';

---Data cleaning:
select distinct(gender) from sales_store_copy;

update sales_store_copy
set gender='Male'
where gender='M';

update sales_store_copy
set gender='Female'
where gender='F';

select distinct(payment_mode) from sales_store_copy;

update sales_store_copy
set payment_mode='Credit Card'
where payment_mode='CC';

---Data Analysis:

--🔥 1. What are the top 5 most selling products by quantity
select product_id,
       product_name,
	   sum(quantity) as total_orders
from sales_store_copy
where status='delivered'
group by 1,2
order by 3 desc
limit 5;

--📉 2. Which products are most frequently cancelled?
select product_id,
       product_name,
	   count(*) as numbers_of_cancelled
from sales_store_copy
where status='cancelled'
group by 1,2
order by numbers_of_cancelled desc;

--🕒 3. What time of the day has the highest number of purchases?
select
      case
	      when date_part('hour',time_of_purchase) between 5 and 11 then 'Morning'
		  when date_part('hour',time_of_purchase) between 12 and 15 then 'Afternoon'
		  when date_part('hour',time_of_purchase) between 16 and 19 then 'Evening'
		  else 'Night'
	  end as time_of_day,
	  count(*) as total_purchases
from sales_store_copy
group by 1
order by total_purchases desc;

------Another method
select
    case
        when extract(hour from time_of_purchase) between 5 and 11 then 'Morning'
        when extract(hour from time_of_purchase) between 12 and 15 then 'Afternoon'
        when extract(hour from time_of_purchase) between 16 and 19 then 'Evening'
        else 'Night'
    end as time_of_day,
	count(*) as total_purchases
from sales_store_copy
group by 1
order by 2 desc;

----On the basis of hours
select date_part('hour',time_of_purchase) as Hours,
       count(*) as total_purchases
from sales_store_copy
group by 1
order by 2 desc;

--👥 4. Who are the top 5 highest spending customers?
select customer_id,
       customer_name,
	   sum(price) as total_spent
from sales_store_copy
group by 1,2
order by 3 desc
limit 5;

--🛍️ 5. Which product categories generate the highest revenue?
select product_category,
       sum(price) as revenue
from sales_store_copy
group by 1
order by 2 desc;

--🔄 6. What is the return/cancellation rate per product category?
--For cancelled status
select product_category,
       count(case when status='cancelled' then 1 end)*100/count(*)||'%' as cancelled_percent
from sales_store_copy
group by 1
order by 2 desc;

--For returned category
select product_category,
       count(case when status='returned' then 1 end)*100/count(*)||'%' as returned_percent
from sales_store_copy
group by 1
order by 2 desc;

--💳 7. What is the most preferred payment mode?
select payment_mode,
       count(*) as total_count
from sales_store_copy
group by 1
order by 2 desc;

--🧓 8. How does age group affect purchasing behavior?
select case
           when customer_age between 18 and 25 then '18-25'
		   when customer_age between 26 and 35 then '26-35'
		   when customer_age between 36 and 50 then '36-50'
		   else '51+'
		end as age_group,
		sum(quantity*price) as total_amount
from sales_store_copy
group by 1
order by 2 desc;

--🔁 9. What’s the monthly sales trend?

select to_char(purchase_date,'mm-yyyy') as month_year,
       sum(quantity*price)
from sales_store_copy
group by 1
order by 2 desc;
------Another method------
select date_part('year',purchase_date) as year,
       date_part('month',purchase_date) as month,
	   sum(quantity*price) as total_amount
from sales_store_copy
group by date_part('year',purchase_date),
       date_part('month',purchase_date)
order by sum(quantity*price) desc;
