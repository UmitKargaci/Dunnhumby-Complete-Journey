{{ config(tags=['needs_ml_output']) }}

-- Rapor modeli: segment profili. Grain: household_key. H12 (sepet büyüklüğü) ve H13 (kategori payları) için.
-- Kaynak mart_household_segmentation_features (tüm dönem) + ml_output.household_segments.
-- Segmentler tüm dönem verisiyle kuruldu; bu sayfadaki farklar betimleyicidir.
-- Eşleme varsayımı: market = GROCERY, taze = FRESH, kişisel bakım = DRUG_GM.
-- Segmenti olmayan haneler 'Segment yok' etiketiyle kalır, böylece toplamlar tutar.

select
    f.household_key,
    s.segment_id,
    case
        when s.segment_id is null then 'Segment yok'
        else concat('Segment ', cast(s.segment_id as string))
    end as segment_name,

    f.total_sales,
    f.basket_count,
    f.avg_basket_sales,
    f.avg_categories_per_basket,
    f.avg_products_per_basket,

    f.grocery_share,
    f.fresh_share,
    f.drug_gm_share,
    f.misc_share,
    f.fuel_share,
    f.other_share,

    f.has_demographics,
    f.age_desc,
    f.marital_status,
    f.income_desc,
    f.homeowner_desc,
    f.hh_comp_desc,
    f.household_size_desc,
    f.kid_category_desc

from {{ ref('mart_household_segmentation_features') }} as f
left join {{ source('ml_output', 'household_segments') }} as s
    on f.household_key = s.household_key