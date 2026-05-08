"""
routes/auth.py
--------------
Endpoints:
    POST /signup  – register a new user
    POST /login   – authenticate an existing user
"""

from flask import Blueprint, request, jsonify
from utils.db import get_db
from utils.validators import is_valid_email, is_valid_password

auth_bp = Blueprint("auth", __name__)


# ── POST /signup ──────────────────────────────────────────────────────────────
@auth_bp.route("/signup", methods=["POST"])
def signup():
    data = request.get_json()

    if not data:
        return jsonify({"success": False, "message": "No data provided"}), 400

    # ── Required fields ───────────────────────────────────────────────────────
    name             = data.get("name", "").strip()
    email            = data.get("email", "").strip().lower()
    password         = data.get("password", "")

    # ── Optional fields ───────────────────────────────────────────────────────
    gender = data.get("gender")          # e.g. "male" | "female" | None
    level  = data.get("level")           # 1 | 2 | 3 | 4  | None

    # ── Validation: required fields ───────────────────────────────────────────
    if not name:
        return jsonify({"success": False, "message": "Name is required"}), 400

    if not email:
        return jsonify({"success": False, "message": "Email is required"}), 400

    if not is_valid_email(email):
        return jsonify({"success": False, "message": "Invalid email format"}), 400

    if not password:
        return jsonify({"success": False, "message": "Password is required"}), 400

    if not is_valid_password(password):
        return jsonify({"success": False,
                        "message": "Password must be at least 8 characters"}), 400


    # ── Validation: optional level field ──────────────────────────────────────
    if level is not None and level not in [1, 2, 3, 4]:
        return jsonify({"success": False,
                        "message": "Level must be 1, 2, 3, or 4"}), 400

    # ── Check for duplicate email ─────────────────────────────────────────────
    conn = get_db()
    existing = conn.execute(
        "SELECT id FROM users WHERE email = ?", (email,)
    ).fetchone()

    if existing:
        conn.close()
        return jsonify({"success": False,
                        "message": "Email already registered"}), 409

    # ── Insert new user ───────────────────────────────────────────────────────
    # NOTE: For a real production app you would hash the password (e.g. bcrypt).
    #       For this college project we store it as plain text to stay simple.
    conn.execute(
        "INSERT INTO users (name, email, password, gender, level) VALUES (?,?,?,?,?)",
        (name, email, password, gender, level)
    )
    conn.commit()

    # Fetch the newly created user
    user = conn.execute(
        "SELECT id, name, email, gender, level FROM users WHERE email = ?",
        (email,)
    ).fetchone()
    conn.close()

    return jsonify({
        "success": True,
        "message": "Signup successful",
        "user": dict(user)
    }), 201


# ── POST /login ───────────────────────────────────────────────────────────────
@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    if not data:
        return jsonify({"success": False, "message": "No data provided"}), 400

    email    = data.get("email", "").strip().lower()
    password = data.get("password", "")

    if not email or not password:
        return jsonify({"success": False,
                        "message": "Email and password are required"}), 400

    conn = get_db()
    user = conn.execute(
        "SELECT id, name, email, gender, level, password FROM users WHERE email = ?",
        (email,)
    ).fetchone()
    conn.close()

    # Check user exists and password matches
    if not user or user["password"] != password:
        return jsonify({"success": False,
                        "message": "Invalid email or password"}), 401

    # Return user info (never return the password to the client)
    return jsonify({
        "success": True,
        "message": "Login successful",
        "user": {
            "id":     user["id"],
            "name":   user["name"],
            "email":  user["email"],
            "gender": user["gender"],
            "level":  user["level"]
        }
    }), 200
