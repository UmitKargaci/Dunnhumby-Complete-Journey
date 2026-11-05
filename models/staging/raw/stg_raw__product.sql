-- Ürün tablosu + Sheets'teki kategori eşlemesi (department_category_map).
-- Eşlemede olmayan departmanlar OTHER sayılır.
-- Karşılaştırma büyük harf ve boşluksuz yapılır; Sheets'teki yazım farkları eşlemeyi bozmaz.

with source as (

    select * from {{ source('raw', 'product') }}

),

mapping as (

    select
        upper(trim(department)) as department_key,
        upper(trim(cat))        as cat
    from {{ source('ref', 'department_category_map') }}
    where department is not null
      and trim(department) != ''

),

renamed as (

    select
        CAST(s.PRODUCT_ID AS INT64)                     AS product_id,
        s.MANUFACTURER                                  AS manufacturer,
        nullif(trim(s.DEPARTMENT), '')                  AS department,
        coalesce(m.cat, 'OTHER')                        AS cat,
        s.BRAND                                         AS brand,
        nullif(trim(s.COMMODITY_DESC), '')              AS commodity_desc,
        nullif(trim(s.SUB_COMMODITY_DESC), '')          AS sub_commodity_desc,
        nullif(trim(s.CURR_SIZE_OF_PRODUCT), '')        AS curr_size_of_product
    from source as s
    left join mapping as m
        on upper(trim(s.DEPARTMENT)) = m.department_key

)

select * from renamed