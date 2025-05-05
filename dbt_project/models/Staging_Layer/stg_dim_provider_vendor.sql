/*
Purpose:
--------
This script creates a staging view that links purchase orders to vendors/business entities.
It provides a mapping between purchase orders and vendor information, enabling
analysis of purchase orders by vendor and transaction status.

Tables Created:
---------------
1. vendor (view with purchaseorderid linking to business entities)

Transformations:
---------------
- Type casting for consistency (INT, VARCHAR)
- Joins purchase order headers with vendor dimension
- Renames vendorid to businessentityid for consistency with other tables
- Extracts transaction status for analysis

Dependencies:
------------
- source('providers', 'purchaseorderheader'): Raw purchase order data
- stg_dim_vendor: Vendor dimension with business entity information

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='productid' for consistency
- Simple join that preserves the purchase order to vendor relationship
- Enables vendor-based analysis of purchase orders
*/

{{
  config(
    materialized='view',
    unique_key='productid'
  )
}}

WITH vendor AS (
    SELECT 
        CAST(p.purchaseorderid AS INT) , 
        CAST(p.vendorid AS INT) AS businessentityid,
        CAST(p.status AS VARCHAR) AS transaction_status
    FROM {{ source('providers', 'purchaseorderheader') }} p 
    INNER JOIN {{ ref("stg_dim_vendor") }} v
    ON p.vendorid = v.businessentityid
)

SELECT purchaseorderid, businessentityid, transaction_status
FROM vendor