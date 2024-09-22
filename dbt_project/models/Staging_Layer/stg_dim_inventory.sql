{{ 
  config(
    materialized='view',
    unique_key='inventoryid'
  )
}}

WITH dim_Inventory_level AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS inventoryid,
        productid,
        locationid,
        shelf,
        bin,
        quantity,
        rowguid,
        CAST(modifieddate AS DATE) AS full_date,
        COALESCE(
            TO_CHAR(CAST(modifieddate AS DATE), 'YYYYMMDD'),
            '19000101'
        ) AS dateid
    FROM {{ source("inventory", "productinventory") }}
)

SELECT *
FROM dim_Inventory_level
