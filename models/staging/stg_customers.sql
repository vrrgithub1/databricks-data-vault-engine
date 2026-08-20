{%- set yaml_metadata -%}
source_model: 'raw_customers'
derived_columns:
  RECORD_SOURCE: '!RAW_CUSTOMERS'
  LOAD_DATETIME: 'created_at'
hashed_columns:
  HK_CUSTOMER_ID: 'customer_id'
  HK_CUSTOMER_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'first_name'
      - 'last_name'
      - 'email'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns']) }}