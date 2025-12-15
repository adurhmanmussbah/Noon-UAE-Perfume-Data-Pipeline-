CREATE OR ALTER VIEW dbo.v_noon_analytics AS
SELECT
    title,
    brand,
    brand_cleaned,

    perfume_type,

    size_ml,
    size_oz,
    size_status,

    rating,
    rating_count,

    price_new,
    price_old,

    has_discount,
    discount_amount,
    discount_pct,

    price_per_ml,

    demand_score,

    category_name,
    category_rank,

    selling_fast,

    page_no,
    product_url,
    scraped_at,

    -- Derived helper fields (VERY useful)
    CASE
        WHEN rating_count > 0 THEN rating
        ELSE NULL
    END AS rating_effective,

    CASE
        WHEN size_status = 'EXTRACTED' THEN 1
        ELSE 0
    END AS has_valid_size

FROM Perfume.dbo.Noon2;
