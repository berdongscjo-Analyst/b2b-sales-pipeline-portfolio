-- COALESCE handles two business-logic null findings from QA:
-- close_value NULL → 0 (open deals have no revenue yet)
-- account_key NULL → 0 (maps to Unassigned row in dim_account)
CREATE OR REPLACE TABLE
`sales-pipeline-portfolio.silver.fact_sales` AS
SELECT
sp.opportunity_id,
da.agent_key,
dp.product_key,
COALESCE(dac.account_key, 0) AS account_key,
sp.deal_stage,
sp.engage_date,
sp.close_date,
COALESCE(sp.close_value, 0) AS close_value,
DATE_DIFF(sp.close_date, sp.engage_date, DAY) AS days_to_close,
CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END AS is_won,
CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END AS is_lost
FROM `sales-pipeline-portfolio.bronze.sales_pipeline` sp
LEFT JOIN `sales-pipeline-portfolio.silver.dim_agent` da ON sp.sales_agent = da.sales_agent
LEFT JOIN `sales-pipeline-portfolio.silver.dim_product` dp
ON REPLACE(sp.product, 'GTXPro', 'GTX Pro') = dp.product
LEFT JOIN `sales-pipeline-portfolio.silver.dim_account` dac ON sp.account = dac.account;