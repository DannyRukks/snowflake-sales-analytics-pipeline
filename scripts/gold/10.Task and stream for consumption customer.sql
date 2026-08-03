-- Create the stream
USE DATABASE RETAIL_CURATED;
USE SCHEMA CURATED;
CREATE OR REPLACE STREAM CUSTOMER_CURATED_STREAM
ON TABLE CUSTOMER_CURATED
APPEND_ONLY = TRUE;

-- Create the task
USE DATABASE RETAIL_CONSUMPTION;
USE SCHEMA MART;

CREATE OR REPLACE TASK DIM_CUSTOMER_TASK
WAREHOUSE = RETAIL_ETL_WH
SCHEDULE = '1 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('RETAIL_CURATED.CURATED.CUSTOMER_CURATED_STREAM')
AS
MERGE INTO DIM_CUSTOMER AS T
USING
(
    SELECT *
    FROM
    (
        SELECT
            CustomerID,
            FirstName,
            LastName,
            Gender,
            City,
            State,
            Country,
            JoinDate,
            SOURCEFILE,
            LOADTIMESTAMP,
            ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY LOADTIMESTAMP DESC) AS RN
        FROM RETAIL_CURATED.CURATED.CUSTOMER_CURATED_STREAM
    )
    WHERE RN = 1
) S
ON T.CustomerID = S.CustomerID

WHEN MATCHED THEN
UPDATE SET
    T.FirstName        = S.FirstName,
    T.LastName         = S.LastName,
    T.Gender           = S.Gender,
    T.City             = S.City,
    T.State            = S.State,
    T.Country          = S.Country,
    T.JoinDate         = S.JoinDate,
    T.SOURCEFILE       = S.SOURCEFILE,
    T.LOADTIMESTAMP    = S.LOADTIMESTAMP

WHEN NOT MATCHED THEN
INSERT
(
    CustomerID, FirstName, LastName, Gender,
    City, State, Country, JoinDate, SOURCEFILE, LOADTIMESTAMP
)
VALUES
(
    S.CustomerID, S.FirstName, S.LastName, S.Gender,
    S.City, S.State, S.Country, S.JoinDate, S.SOURCEFILE, S.LOADTIMESTAMP
);

-- Enable the task
ALTER TASK DIM_CUSTOMER_TASK RESUME;
 

