{{
  config(
    materialized='view',
    unique_key='shipmethodid'
  )
}}

WITH dim_shipment as (
    SELECT CAST(shipmethodid as INT ) as shipmethodid,
    name as shipmethod_type
    from {{source('dim_shipments','shipmethod')}}
)

SELECT * from dim_shipment