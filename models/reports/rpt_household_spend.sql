-- Rapor modeli: gelecek harcama. Grain: household_key. H9–H11 için.
--
-- Kaynak mart_household_spend_dataset (past_sales, future_sales, last_13w_sales_share, private_brand_share).
-- Colab'daki B bölümüyle (spend_model_df) aynı mantık, rakamlar testlerle tutsun diye:
--   * past_sales_w17 / past_baskets_w17: 17. haftadan cutoff_week'e kadar (1–16. hafta ısınma dönemi hariç)
--   * en az 5 sepeti olan haneler (past_baskets_w17 >= 5)
-- last_13w_sales_share ve private_brand_share mart tablosundan olduğu gibi gelir (ısınma dönemi dahil).
-- Pencereyi değiştirirseniz sütun adlarındaki "w17"yi ve Colab'daki B bölümünü birlikte güncelleyin.
--
-- Kova eşikleri yer tutucudur; dağılıma bakıp güncelleyin. *_order sütunları rapor aracında sıralama içindir.

with

spend as (

    select
        household_key,
        cutoff_week,
        horizon_weeks,
        past_sales,
        last_13w_sales_share,
        private_brand_share,
        future_sales,
        future_baskets,
        has_future_purchase,
        has_demographics,
        age_desc,
        income_desc,
        household_size_desc
    from {{ ref('mart_household_spend_dataset') }}

),

past_clean as (

    select
        s.household_key,
        sum(b.sales_value)              as past_sales_w17,
        count(distinct b.basket_id)     as past_baskets_w17,
        count(distinct b.week_no)       as past_active_weeks_w17
    from spend as s
    inner join {{ ref('mart_fct_baskets') }} as b
        on  b.household_key = s.household_key
        and b.week_no >= 17
        and b.week_no <= s.cutoff_week
    group by s.household_key

),

joined as (

    select
        s.*,
        p.past_sales_w17,
        p.past_baskets_w17,
        p.past_active_weeks_w17,

        case
            when p.past_sales_w17 < 500 then 1
            when p.past_sales_w17 < 1500 then 2
            when p.past_sales_w17 < 3000 then 3
            else 4
        end as past_sales_order,

        case
            when s.last_13w_sales_share is null then 0
            when s.last_13w_sales_share < 0.10 then 1
            when s.last_13w_sales_share < 0.20 then 2
            when s.last_13w_sales_share < 0.30 then 3
            else 4
        end as last_13w_share_order,

        case
            when s.private_brand_share is null then 0
            when s.private_brand_share < 0.10 then 1
            when s.private_brand_share < 0.20 then 2
            when s.private_brand_share < 0.30 then 3
            else 4
        end as private_brand_share_order

    from spend as s
    inner join past_clean as p
        on s.household_key = p.household_key
    where p.past_baskets_w17 >= 5

)

select
    *,

    case past_sales_order
        when 1 then '<500'
        when 2 then '500-1500'
        when 3 then '1500-3000'
        else '3000+'
    end as past_sales_bucket,

    case last_13w_share_order
        when 0 then 'Harcama yok'
        when 1 then '0-10%'
        when 2 then '10-20%'
        when 3 then '20-30%'
        else '30%+'
    end as last_13w_share_bucket,

    case private_brand_share_order
        when 0 then 'Marka bilgisi yok'
        when 1 then '0-10%'
        when 2 then '10-20%'
        when 3 then '20-30%'
        else '30%+'
    end as private_brand_share_bucket

from joined