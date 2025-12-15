import os
import pyodbc
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# ---------------------------------
# Config
# ---------------------------------
REPORT_DIR = "reports_noon"
os.makedirs(REPORT_DIR, exist_ok=True)

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=joba;"
    "DATABASE=Perfume;"
    "UID=sa;"
    "PWD=P@$$w0rd"
)

df = pd.read_sql("SELECT * FROM dbo.v_noon_analytics", conn)
conn.close()

print("Rows:", len(df))

# ---------------------------------
# 0) Data Quality Snapshot
# ---------------------------------
def missing_pct(col):
    return round(df[col].isna().mean() * 100, 2)

dq = pd.DataFrame({
    "missing_%": {
        "perfume_type": missing_pct("perfume_type"),
        "rating": missing_pct("rating"),
        "rating_count": missing_pct("rating_count"),
        "price_new": missing_pct("price_new"),
        "price_old": missing_pct("price_old"),
        "size_ml": missing_pct("size_ml"),
        "price_per_ml": missing_pct("price_per_ml"),
        "brand_cleaned": missing_pct("brand_cleaned"),
        "demand_score": missing_pct("demand_score")
    }
}).sort_values("missing_%", ascending=False)

print("\nData Quality (missing %):\n", dq)
dq.to_csv(os.path.join(REPORT_DIR, "data_quality_missing_pct.csv"))

# Ensure types (avoid weird object columns)
df["has_discount"] = pd.to_numeric(df["has_discount"], errors="coerce").fillna(0).astype(int)
df["rating_count"] = pd.to_numeric(df["rating_count"], errors="coerce").fillna(0).astype(int)

# ---------------------------------
# 1) Top 10 Brands by Demand (with min sample filter)
# ---------------------------------
brand_stats = (
    df.groupby("brand_cleaned")
      .agg(products=("title", "count"),
           avg_demand=("demand_score", "mean"),
           avg_price=("price_new", "mean"),
           avg_discount=("discount_pct", "mean"))
)

top_brands = (
    brand_stats[brand_stats["products"] >= 10]
    .sort_values("avg_demand", ascending=False)
    .head(10)
)

plt.figure()
plt.bar(top_brands.index.astype(str), top_brands["avg_demand"])
plt.title("Top 10 Brands by Avg Demand (min 10 products)")
plt.xlabel("Brand")
plt.ylabel("Avg Demand Score")
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.savefig(os.path.join(REPORT_DIR, "top_brands_by_demand.png"), dpi=150)
plt.show()

top_brands.to_csv(os.path.join(REPORT_DIR, "top_brands_by_demand.csv"))

# ---------------------------------
# 2) Discount Impact on Demand (boxplot is better than mean only)
# ---------------------------------
no_disc = df[df["has_discount"] == 0]["demand_score"].dropna()
yes_disc = df[df["has_discount"] == 1]["demand_score"].dropna()

plt.figure()
plt.boxplot([no_disc, yes_disc], labels=["No Discount", "Discount"])
plt.title("Demand Score by Discount (Boxplot)")
plt.ylabel("Demand Score")
plt.tight_layout()
plt.savefig(os.path.join(REPORT_DIR, "demand_by_discount_boxplot.png"), dpi=150)
plt.show()

# ---------------------------------
# 3) Price per ML Distribution (normal + log-scale view)
# ---------------------------------
valid_ppml = df["price_per_ml"].dropna()

plt.figure()
plt.hist(valid_ppml, bins=40)
plt.title("Price per ML Distribution (Raw)")
plt.xlabel("Price per ML")
plt.ylabel("Number of Products")
plt.tight_layout()
plt.savefig(os.path.join(REPORT_DIR, "ppml_distribution_raw.png"), dpi=150)
plt.show()

# log10 transform (handles long-tail)
valid_ppml_log = np.log10(valid_ppml[valid_ppml > 0])

plt.figure()
plt.hist(valid_ppml_log, bins=40)
plt.title("Price per ML Distribution (log10)")
plt.xlabel("log10(Price per ML)")
plt.ylabel("Number of Products")
plt.tight_layout()
plt.savefig(os.path.join(REPORT_DIR, "ppml_distribution_log10.png"), dpi=150)
plt.show()

# ---------------------------------
# 4) Demand Score Distribution
# ---------------------------------
valid_demand = df["demand_score"].dropna()

plt.figure()
plt.hist(valid_demand, bins=30)
plt.title("Demand Score Distribution")
plt.xlabel("Demand Score")
plt.ylabel("Number of Products")
plt.tight_layout()
plt.savefig(os.path.join(REPORT_DIR, "demand_distribution.png"), dpi=150)
plt.show()

# ---------------------------------
# 5) Value Map (MOST IMPORTANT): price_per_ml vs demand_score
# ---------------------------------
value_df = df[df["price_per_ml"].notna() & df["demand_score"].notna()]

plt.figure()
plt.scatter(value_df["price_per_ml"], value_df["demand_score"], s=10)
plt.title("Value Map: Price per ML vs Demand Score")
plt.xlabel("Price per ML")
plt.ylabel("Demand Score")
plt.tight_layout()
plt.savefig(os.path.join(REPORT_DIR, "value_map_ppml_vs_demand.png"), dpi=150)
plt.show()

# ---------------------------------
# 6) Simple Opportunity Flags (overpriced + low demand)
# ---------------------------------
ppml_median = value_df["price_per_ml"].median()
demand_median = value_df["demand_score"].median()

flags = value_df[
    (value_df["price_per_ml"] > ppml_median * 2) &
    (value_df["demand_score"] < demand_median)
][["title", "brand_cleaned", "price_new", "price_per_ml", "demand_score", "has_discount", "discount_pct", "product_url"]]

print("\nOverpriced + Low Demand (sample):")
print(flags.head(20))

flags.to_csv(os.path.join(REPORT_DIR, "overpriced_low_demand_flags.csv"), index=False)

print(f"\nSaved outputs to: {REPORT_DIR}")
