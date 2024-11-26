-- DBEAVER не смог подключиться, поэтому пишу с https://sqliteonline.com/ отсюда могут быть некоторые особенности с типами


/*задание 1.1.1
Для каждого города выведите число покупателей из соответствующей таблицы, 
сгруппированных по возрастным категориям и отсортированных по убыванию количества 
покупателей в каждой категории.*/


Select city, CASE 
 WHEN age >= 50 THEN 'old'
    WHEN age <= 20 THEN 'young'
    ELSE 'adult'
    END as category, COUNT(DISTINCT id) as sum
FROM users
GROUP BY category, city
Order by category DESC;



/*задание 1.1.2*/
/*Рассчитайте среднюю цену категорий товаров в таблице products, в названиях товаров которых присутствуют слова «hair» или «home». 
Среднюю цену округлите до двух знаков после запятой. Столбец с полученным значением назовите avg_price.
Поля в результирующей таблице: avg_price, category.
Пояснение: Для решения этой задачи подойдёт конструкция CASE.
В качестве возраста учитывайте число полных лет.*/



SELECT ROUND(AVG(price)) as avg_price, category
FROM products
WHERE LOWER(name) like '%hair%' or LOWER(name) like '%home%' --lower чтобы учесть все вхождения слова(вначале и не только)
GROUP BY category;



/*задание 1.2.1*/
/*Назовем “успешными” (’rich’) селлерами тех:кто продает более одной категории товаров и чья суммарная выручка превышает 50 000
Остальные селлеры (продают более одной категории, но чья суммарная выручка менее 50 000) будут обозначаться как ‘poor’. 
Выведите для каждого продавца количество категорий, средний рейтинг его категорий, суммарную выручку, а также метку ‘poor’ или ‘rich’.
Назовите поля: seller_id, total_categ, avg_rating, total_revenue, seller_type.Выведите ответ по возрастанию id селлера.*/



SELECT seller_id, 
	COUNT(DISTINCT category) as total_categ,
	ROUND(AVG(rating), 2) AS avg_rating,
    SUM(revenue) AS total_revenue,
    CASE 
    WHEN SUM(revenue) > 50000 THEN 'rich'
    ELSE 'poor'
    END AS seller_type
FROM sellers
Where NOT category = 'Bedding'
GROUP BY seller_id
HAVING COUNT(DISTINCT category) > 1
ORDER BY seller_id



/* задание задание 1.2.2
Для каждого из неуспешных продавцов (из предыдущего задания) посчитайте, 
сколько полных месяцев прошло с даты регистрации продавца.
Отсчитывайте от того времени, когда вы выполняете задание. 
Считайте, что в месяце 30 дней. Например, для 61 дня полных месяцев будет 2.
Также выведите разницу между максимальным и минимальным сроком доставки среди неуспешных продавцов. 
Это число должно быть одинаковым для всех неуспешных продавцов. */


SELECT seller_id,
		--отсчитываю от именно от даты, когда делал задание, а не от текущей
        --из интервала извлекаю количество лет, перевожу в месеца и добавляю количество месяцев
       EXTRACT(YEARS FROM AGE('2024-11-17'::date, MIN(TO_DATE(date, 'DD/MM/YYYY'))))* 12 +
       EXTRACT(YEARS FROM AGE('2024-11-17'::date, MIN(TO_DATE(date, 'DD/MM/YYYY')))) AS month_from_registration,
       MAX(delivery_days) - MIN(delivery_days) AS max_delivery_difference
FROM sellers
Where NOT category = 'Bedding'
GROUP BY seller_id
HAVING SUM(revenue) < 50000 AND COUNT(DISTINCT category) > 1
ORDER BY seller_id;


/* Задание 1.2.3
Отберите продавцов, зарегистрированных в 2022 году и продающих ровно 2 категории товаров с суммарной выручкой, превышающей 75 000.
Выведите seller_id данных продавцов, а также столбец category_pair с наименованиями категорий, которые продают данные селлеры.
Например, если селлер продает товары категорий “Game”, “Fitness”, 
то для него необходимо вывести пару категорий category_pair с разделителем “-” в алфавитном порядке (т.е. “Game - Fitness”).
Поля в результирующей таблице: seller_id, category_pair */
--из-за того, что у продавцов есть несколько дат регистрации фильтрацию проводим в HAVING



SELECT seller_id, STRING_AGG(category, '-' ORDER BY category) as category_pair
FROM sellers 
GROUP BY seller_id
HAVING EXTRACT(YEAR FROM TO_DATE(MIN(date_reg), 'DD-MM-YYYY')) = '2022' AND COUNT(category) = 2 AND SUM(revenue) > 75000



