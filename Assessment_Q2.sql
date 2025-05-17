-- Calculate average transactions per customer per month and categorize frequency

WITH customer_transactions AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,
        EXTRACT(YEAR FROM MIN(created_date)) * 12 + EXTRACT(MONTH FROM MIN(created_date)) AS first_month,
        EXTRACT(YEAR FROM MAX(created_date)) * 12 + EXTRACT(MONTH FROM MAX(created_date)) AS last_month
    FROM
        savings_savingsaccount
    GROUP BY
        owner_id
),
customer_activity AS (
    SELECT
        owner_id,
        total_transactions,
        (last_month - first_month + 1) AS active_months,
        total_transactions * 1.0 / (last_month - first_month + 1) AS avg_transactions_per_month
    FROM
        customer_transactions
)
SELECT
    CASE 
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM
    customer_activity
GROUP BY
    frequency_category
ORDER BY
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
