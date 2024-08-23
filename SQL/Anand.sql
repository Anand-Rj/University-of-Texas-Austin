/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms),  both first name and last name are in upper case, customer email id,  customer creation year and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Hint: Use CASE statement, no permanent change in the table is required. 
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
*/

## Answer 1.
USE orders;
select customer_id,
(case
	when customer_gender = 'F' then 'Ms' + upper(Customer_fname)+ upper(Customer_lname)
    else 'Mr' + upper(customer_fname) + upper(customer_lname) end ) as customer_Name,
    customer_email, customer_creation_date,
    (case
		when year(customer_creation_date) < 2005 then 'A'
        when year(customer_creation_date) >=2005 and year (customer_creation_date) < 2011 then 'B'
        when year(customer_creation_date) >=2011 then 'C' else '' end) as customer_category from online_customer;

/* Q2. Write a query to display the following information for the products, which have not been sold: product_id, product_desc, product_quantity_avail, product_price, inventory values ( product_quantity_avail * product_price), New_Price after applying discount as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 200,000 then apply 20% discount 
ii) If Product Price > 100,000 then apply 15% discount 
iii) if Product Price =< 100,000 then apply 10% discount 
Hint: Use CASE statement, no permanent change in table required. 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE] */

## Answer 2.
use orders;
select p.product_id,p.product_desc,p.product_quantity_avail,p.product_price, (p.product_quantity_avail*p.product_price) as inventory_value,
(case
	when product_price > 200000 then product_price - (product_price/100)*20
    when product_price > 100000 then product_price - (product_price/100)*15
    when product_price <= 100000 then product_price - (product_price/100)*10 end ) as New_price
from product as p
where product_id not in (Select Distinct product_id from order_items)
order by (p.product_quantity_avail*p.product_price) Desc;

/* Q3. Write a query to display Product_class_code, Product_class_description, 
Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price).
Information should be displayed for only those product_class_code which
 have more than 1,00,000 Inventory Value. Sort the output with respect to
 decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS] */

## Answer 3.

use orders;
select A.product_class_code,B.product_class_desc,count(1),
sum(A.product_quantity_avail*A.product_price) as Inventory_value
from product_class B
join product A 
On A.PRODUCT_CLASS_CODE =B.PRODUCT_CLASS_CODE
group by A.PRODUCT_CLASS_CODE,B.PRODUCT_CLASS_DESC
Having sum(A.product_quantity_avail*A.product_price)>100000
order by sum(A.product_quantity_avail*A.product_price) DESC;

/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled###Order#### all the orders placed by them.
Expected 1 row in the final output
 [NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER] */
 
## Answer 4.
use orders;
select c.Customer_id,(C.customer_fname+C.customer_lname)as Full_Name, 
C.customer_email, C.customer_phone, A.country 
from order_header as o
join online_customer as C
on o.customer_id =C.customer_id
join Address A
on C.address_id =A.address_id
where o.order_status ='Cancelled'
and o.customer_id not in
(select customer_id from order_header where order_status in ('Shipped','In process')
group by Customer_id);




/* Q5. Write a query to display Shipper name, City to which it is catering,
 num of customer catered by the shipper in the city , number of consignment
 delivered to that city for Shipper DHL 
Hint: The answer should only be based on Shipper_Name -- DHL.
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER] */

## Answer 5.  
use orders;
select s.Shipper_name,A.city,count(c.customer_ID) as num_of_customer 
from online_customer as c
join address A
on C.address_id =A.address_id
join order_header O
on O.customer_id =c.customer_id
join shipper S
on S.shipper_id =O.shipper_id
where S.shipper_name ='DHL'
group by s.Shipper_name,A.city;





/* Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and show inventory Status of products as per below condition: 
a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, 
need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
  [NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] */

## Answer 6.
use orders;
-- For Ans a.
select distinct p.product_id, pc.product_class_desc, p.product_quantity_avail,oi.product_quantity, round(product_quantity/product_quantity_avail * 100,2)as Quantity_sold,
case
	when (product_quantity/product_quantity_avail * 100)  < 0 then "No Sales"
    when (product_quantity/product_quantity_avail * 100) > 0 and (product_quantity/product_quantity_avail * 100) < 10 then "Low Inventory"
    when (product_quantity/product_quantity_avail * 100) >=10   and (product_quantity/product_quantity_avail * 100)<50 then "Medium Inventory"
    when (product_quantity/product_quantity_avail * 100) >=50 then "Sufficient Inventory" 
    
