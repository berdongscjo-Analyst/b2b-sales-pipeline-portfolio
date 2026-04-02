CREATE OR REPLACE TABLE
`sales-pipeline-portfolio.silver.dim_agent` AS
SELECT
ROW_NUMBER() OVER (ORDER BY sales_agent) AS agent_key,
sales_agent,
manager,
regional_office
FROM `sales-pipeline-portfolio.bronze.sales_teams`;