-- Hane × kampanya fact tablosu. Grain: household_key × campaign_id.
-- Hedef: redeemed / redemption_count. Özellikler kampanya başlangıcından önceki davranıştan hesaplanır.
-- Demografi için dim_household'a bağlanın.

select *
from {{ ref('Int_household_campaign') }}