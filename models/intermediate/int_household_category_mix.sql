-- Hane başına kategori payları ve sepet büyüklüğü. Grain: household_key.
-- Segmentasyon özellikleri için (tüm dönem). Gelecek harcama tahmininde KULLANMAYIN:
-- tüm haneyi kapsadığı için veri sızıntısı yaratır, orada int_household_future_spend kullanılır.
-- Eşleme varsayımı: market = GROCERY, taze = FRESH, kişisel bakım = DRUG_GM (ilaç ve genel ürünler).

with

cat_sales as (

    select
        household_key,
        sum(sales_value)                                       as total_sales,
        sum(if(cat = 'GROCERY', sales_value, 0))               as grocery_sales,
        sum(if(cat = 'FRESH',   sales_value, 0))               as fresh_sales,
        sum(if(cat = 'DRUG_GM', sales_value, 0))               as drug_gm_sales,
        sum(if(cat = 'MISC',    sales_value, 0))               as misc_sales,
        sum(if(cat = 'FUEL',    sales_value, 0))               as fuel_sales,
        sum(if(cat = 'OTHER',   sales_value, 0))               as other_sales
    from {{ ref('int_transactions_enriched') }}
    group by household_key

),

basket_stats as (

    select
        household_key,
        count(*)                       as basket_count,
        avg(sales_value)               as avg_basket_sales,
        avg(category_count)            as avg_categories_per_basket,
        avg(distinct_products)         as avg_products_per_basket
    from {{ ref('int_baskets') }}
    group by household_key

)

select
    c.household_key,
    c.total_sales,
    c.grocery_sales,
    c.fresh_sales,
    c.drug_gm_sales,
    c.misc_sales,
    c.fuel_sales,
    c.other_sales,
    safe_divide(c.grocery_sales, c.total_sales)    as grocery_share,
    safe_divide(c.fresh_sales,   c.total_sales)    as fresh_share,
    safe_divide(c.drug_gm_sales, c.total_sales)    as drug_gm_share,
    safe_divide(c.misc_sales,    c.total_sales)    as misc_share,
    safe_divide(c.fuel_sales,    c.total_sales)    as fuel_share,
    safe_divide(c.other_sales,   c.total_sales)    as other_share,
    b.basket_count,
    b.avg_basket_sales,
    b.avg_categories_per_basket,
    b.avg_products_per_basket

from cat_sales as c
inner join basket_stats as b
    on c.household_key = b.household_key