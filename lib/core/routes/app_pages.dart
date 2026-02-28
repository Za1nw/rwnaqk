import 'package:get/get.dart';
import 'package:rwnaqk/core/bindings/flash_sale_binding.dart';
import 'package:rwnaqk/core/bindings/forgot_password_binding.dart';
import 'package:rwnaqk/core/bindings/login_binding.dart';
import 'package:rwnaqk/core/bindings/onboarding_binding.dart';
import 'package:rwnaqk/core/bindings/product_details_binding.dart';
import 'package:rwnaqk/core/bindings/register_binding.dart';
import 'package:rwnaqk/core/bindings/search_binding.dart';
import 'package:rwnaqk/core/bindings/search_results_binding.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/screens/auth/forgot_password_method_screen.dart';
import 'package:rwnaqk/screens/auth/login_screen.dart';
import 'package:rwnaqk/screens/auth/otp_verify_screen.dart';
import 'package:rwnaqk/screens/auth/register_screen.dart';
import 'package:rwnaqk/screens/auth/reset_password_screen.dart';
import 'package:rwnaqk/screens/cart_screen.dart';
import 'package:rwnaqk/screens/flash_sale_screen.dart';
import 'package:rwnaqk/screens/home_screen.dart';
import 'package:rwnaqk/screens/main_screen.dart';
import 'package:rwnaqk/screens/onboarding_screen.dart';
import 'package:rwnaqk/screens/product_details_screen.dart';
import 'package:rwnaqk/screens/reviews_screen.dart';
import 'package:rwnaqk/screens/search_results_screen.dart';
import 'package:rwnaqk/screens/search_screen.dart';
import 'package:rwnaqk/screens/wishlist_screen.dart';

class AppPages {
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
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.forgot,
      page: () => const ForgotPasswordMethodScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpVerifyScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.reset,
      page: () => const ResetPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: AppRoutes.results,
      page: () => const SearchResultsScreen(),
      binding: SearchResultsBinding(),
    ),
    GetPage(
      name: AppRoutes.flashSale,
      page: () => const FlashSaleScreen(),
      binding: FlashSaleBinding(),
    ),
    GetPage(
      name: AppRoutes.product,
      page: () => const ProductDetailsScreen(),
      binding: ProductDetailsBinding(),
    ),
    GetPage(name: AppRoutes.reviews, page: () => const ReviewsScreen()),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistScreen(),
      
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartScreen(),
      // binding: CartBinding(),
    ),
  ];
}
