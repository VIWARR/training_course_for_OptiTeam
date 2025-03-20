select * from auto;
				 
with ranked_autos as (
    select
        row_number() over (partition by brand order by ctid) AS row_num,
        *
    from
        auto
)
delete from auto
where ctid in (
    select ctid
    from ranked_autos
    where row_num > 7
);
ALTER TABLE auto
ADD COLUMN id SERIAL PRIMARY KEY;
-------------------практические примеры -----------------------
--- рассчитаем накопительную сумму цен для каждого model, но только для машин с ценой выше 4000
select 
	brand,
	model,
	price,
	sum(case when price > 4000 then price else 0 end) over (
		partition by brand, model
		order by model
		rows between unbounded preceding and current row --- окно от первой строки в группе до текущей
	) as comulative_price_model_more_than_4000
from auto
order by brand, model;

--- расчет разницы между текущим значением и средним
with auto_avg as(
	select
		brand,
		model,
		price,
		avg(price) over (partition by model)::int as avg_price
	from auto
)
select
	*,
	price - avg_price as price_diff
from auto_avg;

--- поиск разрыва системного id
with ctid_auto as(
	select
		ctid,
		brand,
		model,
		lag(ctid) over (partition by brand) as prev_ctid,
		lag(ctid) over (partition by brand) as next_ctid
	from auto
)
select
	prev_ctid - ctid as prev_graps,
	next_ctid - ctid as next_graps,
	*
from ctid_auto;

--- написать запрос, который добавит столбец с позицей каждой модели автомобиля на основе его цены в бренде
--- модель с самой высокой ценой получает позицию 1

select
	brand,
	model,
	price,
	rank() over (partition by brand order by price desc) as price_rank
from
	auto;

--- написать запрос, который выведет самый дорогой автомобиль в окне модель
with ranked_autos as(
	select
		brand,
		model,
		price,
		rank() over (partition by model order by price desc) as price_rank
	from
		auto
	order by brand, model, price_rank
)
select
	*
from ranked_autos
where price_rank = 1;

SELECT TO_DATE('The date is 25-10-2023', '"The date is: "DD-MM-YYYY');
SELECT TO_DATE('25-10-2023', 'DD-MM-YYYY');
SELECT TO_DATE('10032025', 'DDMMYYYY'); --- Результат: 2025-03-10
SELECT TO_DATE(SPLIT_PART('2052-03-10,2025-03-15,2025-03-20', ',', 1), 'YYYY-MM-DD');
SELECT TO_DATE('10th March 2025', 'DDth Month YYYY'); -- Результат: 2023-10-25

SELECT TO_DATE(SUBSTRING('Дата заказа: 10/03/2025' FROM '\d{2}/\d{2}/\d{4}'), 'DD/MM/YYYY');
SELECT TO_DATE(SUBSTRING('Заказ №2555541 от 10/03/2025' FROM '\d{2}/\d{2}/\d{4}'), 'DD/MM/YYYY');
SELECT TO_DATE(SUBSTRING('Дата: 10/03/2025 | Заказ №2555541' FROM '\d{2}/\d{2}/\d{4}'), 'DD/MM/YYYY');

SELECT TO_DATE('Заказ от 10-03-2025', '"Заказ от "DD-MM-YYYY'); -- Результат: 2025-03-10

SELECT TO_TIMESTAMP('2025-03-10 14:30:00', 'YYYY-MM-DD HH24:MI:SS');
SELECT TO_TIMESTAMP('10/03/2025 02:30 PM', 'DD/MM/YYYY HH12:MI AM');

SELECT '2025-03-10 14:30:00 UTC'::timestamptz;
SELECT '2025-03-10 14:30:00 UTC'::timestamptz; -- Результат: 2025-03-10 17:30:00.000 +0300
SELECT TO_TIMESTAMP('10-Mar-2025 14:30:00', 'DD-Mon-YYYY HH24:MI:SS'); -- Результат: 2025-03-10 14:30:00.000

SHOW TIMEZONE;

SELECT TO_TIMESTAMP('1741606200'); -- Результат: 2025-03-10 14:30:00.000
SELECT '03/10/2025 14:30:00 +03'::timestamptz; -- Результат: 2025-03-10 14:30:00.000 +0300

SELECT EXTRACT(DAY FROM 
	(TO_DATE(SPLIT_PART('2025-03-10,2025-03-15,2025-03-20', ',', 1), 'YYYY-MM-DD'))
);
SELECT DATE_PART('hour', NOW()) AS hour;

SELECT EXTRACT(MONTH FROM NOW()) AS month;
-- Результат: 10

SELECT EXTRACT(DAY FROM NOW()) AS day;
-- Результат: 25

SELECT DATE_PART('hour', NOW()) AS hour;
-- Результат: 14

SELECT TO_CHAR(
	TO_TIMESTAMP('1741606200'),
	'DD Mon YY'
);

SELECT 'FY' || TO_CHAR(TO_TIMESTAMP('1741606200'), 'YY');

SELECT TO_CHAR(
	TO_TIMESTAMP('1741606200'), -- приводим Unix-время к типу TIMESTAMP 
	'Mon' 
);

SELECT TO_CHAR(
	TO_TIMESTAMP('1741606200'), -- приводим Unix-время к типу TIMESTAMP 
	'Mon' 
);

SELECT( 
	'W' || 
	EXTRACT(WEEK FROM  TO_TIMESTAMP('1741606200')) || 
	'_' || 
	TO_CHAR(TO_TIMESTAMP('1741606200'), 'YY')
) as week;







