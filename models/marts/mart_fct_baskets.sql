-- Sepet fact tablosu. Grain: household_key × basket_id.
-- Sepet bazlı ölçüler için (ortalama sepet, kuponlu sepet oranı, kategori sayısı) bunu kullanın;
-- işlem satırı tablosundan hesaplamak sepet sayısını şişirir.

select
    household_key,
    basket_id,
    store_id,
    day,
    week_no,
    purchase_date,
    sales_value,
    gross_value,
    paid_value,
    total_discount,
    discount_depth,
    total_quantity,
    line_count,
    distinct_products,
    category_count,
    has_coupon_disc

from {{ ref('int_baskets') }}