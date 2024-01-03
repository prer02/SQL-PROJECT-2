use dannys_diner;
SELECT * from members;
SELECT * from menu;
SELECT * from sales;

#1 What is the total amount each customer spent at the restaurant?
WITH cte1 as (
SELECT s.customer_id,
s.order_date,s.product_id,
me.product_name,
me.price 
FROM sales s
JOIN menu me on s.product_id=me.product_id)
SELECT
customer_id,
SUM(price) amount_spent
FROM cte1 
GROUP BY customer_id;
#Alternative

SELECT 
customer_id,
SUM(price)  total_spend 
FROM SALES s JOIN menu m on s.product_id=m.product_id
GROUP BY customer_id;

#2 How many days has each customer visited the restaurant?
SELECT customer_id,
COUNT(Distinct order_date)  days
FROM Sales
GROUP BY customer_id;

#3  What was the first item from the menu purchased by each customer?
WITH cte1 as ( 
SELECT customer_id,
s.order_date,
me.product_name,
DENSE_RANK() OVER(PARTITION BY customer_id 
ORDER BY order_date) first_item_rank
FROM sales s 
JOIN menu me on s.product_id=me.product_id)
SELECT customer_id,
 order_date,
 product_name 
 FROM cte1 
 WHERE first_item_rank =1;
    
   
#4   What is the most purchased item on the menu and how many times was it purchased by all customers?
     WITH cte1 as (
     SELECT 
     customer_id,
     s.order_date,
     s.product_id,
     me.product_name,me.price 
	 FROM sales s 
     JOIN menu me on s.product_id=me.product_id) 
     SELECT 
     product_name,
     COUNT(customer_id) as No_of_times_ordered 
     FROM cte1 
     GROUP BY product_name;
	
#5   Which item was the most popular for each customer?
     WITH cte1 as (
          SELECT 
          product_name,
          customer_id,
          COUNT(order_date) orders,
          RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) rnk 
          FROM sales s 
          JOIN menu m on s.product_id=m.product_id
          GROUP BY product_name,
          customer_id
          )
       SELECT 
       customer_id,
       product_name
       FROM cte1;
      
     


#6    Which item was purchased first by the customer after they became a member?
       WITH cte1 as (
             SELECT 
			 s.customer_id,
             order_date,
             join_date,
             product_name,
             rank() over(PARTITION BY s.customer_id ORDER BY order_date) as rnk
             FROM sales s
             JOIN members me on me.customer_id=s.customer_id 
             JOIN menu m on s.product_id=m.product_id 
             WHERE order_date>= join_date 
             )
             SELECT 
             customer_id,
             product_name
             FROM cte1 
             WHERE rnk=1

..
#7     Which item was purchased just before the customer became a member?
         with cte1 as (
             SELECT 
			 s.customer_id,
             order_date,
             join_date,
             product_name,
             rank() over(PARTITION BY s.customer_id ORDER BY order_date DESC) as rnk
             FROM sales s
             JOIN members me on me.customer_id=s.customer_id 
             JOIN menu m on s.product_id=m.product_id 
             WHERE order_date < join_date 
             )
             SELECT 
             customer_id,
             product_name
             FROM cte1 
             WHERE rnk=1
	   


#8 What is the total items and amount spent for each member before they became a member?
   SELECT 
   s.customer_id,
   COUNT(product_name) as total_items,
   SUM(price) amount_spent
   FROM SALES s
   JOIN members me on s.customer_id=me.customer_id
   JOIN menu m on s.product_id=m.product_id
   WHERE order_date < join_date 
   GROUP BY s.customer_id;
   
#9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
    SELECT
    customer_id,
    SUM(CASE
    WHEN product_name='sushi' THEN price *20
    ELSE price*10
    END) as points
    FROM menu m
    JOIN sales s on s.product_id=m.product_id
    GROUP BY customer_id;

#10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
    # not just sushi - how many points do customer A and B have at the end of January?
    WITH cte1 as ( 
    SELECT s.customer_id,
    s.order_date,
    me.product_name,me.price,
    case when 
    product_name='sushi' THEN
    2*me.price
    WHEN s.order_date BETWEEN m.join_date
    AND (m.join_date+INTERVAL 6 day)
    THEN 2*me.price
    ELSE me.price end as newprice
    FROM sales s 
    JOIN menu me
    on s.product_id=me.product_id
	JOIN  members m
    on s.customer_id=m.customer_id
    WHERE order_date <='2021-01-31')
    SELECT customer_id,
    SUM(newprice)*10  as Total_points
    FROM cte1
    GROUP BY customer_id
    
   