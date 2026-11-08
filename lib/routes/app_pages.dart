import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/customer/bindings/customer_binding.dart';
import 'package:rwnaqk_frontend/modules/catalog/bindings/flash_sale_binding.dart';
import 'package:rwnaqk_frontend/modules/auth/bindings/forgot_password_binding.dart';
import 'package:rwnaqk_frontend/modules/auth/bindings/login_binding.dart';
import 'package:rwnaqk_frontend/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:rwnaqk_frontend/modules/catalog/bindings/product_details_binding.dart';
import 'package:rwnaqk_frontend/modules/catalog/bindings/products_listing_binding.dart';
import 'package:rwnaqk_frontend/modules/auth/bindings/register_binding.dart';
import 'package:rwnaqk_frontend/modules/catalog/bindings/reviews_binding.dart';
import 'package:rwnaqk_frontend/modules/search/bindings/search_binding.dart';
import 'package:rwnaqk_frontend/modules/support/bindings/support_binding.dart';
import 'package:rwnaqk_frontend/core/middleware/auth_middleware.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/modules/auth/views/forgot_password_method_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/email_verification_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/login_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/otp_verify_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/register_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/reset_password_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/two_factor_challenge_view.dart';
import 'package:rwnaqk_frontend/modules/cart/views/cart_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/flash_sale_view.dart';
import 'package:rwnaqk_frontend/modules/home/views/home_view.dart';
import 'package:rwnaqk_frontend/modules/support/views/help_center_view.dart';
import 'package:rwnaqk_frontend/modules/home/views/main_view.dart';
import 'package:rwnaqk_frontend/modules/onboarding/views/onboarding_view.dart';
import 'package:rwnaqk_frontend/modules/orders/views/order_details_view.dart';
import 'package:rwnaqk_frontend/modules/orders/views/order_tracking_view.dart';
import 'package:rwnaqk_frontend/modules/orders/views/orders_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/payment_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/order_confirmation_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/order_success_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/product_details_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/products_listing_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/addresses_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/edit_profile_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/profile_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/reviews_view.dart';
import 'package:rwnaqk_frontend/modules/search/views/search_results_view.dart';
import 'package:rwnaqk_frontend/modules/search/views/search_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/settings_view.dart';
import 'package:rwnaqk_frontend/modules/support/views/support_chat_view.dart';
import 'package:rwnaqk_frontend/modules/wishlist/views/wishlist_view.dart';

class AppPages {
  static final _guestOnly = <GetMiddleware>[GuestMiddleware(priorityValue: 10)];
  static final _authOnly = <GetMiddleware>[AuthMiddleware(priorityValue: 10)];

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      middlewares: _guestOnly,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
      middlewares: _guestOnly,
    ),
    GetPage(
      name: AppRoutes.emailVerify,
      page: () => const EmailVerificationScreen(),
      binding: LoginBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.twoFactorChallenge,
      page: () => const TwoFactorChallengeScreen(),
      binding: LoginBinding(),
      middlewares: _guestOnly,
    ),
    GetPage(
      name: AppRoutes.forgot,
      page: () => const ForgotPasswordMethodScreen(),
      binding: ForgotPasswordBinding(),
      middlewares: _guestOnly,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpVerifyScreen(),
      binding: ForgotPasswordBinding(),
      middlewares: _guestOnly,
    ),
    GetPage(
      name: AppRoutes.reset,
      page: () => const ResetPasswordScreen(),
      binding: ForgotPasswordBinding(),
      middlewares: _guestOnly,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.searchResults,
      page: () => const SearchResultsScreen(),
      binding: SearchBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.flashSale,
      page: () => const FlashSaleScreen(),
      binding: FlashSaleBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.product,
      page: () => const ProductDetailsScreen(),
      binding: ProductDetailsBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.reviews,
      page: () => const ReviewsScreen(),
      binding: ReviewsBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistScreen(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartScreen(),
      // binding: CartBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.payment,
      page: () => const PaymentScreen(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.orderConfirmation,
      page: () => const OrderConfirmationScreen(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.orderSuccess,
      page: () => const OrderSuccessScreen(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.helpCenter,
      page: () => const HelpCenterScreen(),
      binding: SupportBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.supportChat,
      page: () => const SupportChatScreen(),
      binding: SupportBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: EditProfileBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.addresses,
      page: () => const AddressesScreen(),
      binding: AddressesBinding(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersScreen(),
      middlewares: _authOnly,
      // binding:BindingsBuilder(
      //    Get.lazyPut(() =>OrdersController());
      // ),
    ),
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => const OrderDetailsScreen(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.orderTracking,
      page: () => const OrderTrackingScreen(),
      middlewares: _authOnly,
      // ما يحتاج binding لأنه يستخدم نفس OrdersController الموجود
    ),
    GetPage(
      name: AppRoutes.listing,
      page: () => const ProductsListingScreen(),
      binding: ProductsListingBinding(),
      middlewares: _authOnly,
    ),
  ];
}
