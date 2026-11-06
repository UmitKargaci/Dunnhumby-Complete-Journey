-- Hane boyutu. Grain: household_key.
-- Hane evreni: işlem, kampanya ve kupon kullanımı tablolarındaki tüm haneler
-- (Power BI'da fact tablolarında kayıp ilişki kalmaması için).
-- Demografi hanelerin yalnızca bir kısmı için (yaklaşık 801) var. Olmayanlar 'Not Available' olur
-- ve has_demographics = false; kaynaktaki gerçek 'Unknown' değerinden ayrı tutulur.
-- Aktivite sütunları int_baskets'e dayanır: exclude_fuel = true iken yalnızca akaryakıt alan haneler 0 sepetli görünür.

with

households as (

    select household_key from {{ ref('stg_raw__transaction_data') }}
    union distinct
    select household_key from {{ ref('stg_raw__campaign_table') }}
    union distinct
    select household_key from {{ ref('stg_raw__coupon_redempt') }}

),

demographics as (

    select * from {{ ref('stg_raw__hh_demographic') }}

),

activity as (

    select
        household_key,
        min(purchase_date)            as first_purchase_date,
        max(purchase_date)            as last_purchase_date,
        min(day)                      as first_purchase_day,
        max(day)                      as last_purchase_day,
        count(*)                      as basket_count,
        count(distinct week_no)       as active_weeks,
        sum(sales_value)              as total_sales
    from {{ ref('int_baskets') }}
    group by household_key

)

select
    h.household_key,
    d.household_key is not null                              as has_demographics,
    coalesce(d.age_desc, 'Not Available')                    as age_desc,
    coalesce(d.marital_status, 'Not Available')              as marital_status,
    coalesce(d.income_desc, 'Not Available')                 as income_desc,
    coalesce(d.homeowner_desc, 'Not Available')              as homeowner_desc,
    coalesce(d.hh_comp_desc, 'Not Available')                as hh_comp_desc,
    coalesce(d.household_size_desc, 'Not Available')         as household_size_desc,
    coalesce(d.kid_category_desc, 'Not Available')           as kid_category_desc,
    a.first_purchase_date,
    a.last_purchase_date,
    a.first_purchase_day,
    a.last_purchase_day,
    coalesce(a.basket_count, 0)                              as basket_count,
    coalesce(a.active_weeks, 0)                              as active_weeks,
    coalesce(a.total_sales, 0)                               as total_sales

from households as h
left join demographics as d
    on h.household_key = d.household_key
left join activity as a
    on h.household_key = a.household_key