-- Part 2: Staging Layer (sql/01_staging.sql)
-- Renames columns, normalizes text to lowercase, casts types, and adds surrogate passenger_id

DROP TABLE IF EXISTS stg_titanic;

CREATE TABLE stg_titanic AS
SELECT
    ROW_NUMBER() OVER () AS passenger_id,
    CAST(survived AS SIGNED) AS survived,
    CAST(pclass AS SIGNED) AS passenger_class,
    LOWER(TRIM(CAST(sex AS CHAR))) AS sex,
    CAST(age AS DECIMAL(5,2)) AS age,
    CAST(sibsp AS SIGNED) AS sibsp,
    CAST(parch AS SIGNED) AS parch,
    CAST(fare AS DECIMAL(10,4)) AS fare,
    LOWER(TRIM(CAST(embarked AS CHAR))) AS embarked,
    LOWER(TRIM(CAST(class AS CHAR))) AS ticket_class,
    LOWER(TRIM(CAST(who AS CHAR))) AS passenger_type,
    adult_male,
    LOWER(TRIM(CAST(deck AS CHAR))) AS deck,
    LOWER(TRIM(CAST(embark_town AS CHAR))) AS embark_town,
    LOWER(TRIM(CAST(alive AS CHAR))) AS alive,
    alone,
    load_timestamp,
    batch_id
FROM raw_titanic;

