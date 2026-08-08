abstract final class AppRoutes {
  static const String products = '/products';
  static const String favourites = '/favourites';
  static const String cart = '/cart';
  static const String productDetails = 'details/:id';

  static String productDetailsPath(int id) => '/products/details/$id';
}
