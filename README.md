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

```python
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


```python

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





