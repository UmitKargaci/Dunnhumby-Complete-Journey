{{ config(materialized='table') }}
 
-- Sepet başına özet. Grain: household_key × basket_id.
-- Kullanım: alışveriş sayısı, sepet büyüklüğü (kategori sayısı), kuponlu sepet oranı, indirim derinliği.
 
select
    household_key,
    basket_id,
    min(store_id)                                          as store_id,
    min(day)                                               as day,
    min(week_no)                                           as week_no,
    min(purchase_date)                                     as purchase_date,
    sum(sales_value)                                       as sales_value,
    sum(gross_value)                                       as gross_value,
    sum(paid_value)                                        as paid_value,
    sum(total_discount)                                    as total_discount,
    -- indirim derinliği: indirimin raf değerine oranı (0 = indirimsiz, 0.25 = %25)
    safe_divide(-sum(total_discount), sum(gross_value))    as discount_depth,
    sum(quantity)                                          as total_quantity,
    count(*)                                               as line_count,
    count(distinct product_id)                             as distinct_products,
    count(distinct cat)                                    as category_count,
    logical_or(has_coupon_disc)                            as has_coupon_disc
 
from {{ ref('int_transactions_enriched') }}
group by household_key, basket_id