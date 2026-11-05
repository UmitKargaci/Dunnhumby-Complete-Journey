-- Hane demografisi (2.500 hanenin yalnızca 801'i için kayıt var).
with

source as (

    select * from {{ source('raw', 'hh_demographic') }}

),

renamed as (

    select
        CAST(household_key AS INT64) AS household_key,
        AGE_DESC                     AS age_desc,
        MARITAL_STATUS_CODE          AS marital_status_code,
        INCOME_DESC                  AS income_desc,
        HOMEOWNER_DESC               AS homeowner_desc,
        HH_COMP_DESC                 AS hh_comp_desc,
        HOUSEHOLD_SIZE_DESC          AS household_size_desc,
        KID_CATEGORY_DESC            AS kid_category_desc,
        case MARITAL_STATUS_CODE
            when 'A' then 'Married'
            when 'B' then 'Single'
       else 'Unknown'
   end as marital_status,
    from source

)

select * from renamed