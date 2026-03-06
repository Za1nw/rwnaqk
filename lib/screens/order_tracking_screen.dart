import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/controllers/orders_controller.dart';
import 'package:rwnaqk/models/order_model.dart';
import 'package:rwnaqk/widgets/orders/order_status_pill.dart';
import 'package:rwnaqk/widgets/orders/order_timeline.dart';

class OrderTrackingScreen extends GetView<OrdersController> {
  const OrderTrackingScreen({super.key});

  String _money(double v) => v.toStringAsFixed(0);

  String _statusLabel(String s) {
    switch (s) {
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
        return s;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
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

  /// ETA mock (بدّلها لاحقًا بقيمة من API)
  String _etaText(String status) {
    switch (status) {
      case 'pending':
        return 'متوقع خلال 24 ساعة'.tr;
      case 'confirmed':
        return 'متوقع اليوم'.tr;
      case 'shipped':
        return 'متوقع خلال 2-4 ساعات'.tr;
      case 'delivered':
        return 'تم التسليم'.tr;
      case 'canceled':
        return 'تم الإلغاء'.tr;
      default:
        return 'قريباً'.tr;
    }
  }

  bool _canCancel(String status) => status == 'pending' || status == 'confirmed';
  bool _canReorder(String status) => status == 'delivered' || status == 'canceled';

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as OrderModel;
    final steps = controller.buildTrackingSteps(order);

    final id = order.id;
    final status = order.status;
    final addressLine = order.addressLine;

    final createdAt = order.createdAt;
    final itemsCount = order.itemsCount;
    final total = order.total;

    final deliveryName = order.deliveryName;
    final deliveryPhone = order.deliveryPhone;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          children: [
            // =========================
            // Header
            // =========================
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back_rounded, color: context.foreground),
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
            ),
            const SizedBox(height: 12),

            // =========================
            // Order summary card
            // =========================
            Material(
              color: context.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: context.border.withOpacity(.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            id,
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                        OrderStatusPill(status: status),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _MiniInfo(
                          icon: Icons.calendar_month_outlined,
                          text:
                              '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}',
                        ),
                        const SizedBox(width: 12),
                        _MiniInfo(
                          icon: Icons.shopping_bag_outlined,
                          text: '${itemsCount.toString()} ${'عنصر'.tr}',
                        ),
                        const Spacer(),
                        Text(
                          '${_money(total)}',
                          style: TextStyle(
                            color: context.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),

                    if ((addressLine ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 18, color: context.muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              addressLine!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.muted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Recipient (اختياري)
                    if (((deliveryName ?? '').trim().isNotEmpty) ||
                        ((deliveryPhone ?? '').trim().isNotEmpty)) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.input,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.border.withOpacity(.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 18, color: context.muted),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                [
                                  if ((deliveryName ?? '').trim().isNotEmpty)
                                    deliveryName!.trim(),
                                  if ((deliveryPhone ?? '').trim().isNotEmpty)
                                    deliveryPhone!.trim(),
                                ].join(' • '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.foreground,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // ETA Card
            // =========================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.primary.withOpacity(.16)),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon(status), color: context.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${'الحالة'.tr}: ${_statusLabel(status).tr}  •  ${'الوصول المتوقع'.tr}: ${_etaText(status)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // Timeline
            // =========================
            Text(
              'حالة الطلب'.tr,
              style: TextStyle(
                color: context.foreground,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            Material(
              color: context.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: context.border.withOpacity(.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: OrderTimeline(
                  steps: steps,
                  currentStatus: status,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // Actions (حسب الحالة)
            // =========================
            Row(
              children: [
                if (_canCancel(status))
                  Expanded(
                    child: _ActionButton(
                      text: 'إلغاء الطلب'.tr,
                      outlined: true,
                      onTap: () {
                        Get.snackbar('إلغاء الطلب'.tr, 'تم (Mock)'.tr);
                      },
                    ),
                  ),
                if (_canCancel(status)) const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    text: _canReorder(status) ? 'إعادة الطلب'.tr : 'مساعدة'.tr,
                    onTap: () {
                      Get.snackbar('تم'.tr, 'Mock action'.tr);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (status == 'delivered')
              _ActionButton(
                text: 'تقييم الطلب'.tr,
                outlined: true,
                onTap: () {
                  Get.snackbar('تقييم'.tr, 'Mock action'.tr);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: context.muted),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: context.muted,
            fontWeight: FontWeight.w800,
            fontSize: 12.3,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({
    required this.text,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = outlined ? Colors.transparent : context.primary;
    final fg = outlined ? context.primary : context.primaryForeground;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: outlined ? BorderSide(color: fg) : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w900,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}