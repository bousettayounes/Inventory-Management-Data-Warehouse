/*
Purpose:
--------
This script creates a staging view for warehouse locations as part of the dimensional modeling layer.
It provides location reference data for inventory analysis and warehouse management,
serving as a key dimension for inventory fact tables.

Tables Created:
---------------
1. warehouse_location (view with unique locationid as key)

Transformations:
---------------
- Simple pass-through of locationid and name
- No transformations applied, preserving source structure

Dependencies:
------------
- source("warehouse_location","location"): Raw warehouse location data from source system

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='locationid' for consistency
- Minimal approach with no transformations suggests the source is already well-structured
- Essential dimension for inventory location analysis
- Referenced by inventory fact tables to provide location context
*/

{{
  config(
    materialized='view',
    unique_key='locationid'
  )
}}


with warehouse_location as (
    select locationid , name
    from {{source("warehouse_location","location")}}
)

SELECT * from warehouse_location