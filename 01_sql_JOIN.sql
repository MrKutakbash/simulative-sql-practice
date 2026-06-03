-- ==========================================
-- SQL JOIN (ТРЕНАЖЕР SIMULATIVE)
-- ==========================================

-- Задача 1: SQL. ДЗ 1. Смоделировать EXCEPT через JOIN
select c.id_cat_an
from category_an c
left join analysis a on a.id_cat_an = c.id_cat_an
where a.id_cat_an is null
order by id_cat_an desc

-- Задача 2: SQL. ДЗ 1. Категории анализов, которые не заказывали
select c.name as name
from orderitems o
join analysis a on o.id_an = a.id_an
right join category_an c on c.id_cat_an = a.id_cat_an
where o.id_an is null
order by name 

-- Задача 3: SQL. ДЗ 1. Фильтр по наценке и по группе
select name, id_cat_an, round((selling_price - cost_price)/cost_price * 100, 3) as markup 
from analysis
where round((selling_price - cost_price)/cost_price * 100, 3) > 35
union all
select name, id_cat_an, round((selling_price - cost_price)/cost_price * 100, 3) as markup 
from analysis
where id_cat_an = 7
order by markup desc

-- Задача 4: SQL. ДЗ 1. Минимальное значение по лексикографическому принципу
SELECT MIN(t.name) AS name
FROM types_an t
JOIN analysis a
ON a.id_type=t.id_type

-- Задача 5: SQL. ДЗ 1. Транзитивная связь
SELECT fio
FROM clients cl
JOIN orders ord
ON cl.id_cl=ord.id_cl
JOIN orderitems oi
ON ord.id_orders=oi.id_orders
JOIN analysis an
ON oi.id_an=an.id_an
JOIN category_an cat
ON an.id_cat_an=cat.id_cat_an
WHERE cat.name = 'Микроэлементы'
ORDER BY fio

-- =============================
-- ==== БИЗНЕСОВАЯ ПРАКТИКА ====
-- =============================

-- Задача 1: SQL. ПРАКТИКА. Как студенты решают домашки
select
    u.username,
    u.email,
    p.name,
    c.code,
    c.is_false
from codesubmit c
join problem p
on c.problem_id = p.id
join users u
on u.id = c.user_id
join problem_to_company ptc
on u.company_id = ptc.company_id and ptc.problem_id = p.id
where u.company_id = 1

-- Задача 2: SQL. ПРАКТИКА. Статистика прохождения тестов
select
    u.username,
    u.email,
    t2.name,
    t3.value as tq_value,
    t4.value as ta_value,
    t4.is_correct
from testresult t
join test t2
on t.test_id = t2.id
join testquestion t3
on t.question_id = t3.id
join users u
on u.id = t.user_id
left join testanswer t4
on t.answer_id = t4.id
where u.company_id = 1

-- Задача 3: SQL. ПРАКТИКА. Полные бездельники
select
    u.username,
    u.email,
    date_joined::date
from users u
left join codesubmit c
on u.id = c.user_id
where c.id is null and u.company_id = 1

-- Задача 4: SQL. ПРАКТИКА. Любители задач
select distinct
    u.username,
    u.email
from users u
join codesubmit c
on u.id = c.user_id
left join teststart t
on u.id = t.user_id
where t.id is null and u.company_id = 1

-- Задача 5: SQL. ПРАКТИКА. Задачи без сабмитов
select
    p.name,
    pg.path,
    false as have_submits
from problem p
join page pg
on p.page_id = pg.id
left join codesubmit c
on c.problem_id = p.id
where c.id is null

-- Задача 6: SQL. ПРАКТИКА. Дни с момента активности
select
    u.email,
    u.username,
    c.created_at::date,
    'submit' as "type",
    c.created_at::date - u.date_joined::date as diff
from codesubmit c
join users u
on c.user_id = u.id
where c.user_id > 94
union all
select
    u.email,
    u.username,
    c.created_at::date,
    'run',
    c.created_at::date - u.date_joined::date as diff
from coderun c
join users u
on c.user_id = u.id
where c.user_id > 94
union all
select
    u.email,
    u.username,
    c.created_at::date,
    'test',
    c.created_at::date - u.date_joined::date as diff
from teststart c
join users u
on c.user_id = u.id
where c.user_id > 94

-- Задача 7: SQL. ПРАКТИКА. Как студенты решают задачи
select
    u.username,
    u.email,
    p.name,
    c.code,
    c.is_false
from codesubmit c
join problem p
on c.problem_id = p.id
right join users u
on u.id = c.user_id
where u.company_id = 1

-- Задача 8: SQL. ПРАКТИКА. Формирование табеля
select num, p.id as problem
from pg_catalog.generate_series(1, 12) num
cross join problem p
