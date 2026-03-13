
WITH src AS (
    SELECT *
    FROM {{ ref('date_to_integer')}}

)

SELECT 
    user_id,
    SUM(bit_value) AS bit_value_sum,
    (SUM(bit_value) > 0) AS monthly_active,
    (BITAND(SUM(bit_value), 4261412864) > 0) AS weekly_active,
    (BITAND(SUM(bit_value), 2147483648) > 0) AS daily_active,
    date_recorded_at
FROM src
GROUP BY user_id, date_recorded_at
