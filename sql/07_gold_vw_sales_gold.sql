CREATE OR REPLACE VIEW
`sales-pipeline-portfolio.gold.vw_sales_gold` AS
SELECT
f.opportunity_id,
f.deal_stage,
f.engage_date,
f.close_date,
f.close_value,
f.days_to_close,
f.is_won,
f.is_lost,
da.sales_agent,
da.manager,
da.regional_office,
dp.product,
dp.series AS product_series,
dp.sales_price AS list_price,
dac.account,
dac.sector,
dac.account_revenue_millions,
dac.account_employees,
dac.office_location,
-- pct_of_list_price intentionally excluded from Gold view
-- Calculated dynamically in Power BI DAX to respond to deal_stage slicers
FROM `sales-pipeline-portfolio.silver.fact_sales` f
LEFT JOIN `sales-pipeline-portfolio.silver.dim_agent` da ON f.agent_key = da.agent_key
LEFT JOIN `sales-pipeline-portfolio.silver.dim_product` dp ON f.product_key = dp.product_key
LEFT JOIN `sales-pipeline-portfolio.silver.dim_account` dac ON f.account_key = dac.account_key;


