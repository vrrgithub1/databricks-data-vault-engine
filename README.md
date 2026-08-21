# Enterprise Data Vault 2.0 Engine on Azure Databricks with dbt and Unity Catalog

A scalable, auditable, and production-ready Medallion Data Vault implementation built on Azure Databricks, dbt Core, AutomateDV, and Unity Catalog.

## 📌 Executive Summary

Modern enterprise data platforms face severe challenges with rapid schema evolution, historical auditability, and late-arriving operational data. Traditional Kimball star schemas often struggle when source systems change frequently or when regulatory frameworks require immutable tracking down to the exact second.

This repository provides an end-to-end implementation of a Data Vault 2.0 Engine deployed on Azure Databricks Delta Lake. By leveraging dbt Core and AutomateDV, this pipeline automates key hashing, satellite change detection, point-in-time performance optimizations, and gold-layer dimensional reporting—all governed natively under Unity Catalog.

## 🏗️ Architecture & Design

This platform maps Data Vault 2.0 standards directly onto the Medallion Architecture (Bronze, Silver, Gold), isolating raw ingestion, core historical tracking, snapshot performance optimization, and reporting layers.

```text
      +-------------------------------------------------------+
      |               Bronze Layer (Landing)                  |
      |   Raw Ingestion Seeds (raw_customers, raw_orders)     |
      +---------------------------+---------------------------+
                                  |
                                  v
      +-------------------------------------------------------+
      |              Silver Layer: Staging                    |
      |   stg_customers, stg_orders (SHA256 Hashing & Meta)   |
      +---------------------------+---------------------------+
                                  |
                                  v
      +-------------------------------------------------------+
      |             Silver Layer: Raw Vault                   |
      |   Hubs (hub_customer) | Links (link_order_customer)   |
      |          Satellites (sat_customer_details)            |
      +---------------------------+---------------------------+
                                  |
                                  v
      +-------------------------------------------------------+
      |           Silver Layer: Business Vault                |
      |   Point-In-Time Table (pit_customer Snapshot)         |
      +---------------------------+---------------------------+
                                  |
                                  v
      +-------------------------------------------------------+
      |             Gold Layer: Information Marts             |
      |   Star Schema Views (dim_customers, fact_orders)      |
      +-------------------------------------------------------+
```

### Layer Breakdown

- **1. Bronze Layer (*dv_staging*):** Ingests raw transactional CSV seed payloads (*raw_customers, raw_orders, raw_products*) via dbt seed without applying schema transformations.

- **2. Silver Staging Layer (*dv_staging_staging*):** Computes deterministic SHA256 business keys (*HK_CUSTOMER_ID, HK_ORDER_ID*), change tracking diffs (*HK_CUSTOMER_HASHDIFF*), and system metadata (*RECORD_SOURCE, LOAD_DATETIME*).

- **3. Silver Raw Vault Layer (*dv_staging_raw_vault*):** Builds core Data Vault entities:

  - Hubs (*hub_customer*): Unique business key registries.

  - Links (*link_order_customer*): Immutable relationship tables.

  - Satellites (*sat_customer_details*): Descriptive context tables tracking complete change history over time.

- **4. Silver Business Vault Layer (*dv_staging_business_vault*):**  Contains snapshot Point-In-Time (*pit_customer*) tables that optimize query performance by avoiding expensive runtime window functions during point-in-time joins.

- **5. Gold Information Marts (*dv_staging_info_marts*):** Exposes denormalized Star Schema views (*dim_customers, fact_orders*) optimized for direct consumption by BI tools like Power BI and Databricks SQL Editor.

## 🛠️ Tech Stack & Prerequisites

- **Data Warehouse / Lakehouse:** Azure Databricks (Delta Lake)

- **Data Governance:** Unity Catalog

- **Transformation Framework:** dbt Core (dbt-databricks adapter)

- **Data Vault Framework:** AutomateDV (formerly dbtvault)

- **Cloud Storage:** Azure Data Lake Storage (ADLS Gen2)

## 📂 Project Directory Structure

```text
databricks-data-vault-engine/
├── seeds/                         # Raw CSV seed payloads (Bronze)
│   ├── raw_customers.csv
│   └── raw_orders.csv
├── models/
│   ├── staging/                   # Staging models (SHA256 Hashing)
│   │   ├── stg_customers.sql
│   │   └── stg_orders.sql
│   ├── raw_vault/                 # Core Data Vault entities
│   │   ├── hub_customer.sql
│   │   ├── link_order_customer.sql
│   │   └── sat_customer_details.sql
│   ├── business_vault/            # Business Vault snapshot models
│   │   └── pit_customer.sql
│   └── info_marts/                # Gold layer Star Schema views
│       ├── dim_customers.sql
│       └── fact_orders.sql
├── dbt_project.yml                # Project configurations & schema mappings
├── packages.yml                   # Package dependencies (automate_dv, dbt_utils)
└── README.md
```

## 🚀 Execution & Quickstart Guide

### 1. Environment Setup

Clone the repository and set up a virtual environment:

```powershell
git clone https://github.com/YOUR_USERNAME/databricks-data-vault-engine.git
cd databricks-data-vault-engine

python -m venv dbt-vault-env
.\dbt-vault-env\Scripts\Activate.ps1

pip install dbt-databricks
dbt deps
```

### 2. Run the Full Medallion Data Vault Pipeline

Execute the full build sequentially from seeds to Gold Information Marts:

```powershell
# Ingest Bronze seeds
dbt seed

# Compile and materialize all models (Staging -> Raw Vault -> Business Vault -> Information Marts)
dbt run

# Run automated schema and data quality tests
dbt test
```

## 🧪 Data Quality & Validation

We enforce strict data contracts using native dbt test assertions. Foreign key integrity, key uniqueness, and NOT NULL constraints are automatically validated across Gold Information Marts:

```yaml
models:
  - name: dim_customers
    columns:
      - name: customer_hk
        tests:
          - unique
          - not_null

  - name: fact_orders
    columns:
      - name: customer_hk
        tests:
          - relationships:
              to: ref('dim_customers')
              field: customer_hk
```

## 🔮 Roadmap & Upcoming Features

- **[x] Phase I:** Core Data Vault 2.0 Engine & Gold Information Marts

- **[ ] Phase II:** Automated GitHub Actions CI/CD Pipeline (Slim CI, SQLFluff Linting, Databricks Service Principal integration)

## 📝 Author & Acknowledgments

Author: Venkat Rajadurai

Articles & Guides: Read the full technical deep-dive on Medium (Insert your Medium article link here once published)
