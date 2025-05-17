-- Find active accounts with no inflow transactions in the last 365 days

WITH last_inflow AS (
    SELECT
        plan_id,
        MAX(created_date) AS last_transaction_date
    FROM
        savings_savingsaccount
    WHERE
        confirmed_amount > 0 -- inflow only
    GROUP BY
        plan_id
),
active_accounts AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        CASE
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type
    FROM
        plans_plan p
    WHERE
        p.is_active = 1 -- assuming there's a field to mark active accounts
)
SELECT
    aa.plan_id,
    aa.owner_id,
    aa.type,
    li.last_transaction_date,
    CURRENT_DATE - li.last_transaction_date AS inactivity_days
FROM
    active_accounts aa
LEFT JOIN
    last_inflow li ON aa.plan_id = li.plan_id
WHERE
    (li.last_transaction_date IS NULL OR li.last_transaction_date <= CURRENT_DATE - INTERVAL '365' DAY)
ORDER BY
    inactivity_days DESC NULLS LAST;
