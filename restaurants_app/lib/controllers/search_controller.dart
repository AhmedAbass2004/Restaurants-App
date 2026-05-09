import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

import '../models/product.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class SearchController {
  SearchController({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  final BehaviorSubject<bool> _loadingSubject = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _errorSubject = BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<List<Product>> _productsSubject =
      BehaviorSubject<List<Product>>.seeded(const []);
  final BehaviorSubject<List<Restaurant>> _searchResultsSubject =
      BehaviorSubject<List<Restaurant>>.seeded(const []);
  final BehaviorSubject<Position?> _userLocationSubject =
      BehaviorSubject<Position?>.seeded(null);
  final BehaviorSubject<Restaurant?> _selectedRestaurantSubject =
      BehaviorSubject<Restaurant?>.seeded(null);
  final BehaviorSubject<Map<int, double>> _distancesSubject =
      BehaviorSubject<Map<int, double>>.seeded({});

  ValueStream<bool> get loadingStream => _loadingSubject.stream;
  ValueStream<String?> get errorStream => _errorSubject.stream;
  ValueStream<List<Product>> get productsStream => _productsSubject.stream;
  ValueStream<List<Restaurant>> get searchResultsStream => _searchResultsSubject.stream;
  ValueStream<Position?> get userLocationStream => _userLocationSubject.stream;
  ValueStream<Restaurant?> get selectedRestaurantStream =>
      _selectedRestaurantSubject.stream;
  ValueStream<Map<int, double>> get distancesStream => _distancesSubject.stream;

  Position? get userLocation => _userLocationSubject.value;
  Map<int, double> get distances => _distancesSubject.value;

  Future<void> loadProducts() async {
    _loadingSubject.add(true);
    _errorSubject.add(null);

    final response = await _apiService.getProducts();
    _loadingSubject.add(false);

    if (response.isSuccess && response.data != null) {
      _productsSubject.add(response.data!);
    } else {
      _errorSubject.add(response.error ?? 'Failed to load products');
    }
  }

  Future<void> searchByProduct(String product) async {
    _loadingSubject.add(true);
    _errorSubject.add(null);

    final response = await _apiService.searchRestaurantsByProduct(product);
    _loadingSubject.add(false);

    if (response.isSuccess && response.data != null) {
      _searchResultsSubject.add(response.data!);
      await _calculateDistances(response.data!);
    } else {
      _errorSubject.add(response.error ?? 'Search failed');
    }
  }

  /// Load user's current location with permission handling.
  /// This is non-blocking and handles timeouts gracefully.
  Future<void> loadCurrentLocation() async {
    try {
      // Run location fetch with timeout to prevent hanging
      final location = await LocationService.getCurrentLocation().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          return null;
        },
      );
      _userLocationSubject.add(location);
    } catch (e) {
      // Silently handle errors during background location load
      _userLocationSubject.add(null);
    }
  }

  /// Calculate distances from user to all restaurants in search results.
  Future<void> _calculateDistances(List<Restaurant> restaurants) async {
    final userLoc = _userLocationSubject.value;
    if (userLoc == null) {
      return; // User location not available
    }

    final distanceMap = <int, double>{};
    for (final restaurant in restaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        final distance = LocationService.calculateDistance(
          userLoc.latitude,
          userLoc.longitude,
          restaurant.latitude!,
          restaurant.longitude!,
        );
        distanceMap[restaurant.id] = distance;
      }
    }
    _distancesSubject.add(distanceMap);
  }

  /// Get distance to a specific restaurant in km.
  double? getDistanceToRestaurant(Restaurant restaurant) {
    return _distancesSubject.value[restaurant.id];
  }

  /// Refresh distances for current search results.
  Future<void> refreshDistances() async {
    final results = _searchResultsSubject.value;
    if (results.isNotEmpty) {
      await _calculateDistances(results);
    }
  }

  /// Select a restaurant for details view.
  void selectRestaurant(Restaurant restaurant) {
    _selectedRestaurantSubject.add(restaurant);
  }

  /// Clear selected restaurant.
  void clearSelectedRestaurant() {
    _selectedRestaurantSubject.add(null);
  }

  void dispose() {
    _loadingSubject.close();
    _errorSubject.close();
    _productsSubject.close();
    _searchResultsSubject.close();
    _userLocationSubject.close();
    _selectedRestaurantSubject.close();
    _distancesSubject.close();
    _apiService.dispose();
  }
}
