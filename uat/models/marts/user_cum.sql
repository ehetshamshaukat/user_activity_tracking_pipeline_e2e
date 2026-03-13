
WITH yesterday AS (
    {% if is_incremental() %}
        -- Only select from the table if it already exists
        SELECT user_id, dates_active, date_recorded_at, active_month
        FROM {{ this }}
        WHERE date_recorded_at = (select max(date_recorded_at) from {{this}})
    {% else %}
        SELECT 
            CAST(NULL AS STRING) AS user_id,
            ARRAY_CONSTRUCT() AS dates_active,
            CAST(NULL AS DATE) AS date_recorded_at,
            CAST(null as text ) as active_month
        FROM {{ ref('stg_raw_data') }}
        -- We use a LIMIT 0 to ensure this returns NO rows
        LIMIT 0
    {% endif %}
),

today AS (
    SELECT  DISTINCT DATE(event_time) AS date_active, CAST(user_id AS TEXT) AS user_id, cast(TO_CHAR(event_time, 'Mon') as text) AS active_month
    FROM {{ ref('stg_raw_data') }} 
    WHERE DATE(event_time) = date('2023-01-15')::DATE AND user_id IS NOT NULL
    GROUP BY 1, 2, 3
)

SELECT 
    COALESCE(t.user_id, y.user_id) AS user_id,
    COALESCE(t.active_month, y.active_month) as active_month,
    CASE 
        WHEN y.dates_active IS NULL THEN ARRAY_CONSTRUCT(t.date_active)
        WHEN t.date_active IS NULL THEN y.dates_active
        ELSE array_distinct(ARRAY_CAT( y.dates_active,ARRAY_CONSTRUCT(t.date_active)))
    END AS dates_active,
    coalesce(t.date_active,max(t.date_active) over())  AS date_recorded_at
FROM today as t
FULL OUTER JOIN yesterday as y 
ON t.user_id = y.user_id