-- Ürün boyutu. Grain: product_id.
-- Not: akaryakıt ürünleri exclude_fuel = true iken bile burada kalır (fact tablosunda satırı olmaz).
-- Not: işlemlerde olup product tablosunda olmayan product_id'ler burada yoktur; Power BI'da boş (blank) görünür.

select
    product_id,
    manufacturer,
    department,
    cat,
    brand,
    commodity_desc,
    sub_commodity_desc,
    curr_size_of_product,
    coalesce(cat = 'FUEL', false)          as is_fuel,
    coalesce(brand = 'Private', false)     as is_private_brand

from {{ ref('stg_raw__product') }}


  