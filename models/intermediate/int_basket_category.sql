-- Sepet × kategori. Grain: household_key × basket_id × cat.
-- Kullanım: birlikte alınan kategoriler, sepet içeriği analizi.
 
select
    household_key,
    basket_id,
    cat,
    count(*)           as line_count,
    sum(sales_value)   as sales_value
 
from {{ ref('int_transactions_enriched') }}
group by household_key, basket_id, cat