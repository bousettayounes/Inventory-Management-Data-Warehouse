{{
  config(
    materialized='view',
    unique_key='productmodelid'
  )
}}


with products_model as( 
    SELECT 
    CAST(productmodelid as INT),
    CAST(name as VARCHAR)
    FROM {{source("product_model","productmodel")}}
)

SELECT * FROM products_model