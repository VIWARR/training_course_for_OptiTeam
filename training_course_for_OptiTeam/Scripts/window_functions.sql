select * from auto;
---------------------------------------------------

create table auto_backup as select * from auto;
---------------------------------------------------

with ranked_autos as (
    select
        row_number() over (partition by brand order by ctid) AS row_num,
        *
    from
        auto
)
SELECT *
FROM ranked_autos;
---------------------------------------------------

create table auto_backup as select * from auto;
---------------------------------------------------



