with 

source as (

    select * from {{ source('raw', 'campaign_desc') }}

),

renamed as (

    select
        CAST(CAMPAIGN  AS INT64)                                             AS campaign_id,
        DESCRIPTION                                                          AS campaign_type,
        CAST(START_DAY AS INT64)                                             AS start_day,
        CAST(END_DAY   AS INT64)                                             AS end_day,
        DATE_ADD(DATE '2020-01-01', INTERVAL CAST(START_DAY AS INT64) - 1 DAY) AS start_date,
        DATE_ADD(DATE '2020-01-01', INTERVAL CAST(END_DAY   AS INT64) - 1 DAY) AS end_date,
        CAST(END_DAY AS INT64) - CAST(START_DAY AS INT64) + 1                AS duration_days

    from source

)

select * from renamed