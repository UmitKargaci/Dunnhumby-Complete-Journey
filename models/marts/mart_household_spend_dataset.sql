-- Gelecek harcama tahmini için veri seti. Grain: household_key.
-- Hedef: future_sales (cutoff sonrası horizon_weeks haftalık harcama), has_future_purchase.
-- Özellikler yalnızca cutoff_week'e kadarki veriden hesaplanır (veri sızıntısı yok).
-- Uyarı: int_household_category_mix / ml_household_segmentation_features tüm dönemi kapsar;
-- bu tahmin modelinde o tablodaki payları KULLANMAYIN.
-- Demografi eksik hanelerde 'Not Available' (has_demographics = false).

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

from {{ ref('int_household_future_spend') }} as f
inner join {{ ref('mart_dim_household') }} as d
    on f.household_key = d.household_key