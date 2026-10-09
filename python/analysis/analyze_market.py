import os
import sqlite3
import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RAW_DATA_DIR = os.path.join(BASE_DIR, 'data', 'raw')
PROCESSED_DATA_DIR = os.path.join(BASE_DIR, 'data', 'processed')
DB_PATH = os.path.join(PROCESSED_DATA_DIR, 'novapharm.db')

os.makedirs(PROCESSED_DATA_DIR, exist_ok=True)
print(f'Populating SQLite Database at {DB_PATH}...')

conn = sqlite3.connect(DB_PATH)

tables = ['dim_product', 'dim_region', 'dim_competitor', 'dim_date', 'fact_sales', 'fact_market', 'fact_penetration']
for t in tables:
    csv_file = os.path.join(RAW_DATA_DIR, f'{t}.csv')
    df = pd.read_csv(csv_file)
    df.to_sql(t, conn, if_exists='replace', index=False)
    print(f' - Loaded {len(df)} rows into table: {t}')

print('\n--- Executing Key Analytical Queries ---')

q1 = '''
SELECT
    d.year,
    ROUND(SUM(s.revenue), 2) AS novapharm_revenue,
    SUM(s.units_sold) AS novapharm_units,
    ROUND(SUM(m.total_market_value), 2) AS total_market_value,
    ROUND((SUM(s.revenue) / SUM(m.total_market_value)) * 100, 2) AS value_market_share_pct
FROM fact_sales s
JOIN dim_date d ON s.date = d.date
JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
GROUP BY d.year
ORDER BY d.year;
'''
df_q1 = pd.read_sql_query(q1, conn)
print('\n1. Executive Performance Summary:')
print(df_q1.to_string(index=False))
df_q1.to_csv(os.path.join(PROCESSED_DATA_DIR, 'summary_executive_kpis.csv'), index=False)

q2 = '''
WITH yearly AS (
    SELECT
        p.product_id,
        p.product_name,
        p.brand_name,
        p.therapeutic_area,
        p.product_type,
        SUM(CASE WHEN d.year = 2024 THEN s.revenue ELSE 0 END) AS rev_2024,
        SUM(CASE WHEN d.year = 2025 THEN s.revenue ELSE 0 END) AS rev_2025,
        SUM(CASE WHEN d.year = 2025 THEN s.units_sold ELSE 0 END) AS units_2025,
        SUM(CASE WHEN d.year = 2025 THEN m.total_market_value ELSE 0 END) AS market_val_2025
    FROM fact_sales s
    JOIN dim_product p ON s.product_id = p.product_id
    JOIN dim_date d ON s.date = d.date
    JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
    GROUP BY p.product_id, p.product_name, p.brand_name, p.therapeutic_area, p.product_type
)
SELECT
    product_id,
    product_name,
    brand_name,
    therapeutic_area,
    product_type,
    ROUND(rev_2024, 2) AS rev_2024,
    ROUND(rev_2025, 2) AS rev_2025,
    ROUND(((rev_2025 - rev_2024) / NULLIF(rev_2024, 0)) * 100, 2) AS yoy_growth_pct,
    ROUND((rev_2025 / NULLIF(market_val_2025, 0)) * 100, 2) AS market_share_2025_pct
FROM yearly
ORDER BY rev_2025 DESC;
'''
df_q2 = pd.read_sql_query(q2, conn)
print('\n2. Product YoY Performance (Top 5):')
print(df_q2.head(5).to_string(index=False))
df_q2.to_csv(os.path.join(PROCESSED_DATA_DIR, 'summary_product_performance.csv'), index=False)

q3 = '''
SELECT
    r.region_id,
    r.region,
    r.country,
    r.market_type,
    ROUND(SUM(s.revenue), 2) AS region_revenue,
    SUM(pen.addressable_population) AS addressable_population,
    SUM(pen.patients_reached) AS patients_reached,
    ROUND((CAST(SUM(pen.patients_reached) AS FLOAT) / SUM(pen.addressable_population)) * 100, 2) AS penetration_rate_pct
FROM fact_sales s
JOIN dim_region r ON s.region_id = r.region_id
JOIN fact_penetration pen ON s.date = pen.date AND s.product_id = pen.product_id AND s.region_id = pen.region_id
WHERE s.date >= '2025-01-01'
GROUP BY r.region_id, r.region, r.country, r.market_type
ORDER BY penetration_rate_pct DESC;
'''
df_q3 = pd.read_sql_query(q3, conn)
print('\n3. Regional Penetration Performance:')
print(df_q3.to_string(index=False))
df_q3.to_csv(os.path.join(PROCESSED_DATA_DIR, 'summary_regional_penetration.csv'), index=False)

