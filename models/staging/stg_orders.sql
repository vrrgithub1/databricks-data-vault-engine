{%- set yaml_metadata -%}
source_model: 'raw_orders'
derived_columns:
  RECORD_SOURCE: '!RAW_ORDERS'
  LOAD_DATETIME: 'order_date'
hashed_columns:
  HK_ORDER_ID: 'order_id'
  HK_CUSTOMER_ID: 'customer_id'
  HK_PRODUCT_ID: 'product_id'
  HK_LINK_ORDER_CUSTOMER:
    - 'order_id'
    - 'customer_id'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns']) }}