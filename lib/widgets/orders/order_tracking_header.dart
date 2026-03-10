import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class OrderTrackingHeader extends StatelessWidget {
  const OrderTrackingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.foreground,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'تتبع الطلب'.tr,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}