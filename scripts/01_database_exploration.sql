/* =============================================================================
   Database Exploration
   =============================================================================
   Purpose:
     • Review the structure of the database.
     • List all tables and inspect their column metadata.
     • Understand foundational elements used in downstream analysis.

   System Objects:
     • INFORMATION_SCHEMA.TABLES
     • INFORMATION_SCHEMA.COLUMNS
   =============================================================================
*/

-- List all tables available in the current database
SELECT 
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;


-- Inspect column details for table: dim_customers
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
