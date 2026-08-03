CREATE OR REPLACE DATABASE RETAIL_CONSUMPTION;
USE DATABASE RETAIL_CONSUMPTION;
CREATE OR REPLACE SCHEMA MART;

CREATE OR REPLACE TABLE DIM_CUSTOMER
(
    CustomerID       STRING PRIMARY KEY,
    FirstName        STRING,
    LastName         STRING,
    Gender           STRING,
    Email            STRING,
    City             STRING,
    State            STRING,
    Country          STRING,
    JoinDate         DATE,
    SOURCEFILE       STRING,
    LOADTIMESTAMP   TIMESTAMP_NTZ
);
 
CREATE OR REPLACE TABLE DIM_PRODUCT
(
    ProductID        STRING PRIMARY KEY,
    ProductName      STRING,
    Category         STRING,
    Brand            STRING,
    CostPrice        NUMBER(10,2),
    SellingPrice     NUMBER(10,2),
    SOURCEFILE       STRING,
    LOADTIMESTAMP   TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE FACT_SALES
(
    SaleID           STRING PRIMARY KEY,
    SaleDate         DATE,
    CustomerID       STRING,
    ProductID        STRING,
    Quantity         NUMBER,
    UnitPrice        NUMBER(10,2),
    Discount         NUMBER(5,2),
    StoreID          STRING,
    SOURCEFILE       STRING,
    LOADTIMESTAMP    TIMESTAMP_NTZ
);