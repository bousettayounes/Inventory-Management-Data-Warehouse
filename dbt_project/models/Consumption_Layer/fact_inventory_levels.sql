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
