use sakila;

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

create view rental_summary as 
select c.customer_id, concat(c.first_name, ' ', c.last_name) as cust_name, c.email, count(r.rental_id) as rental_count
from customer as c
left join rental as r on r.customer_id = c.customer_id
group by customer_id;

select * from rental_summary;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
-- and calculate the total amount paid by each customer.

create temporary table cust_payment_summary as
select rs.customer_id, rs.cust_name, sum(p.amount) as total_paid
from payment as p 
inner join rental_summary as rs on rs.customer_id = p.customer_id
group by rs.customer_id;

select * from cust_payment_summary;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.

with cust_summary_report as (
select rs.customer_id, rs.cust_name, rs.email, rs.rental_count, cps.total_paid
from rental_summary as rs
inner join cust_payment_summary as cps on cps.customer_id = rs.customer_id
)
select * from cust_summary_report
;

-- Next, using the CTE, create the query to generate the final customer summary report, 
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.

with cust_summary_report as (
select rs.customer_id, rs.cust_name, rs.email, rs.rental_count, cps.total_paid
from rental_summary as rs
inner join cust_payment_summary as cps on cps.customer_id = rs.customer_id
)
select csr.*, round(csr.total_paid / csr.rental_count,2) as avg_payment_per_rental
from cust_summary_report as csr;


