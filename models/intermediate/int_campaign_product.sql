-- Kampanyalardaki kupon kapsamındaki ürünler. Grain: campaign_id × product_id.
-- Not: stg_raw__coupon'daki kampanya sütunu şu an "campaign". SQL'de campaign_id'ye çevrilirse
-- aşağıdaki "c.campaign" ifadesini "c.campaign_id" yapın.

select
    c.campaign           as campaign_id,
    c.product_id,
    coalesce(p.cat, 'OTHER')   as cat,
    p.brand

from {{ ref('stg_raw__coupon') }} as c
left join {{ ref('stg_raw__product') }} as p
    on c.product_id = p.product_id
group by c.campaign, c.product_id, p.cat, p.brand