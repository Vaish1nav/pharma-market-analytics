-- =============================================================================
-- Database Schema: NovaPharm Market & Product Performance Analytics System
-- Target DBMS: PostgreSQL 14+
-- Description: Dimension and Fact tables with integrity constraints & indexes.
-- =============================================================================

DROP TABLE IF EXISTS fact_penetration CASCADE;
DROP TABLE IF EXISTS fact_market CASCADE;
DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_competitor CASCADE;
DROP TABLE IF EXISTS dim_region CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

-- 1. DIMENSION: dim_product
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    brand_name VARCHAR(50) NOT NULL,
    therapeutic_area VARCHAR(50) NOT NULL,
    dosage_form VARCHAR(30) NOT NULL,
    molecule VARCHAR(100) NOT NULL,
    product_type VARCHAR(20) NOT NULL CHECK (product_type IN ('Branded', 'Generic', 'Line Extension')),
    launch_date DATE NOT NULL,
    patent_status VARCHAR(20) NOT NULL CHECK (patent_status IN ('On-Patent', 'Off-Patent')),
    base_price NUMERIC(10,2) NOT NULL CHECK (base_price > 0)
);

-- 2. DIMENSION: dim_region
CREATE TABLE dim_region (
    region_id INT PRIMARY KEY,
    region VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    primary_city VARCHAR(50) NOT NULL,
    market_type VARCHAR(30) NOT NULL CHECK (market_type IN ('Metro Tier 1', 'Metro Tier 2', 'Regional Tier 3'))
);

-- 3. DIMENSION: dim_competitor
CREATE TABLE dim_competitor (
    competitor_id INT PRIMARY KEY,
    competitor_name VARCHAR(100) NOT NULL,
    competitor_product_name VARCHAR(100) NOT NULL,
    therapeutic_area VARCHAR(50) NOT NULL,
    price_multiplier NUMERIC(4,2) NOT NULL
);

-- 4. DIMENSION: dim_date
CREATE TABLE dim_date (
    date DATE PRIMARY KEY,
    month_num INT NOT NULL CHECK (month_num BETWEEN 1 AND 12),
    month_name VARCHAR(15) NOT NULL,
    quarter VARCHAR(5) NOT NULL,
    year INT NOT NULL CHECK (year >= 2020),
    year_month VARCHAR(7) NOT NULL
);

-- 5. FACT TABLE: fact_sales
CREATE TABLE fact_sales (
    sales_id SERIAL PRIMARY KEY,
    date DATE NOT NULL REFERENCES dim_date(date),
    product_id INT NOT NULL REFERENCES dim_product(product_id),
    region_id INT NOT NULL REFERENCES dim_region(region_id),
    units_sold INT NOT NULL CHECK (units_sold >= 0),
    selling_price NUMERIC(10,2) NOT NULL CHECK (selling_price >= 0),
    revenue NUMERIC(12,2) NOT NULL CHECK (revenue >= 0),
    prescriptions INT NOT NULL CHECK (prescriptions >= 0)
);

-- 6. FACT TABLE: fact_market
CREATE TABLE fact_market (
    market_fact_id SERIAL PRIMARY KEY,
    date DATE NOT NULL REFERENCES dim_date(date),
    product_id INT NOT NULL REFERENCES dim_product(product_id),
    region_id INT NOT NULL REFERENCES dim_region(region_id),
    total_market_units INT NOT NULL CHECK (total_market_units >= 0),
    total_market_value NUMERIC(14,2) NOT NULL CHECK (total_market_value >= 0),
    competitor_units INT NOT NULL CHECK (competitor_units >= 0),
    competitor_revenue NUMERIC(14,2) NOT NULL CHECK (competitor_revenue >= 0)
);

-- 7. FACT TABLE: fact_penetration
CREATE TABLE fact_penetration (
    penetration_id SERIAL PRIMARY KEY,
    date DATE NOT NULL REFERENCES dim_date(date),
    product_id INT NOT NULL REFERENCES dim_product(product_id),
    region_id INT NOT NULL REFERENCES dim_region(region_id),
    target_population INT NOT NULL CHECK (target_population >= 0),
    addressable_population INT NOT NULL CHECK (addressable_population >= 0),
    patients_reached INT NOT NULL CHECK (patients_reached >= 0)
);

-- INDEXES FOR ANALYTICAL QUERY PERFORMANCE
CREATE INDEX idx_fact_sales_date_prod ON fact_sales(date, product_id);
CREATE INDEX idx_fact_sales_region ON fact_sales(region_id);
CREATE INDEX idx_fact_market_date_prod ON fact_market(date, product_id);
CREATE INDEX idx_fact_penetration_prod_reg ON fact_penetration(product_id, region_id);
