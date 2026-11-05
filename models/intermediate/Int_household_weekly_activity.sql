-- Hane × hafta aktivitesi. Grain: household_key × week_no.
-- Seyrek tablo: hanenin alışveriş yapmadığı haftalar için satır yoktur (analizde 0 sayılmalı).
-- Not: 1. hafta 5 gün, 102. hafta eksik gün içerir; haftalık karşılaştırmalarda dikkate alın.

select
    household_key,
    week_no,
    count(*)                       as basket_count,
    count(distinct day)            as visit_days,
    sum(sales_value)               as sales_value,
    sum(gross_value)               as gross_value,
    sum(total_discount)            as total_discount,
    countif(has_coupon_disc)       as coupon_basket_count

from {{ ref('int_baskets') }}
group by household_key, week_no