-- =============================================================================
-- Views & Materialized Analytics Views: NovaPharm Analytics System
-- Description: Core analytical transformations for Market Share, Price Index, Evolution Index.
-- =============================================================================

-- VIEW 1: Monthly Product Performance & Market Share
CREATE VIEW vw_monthly_product_kpis AS
SELECT 
    s.date,
    d.year,
    d.month_num,
    d.year_month,
    p.product_id,
    p.product_name,
    p.brand_name,
    p.therapeutic_area,
    p.product_type,
    SUM(s.units_sold) AS novapharm_units,
    SUM(s.revenue) AS novapharm_revenue,
    SUM(m.total_market_units) AS total_market_units,
    SUM(m.total_market_value) AS total_market_revenue,
    ROUND((SUM(s.revenue) / NULLIF(SUM(m.total_market_value), 0)) * 100, 2) AS value_market_share_pct,
    ROUND((SUM(s.units_sold)::NUMERIC / NULLIF(SUM(m.total_market_units), 0)) * 100, 2) AS unit_market_share_pct
FROM fact_sales s
JOIN dim_product p ON s.product_id = p.product_id
JOIN dim_date d ON s.date = d.date
JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
GROUP BY s.date, d.year, d.month_num, d.year_month, p.product_id, p.product_name, p.brand_name, p.therapeutic_area, p.product_type;

-- VIEW 2: Regional Market Penetration & Performance
CREATE VIEW vw_regional_performance AS
SELECT
    r.region_id,
    r.region,
    r.country,
    p.therapeutic_area,
    p.product_id,
    p.product_name,
    SUM(s.revenue) AS region_revenue,
    SUM(s.units_sold) AS region_units,
    SUM(pen.patients_reached) AS total_patients_reached,
    SUM(pen.addressable_population) AS total_addressable_pop,
    ROUND((SUM(pen.patients_reached)::NUMERIC / NULLIF(SUM(pen.addressable_population), 0)) * 100, 2) AS regional_penetration_pct
FROM fact_sales s
JOIN dim_region r ON s.region_id = r.region_id
JOIN dim_product p ON s.product_id = p.product_id
JOIN fact_penetration pen ON s.date = pen.date AND s.product_id = pen.product_id AND s.region_id = pen.region_id
GROUP BY r.region_id, r.region, r.country, p.therapeutic_area, p.product_id, p.product_name;

-- VIEW 3: Pricing & Competitive Positioning View
CREATE VIEW vw_pricing_competitor_comparison AS
SELECT
    p.product_id,
    p.product_name,
    p.therapeutic_area,
    p.product_type,
    ROUND(AVG(s.selling_price), 2) AS novapharm_avg_price,
    ROUND(AVG(m.competitor_revenue / NULLIF(m.competitor_units, 0)), 2) AS competitor_avg_price,
    ROUND((AVG(s.selling_price) / NULLIF(AVG(m.competitor_revenue / NULLIF(m.competitor_units, 0)), 0)) * 100, 2) AS price_index
FROM fact_sales s
JOIN dim_product p ON s.product_id = p.product_id
JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
GROUP BY p.product_id, p.product_name, p.therapeutic_area, p.product_type;
