-- =============================================================================
-- Analytical SQL Queries: NovaPharm Market & Product Performance System
-- Target DBMS: PostgreSQL / Standard ANSI SQL
-- Description: 20 Business-oriented Analytical Queries
-- =============================================================================

-- QUERY 1: Overall NovaPharm Portfolio Performance Summary
-- Business Question: What is NovaPharm\'s total revenue, total units sold, and overall market share for 2024 and 2025?
SELECT
    d.year,
    SUM(s.revenue) AS novapharm_revenue,
    SUM(s.units_sold) AS novapharm_units,
    SUM(m.total_market_value) AS total_market_value,
    ROUND((SUM(s.revenue) / SUM(m.total_market_value)) * 100, 2) AS value_market_share_pct
FROM fact_sales s
JOIN dim_date d ON s.date = d.date
JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
GROUP BY d.year
ORDER BY d.year;

-- QUERY 2: Market Share by Therapeutic Area (2025)
-- Business Question: What is our market share across each Therapeutic Area, and which TA dominates?
SELECT
    p.therapeutic_area,
    SUM(s.revenue) AS novapharm_ta_revenue,
    SUM(m.total_market_value) AS total_ta_market_value,
    ROUND((SUM(s.revenue) / SUM(m.total_market_value)) * 100, 2) AS ta_market_share_pct,
    ROUND((SUM(s.revenue) / SUM(SUM(s.revenue)) OVER()) * 100, 2) AS portfolio_revenue_contrib_pct
FROM fact_sales s
JOIN dim_product p ON s.product_id = p.product_id
JOIN dim_date d ON s.date = d.date
JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
WHERE d.year = 2025
GROUP BY p.therapeutic_area
ORDER BY novapharm_ta_revenue DESC;

-- QUERY 3: Product Revenue & Market Share Ranking (2025)
-- Business Question: How do individual products rank in revenue and market share performance?
SELECT
    p.product_id,
    p.product_name,
    p.therapeutic_area,
    p.product_type,
    SUM(s.revenue) AS annual_revenue,
    RANK() OVER (ORDER BY SUM(s.revenue) DESC) AS revenue_rank,
    ROUND((SUM(s.revenue) / SUM(m.total_market_value)) * 100, 2) AS market_share_pct
FROM fact_sales s
JOIN dim_product p ON s.product_id = p.product_id
JOIN dim_date d ON s.date = d.date
JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
WHERE d.year = 2025
GROUP BY p.product_id, p.product_name, p.therapeutic_area, p.product_type
ORDER BY revenue_rank;

-- QUERY 4: Year-over-Year (YoY) Product Growth Analysis
-- Business Question: Which products achieved the highest YoY growth from 2024 to 2025?
WITH yearly_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.therapeutic_area,
        d.year,
        SUM(s.revenue) AS revenue
    FROM fact_sales s
    JOIN dim_product p ON s.product_id = p.product_id
    JOIN dim_date d ON s.date = d.date
    GROUP BY p.product_id, p.product_name, p.therapeutic_area, d.year
)
SELECT
    product_id,
    product_name,
    therapeutic_area,
    MAX(CASE WHEN year = 2024 THEN revenue END) AS revenue_2024,
    MAX(CASE WHEN year = 2025 THEN revenue END) AS revenue_2025,
    ROUND(
        ((MAX(CASE WHEN year = 2025 THEN revenue END) - MAX(CASE WHEN year = 2024 THEN revenue END)) / 
        MAX(CASE WHEN year = 2024 THEN revenue END)) * 100, 2
    ) AS yoy_growth_pct
FROM yearly_sales
GROUP BY product_id, product_name, therapeutic_area
ORDER BY yoy_growth_pct DESC;

