-- ==========================================
-- SQL GROUP BY (ТРЕНАЖЕР SIMULATIVE)
-- ==========================================

-- Задача 1: Количество чеков по сотрудникам
SELECT employee, COUNT(DISTINCT doc_id) AS amount
FROM transactions
GROUP BY employee
HAVING COUNT(DISTINCT doc_id) < 8
ORDER BY amount DESC

-- Задача 2: Сотрудник с максимальными накоплениями
select employee, sum(sum) as summ
from transactions
where type = 0
group by employee
order by summ desc
limit 1

-- Задача 3: Начисления с разбивкой по сотрудникам и по типу скидки
SELECT t.employee, d.value, sum(t.sum) AS accruals
FROM transactions t
JOIN discounts d
ON t.disc_id=d.id
WHERE t.type = 0
GROUP BY t.employee, d.value
ORDER BY employee, accruals DESC

-- Задача 4: Чеки за период дат
SELECT DATE(date) as date, COUNT(DISTINCT doc_id) AS amount
FROM transactions
WHERE DATE(date) BETWEEN '2019-10-25' AND '2019-11-02'
GROUP BY DATE(date)
ORDER BY amount DESC

-- Задача 5: Поиск дублей группировкой
SELECT id_transaction, card_id, maincard_id, date, sum, type, employee, doc_id, cash_id, shop_id, doc_type, disc_id, disc_source
FROM transactions
GROUP BY id_transaction, card_id, maincard_id, date, sum, type, employee, doc_id, cash_id, shop_id, doc_type, disc_id, disc_source
HAVING COUNT(*) > 1
ORDER BY id_transaction

-- Задача 6: Фильтрация агрегированных значений
SELECT card_id, MAX(d.value) AS max_perc, SUM(t.sum) AS summ, COUNT(*) as amount
FROM transactions t
JOIN discounts d
ON t.disc_id=d.id
WHERE type = 0
GROUP BY t.card_id
HAVING MAX(d.value) = 7 OR SUM(t.sum) > 20 AND COUNT(*) < 5
ORDER BY card_id

-- Задача 7: Второй и третий сотрудник
SELECT employee, SUM(sum) AS summ
FROM transactions
WHERE type = 0
GROUP BY employee
ORDER BY summ DESC
LIMIT 2
OFFSET 1

-- =============================
-- ==== БИЗНЕСОВАЯ ПРАКТИКА ====
-- =============================
    
-- Задача 1: Фильтрация попыток
select
    u.id,
    count(*) as cnt
from codesubmit c
join users u
on c.user_id = u.id
group by u.id
having count(*) > 10

-- Задача 2: Объединение строк по группам
SELECT user_id,
       ARRAY_TO_STRING(ARRAY_AGG(DISTINCT problem_id ORDER BY problem_id DESC), ' - ' ) AS list
FROM CodeSubmit c
GROUP BY user_id;

-- Задача 3: Расчет корреляции
with agg_tests as (
    select
        created_at::date as dt,
        count(*) as cnt
    from teststart t
    group by dt
),
all_problems as (
    select
        created_at::date as dt
    from coderun c
    union all
    select
        created_at::date
    from codesubmit c2
),
agg_problems as (
    select
        dt,
        count(*) as cnt
    from all_problems
    group by dt
)
select
    round(corr(coalesce(p.cnt, 0), coalesce(t.cnt, 0))::numeric, 2) as cnt_corr
from agg_problems p
full join agg_tests t
on p.dt = t.dt

-- Задача 4: Распределение числа решенных задач и тестов
with tests as (
    select user_id, count(distinct test_id) as tests_cnt
    from teststart t
    group by user_id
),
problems as (
    select user_id, problem_id
    from coderun c
    union all
    select user_id, problem_id
    from codesubmit c2
),
agg_problems as (
    select user_id, count(distinct problem_id) as problems_cnt
    from problems
    group by user_id
),
agg as (
    select u.id, t.tests_cnt, a.problems_cnt
    from users u
    left join tests t
    on u.id = t.user_id
    left join agg_problems a
    on u.id = a.user_id
)
select
    round(avg(problems_cnt), 2) as problems_avg,
    round(avg(tests_cnt), 2) as tests_avg,
    percentile_disc(0.5) within group (order by problems_cnt) as problems_median,
    percentile_disc(0.5) within group (order by tests_cnt) as tests_median
from agg

-- Задача 5: Распределение списаний и начислений
with agg as (
    select
        user_id,
        sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then -value end) write_off,
        sum(case when type_id not in (1, 23, 24, 25, 26, 27, 28) then value end) accruals,
        sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then -value else value end) balance
    from "transaction" t
    where value < 500
    group by user_id
)
select
    round(avg(write_off), 2) as write_off,
    round(avg(accruals), 2) as accruals,
    round(avg(balance), 2) as balance
