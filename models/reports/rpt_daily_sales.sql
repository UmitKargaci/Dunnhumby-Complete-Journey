-- Rapor modeli: günlük satış. Grain: day. Genel özet sayfası için.
-- Oranlar (ortalama sepet, kuponlu sepet oranı) burada saklanmaz: gün/hafta/ay düzeyinde doğru toplansın diye
-- rapor aracında toplamlardan hesaplanır (ortalama sepet = sales_value / basket_count).
-- Tarihler temsilidir (1. gün = 2020-01-01). Satışı olmayan günler 0 ile yer alır.

with

daily as (

    select
        day,
        count(*)                             as basket_count,
        count(distinct household_key)        as active_households,
        sum(sales_value)                     as sales_value,
        sum(gross_value)                     as gross_value,
        sum(total_discount)                  as total_discount,
        countif(has_coupon_disc)             as coupon_basket_count
    from {{ ref('mart_fct_baskets') }}
    group by day

)

select
    d.day,
    d.date_day,
    d.week_no,
    d.week_start_date,
    d.is_partial_week,
    coalesce(f.basket_count, 0)          as basket_count,
    coalesce(f.active_households, 0)     as active_households,
    coalesce(f.sales_value, 0)           as sales_value,
    coalesce(f.gross_value, 0)           as gross_value,
    coalesce(f.total_discount, 0)        as total_discount,
    coalesce(f.coupon_basket_count, 0)   as coupon_basket_count

from {{ ref('mart_dim_date') }} as d
left join daily as f
    on d.day = f.day