-- QUERY 5: Evolution Index Calculation (Base Month = Jan 2024)
-- Business Question: How has each product evolved compared to the base period (Jan 2024 = 100)?
WITH base_period AS (
    SELECT product_id, SUM(revenue) AS base_revenue
    FROM fact_sales
    WHERE date = \'2024-01-01\'
    GROUP BY product_id
),
latest_period AS (
    SELECT product_id, SUM(revenue) AS current_revenue
    FROM fact_sales
    WHERE date = \'2025-12-01\'
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.therapeutic_area,
    b.base_revenue AS jan_2024_revenue,
    l.current_revenue AS dec_2025_revenue,
    ROUND((l.current_revenue / NULLIF(b.base_revenue, 0)) * 100, 2) AS evolution_index,
    CASE 
        WHEN (l.current_revenue / NULLIF(b.base_revenue, 0)) * 100 > 110 THEN \'Strong Growth\'
        WHEN (l.current_revenue / NULLIF(b.base_revenue, 0)) * 100 BETWEEN 95 AND 110 THEN \'Stable\'
        ELSE \'Declining\'
    END AS performance_category
FROM dim_product p
JOIN base_period b ON p.product_id = b.product_id
JOIN latest_period l ON p.product_id = l.product_id
ORDER BY evolution_index DESC;

-- QUERY 6: Regional Market Penetration Rate Analysis
-- Business Question: Which regions have the highest and lowest patient penetration rates?
SELECT
    r.region_id,
    r.region,
    r.country,
    SUM(s.revenue) AS region_revenue,
    SUM(pen.addressable_population) AS addressable_population,
    SUM(pen.patients_reached) AS patients_reached,
    ROUND((SUM(pen.patients_reached)::NUMERIC / SUM(pen.addressable_population)) * 100, 2) AS penetration_rate_pct
FROM fact_sales s
JOIN dim_region r ON s.region_id = r.region_id
JOIN fact_penetration pen ON s.date = pen.date AND s.product_id = pen.product_id AND s.region_id = pen.region_id
WHERE s.date >= \'2025-01-01\'
GROUP BY r.region_id, r.region, r.country
ORDER BY penetration_rate_pct DESC;

-- QUERY 7: Price Index vs Competitor & Market Share Correlation
-- Business Question: Are higher-priced NovaPharm products losing market share to competitors?
SELECT
    p.product_id,
    p.product_name,
    p.product_type,
    ROUND(AVG(s.selling_price), 2) AS novapharm_avg_price,
    ROUND(AVG(m.competitor_revenue / NULLIF(m.competitor_units, 0)), 2) AS competitor_avg_price,
    ROUND((AVG(s.selling_price) / AVG(m.competitor_revenue / NULLIF(m.competitor_units, 0))) * 100, 2) AS price_index,
    ROUND((SUM(s.revenue) / SUM(m.total_market_value)) * 100, 2) AS novapharm_market_share_pct
FROM fact_sales s
JOIN dim_product p ON s.product_id = p.product_id
JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
WHERE s.date >= \'2025-01-01\'
GROUP BY p.product_id, p.product_name, p.product_type
ORDER BY price_index DESC;

-- QUERY 8: Portfolio Cumulative Revenue Contribution (Pareto 80/20 Analysis)
-- Business Question: Which top products account for 80% of total company revenue?
WITH product_rev AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(s.revenue) AS product_revenue
    FROM fact_sales s
    JOIN dim_product p ON s.product_id = p.product_id
    WHERE s.date >= \'2025-01-01\'
    GROUP BY p.product_id, p.product_name
),
cumulative_rev AS (
    SELECT
        product_id,
        product_name,
        product_revenue,
        SUM(product_revenue) OVER (ORDER BY product_revenue DESC) AS running_total_revenue,
        SUM(product_revenue) OVER () AS total_portfolio_revenue
    FROM product_rev
)
SELECT
    product_id,
    product_name,
    product_revenue,
    ROUND((product_revenue / total_portfolio_revenue) * 100, 2) AS revenue_share_pct,
    ROUND((running_total_revenue / total_portfolio_revenue) * 100, 2) AS cumulative_share_pct,
    CASE WHEN (running_total_revenue / total_portfolio_revenue) <= 0.80 THEN \'Top 80% Core\' ELSE \'Bottom 20% Tail\' END AS pareto_class
FROM cumulative_rev
ORDER BY product_revenue DESC;

