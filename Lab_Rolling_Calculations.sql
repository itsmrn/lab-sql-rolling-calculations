-- DONE: LAB Rolling Calculations

use sakila;

-- Get number of monthly active customers.

select * from rental;
select * from customer;

create or replace view monthly_active_customers as
select count(customer_id) MAU,
		date_format(rental_date, '%M') as Activity_Month,
        date_format(rental_date, '%Y') as Activity_Year
from rental
group by Activity_Month, Activity_Year
order by Activity_Month, Activity_Year;

select * from monthly_active_customers;


-- Active users in the previous month.
create or replace view previous_monthly_active_customers as
select Activity_Year, Activity_Month, MAU,
lag(MAU) over(partition by Activity_Year order by Activity_Month) as last_month_MAU 
from monthly_active_customers;

select * from previous_monthly_active_customers;

-- Percentage change in the number of active customers.

select *, round(MAU/last_month_MAU,2) as Change_in_Percentage
from previous_monthly_active_customers;

-- Retained customers every month.

create or replace view active_customers as
select customer_id,
		date_format(rental_date, '%M') as Activity_Month,
        date_format(rental_date, '%Y') as Activity_Year
from rental;

select * from active_customers;

create or replace view distinct_customers as
  select distinct customer_id as active_id,
         Activity_Year,
         Activity_Month
  from active_customers
  order by Activity_Year, Activity_Month, active_id;

select * from distinct_customers;

create or replace view retained_customers as
  select
	d1.active_id, d1.Activity_Year, d1.Activity_Month 
  from 
	distinct_customers d1
		join distinct_customers d2
		on d1.Activity_Year = d2.Activity_Year
		and d1.Activity_Month = d2.Activity_Month + 1
		and d1.active_id = d2.active_id 
  order by d1.active_id, d1.Activity_Year, d1.Activity_Month;
  
  select * from retained_customers;