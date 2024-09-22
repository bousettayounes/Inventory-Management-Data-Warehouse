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
