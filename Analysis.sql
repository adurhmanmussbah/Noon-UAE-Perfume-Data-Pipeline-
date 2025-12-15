----Market volume Top brands 

SELECT TOP 20
    brand_cleaned,
    COUNT(*) AS products
FROM dbo.v_noon_analytics
GROUP BY brand_cleaned
ORDER BY products DESC;


-----type distribution

SELECT
    perfume_type,
    COUNT(*) AS products
FROM dbo.v_noon_analytics
GROUP BY perfume_type
ORDER BY products DESC;


-------Price Distribution (Summary Stats)

SELECT
    MIN(price_new) AS min_price,
    MAX(price_new) AS max_price,
    AVG(price_new) AS avg_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_new) OVER() AS median_price
FROM dbo.v_noon_analytics
WHERE price_new IS NOT NULL;



-------Discount Coverage + Avg Discount %
SELECT
    has_discount,
    COUNT(*) AS products,
    AVG(discount_pct) AS avg_discount_pct
FROM dbo.v_noon_analytics
GROUP BY has_discount;



----Best Value Brands (Lowest price_per_ml)

SELECT TOP 20
    brand_cleaned,
    AVG(price_per_ml) AS avg_price_per_ml,
    COUNT(*) AS n
FROM dbo.v_noon_analytics
WHERE price_per_ml IS NOT NULL
GROUP BY brand_cleaned
HAVING COUNT(*) >= 20
ORDER BY avg_price_per_ml ASC;

----Demand Score Distribution (Percentiles)

SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY demand_score) OVER() AS p25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY demand_score) OVER() AS p50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY demand_score) OVER() AS p75
FROM dbo.v_noon_analytics
WHERE demand_score IS NOT NULL;


----Demand vs Discount (Do discounted items score higher?)

SELECT
    has_discount,
    AVG(demand_score) AS avg_demand,
    AVG(rating) AS avg_rating,
    AVG(rating_count) AS avg_rating_count,
    COUNT(*) AS n
FROM dbo.v_noon_analytics
GROUP BY has_discount
ORDER BY has_discount DESC;


















