# Enterprise Mobile Development Project - Restaurants App

This repository contains a course project for **Enterprise Mobile Application Development** using:
- **Flutter** (mobile client)
- **RxDart** (state streams in controllers)
- **Flask + SQLite** (REST API backend)

The project brief is defined in `Enterprise Mobile Development Project.pdf`.

## Repository Structure

```text
Restaurants App/
├── Enterprise Mobile Development Project.pdf
├── backend/
│   ├── app.py
│   ├── init_db.py
│   ├── seed.py
│   ├── requirements.txt
│   ├── routes/
│   │   ├── auth.py
│   │   ├── restaurants.py
│   │   └── products.py
│   ├── utils/
│   │   ├── db.py
│   │   └── validators.py
│   └── database/
│       └── app.db
└── restaurants_app/
    ├── lib/
    │   ├── controllers/
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   ├── utils/
    │   └── widgets/
    └── pubspec.yaml
```

## Technical Details

## Backend (Flask)

- Entry point: `backend/app.py`
- API style: JSON REST endpoints
- CORS: enabled for cross-origin mobile/web requests
- Database: SQLite (`backend/database/app.db`)
- Data model:
  - `users`
  - `restaurants`
  - `products`
  - `restaurant_products` (many-to-many between restaurants and products)

### Implemented Endpoints

- `GET /` health check
- `POST /signup` user registration with validation
- `POST /login` authentication
- `GET /restaurants` list all restaurants/cafes
- `GET /restaurants/<id>/products` list products for one restaurant/cafe
- `GET /products` list all products (for search selection)
- `GET /search?product=<name>` find restaurants/cafes serving selected product

## Mobile App (Flutter + RxDart)

- Entry point: `restaurants_app/lib/main.dart`
- Architecture:
  - `screens/` UI pages
  - `controllers/` RxDart state management and business logic
  - `services/` API communication + local session storage
  - `models/` DTO/domain objects
  - `utils/` constants and validators

### Current Screens

- `SplashScreen`: checks saved login session and routes to login/restaurants
- `LoginScreen`: form validation + login API integration
- `SignupScreen`: full registration form with required/optional rules
- `RestaurantsScreen`: currently placeholder only (`Text('Restaurants list placeholder')`)

### Key Client Services

- `ApiService`: wraps all backend HTTP calls
- `AuthLocalStorageService`: stores login state in `shared_preferences`
- `AuthController`, `RestaurantController`, `SearchController`: Rx streams for loading, errors, and data

## Setup and Run

## 1. Backend

```bash
cd backend
pip install -r requirements.txt
python init_db.py
python seed.py
python app.py
```

Backend runs on `http://0.0.0.0:5000`.

## 2. Flutter app

```bash
cd restaurants_app
flutter pub get
flutter run
```

Note:
- `ApiConstants.baseUrl` is currently `http://10.0.2.2:5000` (Android emulator loopback to host machine).
- For physical devices, update base URL to your machine LAN IP.

## PDF Requirements Status (Done vs Not Yet)

Source: `Enterprise Mobile Development Project.pdf` (single-page brief)

1. Create Signup screen  
Status: **Done**
- 1.1 Name mandatory: Done
- 1.2 Gender radio optional: Done
- 1.3 Email format + mandatory: Done
- 1.4 Level options {1,2,3,4} optional: Done
- 1.5 Password >= 8 mandatory: Done
- 1.6 Confirm password matching + mandatory: Done (client-side)

2. Signup fails if validation conditions fail  
Status: **Done**
- Enforced in Flutter form and backend `/signup` validation logic.

3. Create login screen  
Status: **Done**
- UI and API integration are implemented.

4. Create screen for list of all restaurants/cafes  
Status: **Not Yet**
- Backend endpoint exists, but Flutter screen is still placeholder.

5. Create screen for list of products in each restaurant/cafe  
Status: **Not Yet**
- Backend endpoint exists, but no implemented products-list UI.

6. Create search-by-product screen  
Status: **Partially Done**
- 6.1 Select product from list: Not yet in UI (data/API ready)
- 6.2 Show results list of restaurants/cafes: Not yet in UI (API ready)
- 6.3 Toggle results to map view: Not yet

7. Select search result and show distance + directions from current location  
Status: **Not Yet**
- No geolocation, distance calculation, maps, or directions flow implemented yet.

## Implementation Notes and Gaps

- Backend schema in code uses normalized many-to-many relation (`restaurant_products`), which differs from earlier backend README examples.
- Passwords are stored as plain text in current backend implementation; acceptable for course prototype, not for production.
- No automated tests beyond default Flutter template test.
- No stateful restaurant/product/search screens wired to controllers yet.

## Suggested Next Development Steps

1. Build `RestaurantsScreen` with `RestaurantController.loadRestaurants()`.
2. Add restaurant details/products screen using `loadProductsForRestaurant`.
3. Build search screen with product dropdown + results list (use `SearchController`).
4. Add map view (`google_maps_flutter`) for search results.
5. Add current location + route/directions integration.
