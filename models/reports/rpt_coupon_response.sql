-- Rapor modeli: kupon yanıtı. Grain: household_key × campaign_id.
-- Looker Studio / Power BI için H1–H7. Segment (H8) bu modelde yok: segment tablosu Python'dan gelir,
-- bu yüzden ayrı modelde birleştirilir (rpt_coupon_response_segments).
--
-- Pencere: start_day - lookback_days <= day < start_day (varsayılan 91 gün = 13 hafta).
-- Python'daki 02_hipotez_testleri_v2.py ile aynı mantık; rakamlar testlerle tutsun diye iki taraf birlikte değişmeli.
-- Kullanım: dbt run --select rpt_coupon_response --vars '{lookback_days: 91}'
--
-- Kova eşikleri yer tutucudur; dağılıma bakıp güncelleyin. Etiketlerin başındaki rakam, rapor aracında sıralama içindir.

{% set lb = var('lookback_days', 91) %}

with

hc as (

    select household_key, campaign_id, campaign_type, start_day, redeemed
    from {{ ref('mart_fct_household_campaign') }}

),

pre_baskets as (

    select
        hc.household_key,
        hc.campaign_id,
        count(*)                                  as pre_basket_count,
        sum(b.sales_value)                        as pre_sales_value,
        sum(b.gross_value)                        as pre_gross_value,
        sum(b.total_discount)                     as pre_total_discount,
        countif(b.has_coupon_disc)                as pre_coupon_basket_count,
        max(b.day)                                as pre_last_purchase_day
    from hc
    inner join {{ ref('mart_fct_baskets') }} as b
        on  b.household_key = hc.household_key
        and b.day <  hc.start_day
        and b.day >= hc.start_day - {{ lb }}
    group by hc.household_key, hc.campaign_id

),

pre_products as (

    select
        hc.household_key,
        hc.campaign_id,
        count(*)                                  as prepurchase_line_count
    from hc
    inner join {{ ref('mart_fct_transactions') }} as t
        on  t.household_key = hc.household_key
        and t.day <  hc.start_day
        and t.day >= hc.start_day - {{ lb }}
    inner join {{ ref('int_campaign_product') }} as cp
        on  cp.campaign_id = hc.campaign_id
        and cp.product_id  = t.product_id
    group by hc.household_key, hc.campaign_id

),

features as (

    select
        hc.household_key,
        hc.campaign_id,
        hc.campaign_type,
        hc.start_day,
        hc.redeemed,
        coalesce(pb.pre_basket_count, 0)          as pre_basket_count,
        coalesce(pb.pre_sales_value, 0)           as pre_sales_value,
        coalesce(pb.pre_coupon_basket_count, 0)   as pre_coupon_basket_count,
        safe_divide(pb.pre_coupon_basket_count, pb.pre_basket_count)
                                                  as pre_coupon_basket_ratio,
        safe_divide(-pb.pre_total_discount, nullif(pb.pre_gross_value, 0))
                                                  as pre_discount_depth,
        hc.start_day - pb.pre_last_purchase_day   as days_since_last_purchase,
        coalesce(pp.prepurchase_line_count, 0) > 0
                                                  as bought_coupon_product_before
    from hc
    left join pre_baskets  as pb on hc.household_key = pb.household_key and hc.campaign_id = pb.campaign_id
    left join pre_products as pp on hc.household_key = pp.household_key and hc.campaign_id = pp.campaign_id

)

select
    *,

    case
        when pre_basket_count = 0 then 'Alışveriş yok'
        when pre_basket_count <= 5 then '1-5'
        when pre_basket_count <= 15 then '6-15'
        when pre_basket_count <= 30 then '16-30'
        else '30+'
    end as basket_count_bucket,

    case
        when pre_sales_value <= 0 then 'Harcama yok'
        when pre_sales_value < 100 then '<100'
        when pre_sales_value < 300 then '100-300'
        when pre_sales_value < 700 then '300-700'
        else '700+'
    end as sales_value_bucket,

    case
        when pre_coupon_basket_ratio is null then 'Alışveriş yok'
        when pre_coupon_basket_ratio < 0.1 then '0-10%'
        when pre_coupon_basket_ratio < 0.25 then '10-25%'
        when pre_coupon_basket_ratio < 0.5 then '25-50%'
        else '50%+'
    end as coupon_ratio_bucket,

    case
        when days_since_last_purchase is null then 'Alışveriş yok'
        when days_since_last_purchase <= 7 then '0-7 gün'
        when days_since_last_purchase <= 14 then '8-14 gün'
        when days_since_last_purchase <= 30 then '15-30 gün'
        else '30+ gün'
    end as recency_bucket,

    case
        when pre_discount_depth is null then 'Alışveriş yok'
        when pre_discount_depth < 0.05 then '<5%'
        when pre_discount_depth < 0.10 then '5-10%'
        when pre_discount_depth < 0.20 then '10-20%'
        else '20%+'
    end as discount_depth_bucket

from features