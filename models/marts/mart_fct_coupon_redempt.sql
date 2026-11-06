-- Kupon kullanımı fact tablosu. Grain: kupon kullanım satırı (hane × gün × kupon × kampanya).
-- Not: stg_raw__coupon_redempt'teki kampanya sütunu şu an "campaign".

select
    household_key,
    campaign        as campaign_id,
    coupon_upc,
    day,
    week_no,
    redemption_date

from {{ ref('stg_raw__coupon_redempt') }}