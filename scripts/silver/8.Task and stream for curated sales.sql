USE DATABASE RETAIL_LANDING;
USE SCHEMA RAW;

CREATE OR REPLACE STREAM SALES_RAW_STREAM
ON TABLE SALES_RAW
APPEND_ONLY = TRUE;



USE DATABASE RETAIL_CURATED;
USE SCHEMA CURATED;

CREATE OR REPLACE TASK SALES_CURATED_TASK
WAREHOUSE = RETAIL_ETL_WH
SCHEDULE = '1 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('RETAIL_LANDING.RAW.SALES_RAW_STREAM')
AS

MERGE INTO SALES_CURATED AS T
USING
(
    SELECT *
    FROM
    (
        SELECT

            TRIM(SaleID)      AS SaleID,
            SaleDate,
            TRIM(CustomerID)  AS CustomerID,
            TRIM(ProductID)   AS ProductID,
            Quantity,
            UnitPrice,
            Discount,
            TRIM(StoreID)     AS StoreID,
            SOURCEFILE,
            LOAD_TIMESTAMP,
            ROW_NUMBER() OVER(PARTITION BY SaleID ORDER BY LOAD_TIMESTAMP DESC) AS RN
        FROM RETAIL_LANDING.RAW.SALES_RAW_STREAM
        WHERE Quantity > 0
          AND UnitPrice > 0
          AND Discount BETWEEN 0 AND 1
    ) S

    WHERE RN = 1
) SRC
ON T.SaleID = SRC.SaleID

WHEN MATCHED THEN
UPDATE SET

    T.SaleDate         = SRC.SaleDate,
    T.CustomerID       = SRC.CustomerID,
    T.ProductID        = SRC.ProductID,
    T.Quantity         = SRC.Quantity,
    T.UnitPrice        = SRC.UnitPrice,
    T.Discount         = SRC.Discount,
    T.StoreID          = SRC.StoreID,
    T.SOURCEFILE       = SRC.SOURCEFILE,
    T.LOADTIMESTAMP   = SRC.LOADTIMESTAMP

WHEN NOT MATCHED THEN
INSERT
(
    SaleID, SaleDate, CustomerID, ProductID, Quantity, UnitPrice,
    Discount, StoreID, SOURCEFILE, LOADTIMESTAMP
)
VALUES
(
    SRC.SaleID, SRC.SaleDate, SRC.CustomerID, SRC.ProductID, SRC.Quantity, 
    SRC.UnitPrice, SRC.Discount, SRC.StoreID, SRC.SOURCEFILE, SRC.LOADTIMESTAMP
);