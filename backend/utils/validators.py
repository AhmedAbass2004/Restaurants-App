"""
utils/validators.py
-------------------
Reusable validation functions shared across routes.
"""

import re


def is_valid_email(email: str) -> bool:
    """Return True when the email matches a basic RFC-style pattern."""
    pattern = r"^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$"
    return re.match(pattern, email) is not None


def is_valid_password(password: str) -> bool:
    """Password must be at least 8 characters."""
    return len(password) >= 8
