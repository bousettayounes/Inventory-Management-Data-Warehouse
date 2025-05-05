/*
Purpose:
--------
This script creates a staging view for product categories as part of the dimensional modeling layer.
It extracts and transforms category data from the source system to provide a standardized
product category dimension for use in the data warehouse.

Tables Created:
---------------
1. product_category (view with unique productcategoryid as key)

Transformations:
---------------
- Type casting for productcategoryid (INT) and name (VARCHAR)
- Simple extraction without complex transformations
- Maintains source data structure while providing type consistency

Dependencies:
------------
- source("product_category","productcategory"): Raw product category data from source system

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='productcategoryid' for consistency
- Minimal transformation approach focuses on data type standardization
- Serves as a foundational dimension for product hierarchy
*/

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