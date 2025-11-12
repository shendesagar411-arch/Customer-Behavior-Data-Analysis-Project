create database customer_sb;
use customer_sb;

# 1 what is the total revenue generated male vs female
select gender, sum(purchase_amount)as Revenue
from customer
group by gender;

# 2 which customer is used discount but still spend more than average purchase amount
select customer_id, purchase_amount
from customer 
where discount_applied='Yes' and purchase_amount >= (select avg(purchase_amount) from customer);

# 3 which are the top 5 product with the higest average review rating
select item_purchased,round(avg(review_rating),2)as avg_rating
from customer
group by item_purchased
order by avg_rating desc limit 5;

# 4 compare the average purchase amount between standrad and express shipping
select shipping_type, round(avg(purchase_amount),2)as avg_purchase
from customer
where shipping_type in ('Standard','Express')
group by shipping_type;

# 5 Do subscribed customer spend more? compare average spend and total revenue between subscibers and non-subscibers
select subscription_status,
count(customer_id)as Total_customers,
avg(purchase_amount)as Total_avg,
sum(purchase_amount)as Total_revenue
from customer
group by subscription_status;

# 6  which 5 product have the highest percentage of purchase with the
SELECT 
    item_purchased,
    ROUND(
        (SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
        2
    ) AS discount_percentage
FROM customer
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;

# 7 Segments customer into new, Returning and Loyal based on their total number of previous purchases, and show the count of each segment
with customer_type as (
select customer_id,previous_purchases,
	CASE
       WHEN previous_purchases = 1 THEN 'New'
       WHEN previous_purchases BETWEEN 1 AND 10 THEN 'Returning'
       ELSE 'Loyal'
       END as customer_segment
from customer
)
select customer_segment,count(*)as number_of_customer
from customer_type
group by customer_segment;

# 8 what are the top 3 most purchased product within each category
with item_counts as (
select category,
item_purchased,
count(customer_id)as total_orders,
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from customer
group by category,item_purchased
)   
select item_rank,category,item_purchased,total_orders
from item_counts
where item_rank <=3;

# 9 Are customer who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status;

# 10 what is the revenue contribution of each age group
select age_group,sum(purchase_amount)as revenue
from customer
group by age_group
order by revenue desc