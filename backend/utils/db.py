"""
utils/db.py
-----------
Central helper for obtaining a SQLite connection.
Every route imports get_db() from here – no hard-coded paths elsewhere.
"""

import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "..", "database", "app.db")


def get_db():
    """
    Open and return a SQLite connection.
    row_factory = sqlite3.Row lets us access columns by name (like a dict).
    """
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row  # access columns by name: row["email"]
    return conn
