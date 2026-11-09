-- rpt_coupon_response_segments satır sayısı rpt_coupon_response ile aynı olmalı (segment join'i satır çoğaltmamalı).
select 1
from (
    select
        (select count(*) from {{ ref('rpt_coupon_response_segments') }}) as seg_rows,
        (select count(*) from {{ ref('rpt_coupon_response') }}) as base_rows
)
where seg_rows != base_rows