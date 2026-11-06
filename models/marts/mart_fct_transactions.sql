-- İşlem satırı fact tablosu. Grain: işlem satırı (hane × sepet × ürün).
-- Ürün özellikleri (kategori, marka vb.) dim_product üzerinden gelir.
-- exclude_fuel = true iken akaryakıt satırları yoktur (bkz. int_transactions_enriched).

select
    household_key,
    basket_id,
    product_id,
    store_id,
    day,
    week_no,
    purchase_date,
    trans_time,
    quantity,
    sales_value,
    gross_value,
    paid_value,
    total_discount,
    retail_disc,
    coupon_disc,
    coupon_match_disc,
    has_coupon_disc

from {{ ref('int_transactions_enriched') }}