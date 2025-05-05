/*
Purpose:
--------
This script creates a materialized fact table for inventory levels as part of a data warehouse implementation.
It integrates inventory data with warehouse location and date information to provide a complete view of stock availability
across different locations and time periods.

Tables Created:
---------------
1. Fact_Inventory_level (final table with unique inventoryid as primary key)

Transformations:
---------------
- Joins inventory data with warehouse locations to add location names
- Joins with date dimension to add date information
- Creates synthetic primary key using ROW_NUMBER()
- Structures data for inventory analysis and reporting

Dependencies:
------------
- stg_dim_inventory: Source inventory data
- stg_dim_warehouse_location: Warehouse location dimension
- stg_dim_date: Date dimension

Notes:
------
- Table is materialized for performance optimization
- Uses unique_key='inventoryid' for upsert operations
- The first CTE (Fact_Inventory_level_I) creates the initial structure
- The second CTE (Fact_Inventory_level) adds date information
*/

{{ 
  config(
    materialized='table',
    unique_key='inventoryid'
  )
}}

WITH Fact_Inventory_level_I AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS inventoryid,
        inve.productid,
        inve.locationid,
        inve.dateid,
        inve.quantity AS stock_availability,
        loc.name
    FROM {{ ref("stg_dim_inventory") }} inve
    INNER JOIN {{ ref("stg_dim_warehouse_location") }} loc
    ON inve.locationid = loc.locationid
)
,
Fact_Inventory_level AS (
    SELECT 
        finl.inventoryid,
        finl.locationid,
        finl.productid,
        finl.stock_availability,
        finl.name as inventory_name,
        d.date as current_date
    FROM Fact_Inventory_level_I finl
    INNER JOIN {{ ref("stg_dim_date") }} d
    ON finl.dateid = d.date_id
)

SELECT *
FROM Fact_Inventory_level