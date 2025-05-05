/*
Purpose:
--------
This script creates a staging view for transaction data, integrating transaction history
with product information and standardizing date formats. It prepares transaction data
for use in fact tables by providing consistent data types and date representations.

Tables Created:
---------------
1. dim_transaction (view with unique transactionid as key)

Transformations:
---------------
- Type casting for consistency (INT, VARCHAR, DECIMAL)
- Joins transaction history with product dimension to add product names
- Formats dateid in YYYYMMDD format for consistency with date dimension
- Converts transaction dates to standardized format
- Handles NULL dates with fallback to '19000101'

Dependencies:
------------
- source('transactions_infos', 'transactionhistory'): Raw transaction data
- stg_dim_products: Product dimension with product names and attributes

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='transactionid' for consistency
- Includes transaction type for analysis by transaction category
- Standardizes financial values with DECIMAL(10,2) for reporting accuracy
- Core table for transaction analysis and reporting
*/

{{ 
  config(
    materialized='view',
    unique_key='transactionid'
  )
}}

WITH dim_transaction AS (
    SELECT 
        CAST(tr.transactionid AS INT) AS transactionid, 
        CAST(tr.productid AS INTEGER) AS productid,  
        CAST(dp.product_name AS VARCHAR) AS product_name, 
        CAST(tr.transactiontype AS VARCHAR) AS transactiontype,
        
        CASE 
            WHEN tr.transactiondate IS NOT NULL THEN TO_CHAR(tr.transactiondate, 'YYYYMMDD')
            ELSE '19000101'
        END AS dateid,

        COALESCE(tr.transactiondate, '1900-01-01'::DATE) AS transactiondate,

        CAST(tr.quantity AS INT) AS quantity,
        CAST(tr.actualcost AS DECIMAL(10,2)) AS unit_cost

    FROM {{ source('transactions_infos', 'transactionhistory') }} tr 
    INNER JOIN {{ ref("stg_dim_products") }} dp
    ON tr.productid = dp.productid
)

SELECT *
FROM dim_transaction