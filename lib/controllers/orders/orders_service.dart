import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/controllers/orders/orders_ui_controller.dart';
import 'package:rwnaqk/models/order_details_model.dart';
import 'package:rwnaqk/models/order_model.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بمنظومة الطلبات.
///
/// نستخدمه لفصل:
/// - البيانات التجريبية
/// - منطق الفلترة
/// - بناء خطوات التتبع
///
/// لاحقًا عند ربط API الحقيقي، سيكون هذا الملف هو المكان المناسب
/// لجلب الطلبات وبناء بيانات التتبع القادمة من السيرفر.
class OrdersService {
  /// هذه الدالة تعيد قائمة طلبات تجريبية.
  List<OrderModel> seedMockOrders() {
    return [
      OrderModel(
        id: 'ORD-10241',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        total: 24500,
        itemsCount: 3,
        status: 'shipped',
        addressLine: 'Taiz - Jamal St.',
        deliveryName: 'Zain',
        deliveryPhone: '+9677xxxxxxx',
        details: const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'Classic Hoodie',
              subtitle: 'Black, XL',
              quantity: 1,
              unitPrice: 10000,
            ),
            OrderDetailsItem(
              title: 'Urban Sneakers',
              subtitle: 'White, 42',
              quantity: 1,
              unitPrice: 8000,
            ),
            OrderDetailsItem(
              title: 'Daily Cap',
              subtitle: 'Gray',
              quantity: 1,
              unitPrice: 4500,
            ),
          ],
          subtotal: 22500,
          shippingFee: 2000,
          shippingMethodKey: Tk.cartShippingExpressTitle,
          paymentMethodKey: Tk.cartPaymentCodTitle,
          deliveryName: 'Zain Al-Hakimi',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'Jamal Street, Taiz, Yemen',
        ),
      ),
      OrderModel(
        id: 'ORD-10212',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        total: 9800,
        itemsCount: 1,
        status: 'delivered',
        addressLine: 'Taiz - Al Rawdha',
        details: const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'Minimal Leather Bag',
              subtitle: 'Brown',
              quantity: 1,
              unitPrice: 9800,
            ),
          ],
          subtotal: 9800,
          shippingFee: 0,
          shippingMethodKey: Tk.cartShippingStandardTitle,
          paymentMethodKey: Tk.cartPaymentWalletTitle,
          deliveryName: 'Zain Al-Hakimi',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'Al Rawdha District, Taiz, Yemen',
        ),
      ),
      OrderModel(
        id: 'ORD-10188',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        total: 15500,
        itemsCount: 2,
        status: 'canceled',
        details: const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'Sport T-Shirt',
              subtitle: 'Blue, L',
              quantity: 2,
              unitPrice: 7000,
            ),
          ],
          subtotal: 14000,
          shippingFee: 1500,
          shippingMethodKey: Tk.cartShippingStandardTitle,
          paymentMethodKey: Tk.cartPaymentCodTitle,
          deliveryName: 'Zain Al-Hakimi',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'Taiz, Yemen',
        ),
      ),
    ];
  }

  OrderDetailsModel buildOrderDetails(OrderModel order) {
    if (order.details != null) return order.details!;

    switch (order.id) {
      case 'ORD-10241':
        return const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'Classic Hoodie',
              subtitle: 'Black, XL',
              quantity: 1,
              unitPrice: 10000,
            ),
            OrderDetailsItem(
              title: 'Urban Sneakers',
              subtitle: 'White, 42',
              quantity: 1,
              unitPrice: 8000,
            ),
            OrderDetailsItem(
              title: 'Daily Cap',
              subtitle: 'Gray',
              quantity: 1,
              unitPrice: 4500,
            ),
          ],
          subtotal: 22500,
          shippingFee: 2000,
          shippingMethodKey: Tk.cartShippingExpressTitle,
          paymentMethodKey: Tk.cartPaymentCodTitle,
          deliveryName: 'Zain Al-Hakimi',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'Jamal Street, Taiz, Yemen',
        );
      case 'ORD-10212':
        return const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'Minimal Leather Bag',
              subtitle: 'Brown',
              quantity: 1,
              unitPrice: 9800,
            ),
          ],
          subtotal: 9800,
          shippingFee: 0,
          shippingMethodKey: Tk.cartShippingStandardTitle,
          paymentMethodKey: Tk.cartPaymentWalletTitle,
          deliveryName: 'Zain Al-Hakimi',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'Al Rawdha District, Taiz, Yemen',
        );
      default:
        return const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'Sport T-Shirt',
              subtitle: 'Blue, L',
              quantity: 2,
              unitPrice: 7000,
            ),
          ],
          subtotal: 14000,
          shippingFee: 1500,
          shippingMethodKey: Tk.cartShippingStandardTitle,
          paymentMethodKey: Tk.cartPaymentCodTitle,
          deliveryName: 'Zain Al-Hakimi',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'Taiz, Yemen',
        );
    }
  }

  /// هذه الدالة تقوم بفلترة الطلبات بناءً على الفلتر المختار.
  List<OrderModel> filterOrders({
    required List<OrderModel> orders,
    required OrdersFilter filter,
  }) {
    if (filter == OrdersFilter.all) {
      return orders;
    }

    if (filter == OrdersFilter.active) {
      return orders
          .where((o) => !['delivered', 'canceled'].contains(o.status))
          .toList();
    }

    if (filter == OrdersFilter.delivered) {
      return orders.where((o) => o.status == 'delivered').toList();
    }

    return orders.where((o) => o.status == 'canceled').toList();
  }

  /// هذه الدالة تبني خطوات التتبع المناسبة حسب حالة الطلب الحالية.
  ///
  /// نستخدمها في شاشة تتبع الطلب لعرض الخط الزمني المناسب.
  List<OrderStatusStep> buildTrackingSteps(OrderModel order) {
    final steps = <OrderStatusStep>[
      const OrderStatusStep(
        key: 'pending',
        title: Tk.ordersTimelinePending,
      ),
      const OrderStatusStep(
        key: 'confirmed',
        title: Tk.ordersTimelineConfirmed,
      ),
      const OrderStatusStep(
        key: 'shipped',
        title: Tk.ordersTimelineShipped,
      ),
      const OrderStatusStep(
        key: 'delivered',
        title: Tk.ordersTimelineDelivered,
      ),
    ];

    if (order.status == 'canceled') {
      return const [
        OrderStatusStep(
          key: 'pending',
          title: Tk.ordersTimelinePending,
        ),
        OrderStatusStep(
          key: 'canceled',
          title: Tk.ordersTimelineCanceled,
          subtitle: Tk.ordersTimelineCanceledSubtitle,
        ),
      ];
    }

    return steps;
  }
}
