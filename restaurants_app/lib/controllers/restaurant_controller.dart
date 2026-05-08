import 'package:rxdart/rxdart.dart';

import '../models/product.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';

class RestaurantController {
  RestaurantController({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  final BehaviorSubject<bool> _loadingSubject = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _errorSubject = BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<List<Restaurant>> _restaurantsSubject =
      BehaviorSubject<List<Restaurant>>.seeded(const []);
  final BehaviorSubject<List<Product>> _productsSubject =
      BehaviorSubject<List<Product>>.seeded(const []);

  ValueStream<bool> get loadingStream => _loadingSubject.stream;
  ValueStream<String?> get errorStream => _errorSubject.stream;
  ValueStream<List<Restaurant>> get restaurantsStream => _restaurantsSubject.stream;
  ValueStream<List<Product>> get productsStream => _productsSubject.stream;

  Future<void> loadRestaurants() async {
    _loadingSubject.add(true);
    _errorSubject.add(null);

    final response = await _apiService.getRestaurants();
    _loadingSubject.add(false);

    if (response.isSuccess && response.data != null) {
      _restaurantsSubject.add(response.data!);
    } else {
      _errorSubject.add(response.error ?? 'Failed to load restaurants');
    }
  }

  Future<void> loadProductsForRestaurant(int restaurantId) async {
    _loadingSubject.add(true);
    _errorSubject.add(null);

    final response = await _apiService.getRestaurantProducts(restaurantId);
    _loadingSubject.add(false);

    if (response.isSuccess && response.data != null) {
      _productsSubject.add(response.data!);
    } else {
      _errorSubject.add(response.error ?? 'Failed to load products');
    }
  }

  void dispose() {
    _loadingSubject.close();
    _errorSubject.close();
    _restaurantsSubject.close();
    _productsSubject.close();
    _apiService.dispose();
  }
}
