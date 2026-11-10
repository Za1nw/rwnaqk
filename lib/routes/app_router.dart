import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

// Auth Views
import 'package:rwnaqk_frontend/modules/auth/views/email_verification_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/forgot_password_method_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/login_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/otp_verify_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/register_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/reset_password_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/two_factor_challenge_view.dart';

// Cart & Checkout Views
import 'package:rwnaqk_frontend/modules/cart/views/cart_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/order_confirmation_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/order_success_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/payment_view.dart';

// Catalog & Search Views
import 'package:rwnaqk_frontend/modules/catalog/views/flash_sale_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/product_details_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/products_listing_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/reviews_view.dart';
import 'package:rwnaqk_frontend/modules/search/views/search_results_view.dart';
import 'package:rwnaqk_frontend/modules/search/views/search_view.dart';

// Customer Views
import 'package:rwnaqk_frontend/modules/customer/views/addresses_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/edit_profile_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/profile_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/settings_view.dart';

// Home Views
import 'package:rwnaqk_frontend/modules/home/views/home_view.dart';
import 'package:rwnaqk_frontend/modules/home/views/main_view.dart';

// Onboarding Views
import 'package:rwnaqk_frontend/modules/onboarding/views/onboarding_view.dart';

// Orders Views
import 'package:rwnaqk_frontend/modules/orders/views/order_details_view.dart';
import 'package:rwnaqk_frontend/modules/orders/views/order_tracking_view.dart';
import 'package:rwnaqk_frontend/modules/orders/views/orders_view.dart';

// Support Views
import 'package:rwnaqk_frontend/modules/support/views/help_center_view.dart';
import 'package:rwnaqk_frontend/modules/support/views/support_chat_view.dart';

// Wishlist Views
import 'package:rwnaqk_frontend/modules/wishlist/views/wishlist_view.dart';

/// Centralized native router replacing GetPage route table.
abstract final class AppRouter {
  const AppRouter._();

  static const Set<String> _guestOnlyRoutes = {
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgot,
    AppRoutes.otp,
    AppRoutes.reset,
    AppRoutes.twoFactorChallenge,
  };

  static const Set<String> _authOnlyRoutes = {
    AppRoutes.home,
    AppRoutes.search,
    AppRoutes.searchResults,
    AppRoutes.flashSale,
    AppRoutes.product,
    AppRoutes.reviews,
    AppRoutes.wishlist,
    AppRoutes.main,
    AppRoutes.cart,
    AppRoutes.payment,
    AppRoutes.orderConfirmation,
    AppRoutes.orderSuccess,
    AppRoutes.settings,
    AppRoutes.profile,
    AppRoutes.helpCenter,
    AppRoutes.supportChat,
    AppRoutes.editProfile,
    AppRoutes.addresses,
    AppRoutes.orders,
    AppRoutes.orderDetails,
    AppRoutes.orderTracking,
    AppRoutes.listing,
    AppRoutes.emailVerify,
  };

  /// Route generator with security guards and seamless transitions.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.onboarding;

    // Evaluate route guard redirects
    final redirectedRoute = _checkRouteGuards(routeName);
    if (redirectedRoute != null && redirectedRoute != routeName) {
      return onGenerateRoute(
        RouteSettings(name: redirectedRoute, arguments: settings.arguments),
      );
    }

    final builder = _resolveWidgetBuilder(routeName);
    if (builder == null) {
      // Fallback 404 route: go to main or onboarding
      return MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (_) => const MainScreen(),
      );
    }

    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: builder,
    );
  }

  static String? _checkRouteGuards(String route) {
    try {
      final session = globalProviderContainer.read(authSessionProvider);
      final isAuth = session.isAuthenticated;
      final isGuest = session.isGuest;

      if (_guestOnlyRoutes.contains(route)) {
        // If logged in and not preview guest, forward to main
        if (isAuth && !isGuest) {
          return AppRoutes.main;
        }
      }

      if (_authOnlyRoutes.contains(route)) {
        // If not logged in and not guest mode, forward to login
        if (!isAuth && !isGuest) {
          return AppRoutes.login;
        }
      }
    } catch (_) {
      // If session provider isn't ready, let it pass
    }

    return null;
  }

  static WidgetBuilder? _resolveWidgetBuilder(String route) {
    switch (route) {
      case AppRoutes.onboarding:
        return (_) => const OnboardingScreen();
      case AppRoutes.login:
        return (_) => const LoginScreen();
      case AppRoutes.register:
        return (_) => const RegisterScreen();
      case AppRoutes.emailVerify:
        return (_) => const EmailVerificationScreen();
      case AppRoutes.twoFactorChallenge:
        return (_) => const TwoFactorChallengeScreen();
      case AppRoutes.forgot:
        return (_) => const ForgotPasswordMethodScreen();
      case AppRoutes.otp:
        return (_) => const OtpVerifyScreen();
      case AppRoutes.reset:
        return (_) => const ResetPasswordScreen();
      case AppRoutes.home:
        return (_) => const HomeScreen();
      case AppRoutes.search:
        return (_) => const SearchScreen();
      case AppRoutes.searchResults:
        return (_) => const SearchResultsScreen();
      case AppRoutes.flashSale:
        return (_) => const FlashSaleScreen();
      case AppRoutes.product:
        return (_) => const ProductDetailsScreen();
      case AppRoutes.reviews:
        return (_) => const ReviewsScreen();
      case AppRoutes.wishlist:
        return (_) => const WishlistScreen();
      case AppRoutes.main:
        return (_) => const MainScreen();
      case AppRoutes.cart:
        return (_) => const CartScreen();
      case AppRoutes.payment:
        return (_) => const PaymentScreen();
      case AppRoutes.orderConfirmation:
        return (_) => const OrderConfirmationScreen();
      case AppRoutes.orderSuccess:
        return (_) => const OrderSuccessScreen();
      case AppRoutes.settings:
        return (_) => const SettingsScreen();
      case AppRoutes.profile:
        return (_) => const ProfileScreen();
      case AppRoutes.helpCenter:
        return (_) => const HelpCenterScreen();
      case AppRoutes.supportChat:
        return (_) => const SupportChatScreen();
      case AppRoutes.editProfile:
        return (_) => const EditProfileScreen();
      case AppRoutes.addresses:
        return (_) => const AddressesScreen();
      case AppRoutes.orders:
        return (_) => const OrdersScreen();
      case AppRoutes.orderDetails:
        return (_) => const OrderDetailsScreen();
      case AppRoutes.orderTracking:
        return (_) => const OrderTrackingScreen();
      case AppRoutes.listing:
        return (_) => const ProductsListingScreen();
      default:
        return null;
    }
  }
}
