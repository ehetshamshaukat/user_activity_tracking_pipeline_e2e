select date_recorded_at as date,
    sum(case when daily_active = TRUE then 1 else 0 end) as number_of_daily_active ,
    sum(case when weekly_active = TRUE then 1 else 0 end) as number_of_weekly_active, 
    sum(case when monthly_active = TRUE then 1 else 0 end) as number_of_monthly_active 
from {{ref('dau_wau_mau')}}
group by date_recorded_at
order by date_recorded_at asc 