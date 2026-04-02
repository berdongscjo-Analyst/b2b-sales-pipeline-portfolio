CREATE OR REPLACE TABLE
`sales-pipeline-portfolio.silver.dim_product` AS
SELECT
ROW_NUMBER() OVER (ORDER BY product) AS product_key,
product,
series,
sales_price
FROM `sales-pipeline-portfolio.bronze.products`;