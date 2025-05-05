/*
Purpose:
--------
This script creates a staging view for status codes as part of the dimensional modeling layer.
It passes through the status dimension data without transformation to provide
standardized status codes for use in fact tables and analytical processes.

Tables Created:
---------------
1. dim_status (view with unique status_id as key)

Transformations:
---------------
- Simple pass-through of status data
- No transformations applied, preserving source structure

Dependencies:
------------
- source("status","dim_status"): Raw status data from source system

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='status_id' for consistency
- Minimal approach with no transformations suggests the source is already well-structured
- Used as a reference dimension by fact tables for status classification
*/

{{ 
  config(
    materialized='view',
    unique_key='status_id'
  )
}}

with dim_status as (
    select * from {{source("status","dim_status")}}
)

SELECT * FROM dim_status