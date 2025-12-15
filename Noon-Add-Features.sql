UPDATE Perfume.dbo.Noon2
SET price_old = price_new
WHERE price_old IS NULL
  AND price_new IS NOT NULL;


UPDATE Perfume.dbo.Noon2
SET perfume_type = 'UNKNOWN'
WHERE perfume_type IS NULL;



ALTER TABLE Perfume.dbo.Noon2
ADD has_discount BIT;

UPDATE Perfume.dbo.Noon2
SET has_discount =
  CASE WHEN price_old > price_new THEN 1 ELSE 0 END;


ALTER TABLE Perfume.dbo.Noon2
ADD discount_amount DECIMAL(10,2);

UPDATE Perfume.dbo.Noon2
SET discount_amount =
    CASE
        WHEN price_old > price_new THEN price_old - price_new
        ELSE 0
    END;


ALTER TABLE Perfume.dbo.Noon2
ADD discount_pct DECIMAL(5,2);



UPDATE Perfume.dbo.Noon2
SET discount_pct =
    CASE
        WHEN price_old > 0 AND price_old > price_new
            THEN ((price_old - price_new) / price_old) * 100
        ELSE 0
    END;


ALTER TABLE Perfume.dbo.Noon2
ADD price_per_ml DECIMAL(10,4);

UPDATE Perfume.dbo.Noon2
SET price_per_ml =
    CASE
        WHEN size_status = 'EXTRACTED'
         AND size_ml > 0
         AND price_new IS NOT NULL
        THEN price_new / size_ml
        ELSE NULL
    END;


ALTER TABLE Perfume.dbo.Noon2
ADD demand_score DECIMAL(6,3);



UPDATE Perfume.dbo.Noon2
SET demand_score =
(
    -- Rating quality
    (CASE
        WHEN rating_count = 0 THEN 0
        ELSE rating / 5.0
     END) * 0.5

  + -- Rating volume
    (LOG(1 + rating_count) / LOG(1000)) * 0.3

  + -- Discount signal
    (CASE WHEN has_discount = 1 THEN 1 ELSE 0 END) * 0.2

);