-- QUERY 9: Portfolio BCG Growth-Share Quadrant Matrix
-- Business Question: How are products categorized across Market Share and Growth Rate?
WITH market_share AS (
    SELECT
        p.product_id,
        p.product_name,
        p.therapeutic_area,
        SUM(s.revenue) AS revenue,
        ROUND((SUM(s.revenue) / SUM(m.total_market_value)) * 100, 2) AS market_share_pct
    FROM fact_sales s
    JOIN dim_product p ON s.product_id = p.product_id
    JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
    WHERE s.date >= \'2025-01-01\'
    GROUP BY p.product_id, p.product_name, p.therapeutic_area
),
yoy_growth AS (
    SELECT
        s.product_id,
        ROUND(((SUM(CASE WHEN d.year = 2025 THEN s.revenue END) - SUM(CASE WHEN d.year = 2024 THEN s.revenue END)) / 
        SUM(CASE WHEN d.year = 2024 THEN s.revenue END)) * 100, 2) AS growth_pct
    FROM fact_sales s
    JOIN dim_date d ON s.date = d.date
    GROUP BY s.product_id
)
SELECT
    ms.product_id,
    ms.product_name,
    ms.therapeutic_area,
    ms.revenue,
    ms.market_share_pct,
    yg.growth_pct,
    CASE 
        WHEN ms.market_share_pct >= 30 AND yg.growth_pct >= 8 THEN \'Stars (High Share / High Growth)\'
        WHEN ms.market_share_pct >= 30 AND yg.growth_pct < 8 THEN \'Cash Cows (High Share / Low Growth)\'
        WHEN ms.market_share_pct < 30 AND yg.growth_pct >= 8 THEN \'Question Marks (Low Share / High Growth)\'
        ELSE \'Dogs (Low Share / Low Growth)\'
    END AS bcg_quadrant
FROM market_share ms
JOIN yoy_growth yg ON ms.product_id = yg.product_id
ORDER BY ms.revenue DESC;

-- QUERY 10: 3-Month Rolling Average Revenue Trend by Therapeutic Area
-- Business Question: What is the 3-month rolling revenue trend for each Therapeutic Area?
WITH monthly_ta_revenue AS (
    SELECT
        d.year_month,
        s.date,
        p.therapeutic_area,
        SUM(s.revenue) AS monthly_revenue
    FROM fact_sales s
    JOIN dim_product p ON s.product_id = p.product_id
    JOIN dim_date d ON s.date = d.date
    GROUP BY d.year_month, s.date, p.therapeutic_area
)
SELECT
    year_month,
    therapeutic_area,
    monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (
        PARTITION BY therapeutic_area 
        ORDER BY date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3m_avg_revenue
FROM monthly_ta_revenue
ORDER BY therapeutic_area, date;

-- QUERY 11: Regional Growth-Penetration Opportunity Identification
-- Business Question: Which regions have high addressable populations but low penetration (Expansion targets)?
SELECT
    r.region,
    r.country,
    r.market_type,
    SUM(pen.addressable_population) AS total_addressable_pop,
    SUM(pen.patients_reached) AS total_patients_reached,
    ROUND((SUM(pen.patients_reached)::NUMERIC / SUM(pen.addressable_population)) * 100, 2) AS penetration_pct,
    SUM(s.revenue) AS region_revenue,
    CASE 
        WHEN SUM(pen.addressable_population) > 3000000 AND (SUM(pen.patients_reached)::NUMERIC / SUM(pen.addressable_population)) * 100 < 25.0 
        THEN \'Priority Expansion Target\'
        WHEN (SUM(pen.patients_reached)::NUMERIC / SUM(pen.addressable_population)) * 100 >= 30.0 
        THEN \'Mature Strong Market\'
        ELSE \'Niche/Secondary Market\'
    END AS strategic_opportunity_label
FROM fact_sales s
JOIN dim_region r ON s.region_id = r.region_id
JOIN fact_penetration pen ON s.date = pen.date AND s.product_id = pen.product_id AND s.region_id = pen.region_id
WHERE s.date >= \'2025-01-01\'
GROUP BY r.region, r.country, r.market_type
ORDER BY total_addressable_pop DESC;

-- QUERY 12: Month-over-Month Growth Rate (MoM) by Product
-- Business Question: What is the MoM revenue growth rate for OncoShield 100mg in 2025 using LAG()?
WITH mom_sales AS (
    SELECT
        s.date,
        p.product_name,
        SUM(s.revenue) AS monthly_revenue
    FROM fact_sales s
    JOIN dim_product p ON s.product_id = p.product_id
    WHERE p.product_id = 201 AND s.date >= \'2025-01-01\'
    GROUP BY s.date, p.product_name
)
SELECT
    date,
    product_name,
    monthly_revenue,
    LAG(monthly_revenue, 1) OVER (ORDER BY date) AS prev_month_revenue,
    ROUND(
        ((monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY date)) / 
        NULLIF(LAG(monthly_revenue, 1) OVER (ORDER BY date), 0)) * 100, 2
    ) AS mom_growth_pct
