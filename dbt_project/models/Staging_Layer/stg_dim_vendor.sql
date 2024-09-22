{{
  config(
    materialized='view',
    unique_key='businessentityid'
  )
}}


WITH vendor_provider AS (
    SELECT 
        CAST(businessentityid AS INT) AS businessentityid, 
        CAST(name AS VARCHAR) AS vendor_name,  
        CAST(accountnumber AS VARCHAR) AS accountnumber  
    FROM {{ source('vendors', 'vendor') }}
)

SELECT * 
FROM vendor_provider