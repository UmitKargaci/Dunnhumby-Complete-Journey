-- İşlem satırı + ürün bilgisi. Grain: işlem satırı (staging ile aynı).
with

transactions as (
    select * from {{ ref('stg_raw__transaction_data') }}
),

products as (
    select * from {{ ref('stg_raw__product') }}
)

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
    -- Müşterinin ödediği tutar (Dunnhumby sözlüğüne göre; doğrulayın)
    t.sales_value - (t.retail_disc + t.coupon_match_disc) as customer_paid_value,
    p.department,
    p.cat,
    p.brand,
    p.commodity_desc,
    p.sub_commodity_desc,
    p.manufacturer,
    coalesce(p.cat = 'FUEL', false)                       as is_fuel

from transactions as t
left join products as p
    on t.product_id = p.product_id