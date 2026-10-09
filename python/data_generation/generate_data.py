import os
import pandas as pd
import numpy as np

np.random.seed(42)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RAW_DATA_DIR = os.path.join(BASE_DIR, 'data', 'raw')
os.makedirs(RAW_DATA_DIR, exist_ok=True)

# 1. DIM_PRODUCT
products_data = [
    (101, 'Cardiovast 10mg', 'Cardiovast', 'Cardiovascular', 'Tablet', 'Atorvastatin', 'Branded', '2020-03-15', 'On-Patent', 45.00),
    (102, 'Cardiovast 20mg', 'Cardiovast', 'Cardiovascular', 'Tablet', 'Atorvastatin', 'Branded', '2021-06-10', 'On-Patent', 65.00),
    (103, 'Vasoten 5mg', 'Vasoten', 'Cardiovascular', 'Capsule', 'Amlodipine', 'Generic', '2018-01-20', 'Off-Patent', 18.50),
    (104, 'Lipinox 40mg', 'Lipinox', 'Cardiovascular', 'Tablet', 'Rosuvastatin', 'Branded', '2022-11-01', 'On-Patent', 85.00),
    (201, 'OncoShield 100mg', 'OncoShield', 'Oncology', 'Injectable', 'Pembrolizumab', 'Branded', '2021-09-01', 'On-Patent', 1200.00),
    (202, 'Targetis 250mg', 'Targetis', 'Oncology', 'Tablet', 'Gefitinib', 'Branded', '2019-04-15', 'On-Patent', 850.00),
    (203, 'ImmunoMax 500mg', 'ImmunoMax', 'Oncology', 'Infusion', 'Rituximab', 'Generic', '2017-08-10', 'Off-Patent', 620.00),
    (204, 'OncoShield 200mg', 'OncoShield', 'Oncology', 'Injectable', 'Pembrolizumab', 'Branded', '2023-02-15', 'On-Patent', 2100.00),
    (301, 'GlycaControl 5mg', 'GlycaControl', 'Diabetes', 'Tablet', 'Dapagliflozin', 'Branded', '2020-10-05', 'On-Patent', 110.00),
    (302, 'InsuliMax 100IU', 'InsuliMax', 'Diabetes', 'Pen', 'Insulin Glargine', 'Branded', '2019-02-28', 'On-Patent', 145.00),
    (303, 'Metformin Nova 500mg', 'Metformin Nova', 'Diabetes', 'Tablet', 'Metformin', 'Generic', '2015-05-12', 'Off-Patent', 12.00),
    (304, 'GlycaControl 10mg', 'GlycaControl', 'Diabetes', 'Tablet', 'Dapagliflozin', 'Branded', '2022-01-15', 'On-Patent', 160.00),
    (401, 'AeroBreath Inhaler', 'AeroBreath', 'Respiratory', 'Inhaler', 'Fluticasone/Salmeterol', 'Branded', '2020-07-20', 'On-Patent', 130.00),
    (402, 'PulmoShield 10mg', 'PulmoShield', 'Respiratory', 'Tablet', 'Montelukast', 'Generic', '2016-11-11', 'Off-Patent', 25.00),
    (403, 'RespiClear Syrup', 'RespiClear', 'Respiratory', 'Syrup', 'Ambroxol', 'Generic', '2017-03-30', 'Off-Patent', 15.00),
    (404, 'AeroBreath Forte', 'AeroBreath', 'Respiratory', 'Inhaler', 'Budasonide/Formoterol', 'Branded', '2023-05-10', 'On-Patent', 175.00),
    (501, 'GastraGuard 20mg', 'GastraGuard', 'Gastroenterology', 'Capsule', 'Omeprazole', 'Generic', '2016-04-18', 'Off-Patent', 22.00),
    (502, 'AcidOff 40mg', 'AcidOff', 'Gastroenterology', 'Tablet', 'Pantoprazole', 'Branded', '2021-01-22', 'On-Patent', 55.00),
    (503, 'UlcerFree 300mg', 'UlcerFree', 'Gastroenterology', 'Tablet', 'Ranitidine Substitute', 'Generic', '2018-09-09', 'Off-Patent', 16.00),
    (504, 'GastraGuard 40mg', 'GastraGuard', 'Gastroenterology', 'Capsule', 'Omeprazole', 'Generic', '2019-12-01', 'Off-Patent', 34.00),
    (601, 'NeuroCalm 5mg', 'NeuroCalm', 'CNS', 'Tablet', 'Escitalopram', 'Generic', '2017-06-14', 'Off-Patent', 30.00),
    (602, 'Synaptex 50mg', 'Synaptex', 'CNS', 'Tablet', 'Sertraline', 'Branded', '2022-04-01', 'On-Patent', 95.00),
    (603, 'CogniMax 10mg', 'CogniMax', 'CNS', 'Tablet', 'Donepezil', 'Branded', '2020-11-18', 'On-Patent', 140.00),
    (604, 'NeuroCalm 10mg', 'NeuroCalm', 'CNS', 'Tablet', 'Escitalopram', 'Generic', '2019-08-20', 'Off-Patent', 42.00),
    (605, 'Synaptex 100mg', 'Synaptex', 'CNS', 'Tablet', 'Sertraline', 'Branded', '2023-09-01', 'On-Patent', 150.00)
]
df_dim_product = pd.DataFrame(products_data, columns=['product_id', 'product_name', 'brand_name', 'therapeutic_area', 'dosage_form', 'molecule', 'product_type', 'launch_date', 'patent_status', 'base_price'])
df_dim_product.to_csv(os.path.join(RAW_DATA_DIR, 'dim_product.csv'), index=False)

