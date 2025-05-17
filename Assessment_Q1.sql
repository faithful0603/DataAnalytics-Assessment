-- Assessment_Q1.sql
-- Find customers with at least one funded savings and one funded investment plan, sorted by total deposits

SELECT 
    u.id AS owner_id,
    u.name,
    COALESCE(savings_plans.savings_count, 0) AS savings_count,
    COALESCE(investment_plans.investment_count, 0) AS investment_count,
    COALESCE(deposits.total_deposits, 0) / 100.0 AS total_deposits  -- converting kobo to naira
FROM 
    users_customuser u
-- Count funded savings plans per customer
LEFT JOIN (
    SELECT owner_id, COUNT(*) AS savings_count
    FROM plans_plan
    WHERE is_regular_savings = 1
      AND confirmed_amount > 0
    GROUP BY owner_id
) savings_plans ON u.id = savings_plans.owner_id
-- Count funded investment plans per customer
LEFT JOIN (
    SELECT owner_id, COUNT(*) AS investment_count
    FROM plans_plan
    WHERE is_a_fund = 1
      AND confirmed_amount > 0
    GROUP BY owner_id
) investment_plans ON u.id = investment_plans.owner_id
-- Sum total deposits from savings account per customer
LEFT JOIN (
    SELECT owner_id, SUM(confirmed_amount) AS total_deposits
    FROM savings_savingsaccount
    GROUP BY owner_id
) deposits ON u.id = deposits.owner_id
WHERE 
    savings_plans.savings_count >= 1
    AND investment_plans.investment_count >= 1
ORDER BY 
    total_deposits DESC;
