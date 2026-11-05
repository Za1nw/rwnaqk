import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/edit_profile_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/edit_profile_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/two_factor_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/two_factor_settings_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/edit_profile_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
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
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
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
import 'package:rwnaqk_frontend/modules/catalog/views/product_details_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/products_listing_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/addresses_view.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_ui_controller.dart';
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
      page: () => PaymentScreen(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      middlewares: _authOnly,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      middlewares: _authOnly,
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileService>(
          () => ProfileService(Get.find<ProfileStoreService>()),
        );
        Get.lazyPut<ProfileController>(
          () => ProfileController(Get.find<ProfileService>()),
        );
        Get.lazyPut<TwoFactorSettingsService>(
          () => TwoFactorSettingsService(
            Get.find<CustomerAuthApiService>(),
            Get.find<AuthSessionService>(),
          ),
        );
        Get.lazyPut<TwoFactorSettingsController>(
          () =>
              TwoFactorSettingsController(Get.find<TwoFactorSettingsService>()),
        );
      }),
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
      middlewares: _authOnly,
      binding: BindingsBuilder(() {
        Get.lazyPut<EditProfileUiController>(() => EditProfileUiController());
        Get.lazyPut<EditProfileService>(
          () => EditProfileService(Get.find<ProfileStoreService>()),
        );
        Get.lazyPut<EditProfileController>(
          () => EditProfileController(Get.find<EditProfileService>()),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.addresses,
      page: () => const AddressesScreen(),
      middlewares: _authOnly,
      binding: BindingsBuilder(() {
        Get.lazyPut<AddressesUiController>(() => AddressesUiController());
        Get.lazyPut<AddressesService>(
          () => AddressesService(Get.find<ProfileStoreService>()),
        );
        Get.lazyPut<AddressesController>(
          () => AddressesController(Get.find<AddressesService>()),
        );
      }),
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
