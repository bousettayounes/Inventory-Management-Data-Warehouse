/*
Purpose:
--------
This script creates a staging view for provider/vendor purchase order data to prepare it for the fact table.
It performs initial transformations and joins on the source purchase order data, preparing it for
use in the final fact_providers table by integrating vendor and shipment information.

Tables Created:
---------------
1. fact_stg_providers (view with unique purchaseorderid as key)

Transformations:
---------------
- Joins purchase order header data with vendor dimension 
- Adds shipment method information through a join with shipment dimension
- Type casting for consistency
- Date formatting for dateid (YYYYMMDD format)
- Standardizes column names for easier consumption in the fact table

Dependencies:
------------
- source('purchaseorder', 'purchaseorderheader'): Raw purchase order data
- stg_dim_vendor: Vendor dimension
- stg_dim_shipment: Shipment method dimension

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='purchaseorderid' for consistency
- The first CTE (fact_providers_I) handles vendor joins and initial transformations
- The second CTE (fact_providers_II) adds shipment method information
- Includes date handling with fallback to '19000101' for NULL dates
*/

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