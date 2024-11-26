-- DBEAVER не смог подключиться, поэтому пишу с https://sqliteonline.com/ отсюда могут быть некоторые особенности с типами

/*Задание 2.1.1
Найти клиента с самым долгим временем ожидания между заказом и доставкой. 
Для этой задачи у вас есть таблицы "Customers", "Orders"*/


SELect NAME,
	AGE(shipment_date::TIMESTAMP,  order_date::TIMESTAMP) as wait_time
FROM orders LEFT JOIN customers USING(customer_id)
Order BY wait_time DEsc
LIMIT 1


/*Задание 2.1.2
Найти клиентов, сделавших наибольшее количество заказов, и для каждого из них найти среднее время между заказом и доставкой,
а также общую сумму всех их заказов. Вывести клиентов в порядке убывания общей суммы заказов.*/

--ДЛЯ ТОП 5 из максимального количества заказавших товар, Причем отмененные тоже учитываем
WITH sub as(
  SELECT COUNT(order_id) as kolvo, customer_id
  FROM orders
  GROUP BY customer_id
  ORDER BY kolvo DESC
  LIMIT 5
  )
SELECT name, AVG(AGE(shipment_date::TIMESTAMP,  order_date::TIMESTAMP)) AS avg_wait, SUM(order_ammount) AS total_sum
FROM orders 
	LEFT JOIN customers USING(customer_id)
    JOIN sub USING(customer_id)
GROUP BY name
order by total_sum DESC


/*Задание 2.1.2
Найти клиентов, у которых были заказы, доставленные с задержкой более чем на 5 дней, и клиентов,
у которых были заказы, которые были отменены. Для каждого клиента вывести имя, количество доставок с задержкой,
количество отмененных заказов и их общую сумму. Результат отсортировать по общей сумме заказов в убывающем порядке.
*/
-- тут ОБЩАЯ СУММА ВСЕХ ЗАКАЗОВ а не только отмененные 


SELECT 
    name,
    COUNT(CASE 
            WHEN EXTRACT(DAY FROM AGE(shipment_date::date, order_date::date)) > 5 THEN 1 
            ELSE NULL 
          END) AS late_delivery_count,
    COUNT(CASE 
            WHEN order_status = 'Cancel' THEN 1 
            ELSE NULL 
          END) AS canceled_order_count,
    SUM(order_ammount) AS total_order_amount
FROM 
    orders LEFT JOIN customers USING(customer_id)
GROUP BY name
HAVING  COUNT(CASE 
            	WHEN EXTRACT(DAY FROM AGE(shipment_date::date, order_date::date)) > 5 THEN 1 
            	ELSE NULL 
          		END) > 0 OR 
    	COUNT(CASE 
            	WHEN order_status = 'Cancel' THEN 1 
            	ELSE NULL 
          		END) > 0
ORDER BY total_order_amount DESC;

-- ЧАСТЬ 2

/*
Напишите SQL-запрос, который выполнит следующие задачи: 
1. Вычислит общую сумму продаж для каждой категории продуктов. +
2. Определит категорию продукта с наибольшей общей суммой продаж.
3. Для каждой категории продуктов, определит продукт с максимальной суммой продаж в этой категории.
*/

WITH sub as(
SELECT product_category, sum(order_ammount) as total_sum_in_cathegory
FROM orders_2 LEFT JOIN products_3 USING(product_id)
GROUP BY product_category
),
sub2 as(
SELECT sum(order_ammount) as sum_product, product_name
FROM orders_2 LEFT JOIN products_3 USING(product_id)
GROUP BY product_name
ORDER BY sum_product DEsc
),
sub3 AS(
SELECT product_category, MAX(sum_product) as max_sum_in_cathegory
FROM sub2 LEFT JOIN products_3 USING(product_name)
GROUP BY product_category
),
sub4 AS(
SELECT product_category, product_name AS product_with_max_sum_in_cathegory
FROM sub3 LEFT JOIN sub2 ON sub3.max_sum_in_cathegory = sub2.sum_product
)

SELECT sub.product_category, total_sum_in_cathegory, product_with_max_sum_in_cathegory,
	CASE
    WHEN total_sum_in_cathegory = (SELECT MAX(total_sum_in_cathegory) FROM sub)  THEN 'YES'
    ELSE 'NO'
    END AS is_max_cathegory
FROM sub LEFT JOIN sub4 USING(product_category)