end as Inventory_Status
from product as p
join product_class as pc
on p.product_class_code = pc.product_class_code
join order_items as oi
on p.product_id = oi.product_id
where product_class_desc like "Electronics" or product_class_desc like "Computer";
-- For Ans b.
select distinct p.product_id, pc.product_class_desc, p.product_quantity_avail, oi.product_quantity, round(product_quantity/product_quantity_avail * 100,2) as Quantity_sold,
case
	when (product_quantity/product_quantity_avail * 100)  < 0 then "No Sales"
    when (product_quantity/product_quantity_avail * 100) >= 0 and (product_quantity/product_quantity_avail * 100) <= 20 then "Low Inventory"
    when (product_quantity/product_quantity_avail * 100) >= 20   and (product_quantity/product_quantity_avail * 100) <= 60 then "Medium Inventory"
    when (product_quantity/product_quantity_avail * 100) >= 60 then "Sufficient Inventory" 
    
end as Inventory_Status
from product as p
join product_class as pc
on p.product_class_code = pc.product_class_code
join order_items as oi
on p.product_id = oi.product_id
where product_class_desc like "Mobiles" or product_class_desc like "Watches";
-- For Ans C.
select distinct p.product_id, pc.product_class_desc, p.product_quantity_avail,oi.product_quantity, round(product_quantity/product_quantity_avail * 100,2)as Quantity_sold,
case
	when (product_quantity/product_quantity_avail * 100)  < 0 then "No Sales"
    when (product_quantity/product_quantity_avail * 100) >=0 and (product_quantity/product_quantity_avail * 100) < 20 then "Low Inventory"
    when (product_quantity/product_quantity_avail * 100) >=20   and (product_quantity/product_quantity_avail * 100)<60 then "Medium Inventory"
    when (product_quantity/product_quantity_avail * 100) >=60 then "Sufficient Inventory" 
    
end as Inventory_Status
from product as p
join product_class as pc
on p.product_class_code = pc.product_class_code
join order_items as oi
on p.product_id = oi.product_id
where product_class_desc not like "Mobiles" and product_class_desc not like "Watches" and product_class_desc not like  "Electronics"and product_class_desc not like "Computer";




/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) 
that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT] */

## Answer 7.
use orders;
select p.product_id, oi.order_id, (p.len*p.width*p.height) as Volume
from order_items as oi
join product as p
on oi.product_id = p.product_id
group by p.product_id, oi.order_id
having volume <= '18000000'
order by (p.len*p.width*p.height) desc
limit 1;

/* Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER] */

## Answer 8.
use orders;
select distinct oc.customer_id, oh.payment_mode, concat(customer_fname,' ',customer_lname) as fullname
from online_customer as oc
inner join order_header as oh
on oc.customer_id = oh.customer_id
where payment_mode = "Cash" and oc.customer_id in(select customer_id from online_customer where customer_lname like 'G%' ); 



/* Q9. Write a query to display product_id, product_desc and total quantity of products
 which are sold together with product id 201 and are not shipped to city Bangalore and New Delhi. 
Display the output in descending order with respect to the tot_qty. 
Expected 6 rows in final output

Hint:  (USE SUB-QUERY)
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]*/

## Answer 9.

use orders;
select distinct oi.order_id,p.product_id,oi.product_quantity,p.product_desc,a.city
from order_items as oi
inner join product as p
on oi.product_id = p.product_id
join order_header as oh
on oi.order_id = oh.order_id
join online_customer as oc
on oh.customer_id = oc.customer_id
join address as a
on oc.address_id = a.address_id
where p.product_id like  '201' 
and a.city in (select distinct city from address where city not like 'Bangalore' and city not like 'New Delhi');


/* Q10. Write a query to display the order_id, customer_id and customer fullname,
 total quantity of products shipped for order ids which are even and shipped to
 address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS] */

## Answer 10.

use orders;
select distinct oh.order_id,sum(oi.product_quantity) as total_quantity,a.pincode,oc.customer_id , concat(oc.customer_fname,' ',oc.customer_lname) as customer_fullname
from order_header as oh
join order_items as oi
on oh.order_id = oi.order_id
join online_customer as oc
on oh.customer_id = oc.customer_id
join address as a
on oc.address_id = a.address_id
where mod(oh.order_id,2)=0 and a.pincode in (select pincode from address
where pincode not like '5__%')
group by oh.order_id,a.pincode,oc.customer_id ,customer_fullname;