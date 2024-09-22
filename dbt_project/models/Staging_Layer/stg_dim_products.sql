{{
  config(
    materialized='view',
    unique_key='productid'
  )
}}

WITH products_dim AS (
    SELECT 
        CAST(p.productid AS INT) AS productid, 
        CAST(p.productmodelid AS INT) AS productmodelid,
        CAST(p.name AS VARCHAR) AS product_name,
        CAST(sc.name AS VARCHAR) AS category_name,
        CAST(p.size AS VARCHAR) AS size,
        CAST(p.color AS VARCHAR) AS color,
        CAST(p.style AS VARCHAR) AS style
    FROM {{ source('products_infos', 'product') }} p 
    INNER JOIN {{ ref("stg_dim_subcat_products") }} sc
    ON p.productsubcategoryid = sc.productsubcategoryid
),

products AS (
    SELECT 
        pd.productid, 
        pd.product_name,  -- Added a comma here
        pd.category_name,
        pm.name as model_name,-- Corrected comma placement
        pd.size, 
        pd.color, 
        pd.style
    FROM products_dim pd
    inner JOIN {{ ref("stg_dim_product_model") }} pm
    ON pd.productmodelid = pm.productmodelid
)

SELECT * FROM products
