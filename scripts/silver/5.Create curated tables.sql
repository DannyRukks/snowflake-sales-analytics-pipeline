-- Create customer curated
 CREATE OR REPLACE TRANSIENT TABLE CUSTOMER_CURATED
(
    CustomerID        STRING,
    FirstName         STRING,
    LastName          STRING,
    Gender            STRING,
    Email             STRING,
    City              STRING,
    State             STRING,
    Country           STRING,
    JoinDate          DATE,

    SOURCEFILE        STRING,
    LOADTIMESTAMP     TIMESTAMP_NTZ
);

-- Create product curated
CREATE OR REPLACE TRANSIENT TABLE PRODUCT_CURATED
(
    ProductID         STRING,
    ProductName       STRING,
    Category          STRING,
    Brand             STRING,
    CostPrice         NUMBER(10,2),
    SellingPrice      NUMBER(10,2),

    SOURCEFILE        STRING,
    LOADTIMESTAMP     TIMESTAMP_NTZ
);
 
-- Create sales curated
CREATE OR REPLACE TRANSIENT TABLE SALES_CURATED
(
    SaleID            STRING,
    SaleDate          DATE,
    CustomerID        STRING,
    ProductID         STRING,
    Quantity          NUMBER,
    UnitPrice         NUMBER(10,2),
    Discount          NUMBER(10,2),
    StoreID           STRING,

    SOURCEFILE        STRING,
    LOADTIMESTAMP     TIMESTAMP_NTZ
);