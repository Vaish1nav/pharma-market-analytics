# Power BI Dashboard Design Architecture & Specification

## Executive Overview
The **NovaPharm Pharmaceutical Market & Product Performance Analytics Dashboard** is designed as a 4-page interactive reporting environment tailored for executive leadership, commercial operations, and portfolio strategy managers.

---

## Page Layout & Navigation Specifications

### PAGE 1 — Executive Market Overview
* **Target Audience:** C-Suite, VP of Commercial Operations, Franchise Heads.
* **Layout:** Grid structure with top KPI scorecard row, trend charts on left, category breakdown on right.
* **Top KPI Scorecards (5 Cards):**
  1. **Total Revenue:** `$843.30 M` (Card visual with YoY indicator callout `+12.06%`).
  2. **Overall Market Share:** `30.71%` (Card visual with target gauge comparison).
  3. **YoY Revenue Growth:** `+12.06%` (Conditional formatting: Green for > 8%, Red for < 0%).
  4. **Average Patient Penetration:** `2.15%` (Card visual).
  5. **Active Portfolio Count:** `25 Products` across `6 Therapeutic Areas`.
* **Visual 1 (Line & Stacked Column Chart):** Total Market Revenue vs NovaPharm Revenue trend by Month (Jan 2024 – Dec 2025).
* **Visual 2 (Clustered Bar Chart):** Revenue and Market Share % by Therapeutic Area (Cardiovascular, Oncology, Diabetes, Respiratory, Gastroenterology, CNS).
* **Visual 3 (Map / Treemap Visual):** Regional Revenue Distribution across 10 global market zones.
* **Visual 4 (Table Visual):** Top 5 Gaining Products vs Top 5 Declining Products by YoY Delta Revenue.

### PAGE 2 — Product & Portfolio Performance (BCG Scatter Plot)
* **Target Audience:** Portfolio Managers, Brand Directors, R&D Resource Allocation Teams.
* **Layout:** Dual layout with interactive BCG Quadrant Scatter Plot on left and Detailed Matrix on right.
* **Visual 1 (BCG Scatter Plot Matrix):**
  * **X-Axis:** Market Share Value % (`0%` to `60%`).
  * **Y-Axis:** YoY Revenue Growth % (`-15%` to `+35%`).
  * **Bubble Size:** Total Revenue ($).
  * **Details / Legend:** Product Name / Therapeutic Area.
  * **Reference Lines:** X-Axis constant at `30.0%` (Market Share Threshold), Y-Axis constant at `8.0%` (Growth Threshold).
  * **Quadrants:**
    1. Top-Right: **Stars** (OncoShield 100mg, GlycaControl 5mg, Lipinox 40mg).
    2. Bottom-Right: **Cash Cows** (AeroBreath Forte, AcidOff 40mg, Cardiovast 10mg).
    3. Top-Left: **Question Marks / High-Growth Target** (ImmunoMax 500mg, Targetis 250mg).
    4. Bottom-Left: **Underperforming / Erosion** (GastraGuard 20mg, Vasoten 5mg, RespiClear Syrup).
* **Visual 2 (Matrix Table):** Product Name, Brand Name, Product Type, Revenue 2024, Revenue 2025, YoY Growth %, Evolution Index, Revenue Contribution %, Product Rank.

### PAGE 3 — Regional & Penetration Analytics
* **Target Audience:** Regional Sales Directors, Country Managers, Field Operations.
* **Layout:** Map visual on left, Penetration vs Population Scatter Plot on right, Regional Deep-Dive table at bottom.
* **Visual 1 (Choropleth Map / Bubble Map):** Patient Penetration % by Region/Country.
* **Visual 2 (Scatter Plot - Addressable Pop vs Patients Reached):**
  * **X-Axis:** Addressable Patient Population (Millions).
  * **Y-Axis:** Patients Reached.
  * **Visual Highlight:** Identifies high population markets with under-indexed patient reach (APAC - India, LATAM - Brazil).
* **Visual 3 (Clustered Column Chart):** Prescription Volume vs Revenue per Prescription across Market Tiers (Tier 1 Metro vs Tier 2 Metro).

### PAGE 4 — Pricing & Competitive Intelligence
* **Target Audience:** Pricing & Market Access Managers, Competitive Intelligence Lead.
* **Layout:** Price Index Distribution Top, Price vs Share Scatter Plot Middle, Pricing Penalty Table Bottom.
* **Visual 1 (Bullet Chart / Dual Line):** NovaPharm Average Selling Price vs Competitor Average Price by Product.
* **Visual 2 (Clustered Bar Chart):** Price Index by Product (Baseline = `100.0`).
* **Visual 3 (Scatter Plot - Price Index vs Market Share %):** Highlights products where Price Index > 105% is driving market share erosion.
* **Visual 4 (Table Visual):** Pricing Intervention Candidates (Products with Price Index > 105.0 and Negative YoY Growth).

---

## Slicers & Global Filter Panel
* **Date Slicer:** Range Slider & Relative Date Filter (Year: 2024, 2025; Quarter: Q1-Q4; Year-Month).
* **Therapeutic Area Slicer:** Multi-select dropdown (Cardiovascular, Oncology, Diabetes, Respiratory, Gastroenterology, CNS).
* **Product Type Slicer:** Checkbox (Branded, Generic, Line Extension).
* **Region / Market Tier Slicer:** Multi-select list (Metro Tier 1, Metro Tier 2).
