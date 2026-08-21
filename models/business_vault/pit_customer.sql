WITH as_of_dates AS (
    SELECT DISTINCT 
        LOAD_DATETIME AS AS_OF_DATE
    FROM {{ ref('stg_customers') }}
),

hub AS (
    SELECT 
        HK_CUSTOMER_ID
    FROM {{ ref('hub_customer') }}
),

sat AS (
    SELECT 
        HK_CUSTOMER_ID,
        LOAD_DATETIME
    FROM {{ ref('sat_customer_details') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['h.HK_CUSTOMER_ID', 'd.AS_OF_DATE']) }} AS HK_PIT_CUSTOMER,
    h.HK_CUSTOMER_ID,
    d.AS_OF_DATE,
    MAX(s.LOAD_DATETIME) AS SAT_CUSTOMER_DETAILS_LDTS
FROM hub h
INNER JOIN as_of_dates d 
    ON 1 = 1
LEFT JOIN sat s
    ON h.HK_CUSTOMER_ID = s.HK_CUSTOMER_ID
   AND s.LOAD_DATETIME <= d.AS_OF_DATE
GROUP BY 
    h.HK_CUSTOMER_ID,
    d.AS_OF_DATE