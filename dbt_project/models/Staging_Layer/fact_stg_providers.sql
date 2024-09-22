{{ 
  config(
    materialized='view', 
    unique_key='purchaseorderid'
  )
}}

WITH fact_providers_I AS (
    SELECT 
        CAST(po.purchaseorderid AS INT) AS purchaseorderid,
        v.vendor_name AS vendor_name,
        v.accountnumber,
        po.shipmethodid,
        po.vendorid,
        po.orderdate,
        po.shipdate,
        po.status,
        po.subtotal AS sub_total_amount,
        po.taxamt AS tax_amount,
        po.freight AS delivery_fees,
        
        CASE 
            WHEN po.orderdate IS NOT NULL THEN TO_CHAR(po.orderdate, 'YYYYMMDD')
            ELSE '19000101'
        END AS dateid

    FROM {{ source('purchaseorder', 'purchaseorderheader') }} po
    INNER JOIN {{ ref('stg_dim_vendor') }} v
        ON po.vendorid = v.businessentityid
),

fact_providers_II AS (
    SELECT 
        fp.vendorid,
        fp.purchaseorderid,
        fp.vendor_name,
        fp.accountnumber,
        fp.shipmethodid,
        ship.shipmethod_type,
        fp.orderdate,
        fp.shipdate,
        fp.status,
        fp.sub_total_amount,
        fp.tax_amount,
        fp.delivery_fees,
        fp.dateid 

    FROM fact_providers_I fp 
    INNER JOIN {{ ref("stg_dim_shipment") }} ship 
        ON fp.shipmethodid = ship.shipmethodid
)

SELECT *
FROM fact_providers_II