q4 = '''
SELECT
    p.product_id,
    p.product_name,
    p.therapeutic_area,
    p.product_type,
    ROUND(AVG(s.selling_price), 2) AS novapharm_price,
    ROUND(AVG(CAST(m.competitor_revenue AS FLOAT) / NULLIF(m.competitor_units, 0)), 2) AS competitor_price,
    ROUND((AVG(s.selling_price) / AVG(CAST(m.competitor_revenue AS FLOAT) / NULLIF(m.competitor_units, 0))) * 100, 2) AS price_index,
    ROUND((SUM(s.revenue) / SUM(m.total_market_value)) * 100, 2) AS novapharm_market_share_pct
FROM fact_sales s
JOIN dim_product p ON s.product_id = p.product_id
JOIN fact_market m ON s.date = m.date AND s.product_id = m.product_id AND s.region_id = m.region_id
WHERE s.date >= '2025-01-01'
GROUP BY p.product_id, p.product_name, p.therapeutic_area, p.product_type
ORDER BY price_index DESC;
'''
df_q4 = pd.read_sql_query(q4, conn)
print('\n4. Pricing Index & Competitor Benchmark (Top 5 Highest Price Index):')
print(df_q4.head(5).to_string(index=False))
df_q4.to_csv(os.path.join(PROCESSED_DATA_DIR, 'summary_pricing_index.csv'), index=False)

q5 = '''
WITH prod_metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.therapeutic_area,
        SUM(CASE WHEN d.year = 2025 THEN s.revenue ELSE 0 END) AS revenue,
        ROUND((SUM(CASE WHEN d.year = 2025 THEN s.revenue ELSE 0 END) / SUM(CASE WHEN d.year = 2025 THEN m.total_market_value ELSE 0 END)) * 100, 2) AS market_share_pct,
        ROUND(((SUM(CASE WHEN d.year = 2025 THEN s.revenue ELSE 0 END) - SUM(CASE WHEN d.year = 2024 THEN s.revenue ELSE 0 END)) / 
        NULLIF(SUM(CASE WHEN d.year = 2024 THEN s.revenue ELSE 0 END), 0)) * 100, 2) AS yoy_growth_pct,
        ROUND((AVG(s.selling_price) / AVG(CAST(m.competitor_revenue AS FLOAT) / NULLIF(m.competitor_units, 0))) * 100, 2) AS price_index
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
    ROUND(revenue, 2) AS revenue,
    market_share_pct,
    yoy_growth_pct,
    price_index,
    CASE
        WHEN market_share_pct >= 30 AND yoy_growth_pct >= 8 THEN 'INVEST (Stars)'
        WHEN market_share_pct >= 30 AND yoy_growth_pct < 8 THEN 'DEFEND (Cash Cows)'
        WHEN market_share_pct < 30 AND yoy_growth_pct >= 8 AND price_index > 105 THEN 'OPTIMIZE PRICING'
        WHEN market_share_pct < 30 AND yoy_growth_pct >= 8 THEN 'EXPAND REGIONALLY'
        WHEN yoy_growth_pct < 0 THEN 'MONITOR / DE-PRIORITIZE'
        ELSE 'MAINTAIN'
    END AS strategic_recommendation
FROM prod_metrics
ORDER BY revenue DESC;
'''
df_q5 = pd.read_sql_query(q5, conn)
print('\n5. Strategic Product Recommendations Summary:')
print(df_q5.to_string(index=False))
df_q5.to_csv(os.path.join(PROCESSED_DATA_DIR, 'summary_strategic_matrix.csv'), index=False)

conn.close()
print('\nData processing and SQLite analysis completed successfully!')
