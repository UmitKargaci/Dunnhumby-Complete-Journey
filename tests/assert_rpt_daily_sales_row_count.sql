-- rpt_daily_sales her gün için tam bir satır içermeli (mart_dim_date ile aynı satır sayısı).
select 1
from (
    select
        (select count(*) from {{ ref('rpt_daily_sales') }}) as rpt_rows,
        (select count(*) from {{ ref('mart_dim_date') }}) as date_rows
)
where rpt_rows != date_rows