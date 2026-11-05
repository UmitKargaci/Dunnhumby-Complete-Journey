with 

source as (

    select * from {{ source('raw', 'coupon') }}

),

renamed as (

    select distinct
        CAST(COUPON_UPC AS INT64)   AS coupon_upc,
        CAST(PRODUCT_ID AS INT64)   AS product_id,
        CAST(CAMPAIGN   AS INT64)   AS campaign


    from source

)

select * from renamed