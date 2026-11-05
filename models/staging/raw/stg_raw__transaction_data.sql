
-- Ham işlem tablosunun temizlenmiş hali.
-- İade ve sıfır miktarlı satırlar çıkarılır, sütun adları küçük harfe çevrilir.
-- purchase_date TEMSİLİDİR: 1. gün = 2020-01-01. WEEK_NO = DIV(DAY + 1, 7) + 1 olduğu için
-- 6. gün pazartesiye denk gelir ve tarihten türetilen haftalar WEEK_NO ile birebir örtüşür.

with 

source as (

    select * from {{ source('raw', 'transaction_data') }}

),

filtered as (

    -- İade, iptal ve sıfır adetli satırlar çıkarılır (18.917 satır)
    select *
    from source
    where SALES_VALUE > 0
    and QUANTITY > 0

),

renamed as (

    select
        CAST(household_key AS INT64)                                        AS household_key,
        CAST(BASKET_ID     AS INT64)                                        AS basket_id,
        CAST(PRODUCT_ID    AS INT64)                                        AS product_id,
        CAST(STORE_ID      AS INT64)                                        AS store_id,
        CAST(DAY           AS INT64)                                        AS day,
        CAST(WEEK_NO       AS INT64)                                        AS week_no,
        DATE_ADD(DATE '2020-01-01', INTERVAL CAST(DAY AS INT64) - 1 DAY)    AS purchase_date,
        DIV(CAST(TRANS_TIME AS INT64), 100)                                 AS trans_hour,
        TIME(DIV(CAST(TRANS_TIME AS INT64), 100),
             MOD(CAST(TRANS_TIME AS INT64), 100), 0)                        AS trans_time,
        QUANTITY                                                            AS quantity,
        SALES_VALUE                                                         AS sales_value,
        LEAST(RETAIL_DISC, 0)                                               AS retail_disc,   -- 36 pozitif değer sıfırlanır
        COUPON_DISC                                                         AS coupon_disc,
        COUPON_MATCH_DISC                                                   AS coupon_match_disc

    from filtered
)

select * from renamed

