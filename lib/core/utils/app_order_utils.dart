import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

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
        return 'قيد المعالجة';
      case 'confirmed':
        return 'مؤكد';
      case 'shipped':
        return 'قيد التوصيل';
      case 'delivered':
        return 'تم التسليم';
      case 'canceled':
        return 'ملغي';
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
        return 'متوقع خلال 24 ساعة';
      case 'confirmed':
        return 'متوقع اليوم';
      case 'shipped':
        return 'متوقع خلال 2-4 ساعات';
      case 'delivered':
        return 'تم التسليم';
      case 'canceled':
        return 'تم الإلغاء';
      default:
        return 'قريباً';
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