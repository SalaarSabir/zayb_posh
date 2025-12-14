// lib/core/constants/app_routes.dart
class AppRoutes {
  // Private constructor
  AppRoutes._();

  // Authentication Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main Routes
  static const String home = '/home';
  static const String main = '/main'; // Bottom navigation wrapper

  // Product Routes
  static const String products = '/products';
  static const String productDetail = '/product-detail';
  static const String productsByCategory = '/products/category';
  static const String search = '/search';

  // Cart Routes
  static const String cart = '/cart';
  static const String checkout = '/checkout';

  // Order Routes
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';
  static const String trackOrder = '/track-order';

  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String addresses = '/addresses';
  static const String addAddress = '/add-address';
  static const String editAddress = '/edit-address';

  // Wishlist Routes
  static const String wishlist = '/wishlist';

  // Settings Routes
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String aboutUs = '/about-us';
  static const String termsConditions = '/terms-conditions';
  static const String privacyPolicy = '/privacy-policy';
  static const String contactUs = '/contact-us';
  static const String helpSupport = '/help-support';
}