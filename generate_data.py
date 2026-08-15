import pandas as pd
import numpy as np
from faker import Faker
import random

fake = Faker()

# Number of records
NUM_SALES = 6000
NUM_DEALERS = 40

random.seed(42)
np.random.seed(42)

# BMW models
models = [
    "BMW 3 Series",
    "BMW 5 Series",
    "BMW 7 Series",
    "BMW X1",
    "BMW X3",
    "BMW X5",
    "BMW X7",
    "BMW i4",
    "BMW i5",
    "BMW i7"
]

# Cities
cities = [
    "Chennai",
    "Bangalore",
    "Hyderabad",
    "Mumbai",
    "Delhi",
    "Pune",
    "Kolkata",
    "Ahmedabad",
    "Jaipur",
    "Kochi"
]

# Other categories
colors = [
    "Black",
    "White",
    "Blue",
    "Grey",
    "Red",
    "Silver"
]

fuel_types = [
    "Petrol",
    "Diesel",
    "Electric",
    "Hybrid"
]

transmissions = [
    "Automatic",
    "Manual"
]

customer_segments = [
    "Individual",
    "Corporate",
    "Luxury"
]

sales_channels = [
    "Dealer",
    "Online",
    "Corporate"
]

# Price range for each model
model_prices = {
    "BMW 3 Series": (4500000, 6500000),
    "BMW 5 Series": (6500000, 8500000),
    "BMW 7 Series": (14000000, 19000000),
    "BMW X1": (5000000, 6500000),
    "BMW X3": (6500000, 8000000),
    "BMW X5": (9500000, 12000000),
    "BMW X7": (12000000, 16000000),
    "BMW i4": (7000000, 8500000),
    "BMW i5": (9000000, 11000000),
    "BMW i7": (14000000, 18000000)
}

# -------------------------
# Generate Sales Data
# -------------------------

sales_data = []

for i in range(1, NUM_SALES + 1):

    model = random.choice(models)
    city = random.choice(cities)

    min_price, max_price = model_prices[model]

    unit_price = random.randint(min_price, max_price)

    quantity = random.randint(1, 3)

    discount_percent = random.choice([
        0, 2, 5, 7, 10, 12
    ])

    revenue = unit_price * quantity

    discount_amount = revenue * discount_percent / 100

    net_sales = revenue - discount_amount

    sales_data.append({
        "Sale_ID": i,
        "Sale_Date": fake.date_between(
            start_date="-3y",
            end_date="today"
        ),
        "Customer_Name": fake.name(),
        "Model": model,
        "City": city,
        "Color": random.choice(colors),
        "Fuel_Type": random.choice(fuel_types),
        "Transmission": random.choice(transmissions),
        "Customer_Segment": random.choice(customer_segments),
        "Sales_Channel": random.choice(sales_channels),
        "Quantity": quantity,
        "Unit_Price": unit_price,
        "Discount_Percent": discount_percent,
        "Revenue": round(revenue, 2),
        "Discount_Amount": round(discount_amount, 2),
        "Net_Sales": round(net_sales, 2)
    })

sales_df = pd.DataFrame(sales_data)

# Save sales data
sales_df.to_csv("bmw_sales.csv", index=False)

# -------------------------
# Generate Dealer Data
# -------------------------

dealer_data = []

for i in range(1, NUM_DEALERS + 1):

    city = random.choice(cities)

    dealer_data.append({
        "Dealer_ID": i,
        "Dealer_Name": f"BMW {city} Motors",
        "City": city,
        "State": fake.state(),
        "Dealer_Manager": fake.name(),
        "Phone": fake.phone_number(),
        "Email": fake.email(),
        "Dealer_Rating": round(
            random.uniform(3.5, 5.0), 1
        ),
        "Years_Operating": random.randint(2, 25)
    })

dealers_df = pd.DataFrame(dealer_data)

# Save dealer data
dealers_df.to_csv("dealers.csv", index=False)

# Success message
print("BMW dataset generated successfully!")
print(f"Sales records: {len(sales_df)}")
print(f"Dealers: {len(dealers_df)}")