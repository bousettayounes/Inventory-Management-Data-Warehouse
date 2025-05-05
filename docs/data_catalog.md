# Data Catalog - Inventory Management Data Warehouse

## Overview
This data catalog documents the structure of an Inventory Management data warehouse schema consisting of dimension (DIM) and fact (FACT) tables. The schema follows a star schema design pattern with dimension tables linked to central fact tables.

## Fact Tables

### FACT_Transactions
The primary fact table that stores transaction details.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| transaction_id | INT | NOT NULL | Unique identifier for transactions |
| productid | INT | NOT NULL | Foreign key to DIM_Product |
| dateid | DATE | NOT NULL | Foreign key to DIM_Date |
| unit_cost | DECIMAL(10,3) | NULL | Cost per unit |
| nmbr_of_transactions | INT | NOT NULL | Number of transactions |
| transaction_amount | DECIMAL(10,3) | NULL | Total amount of the transaction |
| transaction_date | DATE | NOT NULL | Date when transaction occurred |
| transaction_type | VARCHAR(50) | NOT NULL | Type of transaction |

### FACT_inventory_level
Tracks inventory levels.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| inventoryitemid | INT | NOT NULL | Unique identifier for inventory items |
| productid | INT | NOT NULL | Foreign key to DIM_Product |
| locationid | INT | NOT NULL | Foreign key to DIM_Location |
| dateid | SERIAL | NOT NULL | Foreign key to DIM_Date |
| inventory_name | VARCHAR(25) | NULL | Name or identifier of inventory item |
| stock_availability | INT | NULL | Available stock quantity |
| stock_date | DATE | NOT NULL | Date when stock was recorded |

### FACT_Provider_vendor
Contains vendor and provider information.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| purchaseorderid | INT | NOT NULL | Unique identifier for purchase orders |
| businessentityid | INT | NOT NULL | Foreign key to DIM_Vendor |
| shipmentid | INT | NOT NULL | Foreign key to DIM_Shipment |
| date_id | VARCHAR(10) | NOT NULL | Foreign key to DIM_Date |
| status_id | INT | NOT NULL | Foreign key to DIM_Status |
| account_number | VARCHAR(255) | NOT NULL | Vendor account number |
| order_date | DATE | NOT NULL | Date when order was placed |
| ship_date | DATE | NOT NULL | Date when order was shipped |
| month | VARCHAR(50) | NOT NULL | Month of the transaction |
| total_amount_due_in_dollars | DECIMAL(10,3) | NULL | Total amount due in dollars |

## Dimension Tables

### DIM_Product_Category
Base category for products.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| productcategoryid | INT | NOT NULL | Primary key for product categories |
| category_name | VARCHAR(50) | NULL | Name of the product category |

### DIM_Product_Sub_Category
Product subcategory details.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| productsubcategoryid | INT | NOT NULL | Primary key for product subcategories |
| productcategoryid | VARCHAR(50) | NULL | Foreign key to DIM_Product_Category |
| subcategory_name | VARCHAR(50) | NULL | Name of the product subcategory |
| productcategoryid_fk | INT | NOT NULL | Foreign key reference to product category |

### DIM_Product
Main product dimension table.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| productid | INT | NOT NULL | Primary key for products |
| product_name | VARCHAR(50) | NULL | Name of the product |
| productsubcategoryid | INT | NOT NULL | Foreign key to DIM_Product_Sub_Category |
| size | VARCHAR(10) | NULL | Size of the product |
| productmodelid | INT | NOT NULL | Foreign key to DIM_Product_Model |
| color | VARCHAR(15) | NULL | Color of the product |
| style | VARCHAR(10) | NULL | Style of the product |
| category_name | VARCHAR(50) | NULL | Category name of the product |
| model_name | VARCHAR(50) | NULL | Model name of the product |

### DIM_Product_Model
Product model information.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| productmodelid | INT | NOT NULL | Primary key for product models |
| model_name | VARCHAR(50) | NULL | Name of the product model |

### DIM_Vendor
Vendor information.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| businessentityid | INT | NOT NULL | Primary key for vendors |
| vendor_name | VARCHAR(50) | NULL | Name of the vendor |
| accountnumber | VARCHAR(50) | NOT NULL | Account number for the vendor |

### DIM_Shipment
Shipment details.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| shipmentid | INT | NOT NULL | Primary key for shipments |
| name (shipment_type) | VARCHAR(50) | NULL | Type or method of shipment |

### DIM_Date
Date dimension table.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| date_id | VARCHAR(10) | NOT NULL | Primary key for date dimension |
| date | DATE | NOT NULL | Calendar date |
| month_name | VARCHAR(50) | NOT NULL | Name of the month |
| day_of_month | INT | NULL | Day number within month |
| month_number | INT | NULL | Month number (1-12) |
| year | INT | NULL | Calendar year |

### DIM_Location
Location information.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| locationid | INT | NOT NULL | Primary key for locations |
| location_name | VARCHAR(50) | NULL | Name of the location |

### DIM_Status
Status reference table.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| status_id | INT | NOT NULL | Primary key for statuses |
| status_name | VARCHAR(50) | NULL | Name or description of the status |

## Relationships

### Primary to Foreign Key Relationships
- DIM_Product_Category (productcategoryid) → DIM_Product_Sub_Category (productcategoryid_fk)
- DIM_Product_Sub_Category (productsubcategoryid) → DIM_Product (productsubcategoryid)
- DIM_Product_Model (productmodelid) → DIM_Product (productmodelid)
- DIM_Product (productid) → FACT_Transactions (productid)
- DIM_Product (productid) → FACT_inventory_level (productid)
- DIM_Vendor (businessentityid) → FACT_Provider_vendor (businessentityid)
- DIM_Shipment (shipmentid) → FACT_Provider_vendor (shipmentid)
- DIM_Date (date_id) → FACT_Transactions (dateid)
- DIM_Date (date_id) → FACT_inventory_level (dateid)
- DIM_Date (date_id) → FACT_Provider_vendor (date_id)
- DIM_Location (locationid) → FACT_inventory_level (locationid)
- DIM_Status (status_id) → FACT_Provider_vendor (status_id)

## Design Notes
- This is a star schema design optimized for analytical querying of inventory management data
- The schema uses both surrogate keys (IDs) and natural keys (names) in most dimension tables
- Foreign key relationships are clearly established between dimension and fact tables
- The design supports analysis across multiple dimensions: products, time, location, vendors, and status