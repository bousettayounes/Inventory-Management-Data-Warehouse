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
