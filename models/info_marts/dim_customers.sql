WITH hub AS (
    SELECT 
        HK_CUSTOMER_ID,
        customer_id,
        LOAD_DATETIME AS hub_load_datetime,
        RECORD_SOURCE
    FROM {{ ref('hub_customer') }}
),

sat AS (
    SELECT 
        HK_CUSTOMER_ID,
        first_name,
        last_name,
        email,
        LOAD_DATETIME AS sat_load_datetime
    FROM {{ ref('sat_customer_details') }}
)

SELECT 
    h.HK_CUSTOMER_ID AS customer_hk,
    h.customer_id,
    s.first_name,
    s.last_name,
    s.email,
    h.RECORD_SOURCE AS record_source,
    h.hub_load_datetime AS created_at
FROM hub h
LEFT JOIN sat s 
    ON h.HK_CUSTOMER_ID = s.HK_CUSTOMER_ID