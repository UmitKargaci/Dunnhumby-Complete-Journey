-- Rapor modeli: kampanya × kupon kategorisi. Grain: campaign_id × cat. H15'in ısı haritası ve H7'nin kampanya tablosu için.
-- Kaynak mart_campaign_cou_cat (product_share: kampanyadaki kuponlu ürünlerin kaçı bu kategoride) + kampanya özeti.
-- Segment tarafı (uyum skoru, segment × kupon kategorisi) Python çıktısıdır, ayrı tabloda tutulur.

select
    c.campaign_id,
    c.campaign_type,
    cc.cat,
    cc.coupon_count,
    cc.product_count,
    cc.product_share,

    -- kampanya düzeyi (her kategori satırında tekrar eder; kampanya bazında toplamayın, ortalama ya da max alın)
    c.start_day,
    c.end_day,
    c.duration_days,
    c.targeted_households,
    c.redeemed_households,
    c.household_redemption_rate

from {{ ref('mart_campaign_cou_cat') }} as cc
inner join {{ ref('mart_dim_campaign') }} as c
    on cc.campaign_id = c.campaign_id