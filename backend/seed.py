"""
seed.py
-------
Populates the database with sample restaurants and products.
Run AFTER init_db.py:

    python init_db.py
    python seed.py

Safe to re-run - clears existing data first.
"""

import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "database", "app.db")

RESTAURANTS = [
    {
        "name": "Koshary El Tahrir",
        "image": "https://example.com/images/koshary_tahrir.jpg",
        "latitude": 30.0444,
        "longitude": 31.2357,
    },
    {
        "name": "Cafe Riche",
        "image": "https://example.com/images/cafe_riche.jpg",
        "latitude": 30.0459,
        "longitude": 31.2394,
    },
    {
        "name": "Pizza Hut Cairo",
        "image": "https://example.com/images/pizza_hut.jpg",
        "latitude": 30.0580,
        "longitude": 31.2290,
    },
    {
        "name": "Burger King Mohandeseen",
        "image": "https://example.com/images/burger_king.jpg",
        "latitude": 30.0590,
        "longitude": 31.1990,
    },
    {
        "name": "El Abd Pastry",
        "image": "https://example.com/images/el_abd.jpg",
        "latitude": 30.0480,
        "longitude": 31.2340,
    },
]

# Key = restaurant name, value = list of (name, price, image)
PRODUCTS = {
    "Koshary El Tahrir": [
        ("Koshary Small", 10.0, "https://example.com/images/koshary_s.jpg"),
        ("Koshary Large", 20.0, "https://example.com/images/koshary_l.jpg"),
        ("Lentil Soup", 15.0, "https://example.com/images/lentil.jpg"),
        ("Soft Drink", 8.0, "https://example.com/images/soda.jpg"),
    ],
    "Cafe Riche": [
        ("Espresso", 25.0, "https://example.com/images/espresso.jpg"),
        ("Cappuccino", 35.0, "https://example.com/images/cappuccino.jpg"),
        ("Cheese Sandwich", 40.0, "https://example.com/images/cheese_sand.jpg"),
        ("Soft Drink", 8.0, "https://example.com/images/soda.jpg"),
    ],
    "Pizza Hut Cairo": [
        ("Pizza Margherita", 120.0, "https://example.com/images/margherita.jpg"),
        ("Pizza Pepperoni", 140.0, "https://example.com/images/pepperoni.jpg"),
        ("Pasta Alfredo", 80.0, "https://example.com/images/alfredo.jpg"),
        ("Soft Drink", 8.0, "https://example.com/images/soda.jpg"),
    ],
    "Burger King Mohandeseen": [
        ("Whopper", 85.0, "https://example.com/images/whopper.jpg"),
        ("Chicken Sandwich", 75.0, "https://example.com/images/chicken_sand.jpg"),
        ("French Fries", 30.0, "https://example.com/images/fries.jpg"),
        ("Soft Drink", 8.0, "https://example.com/images/soda.jpg"),
    ],
    "El Abd Pastry": [
        ("Basbousa", 15.0, "https://example.com/images/basbousa.jpg"),
        ("Konafa", 25.0, "https://example.com/images/konafa.jpg"),
        ("Cheese Sandwich", 35.0, "https://example.com/images/cheese_sand.jpg"),
        ("Cappuccino", 30.0, "https://example.com/images/cappuccino.jpg"),
    ],
}


def seed():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Clear existing data (junction first due to FK)
    cursor.execute("DELETE FROM restaurant_products")
    cursor.execute("DELETE FROM products")
    cursor.execute("DELETE FROM restaurants")

    # Reset auto-increment counters
    cursor.execute("DELETE FROM sqlite_sequence WHERE name='products'")
    cursor.execute("DELETE FROM sqlite_sequence WHERE name='restaurants'")

    # Insert restaurants
    for r in RESTAURANTS:
        cursor.execute(
            "INSERT INTO restaurants (name, image, latitude, longitude) VALUES (?,?,?,?)",
            (r["name"], r["image"], r["latitude"], r["longitude"]),
        )

    conn.commit()

    # Build a deduplicated product catalog by full tuple (name, price, image)
    product_map = {}
    for items in PRODUCTS.values():
        for product in items:
            if product not in product_map:
                cursor.execute(
                    "INSERT INTO products (name, price, image) VALUES (?,?,?)",
                    product,
                )
                product_map[product] = cursor.lastrowid

    # Link each restaurant to its products in the junction table
    for restaurant_name, items in PRODUCTS.items():
        row = cursor.execute(
            "SELECT id FROM restaurants WHERE name = ?", (restaurant_name,)
        ).fetchone()

        if not row:
            print(f"Restaurant '{restaurant_name}' not found - skipping products.")
            continue

        restaurant_id = row[0]
        for product in items:
            product_id = product_map[product]
            cursor.execute(
                "INSERT INTO restaurant_products (restaurant_id, product_id) VALUES (?,?)",
                (restaurant_id, product_id),
            )

    conn.commit()
    conn.close()
    print("Seed data inserted successfully!")


if __name__ == "__main__":
    seed()
