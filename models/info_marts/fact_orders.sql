WITH link AS (
    SELECT 
        HK_LINK_ORDER_CUSTOMER,
        HK_ORDER_ID,
        HK_CUSTOMER_ID,
        LOAD_DATETIME,
        RECORD_SOURCE
    FROM {{ ref('link_order_customer') }}
),

stg AS (
    SELECT 
        HK_ORDER_ID,
        order_id,
        amount,
        LOAD_DATETIME AS order_timestamp
    FROM {{ ref('stg_orders') }}
)

SELECT 
    l.HK_LINK_ORDER_CUSTOMER AS order_customer_lk,
    s.order_id,
    l.HK_CUSTOMER_ID AS customer_hk,
    s.amount,
    s.order_timestamp,
    l.RECORD_SOURCE AS record_source
FROM link l
JOIN stg s 
    ON l.HK_ORDER_ID = s.HK_ORDER_ID