# 2. DIM_REGION
regions_data = [
    (1, 'North America - East', 'United States', 'New York City', 'Metro Tier 1'),
    (2, 'North America - West', 'United States', 'Los Angeles', 'Metro Tier 1'),
    (3, 'Europe - DACH', 'Germany', 'Frankfurt', 'Metro Tier 1'),
    (4, 'Europe - UK/IE', 'United Kingdom', 'London', 'Metro Tier 1'),
    (5, 'Europe - Southern', 'Spain', 'Madrid', 'Metro Tier 2'),
    (6, 'APAC - Japan', 'Japan', 'Tokyo', 'Metro Tier 1'),
    (7, 'APAC - India North', 'India', 'Delhi NCR', 'Metro Tier 1'),
    (8, 'APAC - India South', 'India', 'Bengaluru', 'Metro Tier 1'),
    (9, 'LATAM - Brazil', 'Brazil', 'Sao Paulo', 'Metro Tier 2'),
    (10, 'MEA - Gulf', 'UAE', 'Dubai', 'Metro Tier 2')
]
df_dim_region = pd.DataFrame(regions_data, columns=['region_id', 'region', 'country', 'primary_city', 'market_type'])
df_dim_region.to_csv(os.path.join(RAW_DATA_DIR, 'dim_region.csv'), index=False)

# 3. DIM_COMPETITOR
competitors_data = [
    (10, 'CardioGlobal Pharma', 'Cardiostat', 'Cardiovascular', 0.95),
    (11, 'Apex Healthcare', 'VasoPlus', 'Cardiovascular', 0.88),
    (12, 'OncoNova Therapeutics', 'CancerStop', 'Oncology', 1.10),
    (13, 'GlycoGlobal Labs', 'SugarNorm', 'Diabetes', 0.92),
    (14, 'RespiraCorp', 'BreatheEasy', 'Respiratory', 1.05),
    (15, 'GastroMed Inc.', 'AcidiStop', 'Gastroenterology', 0.90),
    (16, 'NeuroPharm Ltd.', 'MindBalance', 'CNS', 1.08),
    (17, 'GenericX Pharma', 'GenericMulti', 'Multiple', 0.75)
]
df_dim_competitor = pd.DataFrame(competitors_data, columns=['competitor_id', 'competitor_name', 'competitor_product_name', 'therapeutic_area', 'price_multiplier'])
df_dim_competitor.to_csv(os.path.join(RAW_DATA_DIR, 'dim_competitor.csv'), index=False)

# 4. DIM_DATE
dates = pd.date_range(start='2024-01-01', end='2025-12-01', freq='MS')
date_records = [{'date': d.strftime('%Y-%m-%d'), 'month_num': d.month, 'month_name': d.strftime('%B'), 'quarter': f'Q{d.quarter}', 'year': d.year, 'year_month': d.strftime('%Y-%m')} for d in dates]
df_dim_date = pd.DataFrame(date_records)
df_dim_date.to_csv(os.path.join(RAW_DATA_DIR, 'dim_date.csv'), index=False)

