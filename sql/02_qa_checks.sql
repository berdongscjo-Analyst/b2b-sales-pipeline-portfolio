-- QA Check 1: Row Count Validation
SELECT 'sales_pipeline' AS tbl, COUNT(*) AS rows
FROM `sales-pipeline-portfolio.bronze.sales_pipeline`
UNION ALL SELECT 'accounts', COUNT(*) FROM `sales-pipeline-portfolio.bronze.accounts`
UNION ALL SELECT 'products', COUNT(*) FROM `sales-pipeline-portfolio.bronze.products`
UNION ALL SELECT 'sales_teams', COUNT(*) FROM `sales-pipeline-portfolio.bronze.sales_teams`;
-- Expected: sales_pipeline=8800 | accounts=85 | products=7 | sales_teams=35
-- QA Check 2: Null Audit on sales_pipeline
SELECT
COUNTIF(opportunity_id IS NULL) AS null_opp_id,
COUNTIF(sales_agent IS NULL) AS null_agent,
COUNTIF(product IS NULL) AS null_product,
COUNTIF(account IS NULL) AS null_account,
COUNTIF(deal_stage IS NULL) AS null_stage,
COUNTIF(close_value IS NULL) AS null_close_value
FROM `sales-pipeline-portfolio.bronze.sales_pipeline`;
-- Finding: null_account=1425, null_close_value=2089
-- These are NOT defects — see QA Check 2b below
-- QA Check 2b: Null Investigation by Deal Stage
-- Confirms nulls are driven by business logic (open deals)
SELECT deal_stage,
COUNTIF(close_value IS NULL) AS null_close_value,
COUNTIF(account IS NULL) AS null_account,
COUNT(*) AS total_rows
FROM `sales-pipeline-portfolio.bronze.sales_pipeline`
GROUP BY deal_stage ORDER BY total_rows DESC;
-- Finding: ALL nulls come from Engaging + Prospecting (open deals)
-- Won and Lost have ZERO nulls — closed deals are complete
-- Resolution: COALESCE applied in Silver fact_sales transformation
-- QA Check 3: Duplicate Opportunity IDs
SELECT opportunity_id, COUNT(*) AS cnt
FROM `sales-pipeline-portfolio.bronze.sales_pipeline`
GROUP BY opportunity_id HAVING cnt > 1;
-- Expected: 0 rows returned
-- QA Check 4: Deal Stage Values
SELECT deal_stage, COUNT(*) AS cnt
FROM `sales-pipeline-portfolio.bronze.sales_pipeline`
GROUP BY deal_stage ORDER BY cnt DESC;
-- Expected: Won(4238) | Lost(2473) | Engaging(1589) | Prospecting(500)
-- QA Check 5: FK Integrity Check
SELECT DISTINCT sp.sales_agent
FROM `sales-pipeline-portfolio.bronze.sales_pipeline` sp
LEFT JOIN `sales-pipeline-portfolio.bronze.sales_teams` st
ON sp.sales_agent = st.sales_agent
WHERE st.sales_agent IS NULL;
-- Expected: 0 rows returned
-- QA Check 6: Product Name Consistency Check
SELECT DISTINCT sp.product AS pipeline_product, pr.product AS products_table
FROM `sales-pipeline-portfolio.bronze.sales_pipeline` sp
LEFT JOIN `sales-pipeline-portfolio.bronze.products` pr ON sp.product = pr.product
WHERE pr.product IS NULL ORDER BY sp.product;
-- Finding: 'GTXPro' (1480 rows) has no space — does not match 'GTX Pro'
-- Resolution: REPLACE(sp.product,'GTXPro','GTX Pro') applied in fact_sales join
-- Bronze data is NOT modified — fix applied at Silver transformation layer
-- QA Check 7: Post-Fix Null Verification on fact_sales (Silver)
-- Run after creating fact_sales in Silver layer
SELECT
COUNTIF(account_key IS NULL) AS null_account_key,
COUNTIF(close_value IS NULL) AS null_close_value,
COUNTIF(agent_key IS NULL) AS null_agent_key,
COUNTIF(product_key IS NULL) AS null_product_key
FROM `sales-pipeline-portfolio.silver.fact_sales`;
-- Expected: all zeros after all three fixes applied