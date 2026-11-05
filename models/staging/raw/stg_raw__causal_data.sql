with 

source as (

    select * from {{ source('raw', 'causal_data') }}

),

renamed as (


    select
        CAST(PRODUCT_ID AS INT64) AS product_id,
        CAST(STORE_ID AS INT64) AS store_id,
        CAST(WEEK_NO AS INT64) AS week_no,
        DATE_ADD(DATE '2019-12-30', INTERVAL (CAST(WEEK_NO AS INT64) - 1) * 7 DAY) AS week_start_date,
        CAST(display AS STRING) AS display_code,
        CAST(mailer AS STRING) AS mailer_code,
        CAST(display AS STRING) != '0' AS is_on_display,
        CAST(mailer AS STRING) != '0' AS is_in_mailer
    from source

)

select * from renamed