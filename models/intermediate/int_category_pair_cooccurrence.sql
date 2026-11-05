-- Aynı sepette birlikte görülen kategori çiftleri. Grain: cat_a × cat_b (cat_a < cat_b, her çift bir kez).
-- support    : çiftin geçtiği sepet / tüm sepetler
-- confidence : A'yı içeren sepetlerin kaçı B'yi de içeriyor
-- lift       : 1'den büyükse kategoriler rastlantıdan daha sık birlikte alınıyor
-- Not: cat yalnızca birkaç değer alır. Daha ayrıntılı birliktelik için aynı mantıkla
-- commodity_desc düzeyine inilebilir.

with

basket_cats as (

    select household_key, basket_id, cat
    from {{ ref('int_basket_category') }}

),

total as (

    select count(*) as total_baskets
    from (select distinct household_key, basket_id from basket_cats)

),

cat_counts as (

    select cat, count(*) as baskets_with_cat
    from basket_cats
    group by cat

),

pairs as (

    select
        a.cat   as cat_a,
        b.cat   as cat_b,
        count(*) as pair_baskets
    from basket_cats as a
    inner join basket_cats as b
        on  a.household_key = b.household_key
        and a.basket_id     = b.basket_id
        and a.cat           < b.cat
    group by cat_a, cat_b

)

select
    p.cat_a,
    p.cat_b,
    p.pair_baskets,
    ca.baskets_with_cat                                                    as baskets_a,
    cb.baskets_with_cat                                                    as baskets_b,
    t.total_baskets,
    safe_divide(p.pair_baskets, t.total_baskets)                           as support,
    safe_divide(p.pair_baskets, ca.baskets_with_cat)                       as confidence_a_to_b,
    safe_divide(p.pair_baskets, cb.baskets_with_cat)                       as confidence_b_to_a,
    safe_divide(p.pair_baskets * t.total_baskets,
                ca.baskets_with_cat * cb.baskets_with_cat)                 as lift

from pairs as p
inner join cat_counts as ca on p.cat_a = ca.cat
inner join cat_counts as cb on p.cat_b = cb.cat
cross join total as t