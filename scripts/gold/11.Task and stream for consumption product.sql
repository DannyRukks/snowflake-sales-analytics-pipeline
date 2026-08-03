-- Create the stream
USE DATABASE RETAIL_CURATED;
USE SCHEMA CURATED;
CREATE OR REPLACE STREAM PRODUCT_CURATED_STREAM
ON TABLE PRODUCT_CURATED
APPEND_ONLY = TRUE;
 
-- Create the task
USE DATABASE RETAIL_CONSUMPTION;
USE SCHEMA MART;

CREATE OR REPLACE TASK DIM_PRODUCT_TASK
WAREHOUSE = RETAIL_ETL_WH
SCHEDULE = '1 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('RETAIL_CURATED.CURATED.PRODUCT_CURATED_STREAM')
AS
MERGE INTO DIM_PRODUCT AS T
USING
(
    SELECT *
    FROM
    (
        SELECT
            ProductID,
            ProductName,
            Category,
            Brand,
            CostPrice,
            SellingPrice,
            SOURCEFILE,
            LOADTIMESTAMP,
            ROW_NUMBER() OVER(PARTITION BY ProductID ORDER BY LOADTIMESTAMP DESC) AS RN
        FROM RETAIL_CURATED.CURATED.PRODUCT_CURATED_STREAM
    )

    WHERE RN = 1
) S
ON T.ProductID = S.ProductID

WHEN MATCHED THEN
UPDATE SET
    T.ProductName      = S.ProductName,
    T.Category         = S.Category,
    T.Brand            = S.Brand,
    T.CostPrice        = S.CostPrice,
    T.SellingPrice     = S.SellingPrice,
    T.SOURCEFILE       = S.SOURCEFILE,
    T.LOADTIMESTAMP    = S.LOADTIMESTAMP

WHEN NOT MATCHED THEN
INSERT
(
    ProductID, ProductName, Category, Brand,
    CostPrice, SellingPrice, SOURCEFILE, LOADTIMESTAMP
)
VALUES
(
    S.ProductID, S.ProductName, S.Category, S.Brand,
    S.CostPrice, S.SellingPrice, S.SOURCEFILE, S.LOADTIMESTAMP
);
 

-- enable task,
ALTER TASK DIM_PRODUCT_TASK RESUME;

