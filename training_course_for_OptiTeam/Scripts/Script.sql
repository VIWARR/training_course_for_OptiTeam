create table payments (
	id serial primary key,
	amount numeric(10, 2),
	date_start date,
	date_end date,
	customer_group char(1),
	customer_status text
);


insert into payments(
	amount,
	date_start,
	date_end,
	customer_group,
	customer_status
)
select
	round((random() * 125008)::numeric, 2),
	(current_date - (random() * 365)::int),
	(current_date + (random() * 365)::int),
	(array['A', 'B', 'C', 'D'])[floor(random() * 4) + 1],
	case when random() < 0.8 then 'Активный' else 'Неактивный' end
from generate_series(1, 30);

select * from payments;

with split_pay_by_day as(
	select
		p.id,
		gs::date as payment_date,
		p.amount / nullif((p.date_end - p.date_start), 0) as daily_amount,
		p.customer_group,
		p.customer_status
	from payments p
	cross join generate_series(p.date_start, p.date_end, '1 day'::interval) as gs
)


select * from split_pay_by_day order by id, payment_date;



with split_pay_by_day as(
	select
		p.id,
		gs::date as payment_date,
		p.amount,
		nullif((p.date_end - p.date_start), 0) as count_day,
		p.customer_group,
		p.customer_status
	from payments p
	cross join generate_series(p.date_start, p.date_end, '1 day'::interval) as gs
)

select
	id,
	payment_date,
	amount,
	count_day,
	amount / count_day as daily_amount, -- Находим сумму платежа, распределенную равномерно по дням
	customer_group,
	customer_status
from 
	split_pay_by_day 
order by 
	id, payment_date;




with split_pay_by_month as(
	select
		p.id,
		gs::date as month_start,
		p.customer_group,
		p.customer_status,
		p.amount / nullif(extract(month from age(p.date_end, p.date_start)), 0) as monthly_amount
	from payments p 
	cross join generate_series(
		date_trunc('month', p.date_start),
		date_trunc('month', p.date_end),
		'1 month'::interval
	) as gs
)


with split_pay_by_month as(
	select
		p.id,
		p.amount,
		gs::date as month_start,
		p.date_end,
		extract(month from age(p.date_end, p.date_start)) as count_months,
		p.customer_group,
		p.customer_status
	from payments p 
	cross join generate_series(
		date_trunc('month', p.date_start),
		date_trunc('month', p.date_end),
		'1 month'::interval
	) as gs
)


select
	id,
	amount,
	count_months,
	amount / nullif(count_months, 0) as monthly_amount,
	customer_group,
	customer_status
from
	split_pay_by_month
order by id, month_start;


with split_pay_by_week as (
    select
        p.id,
        gs::date as week_start,  -- Начало недели в интервале платежа
        p.date_end,
        ceil((p.date_end - p.date_start + 1) / 7.0) as count_weeks,  -- Количество недель в диапазоне платежа
        p.amount,
        p.customer_group,
        p.customer_status
    from payments p 
    cross join generate_series(
        date_trunc('week', p.date_start),  -- Начало недели для диапазона платежа
        date_trunc('week', p.date_end),  -- Конец недели для диапазона платежа
        '1 week'::interval  -- Шаг генерации - 1 неделя
    ) as gs
)


select 
	id,
	min(amount) as amount,
	min(count_weeks) as count_weeks
from 
	split_pay_by_week 
group by id;
select
    id,
    amount,
    count_weeks,
    amount / nullif(count_weeks, 0) as weekly_amount,  -- Сумма платежа, распределенная по неделям
    customer_group,
    customer_status
from split_pay_by_week
order by id, week_start;

select 
	id,
	min(amount) as amount,
	min(count_weeks) as count_weeks
from 
	split_pay_by_week 
group by id;


















