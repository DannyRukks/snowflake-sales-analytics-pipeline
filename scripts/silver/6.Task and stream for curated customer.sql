USE DATABASE RETAIL_LANDING;
USE SCHEMA RAW;

CREATE OR REPLACE STREAM CUSTOMER_RAW_STREAM
ON TABLE CUSTOMER_RAW
APPEND_ONLY = TRUE;
 
USE DATABASE RETAIL_CURATED;
USE SCHEMA CURATED;
CREATE OR REPLACE TASK CUSTOMER_CURATED_TASK
WAREHOUSE = RETAIL_ETL_WH
SCHEDULE = '1 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('RETAIL_LANDING.RAW.CUSTOMER_RAW_STREAM')
AS
MERGE INTO CUSTOMER_CURATED AS T
USING
(
    SELECT *
    FROM
    (
        SELECT
            TRIM(CustomerID) AS CustomerID,
            TRIM(FirstName) AS FirstName,
            TRIM(LastName) AS LastName,

            CASE
                WHEN UPPER(TRIM(Gender)) IN ('M','MALE') THEN 'Male'
                WHEN UPPER(TRIM(Gender)) IN ('F','FEMALE') THEN 'Female'
                ELSE 'Unknown'
            END AS Gender,

            LOWER(TRIM(Email)) AS Email,
            TRIM(City) AS City,
            TRIM(State) AS State,
            TRIM(Country) AS Country,
            JoinDate,
            SOURCEFILE,
            LOADTIMESTAMP,

            ROW_NUMBER() OVER
            (PARTITION BY CustomerID ORDER BY LOADTIMESTAMP DESC) AS RN

        FROM RETAIL_LANDING.RAW.CUSTOMER_RAW_STREAM
    )
    WHERE RN = 1
) S
ON T.CustomerID = S.CustomerID
WHEN MATCHED THEN
UPDATE SET
    T.FirstName        = S.FirstName,
    T.LastName         = S.LastName,
    T.Gender           = S.Gender,
    T.Email            = S.Email,
    T.City             = S.City,
    T.State            = S.State,
    T.Country          = S.Country,
    T.JoinDate         = S.JoinDate,
    T.SOURCEFILE       = S.SOURCEFILE,
    T.LOADTIMESTAMP   = S.LOADTIMESTAMP

WHEN NOT MATCHED THEN
INSERT
(
    CustomerID, FirstName, LastName, Gender, Email,
    City, State, Country, JoinDate, SOURCEFILE, LOADTIMESTAMP
)
VALUES
(
    S.CustomerID, S.FirstName, S.LastName, S.Gender, S.Email,
    S.City, S.State, S.Country, S.JoinDate, S.SOURCEFILE,
    S.LOADTIMESTAMP
);

