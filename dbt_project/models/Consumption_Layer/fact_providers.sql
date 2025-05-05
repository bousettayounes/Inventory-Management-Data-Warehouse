/*
Purpose:
--------
This script creates a materialized fact table for provider/vendor purchase orders as part of a data warehouse implementation.
It transforms and consolidates vendor purchase order data with related dimensions (status, date) to enable
comprehensive analysis of vendor relationships, order processing, and financial metrics.

Tables Created:
---------------
1. fact_providers (final table with unique purchaseorderid as primary key)

Transformations:
---------------
- Joins provider data with date dimension to add month information
- Joins with status dimension to add standardized status information
- Calculates financial metrics including total_amount_due_in_dollars
- Final projection includes only essential fields for analysis

Dependencies:
------------
- fact_stg_providers: Staging view for provider data
- stg_dim_date: Date dimension
- stg_dim_status: Status dimension

Notes:
------
- Table is materialized for performance optimization
- Uses unique_key='purchaseorderid' for upsert operations
- The first CTE (fact_providers_I) performs date-related joins and calculations
- The second CTE (fact_providers_II) adds status information
- Financial calculations handled within the CTEs
*/

{{ 
  config(
    materialized='table',
    unique_key='purchaseorderid'
  )
}}

WITH fact_providers_I AS (
    SELECT 
        fp.purchaseorderid,
        fp.vendorid as businessentityid,
        fp.vendor_name,
        fp.accountnumber,
        fp.shipmethodid,
        fp.shipmethod_type,
        cast(fp.orderdate as date),
        cast(fp.shipdate as date),
        fp.status AS status,
        fp.sub_total_amount,
        fp.tax_amount,
        fp.delivery_fees,
        CAST((fp.sub_total_amount - (fp.tax_amount - fp.delivery_fees)) as decimal(100,2))  AS total_amount_due_in_dollars,
        fp.dateid as dateid,
        da.month_name AS month
    FROM {{ ref('fact_stg_providers') }} fp
    INNER JOIN {{ ref('stg_dim_date') }} da
        ON fp.dateid = da.date_id
),
fact_providers_II as (
    SELECT 
        fct.purchaseorderid,
        fct.businessentityid,
        fct.vendor_name,
        fct.accountnumber,
        fct.shipmethodid,
        fct.shipmethod_type,
        fct.orderdate,
        fct.shipdate,
        st.status_id,
        fct.sub_total_amount,
        fct.tax_amount,
        fct.delivery_fees,
        fct.total_amount_due_in_dollars,
        fct.dateid,
        fct.month
    from fact_providers_I fct
    INNER JOIN {{ref("stg_dim_status")}} st
    ON fct.status = st.status_id
)

SELECT 
    purchaseorderid,
    businessentityid,
    shipmethodid,
    dateid,
    status_id,  
    accountnumber,
    orderdate,
    shipdate,
    total_amount_due_in_dollars,
    month 
FROM fact_providers_II