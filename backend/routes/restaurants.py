"""
routes/restaurants.py
---------------------
Endpoints:
    GET /restaurants
    GET /restaurants/<id>/products
"""

from flask import Blueprint, jsonify
from utils.db import get_db

restaurants_bp = Blueprint("restaurants", __name__)


@restaurants_bp.route("/restaurants", methods=["GET"])
def get_restaurants():
    conn = get_db()
    rows = conn.execute(
        "SELECT id, name, image, latitude, longitude FROM restaurants"
    ).fetchall()
    conn.close()

    restaurants = [dict(row) for row in rows]
    return jsonify({
        "success": True,
        "count": len(restaurants),
        "restaurants": restaurants
    }), 200


@restaurants_bp.route("/restaurants/<int:restaurant_id>/products", methods=["GET"])
def get_restaurant_products(restaurant_id):
    conn = get_db()

    restaurant = conn.execute(
        "SELECT id, name, image, latitude, longitude FROM restaurants WHERE id = ?",
        (restaurant_id,),
    ).fetchone()

    if not restaurant:
        conn.close()
        return jsonify({"success": False, "message": "Restaurant not found"}), 404

    products = conn.execute(
        """
        SELECT p.id, p.name, p.price, p.image
        FROM   restaurant_products rp
        JOIN   products p ON p.id = rp.product_id
        WHERE  rp.restaurant_id = ?
        ORDER  BY p.name
        """,
        (restaurant_id,),
    ).fetchall()
    conn.close()

    return jsonify({
        "success": True,
        "restaurant": dict(restaurant),
        "count": len(products),
        "products": [dict(p) for p in products],
    }), 200
