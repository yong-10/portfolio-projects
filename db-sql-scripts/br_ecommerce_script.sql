--https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download
--#1
--counts number of orders per state
select customer_state, COUNT(*) as state_population
from olist_customers_dataset ocd
group by 1
order by 2 DESC;
--counts number of orders per city
select customer_city , COUNT(*) as city_population
from olist_customers_dataset ocd
group by 1
order by 2 DESC;
--counts number of orders per state and city
select customer_city, customer_state, COUNT(*) as city_state_population
from olist_customers_dataset ocd
group by 1, 2
order by 3 DESC;

--#2
--number of orders per day
select order_purchase_timestamp::date, COUNT(*)
from olist_orders_dataset ood
group by 1
order by 2 DESC;
--number of orders per month
select DATE_TRUNC('month', order_purchase_timestamp::Date)::date, COUNT(*)
from olist_orders_dataset ood
group by 1
order by 2 DESC;

--#3
--counts number of orders per product category
select opd.product_category_name, COUNT(*)
from olist_products_dataset opd
join olist_order_items_dataset ooid on opd.product_id = ooid.product_id
group by 1
order by 2 DESC;
--counts number of orders per product category translated in english
select pcnt.product_category_name_english, COUNT(*)
from olist_products_dataset opd
join olist_order_items_dataset ooid on opd.product_id = ooid.product_id
join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name 
group by 1
order by 2 DESC;

--#4
--average monthly delay/advance of delivery
select DATE_PART('year', order_purchase_timestamp::timestamp) as order_year,
DATE_PART('month', order_purchase_timestamp::timestamp) as order_month,
justify_interval(AVG(order_estimated_delivery_date::timestamp - order_delivered_customer_date::timestamp)) as avg_date_diff
from olist_orders_dataset
where order_status = 'delivered' and order_delivered_customer_date != ''
group by 1,2
order by 1,2;