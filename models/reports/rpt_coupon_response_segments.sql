{{ config(tags=['needs_ml_output']) }}

-- Kupon yanıtı + segment (H8). Grain: household_key × campaign_id (rpt_coupon_response ile aynı).
-- Segmentler Python'da (Colab) üretilip ml_output.household_segments tablosuna yazılır; tablo yoksa bu model çalışmaz.
-- Segmentler tüm dönem verisiyle kuruldu (kampanya sonrası davranışı da içerir), H8 grafiğini betimleyici okuyun.
-- Segmenti olmayan haneler (kümelemeye girmeyenler) 'Segment yok' etiketiyle kalır, böylece toplamlar tutar.

select
    r.*,
    s.segment_id,
    case
        when s.segment_id is null then 'Segment yok'
        else concat('Segment ', cast(s.segment_id as string))
    end as segment_name

from {{ ref('rpt_coupon_response') }} as r
left join {{ source('ml_output', 'household_segments') }} as s
    on r.household_key = s.household_key