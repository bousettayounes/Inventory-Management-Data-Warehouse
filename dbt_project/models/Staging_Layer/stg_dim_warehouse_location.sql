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