-- Kupon yanıtı veri seti. Grain: household_key × campaign_id.
-- Hedef: redeemed (kampanyada kupon kullandı mı) veya redemption_count.
-- Özellikler kampanya başlangıcından önceki davranıştır; demografi dim_household'dan gelir
-- (eksik hanelerde 'Not Available', has_demographics = false).
-- Not: aynı hane birden çok kampanyada yer aldığı için train/test ayrımını hane bazında yapın
-- (aynı hane iki tarafa düşerse sonuç olduğundan iyi görünür).

select
    f.*,
    d.has_demographics,
    d.age_desc,
    d.marital_status,
    d.income_desc,
    d.homeowner_desc,
    d.hh_comp_desc,
    d.household_size_desc,
    d.kid_category_desc

from {{ ref('mart_fct_household_campaign') }} as f
inner join {{ ref('mart_dim_household') }} as d
    on f.household_key = d.household_key