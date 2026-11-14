/// مسارات نقاط نهاية خادم Laravel API
class ApiEndpoints {
  ApiEndpoints._();

  // Authentication
  static const String register = '/api/v1/customer/auth/register';
  static const String login = '/api/v1/customer/auth/login';
  static const String me = '/api/v1/customer/auth/me';
  static const String logout = '/api/v1/customer/auth/logout';
  static const String forgotPassword = '/api/v1/customer/auth/forgot-password';
  static const String verifyPasswordResetCode =
      '/api/v1/customer/auth/verify-reset-code';
  static const String resetPassword = '/api/v1/customer/auth/reset-password';
  static const String sendVerificationCode =
      '/api/v1/customer/auth/email/verification-code';
  static const String verifyEmailCode =
      '/api/v1/customer/auth/email/verify-code';
  static const String updateProfile = '/api/v1/customer/auth/profile';
  static const String changePassword = '/api/v1/customer/auth/password';
  static const String sessions = '/api/v1/customer/auth/sessions';
  static String revokeSession(int id) => '/api/v1/customer/auth/sessions/$id';
  static const String revokeOtherSessions =
      '/api/v1/customer/auth/sessions/revoke-others';
  static const String passkeys = '/api/v1/customer/auth/passkeys';
  static const String passkeyLogin = '/api/v1/customer/auth/passkeys/login';
  static String deletePasskey(int id) => '/api/v1/customer/auth/passkeys/$id';

  // Catalog & Products
  static const String products = '/api/v1/products';
  static String productDetails(String id) => '/api/v1/products/$id';
  static String productReviews(String id) => '/api/v1/products/$id/reviews';
  static const String categories = '/api/v1/categories';
  static const String brands = '/api/v1/brands';

  // Cart & Checkout
  static const String cartQuote = '/api/v1/customer/cart/quote';
  static const String validateCoupon = '/api/v1/customer/cart/validate-coupon';

  // Orders
  static const String orders = '/api/v1/customer/orders';
  static String orderDetails(String id) => '/api/v1/customer/orders/$id';
  static String cancelOrder(String id) => '/api/v1/customer/orders/$id/cancel';

  // Media & Uploads
  static const String temporaryImages = '/api/temporary-images';

  // Customer Addresses
  static const String customerAddresses = '/api/v1/customer/addresses';
  static String customerAddressDetails(String id) => '/api/v1/customer/addresses/$id';
  static String customerAddressPrimary(String id) => '/api/v1/customer/addresses/$id/primary';
}