FROM mom_sales
ORDER BY date;

-- QUERY 13: Respiratory Product Seasonality Impact Analysis
-- Business Question: How does Respiratory product revenue fluctuate between winter peak and summer off-peak?
SELECT
    d.quarter,
    p.product_name,
    SUM(s.revenue) AS quarterly_revenue,
    SUM(s.units_sold) AS quarterly_units
FROM fact_sales s
JOIN dim_product p ON s.product_id = p.product_id
JOIN dim_date d ON s.date = d.date
WHERE p.therapeutic_area = \'Respiratory\' AND d.year = 2025
GROUP BY d.quarter, p.product_name
ORDER BY p.product_name, d.quarter;

-- QUERY 14: Branded vs Generic Portfolio Mix & Performance Comparison
-- Business Question: How does Branded product performance compare to Generic products in revenue and market share?
SELECT
    p.product_type,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(s.revenue) AS total_revenue,
    ROUND(AVG(s.selling_price), 2) AS avg_selling_price,
    ROUND((SUM(s.revenue) / SUM(m.total_market_value)) * 100, 2) AS total_market_share_pct
FROM fact_sales s
JOIN dim_product p ON s.product_id = p.product_id
JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
WHERE s.date >= \'2025-01-01\'
GROUP BY p.product_type;

-- QUERY 15: Regional Product Rank using DENSE_RANK()
-- Business Question: What is NovaPharm\'s top product in each region based on 2025 sales volume?
WITH regional_ranks AS (
    SELECT
        r.region,
        p.product_name,
        SUM(s.units_sold) AS units_sold,
        DENSE_RANK() OVER (PARTITION BY r.region ORDER BY SUM(s.units_sold) DESC) AS regional_rank
    FROM fact_sales s
    JOIN dim_region r ON s.region_id = r.region_id
    JOIN dim_product p ON s.product_id = p.product_id
    WHERE s.date >= \'2025-01-01\'
    GROUP BY r.region, p.product_name
)
SELECT region, product_name, units_sold, regional_rank
FROM regional_ranks
WHERE regional_rank <= 3
ORDER BY region, regional_rank;

-- QUERY 16: Quarterly Evolution Index Summary (2024 Q1 vs 2025 Q4)
-- Business Question: What is the total portfolio evolution index comparing 2024 Q1 to 2025 Q4?
WITH q1_2024 AS (
    SELECT SUM(s.revenue) AS q1_2024_rev
    FROM fact_sales s
    JOIN dim_date d ON s.date = d.date
    WHERE d.year = 2024 AND d.quarter = \'Q1\'
),
q4_2025 AS (
    SELECT SUM(s.revenue) AS q4_2025_rev
    FROM fact_sales s
    JOIN dim_date d ON s.date = d.date
    WHERE d.year = 2025 AND d.quarter = \'Q4\'
)
SELECT
    q1.q1_2024_rev,
    q4.q4_2025_rev,
    ROUND((q4.q4_2025_rev / q1.q1_2024_rev) * 100, 2) AS portfolio_evolution_index
FROM q1_2024 q1, q4_2025 q4;

