/*
Purpose:
--------
This script creates a staging view for vendor data as part of the dimensional modeling layer.
It extracts and standardizes vendor information to provide a consistent vendor dimension
for purchase order analysis and vendor relationship management.

Tables Created:
---------------
1. vendor_provider (view with unique businessentityid as key)

Transformations:
---------------
- Type casting for consistency (INT, VARCHAR)
- Renames columns to provide more descriptive names (name → vendor_name)
- Simple extraction without complex transformations
- Preserves account number for financial reconciliation and reporting

Dependencies:
------------
- source('vendors', 'vendor'): Raw vendor data from source system

Notes:
------
- Implemented as a view rather than a materialized table
- Uses unique_key='businessentityid' for consistency
- Minimal transformation approach focuses on data type standardization
- Core dimension for vendor analysis, referenced by provider/purchase order fact tables
*/

{{
  config(
    materialized='view',
    unique_key='businessentityid'
  )
}}


WITH vendor_provider AS (
    SELECT 
        CAST(businessentityid AS INT) AS businessentityid, 
        CAST(name AS VARCHAR) AS vendor_name,  
        CAST(accountnumber AS VARCHAR) AS accountnumber  
    FROM {{ source('vendors', 'vendor') }}
)

SELECT * 
FROM vendor_provider