-- Part 5: Data Quality Checks (sql/04_data_quality.sql)
-- Executes 5 automated validation checks and records PASS / FAIL into dq_results

CREATE TABLE IF NOT EXISTS dq_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    check_name VARCHAR(255) NOT NULL,
    status VARCHAR(10) NOT NULL,
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

TRUNCATE TABLE dq_results;

-- Check 1: Row count of raw_titanic = row count of clean_passengers
INSERT INTO dq_results (check_name, status)
SELECT
    'Row count of raw_titanic = row count of clean_passengers',
    CASE
        WHEN (SELECT COUNT(*) FROM raw_titanic) = (SELECT COUNT(*) FROM clean_passengers) THEN 'PASS'
        ELSE 'FAIL'
    END;

-- Check 2: No nulls in age, embarked
INSERT INTO dq_results (check_name, status)
SELECT
    'No nulls in age, embarked',
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM clean_passengers
WHERE age IS NULL OR embarked IS NULL;

-- Check 3: No duplicate passengers
INSERT INTO dq_results (check_name, status)
SELECT
    'No duplicate passengers',
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT passenger_id) THEN 'PASS'
        ELSE 'FAIL'
    END
FROM clean_passengers;

-- Check 4: Age is between 0 and 100
INSERT INTO dq_results (check_name, status)
SELECT
    'Age is between 0 and 100',
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM clean_passengers
WHERE age < 0 OR age > 100;

-- Check 5: sex has only 0 or 1
INSERT INTO dq_results (check_name, status)
SELECT
    'sex has only 0 or 1',
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM clean_passengers
WHERE sex NOT IN (0, 1) OR sex IS NULL;

