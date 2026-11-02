-- Part 4: Analytics Layer (sql/03_analytics.sql)
-- Defines 3 analytical views: survival by class/gender, survival by age group, top 3 fares per class

CREATE OR REPLACE VIEW vw_survival_by_class_sex AS
SELECT
    passenger_class,
    sex_label,
    COUNT(*) AS total_passengers,
    SUM(survived) AS survived_passengers,
    ROUND(SUM(survived) * 100.0 / COUNT(*), 2) AS survival_rate_pct
FROM clean_passengers
GROUP BY passenger_class, sex_label
ORDER BY passenger_class, sex_label;

CREATE OR REPLACE VIEW vw_survival_by_age_group AS
SELECT
    age_group,
    COUNT(*) AS total_passengers,
    SUM(survived) AS survived_passengers,
    ROUND(SUM(survived) * 100.0 / COUNT(*), 2) AS survival_rate_pct
FROM clean_passengers
GROUP BY age_group
ORDER BY FIELD(age_group, 'Child', 'Teen', 'Adult', 'Senior');

CREATE OR REPLACE VIEW vw_top_3_fares_by_class AS
WITH ranked_fares AS (
    SELECT
        passenger_class,
        passenger_id,
        sex_label,
        age,
        fare,
        fare_category,
        ROW_NUMBER() OVER (PARTITION BY passenger_class ORDER BY fare DESC) AS fare_rank
    FROM clean_passengers
)
SELECT
    passenger_class,
    fare_rank,
    passenger_id,
    sex_label,
    age,
    fare,
    fare_category
FROM ranked_fares
WHERE fare_rank <= 3
ORDER BY passenger_class, fare_rank;

