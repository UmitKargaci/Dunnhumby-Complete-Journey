-- Tarih boyutu. Grain: day (gün sayacı 1..max_day).
-- Tarihler TEMSİLİDİR (1. gün = 2020-01-01). Hafta günü, ay ve mevsim yorumları gerçek takvimi yansıtmaz.
-- Hafta kuralı: week_no = DIV(day + 1, 7) + 1; 1. hafta 5 gün (2020-01-01 – 2020-01-05), sonraki haftalar pazartesi başlar.
-- max_day değişkeni (varsayılan 711) kaynak veriyle uyumlu olmalı.

with

days as (

    select day_no
    from unnest(generate_array(1, {{ var('max_day', 711) }})) as day_no

),

dates as (

    select
        day_no,
        date_add(date '2020-01-01', interval day_no - 1 day)     as date_day,
        div(day_no + 1, 7) + 1                                   as week_no
    from days

)

select
    day_no                                                       as day,
    date_day,
    week_no,
    case
        when week_no = 1 then date '2020-01-01'
        else date_add(date '2020-01-06', interval (week_no - 2) * 7 day)
    end                                                          as week_start_date,
    extract(year from date_day)                                  as calendar_year,
    extract(month from date_day)                                 as calendar_month,
    format_date('%B', date_day)                                  as month_name,
    extract(dayofweek from date_day)                             as day_of_week_num,  -- 1 = pazar
    format_date('%A', date_day)                                  as day_name,
    extract(dayofweek from date_day) in (1, 7)                   as is_weekend,
    count(*) over (partition by week_no) < 7                     as is_partial_week

from dates