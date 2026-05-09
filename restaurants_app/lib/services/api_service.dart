import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/restaurant.dart';
import '../models/user.dart';
import '../utils/api_constants.dart';
import 'api_response.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .get(uri, headers: _headers())
          .timeout(
            _timeout,
            onTimeout: () => throw TimeoutException('Request timeout'),
          );
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Network request timeout - please check your connection');
    }
  }

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode(body),
          )
          .timeout(
            _timeout,
            onTimeout: () => throw TimeoutException('Request timeout'),
          );
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Network request timeout - please check your connection');
    }
  }

  Map<String, String> _headers() {
    return {'Content-Type': 'application/json'};
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final dynamic decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    final message = decoded is Map<String, dynamic>
        ? (decoded['message'] ?? decoded['error'] ?? 'Request failed').toString()
        : 'Request failed with status ${response.statusCode}';
    throw Exception(message);
  }

  Future<ApiResponse<User>> signup({
    required String name,
    String? gender,
    required String email,
    int? level,
    required String password,
  }) async {
    try {
      final json = await _post(ApiConstants.signup, {
        'name': name,
        'gender': gender,
        'email': email,
        'level': level,
        'password': password,
      });
      final payload = (json['data'] ?? json['user'] ?? json) as Map<String, dynamic>;
      return ApiResponse.success(User.fromJson(payload));
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final json = await _post(ApiConstants.login, {
        'email': email,
        'password': password,
      });
      final payload = (json['data'] ?? json['user'] ?? json) as Map<String, dynamic>;
      return ApiResponse.success(User.fromJson(payload));
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<List<Restaurant>>> getRestaurants() async {
    try {
      final json = await _get(ApiConstants.restaurants);
      final list = (json['data'] ?? json['restaurants'] ?? json) as List<dynamic>;
      final restaurants = list
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(restaurants);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<List<Product>>> getRestaurantProducts(int restaurantId) async {
    try {
      final json = await _get(ApiConstants.restaurantProducts(restaurantId));
      final list = (json['data'] ?? json['products'] ?? json) as List<dynamic>;
      final products =
          list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.success(products);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<List<Product>>> getProducts() async {
    try {
      final json = await _get(ApiConstants.products);
      final list = (json['data'] ?? json['products'] ?? json) as List<dynamic>;
      final products =
          list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.success(products);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<List<Restaurant>>> searchRestaurantsByProduct(
    String product,
  ) async {
    try {
      final json = await _get(ApiConstants.searchByProduct(product));
      final list = (json['data'] ?? json['restaurants'] ?? json) as List<dynamic>;
      final restaurants = list
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(restaurants);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  void dispose() {
    _client.close();
  }
}
