/*
Purpose:
--------
This script creates a staging view for shipment methods as part of the dimensional modeling layer.
It extracts and standardizes shipment method data to provide a consistent dimension for
analyzing shipping-related metrics across the data warehouse.

Tables Created:
---------------
1. dim_shipment (view with unique shipmethodid as key)

Transformations:
---------------
- Type casting for shipmethodid (INT)
- Renames the name field to shipmethod_type for clarity
- Simple extraction without complex transformations

Dependencies:
------------
- source('dim_shipments','shipmethod'): Raw shipment method data from source system

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='shipmethodid' for consistency
- Minimal transformation approach focuses on data type standardization and naming
- Referenced by fact tables to provide shipping method information
*/

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