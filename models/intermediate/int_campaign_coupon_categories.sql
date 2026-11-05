-- Kampanya kuponlarının kategori dağılımı. Grain: campaign_id × cat.
-- product_share: kampanyadaki kuponlu ürünlerin kaçı bu kategoride.
-- Not: stg_raw__coupon'daki kampanya sütunu şu an "campaign" (bkz. int_campaign_products).

with

coupon_products as (

    select
        c.campaign                  as campaign_id,
        c.coupon_upc,
        c.product_id,
        coalesce(p.cat, 'OTHER')    as cat
    from {{ ref('stg_raw__coupon') }} as c
    left join {{ ref('stg_raw__product') }} as p
        on c.product_id = p.product_id

),

by_cat as (

    select
        campaign_id,
        cat,
        count(distinct coupon_upc)   as coupon_count,
        count(distinct product_id)   as product_count
    from coupon_products
    group by campaign_id, cat

)

select
    b.campaign_id,
    d.campaign_type,
    b.cat,
    b.coupon_count,
    b.product_count,
    safe_divide(b.product_count, sum(b.product_count) over (partition by b.campaign_id)) as product_share

from by_cat as b
left join {{ ref('stg_raw__campaign_desc') }} as d
    on b.campaign_id = d.campaign_id


