import pandas as pd
import psycopg2

# ============================================
# 1. PostgreSQL DATABASE DETAILS
# ============================================

DB_NAME = "bmw_analytics"
DB_USER = "postgres"
DB_PASSWORD = "postgres"
DB_HOST = "localhost"
DB_PORT = "5432"

# ============================================
# 2. CONNECT TO POSTGRESQL
# ============================================

print("Connecting to PostgreSQL...")

conn = psycopg2.connect(
    database=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=DB_PORT
)

print("PostgreSQL connection successful!")

# ============================================
# 3. LOAD SALES DATA
# ============================================

query = """
SELECT
    s.Sale_ID,
    s.Sale_Date,
    c.Customer_Name,
    c.Customer_Segment,
    m.Model,
    s.City,
    s.Color,
    s.Fuel_Type,
    s.Transmission,
    s.Sales_Channel,
    s.Quantity,
    s.Unit_Price,
    s.Discount_Percent,
    s.Revenue,
    s.Discount_Amount,
    s.Net_Sales
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
JOIN models m
    ON s.Model_ID = m.Model_ID;
"""

df = pd.read_sql(query, conn)

# ============================================
# DATA CLEANING
# ============================================

print("\nStarting data cleaning...")

# Convert Sale_Date to datetime
df["sale_date"] = pd.to_datetime(df["sale_date"])

print("\nSale date converted successfully.")
print(df["sale_date"].dtype)

numeric_columns = [
    "quantity",
    "unit_price",
    "discount_percent",
    "revenue",
    "discount_amount",
    "net_sales"
]

print("\nNumeric column summary:")
print(df[numeric_columns].describe())

print("\nChecking negative values...")

for column in numeric_columns:
    negative_count = (df[column] < 0).sum()
    print(f"{column}: {negative_count}")

print("\nChecking discount percentage...")

invalid_discount = df[
    (df["discount_percent"] < 0) |
    (df["discount_percent"] > 100)
]

print("Invalid discount records:", len(invalid_discount))

df["calculated_revenue"] = (
    df["quantity"] * df["unit_price"]
)

df["revenue_difference"] = (
    df["revenue"] - df["calculated_revenue"]
).abs()

print("\nRevenue validation:")

print(
    "Incorrect revenue records:",
    (df["revenue_difference"] > 0.01).sum()
)

df["calculated_net_sales"] = (
    df["revenue"] - df["discount_amount"]
)

df["net_sales_difference"] = (
    df["net_sales"] - df["calculated_net_sales"]
).abs()

print(
    "Incorrect net sales records:",
    (df["net_sales_difference"] > 0.01).sum()
)

# Fuel Type
print("\nFuel Types:")
print(df["fuel_type"].value_counts())

# Transmission
print("\nTransmission:")
print(df["transmission"].value_counts())

# Customer Segment
print("\nCustomer Segments:")
print(df["customer_segment"].value_counts())

# Sales Channel
print("\nSales Channels:")
print(df["sales_channel"].value_counts())

# Final Data Cleaning Check
print("\nFinal dataset information:")
print(df.info())

print("\nFinal shape:")
print(df.shape)

# Remove Temporary Columns
df.drop(
    columns=[
        "calculated_revenue",
        "revenue_difference",
        "calculated_net_sales",
        "net_sales_difference"
    ],
    inplace=True
)

print("\nClean dataset shape:")
print(df.shape)

# Save Clean Dataset
df.to_csv(
    "bmw_sales_cleaned.csv",
    index=False
)

print("\nClean dataset saved as bmw_sales_cleaned.csv")


# ============================================
# 4. CHECK DATA
# ============================================

print("\nData loaded successfully!")

print("--------------------------------")
print("Rows:", len(df))
print("Columns:", len(df.columns))
print("--------------------------------")

print("\nFirst 5 rows:")
print(df.head())

print("\nColumn names:")
print(df.columns.tolist())

print("\nData types:")
print(df.dtypes)

# ============================================
# 5. CLOSE CONNECTION
# ============================================
print("\nMissing values:")
print(df.isnull().sum())

print("\nDuplicate rows:", df.duplicated().sum())
conn.close()

print("\nPostgreSQL connection closed.")
print("Done!")