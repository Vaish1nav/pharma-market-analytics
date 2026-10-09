# NovaPharm — Pharmaceutical Market & Product Performance Analytics System

![Domain](https://img.shields.io/badge/Domain-Pharmaceutical_Market_Analytics-1F497D)
![Role](https://img.shields.io/badge/Role-Business_Analytics_%26_Consulting-2F5597)
![Stack](https://img.shields.io/badge/Tech_Stack-SQL_|_Python_|_Power_BI_|_Excel-green)
![Data](https://img.shields.io/badge/Dataset-Synthetic_Relational_Data_(18k%2B_rows)-orange)

---

## Executive Overview
**NovaPharm Laboratories** is a global pharmaceutical manufacturer operating across 6 major therapeutic areas (Cardiovascular, Oncology, Diabetes, Respiratory, Gastroenterology, CNS) with a portfolio of 25 branded and generic therapies.

This project delivers an end-to-end commercial analytics system designed to evaluate **market share dynamics, product growth evolution, patient penetration, competitive pricing positioning, and portfolio revenue contribution**.

### Key Business Results (2025 Financial Year)
* **Total Portfolio Revenue:** **$843.30 Million** (+12.06% YoY Growth from $752.53M in 2024).
* **Overall Market Share:** **30.71%** of total addressable market ($2.75 Billion total market value).
* **Top Revenue Growth Drivers:** `OncoShield 100mg` (+29.34% YoY, $106.60M) and `GlycaControl 5mg` (+28.98% YoY, $48.69M).
* **Core Risk Identification:** Generic erosion in `GastraGuard 20mg` (-10.61% YoY) and premium pricing pressure on `Targetis 250mg` (Price Index = 109.1).

---

## Key Performance Indicators (KPI Definitions)

1. **Revenue ($):** Gross product revenue calculated as $\text{Units Sold} \times \text{Selling Price}$.
2. **Value Market Share (%):** $\frac{\text{NovaPharm Revenue}}{\text{Total Market Revenue}} \times 100$.
3. **Unit Market Share (%):** $\frac{\text{NovaPharm Units Sold}}{\text{Total Market Units}} \times 100$.
4. **Year-over-Year Growth (%):** $\frac{\text{Revenue}_{2025} - \text{Revenue}_{2024}}{\text{Revenue}_{2024}} \times 100$.
5. **Evolution Index (Base Jan 2024 = 100):** $\frac{\text{Revenue}_{\text{Current Month}}}{\text{Revenue}_{\text{Jan 2024}}} \times 100$.
6. **Patient Penetration Rate (%):** $\frac{\text{Patients Reached}}{\text{Addressable Patient Population}} \times 100$.
7. **Price Index (PI):** $\frac{\text{NovaPharm Average Selling Price}}{\text{Competitor Average Selling Price}} \times 100$.

---

## Repository Architecture

```text
pharma-market-analytics/
│
├── data/
│   ├── raw/                        # 7 Relational raw CSV files (18,000+ observations)
│   │   ├── dim_product.csv
│   │   ├── dim_region.csv
│   │   ├── dim_competitor.csv
│   │   ├── dim_date.csv
│   │   ├── fact_sales.csv
│   │   ├── fact_market.csv
│   │   └── fact_penetration.csv
│   └── processed/                  # Processed SQLite DB & CSV Analytical Summaries
│       ├── novapharm.db
│       ├── summary_executive_kpis.csv
│       ├── summary_product_performance.csv
│       ├── summary_regional_penetration.csv
│       ├── summary_pricing_index.csv
│       └── summary_strategic_matrix.csv
│
├── sql/
│   ├── schema/
│   │   └── 01_create_schema.sql    # PostgreSQL DDL, PKs, FKs, Indexes & Constraints
│   ├── transformations/
│   │   └── 02_views_and_mviews.sql # Calculated views for Market Share & Price Index
│   └── analytical_queries/
│       └── 03_business_queries.sql # 20 Business-oriented Analytical SQL Queries
│
├── python/
│   ├── data_generation/
│   │   └── generate_data.py        # Reproducible synthetic dataset generator
│   ├── data_cleaning/
│   │   └── validate_and_clean.py   # Data integrity, NULL check & schema validation
│   └── analysis/
│       ├── analyze_market.py       # SQLite ETL pipeline & query execution
│       └── create_excel_report.py  # OpenPyXL script creating 5-sheet formatted workbook
│
├── excel/
│   └── pharma_market_analysis.xlsx # Executive Excel Workbook (5 Sheets)
│
├── powerbi/
│   ├── dax_measures.dax            # 20+ Production DAX Measures
│   └── dashboard_design_spec.md    # 4-Page Power BI Dashboard Blueprint & Visual Specs
│
├── presentation/
│   └── executive_management_review.md # 10-Slide Management Consulting Deck Script
│
├── docs/
│   ├── KPI_definitions.md          # Complete mathematical KPI reference
│   ├── business_questions.md       # 20 Business Questions registry
│   ├── methodology.md              # ETL & analytical transformation rules
│   └── pharma_domain_primer.md     # Pharma commercial analytics domain guide
│
├── README.md                       # Main project documentation
└── requirements.txt                # Python environment requirements
```

---

## Technical Stack & Implementation Details

* **SQL Database:** PostgreSQL 14+ / SQLite 3 (Window Functions `LAG`, `RANK`, `DENSE_RANK`, CTEs, Subqueries, Aggregations).
* **Python:** `pandas`, `numpy`, `openpyxl`, `sqlite3` (Data generation, statistical modeling, ETL, report automation).
* **Excel Analysis:** 5 formatted sheets featuring KPI Scorecards, Pivot Tables, Currency/Percentage formatting, and Strategic Allocation matrices.
* **Power BI Analytics:** Star-Schema Data Model, 20+ DAX measures, Time Intelligence (`SAMEPERIODLASTYEAR`), BCG Matrix Scatter Plot visual.

---

## How to Run & Reproduce Project

1. **Clone Repository & Install Dependencies:**
   ```bash
   git clone https://github.com/your-username/pharma-market-analytics.git
   cd pharma-market-analytics
   pip install -r requirements.txt
   ```

2. **Generate Synthetic Relational Dataset:**
   ```bash
   python python/data_generation/generate_data.py
   ```

3. **Run SQLite ETL & SQL Query Analytics:**
   ```bash
   python python/analysis/analyze_market.py
   ```

4. **Generate Executive Excel Report:**
   ```bash
   python python/analysis/create_excel_report.py
   ```

---

## Strategic Portfolio Recommendations

1. **Prioritize Stars (Oncology & Diabetes):** Reallocate +15% commercial sales force coverage to `OncoShield 100mg` ($106.60M, +29.34% YoY) and `GlycaControl 5mg` ($48.69M, +28.98% YoY).
2. **Pricing Optimization for Targetis 250mg:** Adjust net pricing by -5% through rebate structures to counter competitor CancerStop's aggressive price expansion (Price Index = 109.1).
3. **Target Regional Expansion in APAC India:** Expand field representative coverage in Delhi NCR and Bengaluru by +25% to capture 61.35M addressable under-penetrated patients.
4. **Rationalize Declining Generic Lines:** Limit promotional capital on `GastraGuard 20mg` (-10.61% YoY) and `Vasoten 5mg` (-10.19% YoY), saving $4.5M for re-investment in Oncology pipelines.

---

## Project Limitations & Future Enhancements

* **Synthetic Data Boundary:** Designed using synthetic distributions; real-world pharma analytics incorporates IQVIA MIDAS/NPA audits and longitudinal patient claims data (LAAD).
* **Future Enhancement:** Integrate Python machine learning (`scikit-learn` ARIMA/Prophet) for 12-month predictive sales forecasting and price elasticity estimation.
