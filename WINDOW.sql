/*
Выведите список сотрудников с именами сотрудников, 
получающими самую высокую зарплату в отделе. Столбцы в результирующей таблице:
first_name, last_name, salary, industry, name_ighest_sal. Последний столбец - 
имя сотрудника для данного отдела с самой высокой зарплатой.
Выведите аналогичный список, но теперь укажите сотрудников с минимальной зарплатой.
В каждом случае реализуйте расчет двумя способами: 
с использованием функций min max (без оконных функций) и с использованием first/last value
*/

--без оконных функций максимум

WITH sub as(
  SELECT industry, MAX(salary) as max
  FROM "Salary"
  Group BY industry
),
sub2 AS(
  SELECT sa.first_name, sub.industry
  FROM "Salary" as sa 
  	JOIN sub ON (sa.industry = sub.industry AND sa.salary = sub.max)
  )
SELECT "Salary".first_name,
	last_name,
    salary,
    sub2.industry,
    sub2.first_name AS name_ighest_sal
FROM "Salary" LEFT JOIN sub2 USING(industry)
ORDER BY id


-- с оконной функцией максимум

SELECT first_name,
	last_name,
    salary,
    industry,
    FIRST_VALUE(first_name) OVER(PARTITION BY industry ORDER BY salary DESC) AS name_highest_sal
FROM "Salary" 

-- миниммум без оконной функции
WITH sub as(
  SELECT industry, MIN(salary) as MIN
  FROM "Salary"
  Group BY industry
),
sub2 AS(
  SELECT sa.first_name, sub.industry
  FROM "Salary" as sa 
  	JOIN sub ON (sa.industry = sub.industry AND sa.salary = sub.MIN)
  )
SELECT "Salary".first_name,
	last_name,
    salary,
    sub2.industry,
    sub2.first_name AS name_lowest_sal
FROM "Salary" LEFT JOIN sub2 USING(industry)

--минимум с оконной функцией
SELECT first_name,
	last_name,
    salary,
    industry,
    FIRST_VALUE(first_name) OVER(PARTITION BY industry ORDER BY salary) AS name_lowest_sal
FROM "Salary" 
Order by id


--ЧАСТЬ 2
--Здесь дико извиняюсь, но файл странно конвертировался и все названия колонок в формате "SHOPNUMBER"(изменить не могу)

/* ЗАДАНИЕ1
Отберите данные по продажам за 2.01.2016. Укажите для каждого магазина его адрес, 
сумму проданных товаров в штуках, сумму проданных товаров в рублях.
Столбцы в результирующей таблице:
SHOPNUMBER , CITY , ADDRESS, SUM_QTY SUM_QTY_PRICE*/


SELECT DISTINCT "SHOPNUMBER",
	"CITY",
    "ADDRESS",
    SUM("QTY") OVER(Partition BY "SHOPNUMBER") AS SUM_QTY,
    SUM("QTY"::INTEGER*"PRICE"::INTEGER) OVER(Partition BY "SHOPNUMBER") AS SUM_QTY_PRICE
FROM sales
	LEFT JOIN shops USING("SHOPNUMBER")
    Left JOIN goods USING("ID_GOOD")
WHERE TO_DATE("DATE", 'DD-MM-YYYY') = '1-01-2016'

/* ЗАДАНИЕ2
Отберите за каждую дату долю от суммарных продаж (в рублях на дату). Расчеты проводите только по товарам направления ЧИСТОТА.
Столбцы в результирующей таблице:
DATE_, CITY, SUM_SALES_REL */

SELECT sub1."DATE", sub1."CITY",
   ROUND((sub1.SUM_SALES::NUMERIC / sub2.TOTAL_SALES_DATE::NUMERIC)*100, 2) AS "SUM_SALES_REL"
FROM (SELECT s."DATE",
            "sh"."CITY",
            SUM(s."QTY"::INTEGER * g."PRICE"::INTEGER) AS SUM_SALES
        FROM sales AS s
        JOIN shops AS sh USING("SHOPNUMBER")
        JOIN goods AS g USING("ID_GOOD")
        GROUP BY s."DATE", sh."CITY"
    ) AS sub1
JOIN (SELECT s."DATE",
            SUM(s."QTY"::INTEGER * "g"."PRICE"::INTEGER) AS TOTAL_SALES_DATE
        FROM sales AS s
        JOIN goods AS g USING("ID_GOOD")
        GROUP BY s."DATE"
    )  AS sub2
USING("DATE")

--Выведите информацию о топ-3 товарах по продажам в штуках в каждом магазине в каждую дату.

SELECT "DATE_", "SHOPNUMBER", "ID_GOOD"
FROM (SELECT 
        "DATE" AS "DATE_", 
        "SHOPNUMBER", 
        "ID_GOOD", 
        DENSE_RANK() OVER (PARTITION BY "DATE", "SHOPNUMBER" ORDER BY "total_qty" DESC) AS "rnk"
    FROM (SELECT "DATE", "SHOPNUMBER", "ID_GOOD",  SUM("QTY") AS "total_qty"
          FROM "sales"
          GROUP BY "DATE", "SHOPNUMBER", "ID_GOOD"
    ) AS sub
) AS ranked
WHERE "rnk" <= 3

