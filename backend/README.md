# Enterprise Mobile App – Flask Backend

A clean, beginner-friendly REST API built with Flask + SQLite for the
Enterprise Mobile Application Development course project.

---

## 📁 Project Structure

```
backend/
├── app.py              ← Flask app entry point
├── init_db.py          ← Creates the SQLite database & tables
├── seed.py             ← Inserts sample restaurants & products
├── requirements.txt    ← Python dependencies
│
├── database/
│   └── app.db          ← SQLite database (auto-created)
│
├── routes/
│   ├── auth.py         ← POST /signup, POST /login
│   ├── restaurants.py  ← GET /restaurants, GET /restaurants/<id>/products
│   └── products.py     ← GET /products, GET /search?product=<name>
│
└── utils/
    ├── db.py           ← SQLite connection helper
    └── validators.py   ← Email & password validation helpers
```

---

## ⚙️ Setup & Run

### 1. Install Python dependencies
```bash
pip install -r requirements.txt
```

### 2. Initialise the database (run ONCE)
```bash
python init_db.py
```

### 3. Insert sample data (run ONCE)
```bash
python seed.py
```

### 4. Start the server
```bash
python app.py
```

The server runs on **http://0.0.0.0:5000**

> **Flutter tip:** Use your machine's local Wi-Fi IP (e.g. `http://192.168.1.x:5000`)
> as the base URL in your Flutter app so your phone can reach it on the same network.

---

## 📡 API Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET  | `/` | Health check |
| POST | `/signup` | Register a new user |
| POST | `/login` | Authenticate a user |
| GET  | `/restaurants` | List all restaurants/cafes |
| GET  | `/restaurants/<id>/products` | Products for one restaurant |
| GET  | `/products` | All products (for search dropdown) |
| GET  | `/search?product=<name>` | Restaurants that serve a product |

---

## 📝 Request & Response Examples

### POST /signup
**Request body:**
```json
{
  "name": "Ahmed",
  "email": "ahmed@example.com",
  "password": "mypassword",
  "confirm_password": "mypassword",
  "gender": "male",
  "level": 2
}
```
**Success response (201):**
```json
{
  "success": true,
  "message": "Signup successful",
  "user": { "id": 1, "name": "Ahmed", "email": "ahmed@example.com", "gender": "male", "level": 2 }
}
```
**Error response (400):**
```json
{ "success": false, "message": "Password must be at least 8 characters" }
```

---

### POST /login
**Request body:**
```json
{ "email": "ahmed@example.com", "password": "mypassword" }
```
**Success response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "user": { "id": 1, "name": "Ahmed", "email": "ahmed@example.com", "gender": "male", "level": 2 }
}
```

---

### GET /restaurants
```json
{
  "success": true,
  "count": 5,
  "restaurants": [
    { "id": 1, "name": "Koshary El Tahrir", "image": "...", "latitude": 30.0444, "longitude": 31.2357 }
  ]
}
```

---

### GET /restaurants/1/products
```json
{
  "success": true,
  "restaurant": { "id": 1, "name": "Koshary El Tahrir", ... },
  "count": 4,
  "products": [
    { "id": 1, "name": "Koshary Small", "price": 10.0, "image": "..." }
  ]
}
```

---

### GET /products
```json
{
  "success": true,
  "count": 20,
  "products": [
    { "id": 1, "name": "Cappuccino", "price": 35.0, "image": "...", "restaurant_id": 2, "restaurant_name": "Cafe Riche" }
  ]
}
```

---

### GET /search?product=cappuccino
```json
{
  "success": true,
  "query": "cappuccino",
  "count": 2,
  "restaurants": [
    {
      "id": 2,
      "name": "Cafe Riche",
      "image": "...",
      "latitude": 30.0459,
      "longitude": 31.2394,
      "product_name": "Cappuccino",
      "product_price": 35.0,
      "product_image": "..."
    }
  ]
}
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE users (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    name     TEXT    NOT NULL,
    email    TEXT    NOT NULL UNIQUE,
    password TEXT    NOT NULL,
    gender   TEXT,
    level    INTEGER
);

CREATE TABLE restaurants (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    name      TEXT    NOT NULL,
    image     TEXT,
    latitude  REAL    NOT NULL,
    longitude REAL    NOT NULL
);

CREATE TABLE products (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    restaurant_id INTEGER NOT NULL,
    name          TEXT    NOT NULL,
    price         REAL    NOT NULL,
    image         TEXT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);
```
