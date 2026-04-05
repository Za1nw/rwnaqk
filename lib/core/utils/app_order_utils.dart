import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

class AppOrderUtils {
  AppOrderUtils._();

  static const List<String> _progressOrder = [
    'pending',
    'confirmed',
    'shipped',
    'delivered',
  ];

  static String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return Tk.ordersStatusPending;
      case 'confirmed':
        return Tk.ordersStatusConfirmed;
      case 'shipped':
        return Tk.ordersStatusShipped;
      case 'delivered':
        return Tk.ordersStatusDelivered;
      case 'canceled':
        return Tk.ordersStatusCanceled;
      default:
        return status;
    }
  }

  static IconData statusIcon(
    String status, {
    bool trackingStyle = false,
  }) {
    if (trackingStyle) {
      switch (status) {
        case 'pending':
          return Icons.timelapse_rounded;
        case 'confirmed':
          return Icons.verified_rounded;
        case 'shipped':
          return Icons.local_shipping_rounded;
        case 'delivered':
          return Icons.check_circle_rounded;
        case 'canceled':
          return Icons.cancel_rounded;
        default:
          return Icons.info_outline_rounded;
      }
    }

    switch (status) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'confirmed':
        return Icons.verified_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'canceled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  static Color statusColor(BuildContext context, String status) {
    if (status == 'canceled') return context.destructive;
    if (status == 'delivered') return context.success;
    if (status == 'shipped') return context.warning;
    return context.primary;
  }

  static String etaText(String status) {
    switch (status) {
      case 'pending':
        return Tk.ordersEtaPending;
      case 'confirmed':
        return Tk.ordersEtaConfirmed;
      case 'shipped':
        return Tk.ordersEtaShipped;
      case 'delivered':
        return Tk.ordersEtaDelivered;
      case 'canceled':
        return Tk.ordersEtaCanceled;
      default:
        return Tk.ordersEtaPending;
    }
  }

  static bool canCancel(String status) {
    return status == 'pending' || status == 'confirmed';
  }

  static bool canReorder(String status) {
    return status == 'delivered' || status == 'canceled';
  }

  static bool isStepDone({
    required String currentStatus,
    required String key,
  }) {
    if (currentStatus == 'canceled') {
      return key == 'pending' || key == 'canceled';
    }

    final currentIndex = _progressOrder.indexOf(currentStatus);
    final keyIndex = _progressOrder.indexOf(key);

    if (keyIndex == -1) {
      return key == currentStatus;
    }

    return keyIndex <= currentIndex;
  }

  static bool isCompleted(String status) {
    return status == 'delivered';
  }

  static bool isCanceled(String status) {
    return status == 'canceled';
  }

  static bool isActive(String status) {
    return !isCompleted(status) && !isCanceled(status);
  }
}
