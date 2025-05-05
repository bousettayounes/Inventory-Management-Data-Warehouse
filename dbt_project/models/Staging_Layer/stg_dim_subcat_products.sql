/*
Purpose:
--------
This script creates a staging view for product subcategories as part of the dimensional modeling layer.
It joins subcategory data with the category dimension to provide a complete view of the
product hierarchy for use in product dimension and analytical processes.

Tables Created:
---------------
1. products_subcat (intermediate CTE with category join)
2. Final view with simplified projection

Transformations:
---------------
- Type casting for consistency (INT, VARCHAR)
- Joins subcategory data with category dimension to add category names
- Final projection includes only subcategoryid and name
- Preserves category relationship in the CTE for possible future use

Dependencies:
------------
- source("products_sub_category", "productsubcategory"): Raw subcategory data
- stg_dim_category: Category dimension referenced for category names

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='productsubcategoryid' for consistency
- Important intermediary dimension in the product hierarchy
- Final projection simplifies the data model by including only essential fields
*/

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