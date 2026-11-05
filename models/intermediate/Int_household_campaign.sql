
-- Hane × kampanya. Grain: household_key × campaign_id (kampanya alan haneler, stg_raw__campaign_table).
-- Hedef: kampanya içinde kupon kullandı mı (redeemed, redemption_count).
-- Özellikler kampanya BAŞLANGICINDAN ÖNCEKİ davranıştan hesaplanır (day < start_day),
-- böylece kupon kullanımının kendisi özelliklere karışmaz.
--   pre_coupon_basket_ratio     : kampanya öncesi sepetlerin kaçı kuponlu/indirimli
--   pre_discount_depth          : kampanya öncesi indirim / raf değeri
--   days_since_last_purchase    : kampanya başlangıcında son alışverişten geçen gün
--   bought_coupon_product_before: kampanyanın kuponlu ürünlerinden birini daha önce aldı mı
-- Not: stg_raw__coupon_redempt'teki kampanya sütunu şu an "campaign".

with

hc as (

    select
        ct.household_key,
        ct.campaign_id,
        cd.campaign_type,
        cd.start_day,
        cd.end_day,
        cd.start_date,
        cd.end_date,
        cd.duration_days
    from {{ ref('stg_raw__campaign_table') }} as ct
    inner join {{ ref('stg_raw__campaign_desc') }} as cd
        on ct.campaign_id = cd.campaign_id

),

pre_baskets as (

    select
        hc.household_key,
        hc.campaign_id,
        count(*)                          as pre_basket_count,
        sum(b.sales_value)                as pre_sales_value,
        sum(b.gross_value)                as pre_gross_value,
        sum(b.total_discount)             as pre_total_discount,
        countif(b.has_coupon_disc)        as pre_coupon_basket_count,
        max(b.day)                        as pre_last_purchase_day
    from hc
    inner join {{ ref('int_baskets') }} as b
        on  b.household_key = hc.household_key
        and b.day           < hc.start_day
    group by hc.household_key, hc.campaign_id

),

pre_coupon_products as (

    select
        hc.household_key,
        hc.campaign_id,
        count(*)                          as prepurchase_line_count,
        count(distinct t.product_id)      as prepurchase_distinct_products,
        sum(t.sales_value)                as prepurchase_sales_value
    from hc
    inner join {{ ref('int_transactions_enriched') }} as t
        on  t.household_key = hc.household_key
        and t.day           < hc.start_day
    inner join {{ ref('int_campaing_product') }} as cp
        on  cp.campaign_id = hc.campaign_id
        and cp.product_id  = t.product_id
    group by hc.household_key, hc.campaign_id

),

redemptions as (

    select
        household_key,
        campaign                       as campaign_id,
        count(*)                       as redemption_count,
        count(distinct coupon_upc)     as distinct_coupons_redeemed,
        min(day)                       as first_redemption_day
    from {{ ref('stg_raw__coupon_redempt') }}
    group by household_key, campaign

)

select
    hc.household_key,
    hc.campaign_id,
    hc.campaign_type,
    hc.start_day,
    hc.end_day,
    hc.start_date,
    hc.end_date,
    hc.duration_days,

    -- hedef
    r.household_key is not null                                         as redeemed,
    coalesce(r.redemption_count, 0)                                     as redemption_count,
    coalesce(r.distinct_coupons_redeemed, 0)                            as distinct_coupons_redeemed,
    r.first_redemption_day,

    -- kampanya öncesi özellikler
    coalesce(pb.pre_basket_count, 0)                                    as pre_basket_count,
    coalesce(pb.pre_sales_value, 0)                                     as pre_sales_value,
    coalesce(pb.pre_coupon_basket_count, 0)                             as pre_coupon_basket_count,
    safe_divide(pb.pre_coupon_basket_count, pb.pre_basket_count)        as pre_coupon_basket_ratio,
    safe_divide(-pb.pre_total_discount, pb.pre_gross_value)             as pre_discount_depth,
    hc.start_day - pb.pre_last_purchase_day                             as days_since_last_purchase,
    coalesce(pp.prepurchase_line_count, 0)                              as prepurchase_line_count,
    coalesce(pp.prepurchase_distinct_products, 0)                       as prepurchase_distinct_products,
    coalesce(pp.prepurchase_sales_value, 0)                             as prepurchase_sales_value,
    coalesce(pp.prepurchase_line_count, 0) > 0                          as bought_coupon_product_before

from hc
left join pre_baskets as pb
    on hc.household_key = pb.household_key and hc.campaign_id = pb.campaign_id
left join pre_coupon_products as pp
    on hc.household_key = pp.household_key and hc.campaign_id = pp.campaign_id
left join redemptions as r
    on hc.household_key = r.household_key and hc.campaign_id = r.campaign_id