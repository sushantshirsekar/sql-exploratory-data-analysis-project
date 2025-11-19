/* =============================================================================
   Database Overview & Structure Check
   =============================================================================
   Goal:
     • Get a quick snapshot of all available tables in the database.
     • Review the column-level details for selected tables to understand 
       field types, sizes, and nullability.

   Referenced System Tables:
     • INFORMATION_SCHEMA.TABLES   – For listing tables
     • INFORMATION_SCHEMA.COLUMNS  – For inspecting column metadata
   =============================================================================
*/

-- List every table present in the current database
SELECT 
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- Column details for a chosen table: dim_customers
-- Helps verify structure before performing transformations or analysis
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
