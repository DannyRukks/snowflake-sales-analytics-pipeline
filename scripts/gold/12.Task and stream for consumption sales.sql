USE DATABASE RETAIL_CURATED;
USE SCHEMA CURATED;
CREATE OR REPLACE STREAM SALES_CURATED_STREAM
ON TABLE SALES_CURATED
APPEND_ONLY = TRUE;
 
USE DATABASE RETAIL_CONSUMPTION;
USE SCHEMA MART;

CREATE OR REPLACE TASK FACT_SALES_TASK
WAREHOUSE = RETAIL_ETL_WH
SCHEDULE = '1 MINUTE'

WHEN SYSTEM$STREAM_HAS_DATA('RETAIL_CURATED.CURATED.SALES_CURATED_STREAM')
AS
MERGE INTO FACT_SALES AS T
USING
(
    SELECT *
    FROM
    (
        SELECT
            SaleID,
            SaleDate,
            CustomerID,
            ProductID,
            Quantity,
            UnitPrice,
            Discount,
            StoreID,
            SOURCEFILE,
            LOADTIMESTAMP,
            ROW_NUMBER() OVER(PARTITION BY SaleID ORDER BY LOADTIMESTAMP DESC) AS RN
        FROM RETAIL_CURATED.CURATED.SALES_CURATED_STREAM
    )
    WHERE RN = 1
) S
ON T.SaleID = S.SaleID

WHEN MATCHED THEN
UPDATE SET
    T.SaleDate         = S.SaleDate,
    T.CustomerID       = S.CustomerID,
    T.ProductID        = S.ProductID,
    T.Quantity         = S.Quantity,
    T.UnitPrice        = S.UnitPrice,
    T.Discount         = S.Discount,
    T.StoreID          = S.StoreID,
    T.SOURCEFILE       = S.SOURCEFILE,
    T.LOADTIMESTAMP   = S.LOADTIMESTAMP

WHEN NOT MATCHED THEN
INSERT
(
    SaleID, SaleDate, CustomerID, ProductID,
    Quantity, UnitPrice, Discount, StoreID, SOURCEFILE, LOADTIMESTAMP
)
VALUES
(
    S.SaleID, S.SaleDate, S.CustomerID, S.ProductID, S.Quantity, 
    S.UnitPrice, S.Discount, S.StoreID, S.SOURCEFILE, S.LOADTIMESTAMP
);
 
-- enable task,
ALTER TASK FACT_SALES_TASK RESUME;