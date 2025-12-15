# Noon-UAE-Perfume-Data-Pipeline-
Web Scraping • Data Engineering • Analytics-Ready Dataset


---

## 📌 Project Overview

This project builds a scalable **end-to-end perfume data pipeline** from **Noon UAE**, one of the largest e-commerce platforms in the Middle East.

The first phase focuses on **high-quality data extraction from search result pages (PLP)**, transforming unstructured e-commerce listings into a **clean, structured, analytics-ready SQL Server dataset**.

The project is designed to evolve in phases:

1. Web scraping (Completed)
2. Data cleaning & normalization (completed)
3. Feature engineering (completed)
4. Exploratory analysis & distribution insights
5. Demand modeling & prediction

---

## 🎯 Objectives (Scrapping Phase)

- Scrape large-scale perfume listings from Noon UAE
- Avoid slow and costly product-page crawling
- Extract business-relevant features directly from listing pages
- Store data in SQL Server for analytics and BI
- Handle real-world inconsistencies in product titles and pricing

---

## 🌐 Data Source

- Platform: Noon UAE  
- Endpoint: `/search?q=perfume`  
- Pages scraped: configurable (tested up to 100 pages)  
- Strategy: Product Listing Page (PLP) scraping only  

---

## 🧱 Architecture (Scraping Phase)

Noon Search Pages
↓
Playwright (Chromium, anti-bot safe)
↓
Python Feature Extraction
↓
Batch Insert (SQL Server)
↓
Analytics-Ready Dataset

---

## ⚙️ Technology Stack

- Python
- Playwright (Chromium)
- SQL Server
- ODBC Driver 17
- Logging (Python logging module)

---

## 📦 Extracted Fields (Scrapping Phase)

| Column | Description |
|------|------------|
| title | Raw product title |
| brand | Brand inferred from title |
| perfume_type | Normalized perfume type |
| size_ml | Product size in milliliters |
| rating | Average rating |
| rating_count | Number of ratings |
| price_new | Current price |
| price_old | Old price (if discounted) |
| product_url | Product URL |
| category_rank | Category rank if shown |
| category_name | Category name if shown |
| selling_fast | Selling-fast indicator |
| page_no | Search page number |
| scraped_at | UTC timestamp |

---

## 🧠 Key Engineering Decisions

### 1) PLP-Only Scraping Strategy
- Faster than product-page crawling
- Scales to tens of thousands of products
- Lower blocking risk
- Still captures pricing, ratings, ranking, and demand signals

### 2) Robust Size Extraction

Handles real-world patterns such as:
- `30 Ml`
- `100ml`
- `100.0ml`
- `50.0 ml`
- `200 ML`

def extract_size_ml(title: str):
    matches = re.findall(
        r"(\\d{1,4}(?:\\.\\d+)?)\\s*[-]?\\s*(ml|m\\s*l)",
        title.lower()
    )
    return max(int(float(m[0])) for m in matches) if matches else None

### 3) Intelligent Perfume Type Detection

Supports:
Perfume Oil
Extrait de Parfum
Eau de Parfum (EDP)
Eau de Toilette (EDT)
Eau de Cologne (EDC)
Body Spray
Generic Perfume


if "perfume oil" in t:
    return "Perfume Oil"
elif "body spray" in t:
    return "Body Spray"
elif "eau de parfum" in t or "edp" in t:
    return "Eau de Parfum"

### 4) Batch Inserts for Performance

Inserts 50 rows per batch
Single commit per batch
Optimized using fast_executemany
Suitable for large-scale scraping (50k+ products)

### 5) Real-World Data Philosophy

Missing ratings = true absence, not errors
Missing category rank = not ranked
No artificial data filling
Dataset reflects actual marketplace conditions


🗄️ Database Schema ([Noon2].sql)

📊 Current Output >> 6584 Products from 100 pages

##Log

--------------------------------------------------------
2025-12-15 02:55:44,598 - INFO - Scraping page 91
2025-12-15 02:55:50,932 - INFO - Scraping page 92
2025-12-15 02:56:00,152 - INFO - Scraping page 93
2025-12-15 02:56:08,216 - INFO - Scraping page 94
2025-12-15 02:56:16,648 - INFO - Scraping page 95
2025-12-15 02:56:25,658 - INFO - Scraping page 96
2025-12-15 02:56:35,065 - INFO - Scraping page 97
2025-12-15 02:56:43,506 - INFO - Scraping page 98
2025-12-15 02:56:52,995 - INFO - Scraping page 99
2025-12-15 02:57:00,688 - INFO - Scraping page 100
---------------------------------------------------------


