/*
Purpose:
--------
This script creates a materialized fact table for product transactions as part of a data warehouse implementation.
It consolidates transaction data with products and dates to provide a comprehensive view of transaction
history, quantities, costs, and transaction types for financial and inventory analysis.

Tables Created:
---------------
1. Fact_transaction_I (intermediate table with calculations)
2. Fact_transaction_II (with date joins and additional transformations)

Note: The final SELECT statement is referencing Fact_transaction_I instead of Fact_transaction_II,
which appears to be an oversight in the original script.

Transformations:
---------------
- Joins transaction data with product information
- Calculates transactions_amount as quantity * unit_cost
- Joins with date dimension to add transaction date information
- Type casts for consistency and reporting accuracy

Dependencies:
------------
- stg_dim_transactions: Source transaction data
- stg_dim_products: Product dimension
- stg_dim_date: Date dimension

Notes:
------
- Table is materialized for performance optimization
- Uses unique_key='transactionid' for upsert operations
- The first CTE (Fact_transaction_I) links products and calculates amounts
- The second CTE (Fact_transaction_II) adds date information
- Supports analysis by transaction type, product, date, and financial metrics
*/

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