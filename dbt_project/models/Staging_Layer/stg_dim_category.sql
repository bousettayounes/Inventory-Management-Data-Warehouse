{{
  config(
    materialized='view',
    unique_key='productcategoryid'
  )
}}

with product_category as (
    SELECT 
    CAST(productcategoryid as INT),
    CAST(name as VARCHAR)
    FROM {{source("product_category","productcategory")}}
)

SELECT * from product_category