from agg

-- Задача 6: Расчет MAU
with groupped as (
    select
        count(distinct user_id) as cnt
    from userentry u
    group by to_char(entry_at, 'YYYY-MM')
    having count(distinct to_char(entry_at, 'YYYY-MM-DD')) >= 25
)
select round(avg(cnt)) as mau
from groupped

-- Задача 7: Расчет n-day retention
with a as (
    select
        u.user_id,
        date(u.entry_at) as entry_at,
        date(u2.date_joined) as date_joined,
        extract(days from u.entry_at - u2.date_joined) as diff,
        to_char(u2.date_joined, 'YYYY-MM') as cohort
    from userentry u
    join users u2
    on u.user_id = u2.id
    where to_char(u2.date_joined, 'YYYY') = '2022'
)
select
    cohort,
    round(count(distinct case when diff = 0 then user_id end) * 100.0 / count(distinct case when diff = 0 then user_id end), 2) as "0 (%)",
    round(count(distinct case when diff = 1 then user_id end) * 100.0 / count(distinct case when diff = 0 then user_id end), 2) as "1 (%)",
    round(count(distinct case when diff = 3 then user_id end) * 100.0 / count(distinct case when diff = 0 then user_id end), 2) as "3 (%)",
    round(count(distinct case when diff = 7 then user_id end) * 100.0 / count(distinct case when diff = 0 then user_id end), 2) as "7 (%)",
    round(count(distinct case when diff = 14 then user_id end) * 100.0 / count(distinct case when diff = 0 then user_id end), 2) as "14 (%)",
    round(count(distinct case when diff = 30 then user_id end) * 100.0 / count(distinct case when diff = 0 then user_id end), 2) as "30 (%)",
    round(count(distinct case when diff = 60 then user_id end) * 100.0 / count(distinct case when diff = 0 then user_id end), 2) as "60 (%)",
    round(count(distinct case when diff = 90 then user_id end) * 100.0 / count(distinct case when diff = 0 then user_id end), 2) as "90 (%)"
from a
group by cohort

-- Задача 8: ABC-анализ
WITH product_metrics AS (
    SELECT 
        dr_ndrugs as product,
        SUM(dr_kol) as total_amount,
        SUM(dr_kol * dr_croz - dr_sdisc) as total_revenue,
        SUM(dr_kol * dr_croz - dr_sdisc - dr_kol * dr_czak) as total_profit
    FROM sales
    GROUP BY dr_ndrugs
),

amount_abc AS (
    SELECT 
        product,
        total_amount,
        total_amount / SUM(total_amount) OVER () as amount_share,
        SUM(total_amount) OVER (ORDER BY total_amount DESC) / SUM(total_amount) OVER () as amount_cumulative,
        CASE 
            WHEN SUM(total_amount) OVER (ORDER BY total_amount DESC) / SUM(total_amount) OVER () <= 0.8 THEN 'A'
            WHEN SUM(total_amount) OVER (ORDER BY total_amount DESC) / SUM(total_amount) OVER () <= 0.95 THEN 'B'
            ELSE 'C'
        END as amount_abc
    FROM product_metrics
),

revenue_abc AS (
    SELECT 
        product,
        total_revenue,
        total_revenue / SUM(total_revenue) OVER () as revenue_share,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) / SUM(total_revenue) OVER () as revenue_cumulative,
        CASE 
            WHEN SUM(total_revenue) OVER (ORDER BY total_revenue DESC) / SUM(total_revenue) OVER () <= 0.8 THEN 'A'
            WHEN SUM(total_revenue) OVER (ORDER BY total_revenue DESC) / SUM(total_revenue) OVER () <= 0.95 THEN 'B'
            ELSE 'C'
        END as revenue_abc
    FROM product_metrics
),

profit_abc AS (
    SELECT 
        product,
        total_profit,
        total_profit / SUM(total_profit) OVER () as profit_share,
        SUM(total_profit) OVER (ORDER BY total_profit DESC) / SUM(total_profit) OVER () as profit_cumulative,
        CASE 
            WHEN SUM(total_profit) OVER (ORDER BY total_profit DESC) / SUM(total_profit) OVER () <= 0.8 THEN 'A'
            WHEN SUM(total_profit) OVER (ORDER BY total_profit DESC) / SUM(total_profit) OVER () <= 0.95 THEN 'B'
            ELSE 'C'
        END as profit_abc
    FROM product_metrics
)

SELECT 
    a.product,
    a.amount_abc,
    p.profit_abc,
    r.revenue_abc
FROM amount_abc a
JOIN profit_abc p ON a.product = p.product
JOIN revenue_abc r ON a.product = r.product
ORDER BY a.product;

