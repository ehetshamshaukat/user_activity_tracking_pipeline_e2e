with src_user_cum as (
    select *
    from {{ref('user_cum')}}
),
series as (
SELECT DATEADD(day, seq4(), DATE('2023-01-01')) AS generate_date
FROM TABLE(GENERATOR(ROWCOUNT => 31))
),
   date_to_int as (
      select *,
        case
            when array_contains(generate_date::variant, dates_active)
            then pow(2, 31 - datediff('day',generate_date, date_recorded_at ))
            else 0
        end as int_val
from src_user_cum
cross join series
)

select user_id, sum(int_val)::bigint as bit_value, date_recorded_at
from date_to_int
group by user_id, date_recorded_at


-- correct data generation with date_recorded_at