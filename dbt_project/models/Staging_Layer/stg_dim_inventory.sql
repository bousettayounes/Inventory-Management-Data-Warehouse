/*
Purpose:
--------
This script creates a staging view for inventory data as part of the dimensional modeling layer.
It extracts inventory records from the source system and adds a synthetic primary key and
standardized date formatting to prepare the data for use in fact tables.

Tables Created:
---------------
1. dim_Inventory_level (view with synthetic inventoryid as unique key)

Transformations:
---------------
- Creates synthetic primary key (inventoryid) using ROW_NUMBER()
- Extracts date components from modifieddate
- Formats dateid in YYYYMMDD format for consistency with date dimension
- Maintains original attributes like shelf, bin, and quantity
- Handles NULL dates with fallback to '19000101'

Dependencies:
------------
- source("inventory", "productinventory"): Raw inventory data from source system

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='inventoryid' for consistency
- ROW_NUMBER() synthetic key allows unique identification of inventory records
- Preserves location details (shelf, bin) for granular inventory analysis
- Converts modifieddate to both full_date (DATE) and dateid (string) formats
*/

{{ 
  config(
    materialized='view',
    unique_key='inventoryid'
  )
}}

WITH dim_Inventory_level AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS inventoryid,
        productid,
        locationid,
        shelf,
        bin,
        quantity,
        rowguid,
        CAST(modifieddate AS DATE) AS full_date,
        COALESCE(
            TO_CHAR(CAST(modifieddate AS DATE), 'YYYYMMDD'),
            '19000101'
        ) AS dateid
    FROM {{ source("inventory", "productinventory") }}
)

SELECT *
FROM dim_Inventory_level