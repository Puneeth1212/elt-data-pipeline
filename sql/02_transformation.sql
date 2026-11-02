-- Part 3: Transformation Layer (sql/02_transformation.sql)
-- Imputes missing values, encodes categorical columns, prunes unneeded columns, and engineers features

DROP TABLE IF EXISTS clean_passengers;

CREATE TABLE clean_passengers AS
WITH mode_embarked AS (
    SELECT embarked
    FROM stg_titanic
    WHERE embarked IS NOT NULL AND embarked != ''
    GROUP BY embarked
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT
    s.passenger_id,
    s.survived,
    s.passenger_class,
    s.ticket_class,
    CASE WHEN LOWER(TRIM(s.sex)) = 'female' THEN 1 ELSE 0 END AS sex,
    s.sex AS sex_label,
    COALESCE(s.age, ROUND(AVG(s.age) OVER (PARTITION BY s.passenger_class, s.sex), 2)) AS age,
    CASE
        WHEN COALESCE(s.age, ROUND(AVG(s.age) OVER (PARTITION BY s.passenger_class, s.sex), 2)) BETWEEN 0 AND 12 THEN 'Child'
        WHEN COALESCE(s.age, ROUND(AVG(s.age) OVER (PARTITION BY s.passenger_class, s.sex), 2)) BETWEEN 13 AND 19 THEN 'Teen'
        WHEN COALESCE(s.age, ROUND(AVG(s.age) OVER (PARTITION BY s.passenger_class, s.sex), 2)) BETWEEN 20 AND 59 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,
    s.sibsp,
    s.parch,
    (s.sibsp + s.parch + 1) AS family_size,
    CASE WHEN (s.sibsp + s.parch + 1) = 1 THEN 1 ELSE 0 END AS is_alone,
    s.fare,
    CASE NTILE(4) OVER (ORDER BY s.fare ASC)
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Premium'
    END AS fare_category,
    COALESCE(NULLIF(s.embarked, ''), (SELECT embarked FROM mode_embarked)) AS embarked,
    s.passenger_type,
    s.alive,
    s.load_timestamp,
    s.batch_id
FROM stg_titanic s;

