WITH customer_tenure AS (
    SELECT
        id AS customer_id,
        name,
        date_joined,
        -- Calculate tenure in months (approximate)
        (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM date_joined)) * 12 +
        (EXTRACT(MONTH FROM CURRENT_DATE) - EXTRACT(MONTH FROM date_joined)) AS tenure_months
    FROM
        users_customuser
),
customer_transactions AS (
    SELECT
        owner_id AS customer_id,
        COUNT(*) AS total_transactions,
        AVG(confirmed_amount) AS avg_transaction_value_kobo
    FROM
        savings_savingsaccount
    WHERE
        confirmed_amount > 0 -- inflow transactions only
    GROUP BY
        owner_id
)
SELECT
    ct.customer_id,
    ct.name,
    ct.tenure_months,
    COALESCE(tr.total_transactions, 0) AS total_transactions,
    ROUND(
        (COALESCE(tr.total_transactions, 0)::numeric / NULLIF(ct.tenure_months, 0)) * 12
        * (COALESCE(tr.avg_transaction_value_kobo, 0) / 100.0 * 0.001), 2
    ) AS estimated_clv
FROM
    customer_tenure ct
LEFT JOIN
    customer_transactions tr ON ct.customer_id = tr.customer_id
WHERE
    ct.tenure_months > 0 -- exclude customers with 0 tenure
ORDER BY
    estimated_clv DESC;
