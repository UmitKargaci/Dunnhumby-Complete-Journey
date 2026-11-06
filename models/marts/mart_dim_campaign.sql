-- Kampanya boyutu. Grain: campaign_id.
-- household_redemption_rate: kampanyayı alan hanelerin kaçı en az bir kupon kullandı.
-- Not: stg_raw__coupon'daki kampanya sütunu şu an "campaign".

with

campaigns as (

    select * from {{ ref('stg_raw__campaign_desc') }}

),

households as (

    select
        campaign_id,
        count(*)                       as targeted_households,
        countif(redeemed)              as redeemed_households,
        sum(redemption_count)          as redemption_count
    from {{ ref('int_household_campaign') }}
    group by campaign_id

),

coupons as (

    select
        campaign                       as campaign_id,
        count(distinct coupon_upc)     as coupon_count,
        count(distinct product_id)     as coupon_product_count
    from {{ ref('stg_raw__coupon') }}
    group by campaign

)

select
    c.campaign_id,
    c.campaign_type,
    c.start_day,
    c.end_day,
    c.start_date,
    c.end_date,
    c.duration_days,
    coalesce(h.targeted_households, 0)                                   as targeted_households,
    coalesce(h.redeemed_households, 0)                                   as redeemed_households,
    coalesce(h.redemption_count, 0)                                      as redemption_count,
    safe_divide(h.redeemed_households, h.targeted_households)            as household_redemption_rate,
    coalesce(cp.coupon_count, 0)                                         as coupon_count,
    coalesce(cp.coupon_product_count, 0)                                 as coupon_product_count

from campaigns as c
left join households as h
    on c.campaign_id = h.campaign_id
left join coupons as cp
    on c.campaign_id = cp.campaign_id