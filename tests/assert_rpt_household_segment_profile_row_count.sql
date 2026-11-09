-- rpt_household_segment_profile satır sayısı mart_household_segmentation_features ile aynı olmalı (segment join'i satır çoğaltmamalı).
select 1
from (
    select
        (select count(*) from {{ ref('rpt_household_segment_profile') }}) as rpt_rows,
        (select count(*) from {{ ref('mart_household_segmentation_features') }}) as src_rows
)
where rpt_rows != src_rows