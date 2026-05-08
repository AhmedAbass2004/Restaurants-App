"""
app.py
------
Main entry point for the Flask application.
Run with:  python app.py
"""

from flask import Flask, jsonify
from flask_cors import CORS

from routes.auth        import auth_bp
from routes.restaurants import restaurants_bp
from routes.products    import products_bp

# ── App setup ─────────────────────────────────────────────────────────────────
app = Flask(__name__)

# Allow requests from any origin (needed for Flutter/mobile clients)
CORS(app)

# ── Register blueprints (route groups) ───────────────────────────────────────
app.register_blueprint(auth_bp)
app.register_blueprint(restaurants_bp)
app.register_blueprint(products_bp)


# ── Health check ─────────────────────────────────────────────────────────────
@app.route("/", methods=["GET"])
def health_check():
    return jsonify({"success": True, "message": "API is running 🚀"}), 200


# ── Global 404 handler ────────────────────────────────────────────────────────
@app.errorhandler(404)
def not_found(e):
    return jsonify({"success": False, "message": "Endpoint not found"}), 404


# ── Global 500 handler ────────────────────────────────────────────────────────
@app.errorhandler(500)
def server_error(e):
    return jsonify({"success": False, "message": "Internal server error"}), 500


# ── Run ───────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    # host="0.0.0.0" makes the server reachable from your physical phone on the
    # same Wi-Fi network. Use your machine's local IP in the Flutter base URL.
    app.run(host="0.0.0.0", port=5000, debug=True)
