"""
routes/products.py
------------------
Endpoints:
    GET /products
    GET /search?product=name
"""

from flask import Blueprint, request, jsonify
from utils.db import get_db

products_bp = Blueprint("products", __name__)


@products_bp.route("/products", methods=["GET"])
def get_all_products():
    """
    Returns product rows with restaurant linkage for Flutter dropdown usage.
    """
    conn = get_db()
    rows = conn.execute(
        """
        SELECT p.id, p.name, p.price, p.image, rp.restaurant_id,
               r.name AS restaurant_name
        FROM   restaurant_products rp
        JOIN   products p ON p.id = rp.product_id
        JOIN   restaurants r ON r.id = rp.restaurant_id
        ORDER  BY p.name
        """
    ).fetchall()
    conn.close()

    return jsonify({
        "success": True,
        "count": len(rows),
        "products": [dict(r) for r in rows]
    }), 200


@products_bp.route("/search", methods=["GET"])
def search_by_product():
    """
    Search for restaurants/cafes that serve a particular product.
    Matched case-insensitively by product name.
    """
    product_name = request.args.get("product", "").strip()

    if not product_name:
        return jsonify({
            "success": False,
            "message": "Query parameter 'product' is required"
        }), 400

    conn = get_db()
    rows = conn.execute(
        """
        SELECT DISTINCT
               r.id,
               r.name,
               r.image,
               r.latitude,
               r.longitude,
               p.name  AS product_name,
               p.price AS product_price,
               p.image AS product_image
        FROM   products p
        JOIN   restaurant_products rp ON rp.product_id = p.id
        JOIN   restaurants r ON r.id = rp.restaurant_id
        WHERE  LOWER(p.name) LIKE LOWER(?)
        """,
        (f"%{product_name}%",),
    ).fetchall()
    conn.close()

    results = [dict(row) for row in rows]

    return jsonify({
        "success": True,
        "query": product_name,
        "count": len(results),
        "restaurants": results
    }), 200
