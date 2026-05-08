class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.0.2.2:5000';

  static const String signup = '/signup';
  static const String login = '/login';
  static const String restaurants = '/restaurants';
  static const String products = '/products';

  static String restaurantProducts(int restaurantId) =>
      '/restaurants/$restaurantId/products';

  static String searchByProduct(String product) =>
      '/search?product=${Uri.encodeQueryComponent(product)}';
}
