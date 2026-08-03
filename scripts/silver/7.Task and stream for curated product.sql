USE DATABASE RETAIL_LANDING;
USE SCHEMA RAW;

CREATE OR REPLACE STREAM PRODUCT_RAW_STREAM
ON TABLE PRODUCT_RAW
APPEND_ONLY = TRUE;
 
USE DATABASE RETAIL_CURATED;
USE SCHEMA CURATED;
CREATE OR REPLACE TASK PRODUCT_CURATED_TASK
WAREHOUSE = RETAIL_ETL_WH
SCHEDULE = '1 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('RETAIL_LANDING.RAW.PRODUCT_RAW_STREAM')
AS
MERGE INTO PRODUCT_CURATED AS T
USING
(
    SELECT *
    FROM
    (
        SELECT
            TRIM(ProductID) AS ProductID,
            TRIM(ProductName) AS ProductName,
            INITCAP(TRIM(Category)) AS Category,
            INITCAP(TRIM(Brand)) AS Brand,
            CostPrice,
            SellingPrice,
            SOURCEFILE,
            LOADTIMESTAMP,
            ROW_NUMBER() OVER(PARTITION BY ProductID ORDER BY LOADTIMESTAMP DESC) AS RN
        FROM RETAIL_LANDING.RAW.PRODUCT_RAW_STREAM
        WHERE CostPrice >= 0
          AND SellingPrice >= 0
          AND SellingPrice >= CostPrice
    )

    WHERE RN = 1

) S
ON T.ProductID = S.ProductID

WHEN MATCHED THEN
UPDATE SET
    T.ProductName       = S.ProductName,
    T.Category          = S.Category,
    T.Brand             = S.Brand,
    T.CostPrice         = S.CostPrice,
    T.SellingPrice      = S.SellingPrice,
    T.SOURCEFILE        = S.SOURCEFILE,
    T.LOADTIMESTAMP     = S.LOADTIMESTAMP

WHEN NOT MATCHED THEN
INSERT
(
    ProductID, ProductName, Category, Brand, CostPrice,
    SellingPrice, SOURCEFILE, LOADTIMESTAMP
)

VALUES
(
    S.ProductID, S.ProductName, S.Category, S.Brand,
    S.CostPrice, S.SellingPrice, S.SOURCEFILE, S.LOADTIMESTAMP
);
 
