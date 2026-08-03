-- Create the snowpipes
CREATE OR REPLACE PIPE SALES_PIPE
AUTO_INGEST = TRUE
AS
COPY INTO RETAIL_LANDING.RAW.SALES_RAW
(
    SaleID, SaleDate, CustomerID, ProductID, Quantity,
    UnitPrice, Discount, StoreID, SOURCEFILE
)
FROM
(
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8,
        METADATA$FILENAME
    FROM @RETAIL_STAGE/sales/
);
 
CREATE OR REPLACE PIPE CUSTOMER_PIPE
AUTO_INGEST = TRUE
AS
COPY INTO RETAIL_LANDING.RAW.CUSTOMER_RAW
(
    CustomerID, FirstName, LastName, Gender, Email,
    City, State, Country, JoinDate, SOURCEFILE
)
FROM
(
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8, $9,
        METADATA$FILENAME
    FROM @RETAIL_STAGE/customers/
);
 
CREATE OR REPLACE PIPE PRODUCT_PIPE
AUTO_INGEST = TRUE
AS
COPY INTO RETAIL_LANDING.RAW.PRODUCT_RAW
(
    ProductID, ProductName, Category, Brand,
    CostPrice, SellingPrice, SOURCEFILE
)
FROM
(
    SELECT
        $1, $2, $3, $4, $5, $6,
        METADATA$FILENAME
    FROM @RETAIL_STAGE/products/
);
