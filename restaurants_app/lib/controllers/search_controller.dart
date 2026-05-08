import 'package:rxdart/rxdart.dart';

import '../models/product.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';

class SearchController {
  SearchController({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  final BehaviorSubject<bool> _loadingSubject = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _errorSubject = BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<List<Product>> _productsSubject =
      BehaviorSubject<List<Product>>.seeded(const []);
  final BehaviorSubject<List<Restaurant>> _searchResultsSubject =
      BehaviorSubject<List<Restaurant>>.seeded(const []);

  ValueStream<bool> get loadingStream => _loadingSubject.stream;
  ValueStream<String?> get errorStream => _errorSubject.stream;
  ValueStream<List<Product>> get productsStream => _productsSubject.stream;
  ValueStream<List<Restaurant>> get searchResultsStream => _searchResultsSubject.stream;

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
    } else {
      _errorSubject.add(response.error ?? 'Search failed');
    }
  }

  void dispose() {
    _loadingSubject.close();
    _errorSubject.close();
    _productsSubject.close();
    _searchResultsSubject.close();
    _apiService.dispose();
  }
}
