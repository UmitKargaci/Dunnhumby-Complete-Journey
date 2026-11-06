-- Aynı sepette birlikte alınan kategori çiftleri (Power BI için). Grain: cat_a × cat_b.
-- Hesaplama int_category_pair_cooccurrence içinde yapılır.

select *
from {{ ref('int_category_pair_cooccurrence') }}