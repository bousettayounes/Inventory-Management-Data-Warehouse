/*
Purpose:
--------
This script creates a staging view for product models as part of the dimensional modeling layer.
It extracts and standardizes product model data to provide a consistent product model dimension
that can be used in product-related analyses and reporting.

Tables Created:
---------------
1. products_model (view with unique productmodelid as key)

Transformations:
---------------
- Type casting for productmodelid (INT) and name (VARCHAR)
- Simple extraction without complex transformations
- Provides consistent data types for integration with product dimension

Dependencies:
------------
- source("product_model","productmodel"): Raw product model data from source system

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='productmodelid' for consistency
- Minimal transformation approach focuses on data type standardization
- Serves as a reference dimension for product categorization
*/

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