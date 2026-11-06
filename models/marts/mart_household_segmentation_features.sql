-- Segmentasyon (kümeleme) özellikleri. Grain: household_key.
-- Kümeleme için kategori payları ve sepet büyüklüğü sütunlarını kullanın; demografi sütunları
-- yalnızca segment profillemesi içindir (801 hane dışında 'Not Available').
-- Tüm dönemi kapsar: gelecek harcama tahmininde kullanılmamalıdır.
-- Segmentler Python'da üretilip BigQuery'ye geri yazıldıktan sonra household_segments ile birleştirilir.

select
    m.*,
    d.active_weeks,
    d.first_purchase_day,
    d.last_purchase_day,
    d.has_demographics,
    d.age_desc,
    d.marital_status,
    d.income_desc,
    d.homeowner_desc,
    d.hh_comp_desc,
    d.household_size_desc,
    d.kid_category_desc

from {{ ref('int_household_category_mix') }} as m
inner join {{ ref('mart_dim_household') }} as d
    on m.household_key = d.household_key