# FACT TABLES
fact_sales_rows, fact_market_rows, fact_penetration_rows = [], [], []
region_populations = {1: 450000, 2: 400000, 3: 380000, 4: 350000, 5: 280000, 6: 500000, 7: 650000, 8: 550000, 9: 320000, 10: 220000}
ta_growth_rates = {'Cardiovascular': 0.04, 'Oncology': 0.14, 'Diabetes': 0.09, 'Respiratory': 0.03, 'Gastroenterology': 0.02, 'CNS': 0.08}
product_volume_mult = {101: 2.2, 102: 1.8, 103: 3.5, 104: 1.2, 201: 0.4, 202: 0.6, 203: 0.8, 204: 0.3, 301: 2.0, 302: 1.5, 303: 4.5, 304: 1.7, 401: 1.9, 402: 2.8, 403: 3.2, 404: 1.1, 501: 3.8, 502: 2.1, 503: 3.0, 504: 2.5, 601: 2.7, 602: 1.6, 603: 1.0, 604: 2.2, 605: 0.9}

for d_idx, d in enumerate(dates):
    year, month, m_idx = d.year, d.month, d_idx
    respiratory_season = 1.35 if month in [11, 12, 1, 2] else 0.88
    for p_idx, prod in df_dim_product.iterrows():
        p_id, ta, base_price = prod['product_id'], prod['therapeutic_area'], prod['base_price']
        vol_mult, ta_growth = product_volume_mult[p_id], ta_growth_rates[ta]
        if p_id in [201, 301, 104]:
            trend = 1.0 + (m_idx * 0.028)
        elif p_id in [501, 103, 403]:
            trend = 1.0 - (m_idx * 0.008)
        else:
            trend = 1.0 + (m_idx * ta_growth / 12.0)
        if ta == 'Respiratory':
            trend *= respiratory_season
        for r_idx, reg in df_dim_region.iterrows():
            r_id, pop = reg['region_id'], region_populations[reg['region_id']]
            r_factor = (r_id * 0.07) + 0.65
            base_units = max(10, int(vol_mult * r_factor * 1200 * trend * np.random.uniform(0.92, 1.08)))
            actual_price = round(base_price * np.random.uniform(0.97, 1.03), 2)
            comp_price_ratio = np.random.uniform(0.85, 0.98) if prod['product_type'] == 'Branded' else np.random.uniform(1.02, 1.15)
            comp_price = round(actual_price * comp_price_ratio, 2)
            novapharm_share = np.random.uniform(0.38, 0.52) if p_id in [201, 301] else (np.random.uniform(0.15, 0.25) if p_id in [501, 403] else np.random.uniform(0.18, 0.42))
            total_market_units = int(base_units / novapharm_share)
            competitor_units = total_market_units - base_units
            novapharm_revenue = round(base_units * actual_price, 2)
            competitor_revenue = round(competitor_units * comp_price, 2)
            total_market_revenue = round(novapharm_revenue + competitor_revenue, 2)
            prescriptions = int(base_units / np.random.uniform(1.5, 2.5))
            addressable_pop = int(pop * np.random.uniform(0.12, 0.22))
            patients_reached = min(int(prescriptions * np.random.uniform(0.8, 1.2)), int(addressable_pop * 0.85))
            
            fact_sales_rows.append({'date': d.strftime('%Y-%m-%d'), 'product_id': p_id, 'region_id': r_id, 'units_sold': base_units, 'selling_price': actual_price, 'revenue': novapharm_revenue, 'prescriptions': prescriptions})
            fact_market_rows.append({'date': d.strftime('%Y-%m-%d'), 'product_id': p_id, 'region_id': r_id, 'total_market_units': total_market_units, 'total_market_value': total_market_revenue, 'competitor_units': competitor_units, 'competitor_revenue': competitor_revenue})
            fact_penetration_rows.append({'date': d.strftime('%Y-%m-%d'), 'product_id': p_id, 'region_id': r_id, 'target_population': pop, 'addressable_population': addressable_pop, 'patients_reached': patients_reached})

pd.DataFrame(fact_sales_rows).to_csv(os.path.join(RAW_DATA_DIR, 'fact_sales.csv'), index=False)
pd.DataFrame(fact_market_rows).to_csv(os.path.join(RAW_DATA_DIR, 'fact_market.csv'), index=False)
pd.DataFrame(fact_penetration_rows).to_csv(os.path.join(RAW_DATA_DIR, 'fact_penetration.csv'), index=False)
print('Dataset generated successfully!')
