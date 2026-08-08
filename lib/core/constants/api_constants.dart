abstract final class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';
  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String categoryList = '/products/category-list';
  static const int defaultPageLimit = 20;
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
