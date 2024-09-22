{{ 
  config(
    materialized='table',
    unique_key='transactionid'
  )
}}

WITH Fact_transaction_I AS (
    SELECT 
        tr.productid,
        tr.transactionid,
        tr.dateid,
        tr.quantity,
        tr.unit_cost,
        tr.transactiontype,
        tr.quantity*tr.unit_cost as transactions_amount
    FROM {{ ref("stg_dim_transactions") }} tr 
    INNER JOIN {{ ref('stg_dim_products') }} dp
    ON tr.productid = dp.productid
)
,
Fact_transaction_II as (
  SELECT 
    ft.productid,
    ft.transactionid,
    dt.date as transaction_date,
    ft.quantity as nmbr_of_transactions,
    ft.unit_cost,
    CAST(ft.transactions_amount as decimal(10,2)),
    ft.transactiontype as transactiontype
  FROM Fact_transaction_I ft 
  INNER JOIN {{ref("stg_dim_date")}} dt
  ON ft.dateid = dt.date_id
)

SELECT *
FROM Fact_transaction_I