## Phase 2: Data Cleaning & Normalization

After completing the scraping phase, the raw dataset contained typical real-world marketplace issues such as inconsistent brand names, missing attributes, and heterogeneous product formats.  
This phase focuses on **standardizing, enriching, and stabilizing the dataset** to make it suitable for analytics and BI consumption.

---

### 1. Brand Normalization (brand_alias & dim_brand)

#### Problem  
Brand names appear in multiple variants across listings, for example:
- `SWISS ARABIAN`
- `Swiss Arabian Perfumes`
- `LATTAFA`
- `LATTAFA PERFUMES`

Such inconsistencies break aggregation, ranking, and trend analysis.

#### Solution  
A **brand alias mapping table** is used to standardize all brand variations into a single canonical name.

CREATE TABLE dbo.brand_alias (
    brand_raw NVARCHAR(200) PRIMARY KEY,
    brand_clean NVARCHAR(200) NOT NULL
);

INSERT INTO dbo.brand_alias (alias, brand_cleaned)
VALUES
('GIORGIO ARMANI%', 'GIORGIO ARMANI'),
('ISSEY MIYAKE%', 'ISSEY MIYAKE'),
('CLINIQUE%', 'CLINIQUE'),
('HUGO BOSS%', 'HUGO BOSS'),
('YVES SAINT LAURENT%', 'YVES SAINT LAURENT'),
('CALVIN KLEIN%', 'CALVIN KLEIN'),
('VERSACE%', 'VERSACE');


run mapping >>> add new column brand_cleaned

UPDATE n
SET brand_cleaned = b.brand_cleaned
FROM Perfume.dbo.Noon2 n
JOIN dbo.brand_alias b
  ON UPPER(n.brand) LIKE b.alias
WHERE n.brand_cleaned IS NULL;


### 2) Missing Perfume Type Resolution

## Problem
Many listings do not explicitly expose perfume type as a structured field.
Types such as Perfume Oil, Body Spray, or generic Perfume are embedded in the product title.

## Solution
Rule-based text classification is applied on the product title to infer perfume type.

Supported categories include:
Perfume Oil
Extrait de Parfum
Eau de Parfum (EDP)
Eau de Toilette (EDT)
Eau de Cologne (EDC)
Body Spray

### 3) Missing Old Price Handling
## Problem

Old price is only available when a discount exists.
For many products, this value is naturally absent.

## Solution

Old price is treated as nullable by design.
Absence of old price correctly represents a non-discounted product,
so , old = new when old is null then disc will be 0

## 4) Missing Rating & Rating Count Handling
## Problem
Some products have:
No ratings (new listings)
Hidden ratings (ads or sponsored items)

## Solution

Ratings and rating counts are kept as NULL / zero where unavailable.
Missing ratings are not errors 

## 5) Missing Size (size_ml) Resolution
## Problem

I extracted size from title , some products have no size like (Gift sets,Atomizers ,Refillable bottles).

## solution
I added flag size_status

----------------------
count	size_status
389	    NOT_SPECIFIED
6195	EXTRACTED
--------------------


## Phase 3: Feature Engineering

With a cleaned and normalized dataset in place, the next phase focuses on **deriving analytical features** that convert raw e-commerce data into **business-relevant signals**.

This phase introduces **demand modeling, product hierarchy, and price efficiency metrics**, which are essential for ranking, comparison, and insight generation.

---

### 1.Price Engineering
price_new & price_old

Discount Features:
has_discount (0 / 1)
discount_amount
discount_pct

Discounts are treated as signals, not guarantees of demand.

### 2.Unit Price Normalization (price_per_ml)
    price_per_ml = price_new / size_ml
Used for value benchmarking,Not used directly for demand modeling,Only calculated when size is valid.

### 3.Demand Score Engineering (demand_score)
composite metric representing observed demand signals, not sales.
Components:

--------------------
Signal            	Reason
Rating              quality	Customer satisfaction
Rating volume	    Social proof strength
Discount presence	Promotional push

--------------------
demand_score =
    (rating_quality * 0.5) A product with bad reviews kills demand long-term.
  + (rating_volume * 0.3)  4.8 rating with 3 reviews ≠ 4.8 with 1,200 reviews , Volume stabilizes trust
  + (discount_signal * 0.2) Short-term demand stimulation , once discount ends → demand may fall

Quality > quantity
Discount matters but doesn’t dominate
Score stays 0 → 1 range

### find SQL queries used in both cleaning and feature engineering (Noon-Brand-cleaning.sql-Noon-Brand-cleaning.sql-Noon-Add-Features.sql)

### SQL View (v_noon_analytics.sql) for analysis and visualization















