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
# 2. READ CSV FILES
# ============================================

print("Reading CSV files...")

sales_df = pd.read_csv("bmw_sales.csv")
dealers_df = pd.read_csv("dealers.csv")

print(f"Sales records found: {len(sales_df)}")
print(f"Dealer records found: {len(dealers_df)}")


# ============================================
# 3. CONNECT TO POSTGRESQL
# ============================================

print("\nConnecting to PostgreSQL...")

conn = psycopg2.connect(
    database=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=DB_PORT
)

cursor = conn.cursor()

print("PostgreSQL connection successful!")


# ============================================
# 4. INSERT DEALERS
# ============================================

print("\nLoading dealers...")

for _, row in dealers_df.iterrows():

    cursor.execute(
        """
        INSERT INTO dealers
        (
            Dealer_ID,
            Dealer_Name,
            City,
            State,
            Dealer_Manager,
            Phone,
            Email,
            Dealer_Rating,
            Years_Operating
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (Dealer_ID) DO NOTHING;
        """,
        (
            int(row["Dealer_ID"]),
            row["Dealer_Name"],
            row["City"],
            row["State"],
            row["Dealer_Manager"],
            str(row["Phone"]),
            row["Email"],
            float(row["Dealer_Rating"]),
            int(row["Years_Operating"])
        )
    )

conn.commit()

print(f"{len(dealers_df)} dealers loaded.")


# ============================================
# 5. CREATE MODEL IDs
# ============================================

print("\nCreating models...")

models = sales_df["Model"].dropna().unique()

for model in models:

    cursor.execute(
        """
        INSERT INTO models (Model)
        VALUES (%s)
        ON CONFLICT (Model) DO NOTHING;
        """,
        (model,)
    )

conn.commit()


# ============================================
# 6. CREATE CUSTOMER IDs
# ============================================

print("Creating customers...")

customers = (
    sales_df[["Customer_Name", "Customer_Segment"]]
    .drop_duplicates()
    .reset_index(drop=True)
)

for _, row in customers.iterrows():

    cursor.execute(
        """
        INSERT INTO customers
        (
            Customer_Name,
            Customer_Segment
        )
        VALUES (%s, %s);
        """,
        (
            row["Customer_Name"],
            row["Customer_Segment"]
        )
    )

conn.commit()

print(f"{len(customers)} customers loaded.")


# ============================================
# 7. CREATE MODEL LOOKUP
# ============================================

cursor.execute(
    "SELECT Model_ID, Model FROM models;"
)

model_rows = cursor.fetchall()

model_map = {
    model: model_id
    for model_id, model in model_rows
}


# ============================================
# 8. CREATE CUSTOMER LOOKUP
# ============================================

cursor.execute(
    "SELECT Customer_ID, Customer_Name, Customer_Segment FROM customers;"
)

customer_rows = cursor.fetchall()

customer_map = {
    (name, segment): customer_id
    for customer_id, name, segment in customer_rows
}


# ============================================
# 9. CREATE DEALER LOOKUP
# ============================================

cursor.execute(
    "SELECT Dealer_ID, City FROM dealers;"
)

dealer_rows = cursor.fetchall()

dealer_map = {}

for dealer_id, city in dealer_rows:
    dealer_map[city] = dealer_id


# ============================================
# 10. INSERT SALES
# ============================================

print("\nLoading sales records...")

loaded_sales = 0

for _, row in sales_df.iterrows():

    # Get Model_ID
    model_id = model_map[row["Model"]]

    # Get Customer_ID
    customer_id = customer_map[
        (
            row["Customer_Name"],
            row["Customer_Segment"]
        )
    ]

    # Get Dealer_ID using City
    dealer_id = dealer_map.get(row["City"])

    if dealer_id is None:
        print(
            f"Warning: No dealer found for city: {row['City']}"
        )
        continue

    cursor.execute(
        """
        INSERT INTO sales
        (
            Sale_ID,
            Sale_Date,
            Customer_ID,
            Model_ID,
            Dealer_ID,
            City,
            Color,
            Fuel_Type,
            Transmission,
            Sales_Channel,
            Quantity,
            Unit_Price,
            Discount_Percent,
            Revenue,
            Discount_Amount,
            Net_Sales
        )
        VALUES
        (
            %s, %s, %s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s, %s, %s, %s
        )
        ON CONFLICT (Sale_ID) DO NOTHING;
        """,
        (
            int(row["Sale_ID"]),
            row["Sale_Date"],
            customer_id,
            model_id,
            dealer_id,
            row["City"],
            row["Color"],
            row["Fuel_Type"],
            row["Transmission"],
            row["Sales_Channel"],
            int(row["Quantity"]),
            float(row["Unit_Price"]),
            float(row["Discount_Percent"]),
            float(row["Revenue"]),
            float(row["Discount_Amount"]),
            float(row["Net_Sales"])
        )
    )

    loaded_sales += 1


conn.commit()

print(f"{loaded_sales} sales records loaded.")


# ============================================
# 11. VERIFY DATA
# ============================================

print("\nChecking database...")

cursor.execute("SELECT COUNT(*) FROM dealers;")
dealer_count = cursor.fetchone()[0]

cursor.execute("SELECT COUNT(*) FROM models;")
model_count = cursor.fetchone()[0]

cursor.execute("SELECT COUNT(*) FROM customers;")
customer_count = cursor.fetchone()[0]

cursor.execute("SELECT COUNT(*) FROM sales;")
sales_count = cursor.fetchone()[0]


print("--------------------------------")
print("DATABASE LOAD COMPLETE")
print("--------------------------------")
print(f"Dealers   : {dealer_count}")
print(f"Models    : {model_count}")
print(f"Customers : {customer_count}")
print(f"Sales     : {sales_count}")
print("--------------------------------")


# ============================================
# 12. CLOSE CONNECTION
# ============================================

cursor.close()
conn.close()

print("\nPostgreSQL connection closed.")
print("Done!")