with 

source as (

    select * from {{ source('raw', 'coupon_redempt') }}

),

renamed as (

    select
        CAST(household_key AS INT64)                                        AS household_key,
        CAST(DAY           AS INT64)                                        AS day,
        DIV(CAST(DAY AS INT64) + 1, 7) + 1                                  AS week_no,
        DATE_ADD(DATE '2020-01-01', INTERVAL CAST(DAY AS INT64) - 1 DAY)    AS redemption_date,
        CAST(COUPON_UPC    AS INT64)                                        AS coupon_upc,
        CAST(CAMPAIGN      AS INT64)                                        AS campaign

    from source

)

select * from renamed