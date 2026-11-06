import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بمنظومة الطلبات.
class OrdersService {
  /// قائمة طلبات تجريبية بأحدث البيانات والمنتجات
  List<OrderModel> seedMockOrders() {
    return [
      OrderModel(
        id: 'ORD-10241',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        total: 24500,
        itemsCount: 3,
        status: 'shipped',
        addressLine: 'صنعاء - حدة، شارع الستين',
        deliveryName: 'أحمد الحكيمي',
        deliveryPhone: '+967 770 245 819',
        details: const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'هودي كلاسيكي مخملي راقي',
              subtitle: 'أسود ملكي، XL',
              quantity: 1,
              unitPrice: 12000,
            ),
            OrderDetailsItem(
              title: 'حذاء سنيكرز جلدي عصري',
              subtitle: 'أبيض ناصع، 42',
              quantity: 1,
              unitPrice: 8000,
            ),
            OrderDetailsItem(
              title: 'قبعة كاجوال مطرزة',
              subtitle: 'رمادي داكن',
              quantity: 1,
              unitPrice: 4500,
            ),
          ],
          subtotal: 24500,
          shippingFee: 0,
          shippingMethodKey: Tk.cartShippingExpressTitle,
          paymentMethodKey: Tk.cartPaymentCodTitle,
          deliveryName: 'أحمد الحكيمي',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'صنعاء - حدة، شارع الستين، بالقرب من مركز الكميم',
        ),
      ),
      OrderModel(
        id: 'ORD-10228',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        total: 18000,
        itemsCount: 2,
        status: 'pending',
        addressLine: 'عدن - خور مكسر',
        deliveryName: 'أحمد الحكيمي',
        deliveryPhone: '+967 770 245 819',
        details: const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'فستان سهرة كريب مطرز',
              subtitle: 'عنابي ملكي، M',
              quantity: 1,
              unitPrice: 15000,
            ),
            OrderDetailsItem(
              title: 'حقيبة كلاتش مخملية',
              subtitle: 'ذهبي فاخر',
              quantity: 1,
              unitPrice: 3000,
            ),
          ],
          subtotal: 18000,
          shippingFee: 0,
          shippingMethodKey: Tk.cartShippingStandardTitle,
          paymentMethodKey: Tk.cartPaymentCodTitle,
          deliveryName: 'أحمد الحكيمي',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'عدن - خور مكسر، حي السفارات',
        ),
      ),
      OrderModel(
        id: 'ORD-10212',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        total: 19500,
        itemsCount: 1,
        status: 'delivered',
        addressLine: 'تعز - شارع جمال',
        deliveryName: 'أحمد الحكيمي',
        deliveryPhone: '+967 770 245 819',
        details: const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'حقيبة يد جلدية فاخرة رَوْنَقُك',
              subtitle: 'بني عسلي طبيعي',
              quantity: 1,
              unitPrice: 19500,
            ),
          ],
          subtotal: 19500,
          shippingFee: 0,
          shippingMethodKey: Tk.cartShippingStandardTitle,
          paymentMethodKey: Tk.cartPaymentWalletTitle,
          deliveryName: 'أحمد الحكيمي',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'تعز - شارع جمال، مجمع السلام التجاري',
        ),
      ),
      OrderModel(
        id: 'ORD-10188',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        total: 15500,
        itemsCount: 2,
        status: 'canceled',
        addressLine: 'صنعاء - الصافية',
        details: const OrderDetailsModel(
          items: [
            OrderDetailsItem(
              title: 'تيشيرت قطن ممشط فاخر',
              subtitle: 'كحلي داكن، L',
              quantity: 2,
              unitPrice: 7000,
            ),
          ],
          subtotal: 14000,
          shippingFee: 1500,
          shippingMethodKey: Tk.cartShippingStandardTitle,
          paymentMethodKey: Tk.cartPaymentCodTitle,
          deliveryName: 'أحمد الحكيمي',
          deliveryPhone: '+967 770 245 819',
          addressLine: 'صنعاء - الصافية، جوار حديقة السبعين',
        ),
      ),
    ];
  }

  /// فلترة الطلبات حسب التبويب المختار
  List<OrderModel> filterOrders({
    required List<OrderModel> orders,
    required OrdersFilter filter,
  }) {
    switch (filter) {
      case OrdersFilter.all:
        return orders;
      case OrdersFilter.active:
        return orders
            .where((o) => !['delivered', 'canceled'].contains(o.status))
            .toList();
      case OrdersFilter.delivered:
        return orders.where((e) => e.status == 'delivered').toList();
      case OrdersFilter.canceled:
        return orders.where((e) => e.status == 'canceled').toList();
    }
  }

  /// بناء خطوات التتبع الزمني للطلب
  List<OrderStatusStep> buildTrackingSteps(OrderModel order) {
    final now = order.createdAt;

    if (order.status == 'canceled') {
      return [
        OrderStatusStep(
          key: 'pending',
          title: Tk.ordersTimelinePending,
          time: now,
        ),
        OrderStatusStep(
          key: 'canceled',
          title: Tk.ordersTimelineCanceled,
          subtitle: Tk.ordersTimelineCanceledSubtitle,
          time: now.add(const Duration(minutes: 45)),
        ),
      ];
    }

    return [
      OrderStatusStep(
        key: 'pending',
        title: Tk.ordersTimelinePending,
        time: now,
      ),
      OrderStatusStep(
        key: 'confirmed',
        title: Tk.ordersTimelineConfirmed,
        time: now.add(const Duration(hours: 1)),
      ),
      OrderStatusStep(
        key: 'shipped',
        title: Tk.ordersTimelineShipped,
        time: order.status == 'shipped' || order.status == 'delivered'
            ? now.add(const Duration(hours: 3))
            : null,
      ),
      OrderStatusStep(
        key: 'delivered',
        title: Tk.ordersTimelineDelivered,
        time: order.status == 'delivered'
            ? now.add(const Duration(days: 1, hours: 2))
            : null,
      ),
    ];
  }

  /// بناء تفاصيل الطلب الاحتياطية في حال لم تكن معبأة
  OrderDetailsModel buildOrderDetails(OrderModel order) {
    if (order.details != null) {
      return order.details!;
    }

    return OrderDetailsModel(
      items: [
        OrderDetailsItem(
          title: 'منتج من رَوْنَقُك',
          subtitle: 'طلب رقم ${order.id}',
          quantity: order.itemsCount,
          unitPrice:
              order.total / (order.itemsCount <= 0 ? 1 : order.itemsCount),
        ),
      ],
      subtotal: order.total,
      shippingFee: 0,
      shippingMethodKey: Tk.cartShippingStandardTitle,
      paymentMethodKey: Tk.cartPaymentCodTitle,
      deliveryName: order.deliveryName ?? 'أحمد الحكيمي',
      deliveryPhone: order.deliveryPhone ?? '+967 770 245 819',
      addressLine: order.addressLine ?? 'صنعاء، اليمن',
    );
  }
}
