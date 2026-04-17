import 'package:get/get.dart';
import 'package:rwnaqk/controllers/addresses/addresses_controller.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_controller.dart';
import 'package:rwnaqk/controllers/profile/profile_controller.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_service.dart';
import 'package:rwnaqk/controllers/profile/profile_service.dart';
import 'package:rwnaqk/controllers/profile/two_factor_settings_controller.dart';
import 'package:rwnaqk/controllers/profile/two_factor_settings_service.dart';
import 'package:rwnaqk/controllers/profile/edit_profile_ui_controller.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/core/bindings/flash_sale_binding.dart';
import 'package:rwnaqk/core/bindings/forgot_password_binding.dart';
import 'package:rwnaqk/core/bindings/login_binding.dart';
import 'package:rwnaqk/core/bindings/onboarding_binding.dart';
import 'package:rwnaqk/core/bindings/product_details_binding.dart';
import 'package:rwnaqk/core/bindings/products_listing_binding.dart';
import 'package:rwnaqk/core/bindings/register_binding.dart';
import 'package:rwnaqk/core/bindings/reviews_binding.dart';
import 'package:rwnaqk/core/bindings/search_binding.dart';
import 'package:rwnaqk/core/bindings/support_binding.dart';
import 'package:rwnaqk/core/middlewares/auth_middlewares.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk/screens/auth/forgot_password_method_screen.dart';
import 'package:rwnaqk/screens/auth/email_verification_screen.dart';
import 'package:rwnaqk/screens/auth/login_screen.dart';
import 'package:rwnaqk/screens/auth/otp_verify_screen.dart';
import 'package:rwnaqk/screens/auth/register_screen.dart';
import 'package:rwnaqk/screens/auth/reset_password_screen.dart';
import 'package:rwnaqk/screens/auth/two_factor_challenge_screen.dart';
import 'package:rwnaqk/screens/cart_screen.dart';
import 'package:rwnaqk/screens/flash_sale_screen.dart';
import 'package:rwnaqk/screens/home_screen.dart';
import 'package:rwnaqk/screens/help_center_screen.dart';
import 'package:rwnaqk/screens/main_screen.dart';
import 'package:rwnaqk/screens/onboarding_screen.dart';
import 'package:rwnaqk/screens/order_details_screen.dart';
import 'package:rwnaqk/screens/order_tracking_screen.dart';
import 'package:rwnaqk/screens/orders_screen.dart';
import 'package:rwnaqk/screens/payment_screen.dart';
import 'package:rwnaqk/screens/product_details_screen.dart';
import 'package:rwnaqk/screens/products_listing_screen.dart';
import 'package:rwnaqk/screens/profile/addresses_screen.dart';
import 'package:rwnaqk/controllers/addresses/addresses_service.dart';
import 'package:rwnaqk/controllers/addresses/addresses_ui_controller.dart';
import 'package:rwnaqk/screens/profile/edit_profile_screen.dart';
import 'package:rwnaqk/screens/profile/profile_screen.dart';
import 'package:rwnaqk/screens/reviews_screen.dart';
import 'package:rwnaqk/screens/search_results_screen.dart';
import 'package:rwnaqk/screens/search_screen.dart';
import 'package:rwnaqk/screens/settings_screen.dart';
import 'package:rwnaqk/screens/support_chat_screen.dart';
import 'package:rwnaqk/screens/wishlist_screen.dart';

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
