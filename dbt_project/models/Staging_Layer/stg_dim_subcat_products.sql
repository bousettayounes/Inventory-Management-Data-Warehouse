{{
    config (
        materialized='view',
        unique_key = 'productsubcategoryid'
    )
}}

WITH products_subcat AS (
    SELECT 
        CAST(psc.productsubcategoryid AS INT) AS productsubcategoryid,
        CAST(c.name AS VARCHAR) AS name,
        CAST(psc.productcategoryid AS INT) AS productcategoryid
    FROM {{ source("products_sub_category", "productsubcategory") }} psc
    INNER JOIN {{ ref('stg_dim_category') }} c
    ON psc.productcategoryid = c.productcategoryid
)

SELECT productsubcategoryid,
name
FROM products_subcat