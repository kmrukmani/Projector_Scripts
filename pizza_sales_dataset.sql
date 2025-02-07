-- Analyzing Pizza Sales Dataset using SQL

-- -1 Retrirve the total number of orders placed.

select count(order_id) as count_orders
from orders

-- 2 Calculated total revnu generate pizza_sales

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_revenue_pizza
FROM
    orders_details
        INNER JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id

-- Question 3 Identityfy the highest-price pizza.

select pizza_types.name,pizzas.price as highest_price_pizza
from pizza_types
inner join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by highest_price_pizza desc
limit 1

 --  Question 4 identityfi the most common pizza size ordered

select pizzas.size,count(orders_details.order_details_id) as mostpizzasize_ordered
from pizzas
inner join orders_details
on pizzas.pizza_id = orders_details.pizza_id
group by pizzas.size
order by mostpizzasize_ordered desc
limit 1

-- Q4. List the top 5 most ordered pizza types along with quantites.

	select pizza_types.name,count(orders_details.quantity) as most_top5pizza_ordered
	from pizza_types
	inner join pizzas
	on pizza_types.pizza_type_id = pizzas.pizza_type_id
	inner join orders_details
	on orders_details.pizza_id = pizzas.pizza_id
	group by pizza_types.name
	order by most_top5pizza_ordered desc
	limit 5

-- intermediate lavel questions----

-- Question 1. join the necessary tables to
--  the total quantity each pizza_category_orders

select pizza_types.category,sum(orders_details.quantity) as quantity
from pizza_types 
inner join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
inner join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by quantity desc

-- Determine the Distributition of orders by the hours.

select hour(order_time),count(order_id)as orders_perhour
 from orders
 group by hour(order_time)
 order by orders_perhour desc

-- join relevent tables to find the category wise distribution of pizzas

select category,count(name) as count_pizza
from pizza_types
group by category


--  group the orders by date and calculated 
-- -- the average number of pizzas orderd per day

select round(avg (quantity),0)from 
(select orders.order_date,sum(orders_details.quantity)as quantity
from orders
inner join orders_details
on orders.order_id = orders_details.order_id
group by orders.order_date) as order_quantity ;

-- Q5...Datermine the top 3 most ordered pizza types
-- -- based on revenue


select pizza_types.name,
sum(orders_details.quantity * pizzas.price) as revenue
from pizza_types
inner join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
inner join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc
limit 3

-- calculated the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
(sum(orders_details.quantity * pizzas.price) /(select 
round(sum(orders_details.quantity * pizzas.price),2) 
as total_revenue_pizza
from orders_details
inner join pizzas
on orders_details.pizza_id = pizzas.pizza_id) )*100 as revenue

from pizza_types
inner join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
inner join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category

-- Analyze the cumlative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from 
(select orders.order_date,
sum(orders_details.quantity * pizzas.price) as revenue
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id
group by orders.order_date) as sales ;


-- Detemine the top 3 most ordered pizza types based on revenue for 
-- each pizza category.

select name,revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name,
sum((orders_details.quantity) * pizzas.price) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn <= 3




