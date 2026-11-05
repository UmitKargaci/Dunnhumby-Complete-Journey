-- Hane başına geçmiş davranış özellikleri ve gelecek harcama (hedef). Grain: household_key.
-- Zaman ayrımı: geçmiş = week_no <= cutoff_week, gelecek = cutoff_week+1 ... cutoff_week+horizon_weeks.
-- Değişkenler (dbt_project.yml > vars): cutoff_week (varsayılan 80), horizon_weeks (varsayılan 22).
-- Veri sızıntısını önlemek için tüm özellikler yalnızca cutoff'a kadarki veriden hesaplanır.
-- Yalnızca cutoff'a kadar en az bir alışverişi olan haneler yer alır.

{% set cutoff_week = var('cutoff_week', 80) %}
{% set horizon_weeks = var('horizon_weeks', 22) %}
{% set cutoff_day = 7 * cutoff_week - 2 %}  -- cutoff haftasının son günü (WEEK_NO formülüne göre)

with

tx as (

    select
        household_key,
        basket_id,
        week_no,
        day,
        sales_value,
        brand,
        is_private_brand
    from {{ ref('int_transactions_enriched') }}

),

past as (

    select
        household_key,
        sum(sales_value)                                                              as past_sales,
        count(distinct basket_id)                                                     as past_baskets,
        count(distinct week_no)                                                       as past_active_weeks,
        max(day)                                                                      as last_purchase_day,
        sum(if(week_no > {{ cutoff_week - 13 }}, sales_value, 0))                     as last_13w_sales,
        count(distinct if(week_no > {{ cutoff_week - 13 }}, basket_id, null))         as last_13w_baskets,
        sum(if(is_private_brand, sales_value, 0))                                     as private_brand_sales,
        sum(if(brand is not null, sales_value, 0))                                    as branded_sales
    from tx
    where week_no <= {{ cutoff_week }}
    group by household_key

),

future as (

    select
        household_key,
        sum(sales_value)            as future_sales,
        count(distinct basket_id)   as future_baskets
    from tx
    where week_no >  {{ cutoff_week }}
      and week_no <= {{ cutoff_week + horizon_weeks }}
    group by household_key

)

select
    p.household_key,
    {{ cutoff_week }}                                           as cutoff_week,
    {{ horizon_weeks }}                                         as horizon_weeks,
    p.past_sales,
    p.past_baskets,
    p.past_active_weeks,
    safe_divide(p.past_sales, {{ cutoff_week }})                as past_avg_weekly_sales,
    p.last_13w_sales,
    p.last_13w_baskets,
    safe_divide(p.last_13w_sales, p.past_sales)                 as last_13w_sales_share,
    safe_divide(p.private_brand_sales, p.branded_sales)         as private_brand_share,
    {{ cutoff_day }} - p.last_purchase_day                      as days_since_last_purchase,
    coalesce(f.future_sales, 0)                                 as future_sales,
    coalesce(f.future_baskets, 0)                               as future_baskets,
    coalesce(f.future_sales, 0) > 0                             as has_future_purchase

from past as p
left join future as f
    on p.household_key = f.household_key