{{ 
  config(
    materialized='view',
    unique_key='date_id'
  )
}}

WITH source_date AS (
    SELECT 
        dateid,
        full_date,
        month_name
    FROM {{ source('date_dim', 'calendare') }}
)

SELECT
    CASE 
        WHEN full_date IS NOT NULL THEN TO_CHAR(full_date, 'YYYYMMDD')
        ELSE '19000101'
    END AS date_id,

    COALESCE(full_date, '1900-01-01'::DATE) AS date,

    month_name AS month_name,
    TO_CHAR(full_date, 'Day') AS day_name,
    EXTRACT(DAY FROM full_date) AS day_of_month,
    EXTRACT(MONTH FROM full_date) AS month_number,
    EXTRACT(YEAR FROM full_date) AS year

FROM source_date
