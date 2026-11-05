{{ config(materialized='table') }}

-- İşlem satırı + ürün bilgisi. Grain: işlem satırı (stg_raw__transaction_data ile aynı).
-- exclude_fuel = true (varsayılan) ise akaryakıt (cat = 'FUEL') satırları burada dışarıda bırakılır.
-- Tüm intermediate modeller bu tablodan beslendiği için tek bir değişkenle karar değişebilir:
--   dbt run --vars '{exclude_fuel: false}'
--
-- Değer alanları (Dunnhumby veri sözlüğüne göre; belgeyle doğrulayın):
--   sales_value    : perakendecinin satıştan aldığı tutar (analizlerde "harcama" olarak bunu kullanıyoruz)
--   gross_value    : indirim öncesi raf değeri = sales_value - retail_disc - coupon_match_disc
--   total_discount : retail_disc + coupon_disc + coupon_match_disc (sıfır veya negatif)
--   paid_value     : müşterinin ödediği tutar = sales_value + coupon_disc

with

transactions as (

    select * from {{ ref('stg_raw__transaction_data') }}

),

products as (

    select * from {{ ref('stg_raw__product') }}

),

joined as (

    select
        t.household_key,
        t.basket_id,
        t.product_id,
        t.store_id,
        t.day,
        t.week_no,
        t.purchase_date,
        t.trans_time,
        t.quantity,
        t.sales_value,
        t.retail_disc,
        t.coupon_disc,
        t.coupon_match_disc,
        t.sales_value - (t.retail_disc + t.coupon_match_disc)                       as gross_value,
        t.retail_disc + t.coupon_disc + t.coupon_match_disc                         as total_discount,
        t.sales_value + t.coupon_disc                                               as paid_value,
        (coalesce(t.coupon_disc, 0) < 0 or coalesce(t.coupon_match_disc, 0) < 0)    as has_coupon_disc,
        p.department,
        coalesce(p.cat, 'OTHER')                                                    as cat,
        p.brand,
        p.commodity_desc,
        p.sub_commodity_desc,
        p.manufacturer,
        coalesce(p.cat = 'FUEL', false)                                             as is_fuel,
        coalesce(p.brand = 'Private', false)                                        as is_private_brand

    from transactions as t
    left join products as p
        on t.product_id = p.product_id

)

select *
from joined
{% if var('exclude_fuel', true) %}
where not is_fuel
{% endif %}