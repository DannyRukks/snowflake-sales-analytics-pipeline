-- Customer Landing Table
CREATE OR REPLACE TRANSIENT TABLE CUSTOMER_RAW
(
    CustomerID      STRING,
    FirstName       STRING,
    LastName        STRING,
    Gender          STRING,
    Email           STRING,
    City            STRING,
    State           STRING,
    Country         STRING,
    JoinDate        DATE,

    SourceFile      STRING,
    LoadTimestamp   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
 
-- Product Landing Table
CREATE OR REPLACE TRANSIENT TABLE PRODUCT_RAW
(
    ProductID       STRING,
    ProductName     STRING,
    Category        STRING,
    Brand           STRING,
    CostPrice       NUMBER(10,2),
    SellingPrice    NUMBER(10,2),

    SourceFile      STRING,
    LoadTimestamp   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
 
--  Sales Landing Table
CREATE OR REPLACE TRANSIENT TABLE SALES_RAW
(
    SaleID          STRING,
    SaleDate        DATE,
    CustomerID      STRING,
    ProductID       STRING,
    Quantity        NUMBER,
    UnitPrice       NUMBER(10,2),
    Discount        NUMBER(10,2),
    StoreID         STRING,

    SourceFile      STRING,
    LoadTimestamp   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);