CREATE OR REPLACE TABLE
`sales-pipeline-portfolio.silver.dim_account` AS
SELECT
ROW_NUMBER() OVER (ORDER BY account) AS account_key,
account,
sector,
revenue AS account_revenue_millions,
employees AS account_employees,
office_location,
subsidiary_of
FROM `sales-pipeline-portfolio.bronze.accounts`;
-- Insert Unassigned placeholder row (account_key = 0)
-- Handles 1,425 Engaging/Prospecting records with no account assigned
-- fact_sales uses COALESCE(account_key, 0) to map to this row
INSERT INTO `sales-pipeline-portfolio.silver.dim_account`
(account_key, account, sector, account_revenue_millions,
account_employees, office_location, subsidiary_of)
VALUES
(0, 'Unassigned', 'Unknown', 0, 0, 'Unknown', NULL);
-- dim_account should now have 86 rows (85 real + 1 Unassigned)