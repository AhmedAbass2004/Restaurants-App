"""
init_db.py
----------
Run this script ONCE to create the SQLite database and all tables.
Usage: python init_db.py
"""

import sqlite3
import os

# Path to the SQLite database file
DB_PATH = os.path.join(os.path.dirname(__file__), "database", "app.db")


def init_db():
    # Make sure the database folder exists
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # users table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            name     TEXT    NOT NULL,
            email    TEXT    NOT NULL UNIQUE,
            password TEXT    NOT NULL,
            gender   TEXT,
            level    INTEGER
        )
    """)

    # restaurants table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS restaurants (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            name      TEXT    NOT NULL,
            image     TEXT,
            latitude  REAL    NOT NULL,
            longitude REAL    NOT NULL
        )
    """)

    # products table (shared product catalog)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id    INTEGER PRIMARY KEY AUTOINCREMENT,
            name  TEXT    NOT NULL,
            price REAL    NOT NULL,
            image TEXT
        )
    """)

    # restaurant_products table (many-to-many)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS restaurant_products (
            restaurant_id INTEGER NOT NULL,
            product_id    INTEGER NOT NULL,
            PRIMARY KEY (restaurant_id, product_id),
            FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
            FOREIGN KEY (product_id) REFERENCES products(id)
        )
    """)

    conn.commit()
    conn.close()
    print("Database initialised successfully at:", DB_PATH)


if __name__ == "__main__":
    init_db()
