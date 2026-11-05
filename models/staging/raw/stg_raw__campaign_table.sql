with 

source as (

    select * from {{ source('raw', 'campaign_table') }}

),

renamed as (

    select
        CAST(household_key AS INT64) AS household_key,
        CAST(CAMPAIGN      AS INT64) AS campaign_id

    from source

)

select * from renamed