/* Задание 4
Выведие для каждого магазина и товарного направления сумму продаж в рублях за предыдущую дату.
Только для магазинов Санкт-Петербурга.*/
-------ПЕРЕПРОВЕРИТЬ!!!!
SELECT
    "DATE",
    "SHOPNUMBER",
    "CATEGORY",
    LAG(SUM_SALES) OVER (PARTITION BY "SHOPNUMBER", "CATEGORY" ORDER BY "DATE") AS "PREV_SALES"
FROM (SELECT s."DATE",
        s."SHOPNUMBER",
        g."CATEGORY",
        SUM(s."QTY"::INTEGER * g."PRICE"::INTEGER) AS SUM_SALES
    FROM sales as s
    JOIN shops AS sh USING("SHOPNUMBER")
    JOIN goods AS G USING("ID_GOOD")
    WHERE sh."CITY" = 'Санкт-Петербург'
    GROUP BY
        s."DATE",
        s."SHOPNUMBER",
        g."CATEGORY"
)AS sub

---ЧАСТЬ 3

CREATE TABLE query (
    searchid SERIAL PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    userid INT,
    ts BIGINT,
    devicetype VARCHAR(50),
    deviceid VARCHAR(50),
    query VARCHAR(255)
);
INSERT INTO query (year, month, day, userid, ts, devicetype, deviceid, query) VALUES
(2024, 10, 5, 1, 1696444800, 'desktop', 'PC123', 'к'),
(2024, 10, 5, 1, 1696444305, 'desktop', 'PC123', 'ку'),
(2024, 10, 5, 1, 1696444810, 'desktop', 'PC123', 'куп'),
(2024, 10, 5, 1, 1696444115, 'desktop', 'PC123', 'купить'),
(2024, 10, 5, 1, 1696444820, 'desktop', 'PC123', 'купить кур'),
(2024, 10, 5, 1, 1696444825, 'desktop', 'PC123', 'купить куртку'),
(2024, 10, 5, 2, 1696444830, 'mobile', 'Phone456', 'т'),
(2024, 10, 5, 2, 1696444135, 'mobile', 'Phone456', 'та'),
(2024, 10, 5, 2, 1696444840, 'mobile', 'Phone456', 'тап'),
(2024, 10, 5, 2, 1696444845, 'mobile', 'Phone456', 'тапок'),
(2024, 10, 5, 3, 1696444150, 'tablet', 'Tablet789', 'но'),
(2024, 10, 5, 3, 1696444855, 'tablet', 'Tablet789', 'ноут'),
(2024, 10, 5, 3, 1696444160, 'tablet', 'Tablet789', 'ноутбук'),
(2024, 10, 5, 4, 1696444865, 'desktop', 'PC234', 'с'),
(2024, 10, 5, 4, 1696444170, 'desktop', 'PC234', 'са'),
(2024, 10, 5, 4, 1696444875, 'desktop', 'PC234', 'сам'),
(2024, 10, 5, 4, 1696444880, 'desktop', 'PC234', 'самс'),
(2024, 10, 5, 4, 1696444885, 'desktop', 'PC234', 'самсунг'),
(2024, 10, 5, 5, 1696444890, 'android', 'Phone567', 'аппппппп'),
(2024, 10, 5, 5, 1696444995, 'android', 'Phone567', 'аппп'),
(2024, 10, 5, 5, 1696449999, 'android', 'Phone567', 'а');
/*
Для каждого запроса определим значение is_final:
Если пользователь вбил запрос (с определенного устройства), и после данного запроса больше ничего не искал, то значение равно 1
Если пользователь вбил запрос (с определенного устройства), и до следующего запроса прошло более 3х минут, то значение также равно 1
Если пользователь вбил запрос (с определенного устройства), И следующий запрос был короче, 
И до следующего запроса прошло прошло более минуты, то значение равно 2
Иначе - значение равно 0
Выведите данные о запросах в определенный день (выберите сами), у которых is_final пользователей устройства android равен 1 или 2.
*/
--`year`, `month`, `day`, `userid`, `ts` , `devicetype`, `deviceid` , `query`, `next_query`, `is_final`
WITH sub as(
  SELECT *, 
  LEAD(ts) OVER (PARTITION BY userid, devicetype ORDER BY ts) AS next_ts,
  LEAD(query) OVER (PARTITION BY userid, devicetype ORDER BY ts) AS next_query 
  FROM query
),
sub2 AS(
SELECT year, month, day, userid, ts, devicetype, deviceid, query, next_query,
	CASE 
    WHEN next_ts IS NULL THEN 1
    WHEN LENGTH(next_query) < LENGTH(query) AND next_ts - ts > 60 THEN 2 --стоит раньше, чтобы не присвоилось 1
    WHEN next_ts - ts > 180 THEN 1
    else 0
    END AS is_final
FROM sub
WHERE year = 2024 AND month = 10 and day = 5
)
SELECT *
FROM sub2
WHERE devicetype = 'android' AND NOT is_final = 0




