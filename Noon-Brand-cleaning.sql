UPDATE t
SET brand_cleaned = b.brand_name
FROM Noon2 t
JOIN dim_brand b
ON UPPER(t.brand) LIKE b.brand_name + '%';


UPDATE Noon2
SET brand_cleaned = 'LATTAFA'
WHERE UPPER(brand) LIKE 'LATAFA%';


UPDATE Noon2
SET brand_cleaned = 'LATTAFA'
WHERE UPPER(brand) LIKE 'LATAFA%';


UPDATE n
SET n.brand_cleaned = a.brand_cleaned
FROM Perfume.dbo.Noon2 n
JOIN dbo.brand_alias a
  ON UPPER(n.brand) LIKE UPPER(a.alias)
WHERE n.brand_cleaned IS NULL
  AND n.brand IS NOT NULL;





UPDATE Perfume.dbo.Noon2
SET brand_cleaned = 'UNKNOWN'
WHERE brand_cleaned IS NULL
  AND brand IS NOT NULL


UPDATE Perfume.dbo.Noon2
SET brand_cleaned = 'UNKNOWN'
WHERE brand_cleaned IS NULL





UPDATE Perfume.dbo.Noon2
SET brand_cleaned = 'VIKTOR & ROLF'
WHERE brand_cleaned = 'VIKTOR & ROLF SPICE';


UPDATE Perfume.dbo.Noon2
SET brand_cleaned = 'JEAN PAUL GAULTIER'
WHERE brand_cleaned = 'JEAN PAUL';



UPDATE Perfume.dbo.Noon2
SET brand_cleaned = 'COLOUR ME'
WHERE brand_cleaned = 'COLOUR';


UPDATE Perfume.dbo.Noon2
SET brand_cleaned = 'WORLD GOLDEN PERFUMES'
WHERE brand_cleaned = 'WORLD GOLDEN';


















