-- Kampanya kuponlarının kategori dağılımı (Power BI için). Grain: campaign_id × cat.
-- Segment ile birleştirme, segmentler Python'dan BigQuery'ye yazıldıktan sonra yapılır.

select *
from {{ ref('int_campaign_coupon_categories') }}