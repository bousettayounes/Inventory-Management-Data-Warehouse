/*
Purpose:
--------
This script creates a comprehensive product dimension staging view that integrates product data
with subcategory and model information. It provides a rich product dimension with attributes
for product analysis and serves as a key dimension for multiple fact tables.

Tables Created:
---------------
1. products_dim (intermediate CTE with initial join to subcategories)
2. products (final view with model information included)

Transformations:
---------------
- Type casting for consistency (INT, VARCHAR)
- Joins product data with subcategory information
- Adds product model names through additional join
- Standardizes column names with descriptive prefixes
- Preserves product attributes like size, color, and style

Dependencies:
------------
- source('products_infos', 'product'): Raw product data
- stg_dim_subcat_products: Product subcategory dimension
- stg_dim_product_model: Product model dimension

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='productid' for consistency
- Two-stage CTE approach for clarity in transformations
- Final view includes rich product metadata from multiple sources
- Core dimension that's referenced by multiple fact tables
*/

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
        pd.product_name,
        pd.category_name,
        pm.name as model_name,
        pd.size, 
        pd.color, 
        pd.style
    FROM products_dim pd
    inner JOIN {{ ref("stg_dim_product_model") }} pm
    ON pd.productmodelid = pm.productmodelid
)

SELECT * FROM products