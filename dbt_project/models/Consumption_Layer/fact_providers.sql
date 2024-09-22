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
        fct.total_amount_due_in_dollars ,
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