-- QUERY 17: Market Share Gainers vs Losers (2024 vs 2025 Delta Share)
-- Business Question: Which products gained or lost market share percentage points from 2024 to 2025?
WITH share_2024 AS (
    SELECT s.product_id, ROUND((SUM(s.revenue)/SUM(m.total_market_value))*100, 2) AS share_2024
    FROM fact_sales s JOIN dim_date d ON s.date = d.date JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
    WHERE d.year = 2024 GROUP BY s.product_id
),
share_2025 AS (
    SELECT s.product_id, ROUND((SUM(s.revenue)/SUM(m.total_market_value))*100, 2) AS share_2025
    FROM fact_sales s JOIN dim_date d ON s.date = d.date JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
    WHERE d.year = 2025 GROUP BY s.product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.therapeutic_area,
    s24.share_2024,
    s25.share_2025,
    ROUND(s25.share_2025 - s24.share_2024, 2) AS market_share_delta_pts,
    CASE WHEN s25.share_2025 > s24.share_2024 THEN \'Share Gainer\' ELSE \'Share Loser\' END AS share_trajectory
FROM dim_product p
JOIN share_2024 s24 ON p.product_id = s24.product_id
JOIN share_2025 s25 ON p.product_id = s25.product_id
ORDER BY market_share_delta_pts DESC;

-- QUERY 18: Prescription Efficiency (Revenue per Prescription across Regions)
-- Business Question: What is the average revenue generated per prescription written across regions?
SELECT
    r.region,
    r.market_type,
    SUM(s.revenue) AS total_revenue,
    SUM(s.prescriptions) AS total_prescriptions,
    ROUND(SUM(s.revenue) / NULLIF(SUM(s.prescriptions), 0), 2) AS revenue_per_rx
FROM fact_sales s
JOIN dim_region r ON s.region_id = r.region_id
WHERE s.date >= \'2025-01-01\'
GROUP BY r.region, r.market_type
ORDER BY revenue_per_rx DESC;

-- QUERY 19: High-Price Penalty Analysis (Price Index > 105 & Declining Market Share)
-- Business Question: Which products are priced significantly higher than competitors and experiencing market share loss?
WITH share_delta AS (
    SELECT s.product_id, 
           (SUM(CASE WHEN d.year = 2025 THEN s.revenue END)/SUM(CASE WHEN d.year = 2025 THEN m.total_market_value END)*100) -
           (SUM(CASE WHEN d.year = 2024 THEN s.revenue END)/SUM(CASE WHEN d.year = 2024 THEN m.total_market_value END)*100) AS share_change
    FROM fact_sales s JOIN dim_date d ON s.date = d.date JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
    GROUP BY s.product_id
),
price_idx AS (
    SELECT s.product_id, ROUND((AVG(s.selling_price)/AVG(m.competitor_revenue/NULLIF(m.competitor_units,0)))*100, 2) AS price_index
    FROM fact_sales s JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
    GROUP BY s.product_id
)
SELECT
    p.product_id,
    p.product_name,
    pi.price_index,
    ROUND(sd.share_change, 2) AS share_change_pts,
    \'Pricing Review Required (Overpriced & Losing Share)\' AS action_recommended
FROM dim_product p
JOIN price_idx pi ON p.product_id = pi.product_id
JOIN share_delta sd ON p.product_id = sd.product_id
WHERE pi.price_index > 105.0 AND sd.share_change < 0
ORDER BY pi.price_index DESC;

-- QUERY 20: Strategic Investment Allocation Matrix
-- Business Question: What strategic action is recommended for each product based on BCG quadrant and price index?
WITH prod_metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.therapeutic_area,
        SUM(s.revenue) AS revenue,
        ROUND((SUM(s.revenue) / SUM(m.total_market_value)) * 100, 2) AS market_share_pct,
        ROUND(((SUM(CASE WHEN d.year = 2025 THEN s.revenue END) - SUM(CASE WHEN d.year = 2024 THEN s.revenue END)) / 
        SUM(CASE WHEN d.year = 2024 THEN s.revenue END)) * 100, 2) AS yoy_growth_pct,
        ROUND((AVG(s.selling_price) / AVG(m.competitor_revenue / NULLIF(m.competitor_units, 0))) * 100, 2) AS price_index
    FROM fact_sales s
    JOIN dim_product p ON s.product_id = p.product_id
    JOIN dim_date d ON s.date = d.date
    JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
    GROUP BY p.product_id, p.product_name, p.therapeutic_area
)
SELECT
    product_id,
    product_name,
    therapeutic_area,
    revenue,
    market_share_pct,
    yoy_growth_pct,
    price_index,
    CASE
        WHEN market_share_pct >= 30 AND yoy_growth_pct >= 8 THEN \'INVEST (Expand Sales Force & Marketing)\'
        WHEN market_share_pct >= 30 AND yoy_growth_pct < 8 THEN \'DEFEND (Protect Margin & Maintain Prescriber Base)\'
        WHEN market_share_pct < 30 AND yoy_growth_pct >= 8 AND price_index > 105 THEN \'OPTIMIZE PRICING (Reduce Price to Capture Volume)\'
        WHEN market_share_pct < 30 AND yoy_growth_pct >= 8 THEN \'EXPAND REGIONALLY (Target Low-Penetration Markets)\'
        WHEN yoy_growth_pct < 0 THEN \'MONITOR / DE-PRIORITIZE (Limit Capital Reinvestment)\'
        ELSE \'MAINTAIN (Selective Marketing support)\'
    END AS strategic_recommendation
FROM prod_metrics
ORDER BY revenue DESC;
