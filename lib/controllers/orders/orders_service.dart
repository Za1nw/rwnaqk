import 'package:rwnaqk/controllers/orders/orders_ui_controller.dart';
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
      ),
      OrderModel(
        id: 'ORD-10212',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        total: 9800,
        itemsCount: 1,
        status: 'delivered',
        addressLine: 'Taiz - Al Rawdha',
      ),
      OrderModel(
        id: 'ORD-10188',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        total: 15500,
        itemsCount: 2,
        status: 'canceled',
      ),
    ];
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
        title: 'تم استلام الطلب',
      ),
      const OrderStatusStep(
        key: 'confirmed',
        title: 'تم تأكيد الطلب',
      ),
      const OrderStatusStep(
        key: 'shipped',
        title: 'خرج للتوصيل',
      ),
      const OrderStatusStep(
        key: 'delivered',
        title: 'تم التسليم',
      ),
    ];

    if (order.status == 'canceled') {
      return const [
        OrderStatusStep(
          key: 'pending',
          title: 'تم استلام الطلب',
        ),
        OrderStatusStep(
          key: 'canceled',
          title: 'تم إلغاء الطلب',
          subtitle: 'تم الإلغاء من قبل المستخدم/النظام',
        ),
      ];
    }

    return steps;
  }
}