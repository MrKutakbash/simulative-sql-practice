-- ==========================================
-- БАЗОВЫЕ ОПЕРАЦИИ SQL (ТРЕНАЖЕР SIMULATIVE)
-- ==========================================

-- Задача 1: SQL. ДЗ 1. Анализы в диапазоне цен
select id_an, selling_price
from analysis
where selling_price between 200 and 300

-- Задача 2: SQL. ДЗ 1. Уникальные типы анализов
select distinct id_type
from analysis where selling_price between 200 and 300

-- Задача 3: SQL. ДЗ 1. Возраст клиентов
select fio, birthday
from clients 
where birthday < '1990.01.01'

-- Задача 4: SQL. ДЗ 1. Начало телефонного номера
select fio, phone
from sales_man
where phone like '896%'

-- Задача 5: SQL. ДЗ 1. Конец телефонного номера
select fio, phone
from sales_man
where phone like '%2'

-- Задача 6: SQL. ДЗ 1. Поиск по слову в названии
select name 
from analysis
where name ilike '%крови%'

-- Задача 7: SQL. ДЗ 1. Расчет наценки
select *, round((selling_price - cost_price)/cost_price*100, 3) as Markup
from analysis 

-- Задача 8: SQL. ДЗ 1. Найти ошибку в запросе
SELECT fio, EXTRACT(YEAR FROM birthday) AS birth_year
FROM sales_man s
WHERE EXTRACT(YEAR FROM birthday) > 1985

-- Задача 9: SQL. ДЗ 1. Нечетные ID
select id_man, fio
from sales_man 
where (id_man % 2) <> 0

-- Задача 10: SQL. ДЗ 1. Фильтр и сортировка розничной цены
select id_an, selling_price, name
from analysis
where selling_price between 100 and 1000
order by selling_price desc

-- Задача 11: SQL. ДЗ 1. Смешанная сортировка
select id_an, name, id_cat_an, cost_price
from analysis
order by id_cat_an, cost_price desc

-- Задача 12: SQL. ДЗ 1. Фильтр строк неравенством
select id_an, name, id_type
from analysis
where id_type != 1
order by id_an 

-- Задача 13: SQL. ДЗ 1. Фильтр по длине слов
select id_an, name, length(name) as length
from analysis
where length(name) > 20 or length(name) < 10
order by length 

-- Задача 14: SQL. ДЗ 1. Фильтр по длине слов
select id_an, name, length(name) as length
from analysis
where length(name) > 20 or length(name) < 10
order by length 

-- Задача 15: SQL. ДЗ 1. Комбинирование условий фильтрации
select id_an, name, id_cat_an, selling_price
from analysis
where (id_cat_an = 1 and selling_price between 200 and 300)
or (id_cat_an = 6 and selling_price < 1000)
order by name desc

-- Задача 16: SQL. ДЗ 1. Поиск значений из списка
select id_an, name, cost_price
from analysis
where name in ('АЛТ', 'ГГТ', 'АКТГ', 'Базовый')
order by cost_price desc

-- Задача 17: SQL. ДЗ 1. Отсутствие пропусков
select id_an, name, info
from analysis
where info is not null
order by id_an

-- Задача 18: SQL. ДЗ 1. Регулярные выражения
select id_cl, email
from clients
where email like '%a%' and '%@iitp.ru' and '%@mail.ru'
order by id_cl 
