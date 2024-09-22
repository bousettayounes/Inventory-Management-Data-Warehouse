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