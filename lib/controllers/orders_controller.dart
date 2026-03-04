import 'package:get/get.dart';
import '../models/order_model.dart';

enum OrdersFilter { all, active, delivered, canceled }

class OrdersController extends GetxController {
  final filter = OrdersFilter.all.obs;

  /// بيانات وهمية (بدّلها لاحقًا بـ API)
  final orders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedMock();
  }

  void setFilter(OrdersFilter f) => filter.value = f;

  List<OrderModel> get filteredOrders {
    final f = filter.value;
    if (f == OrdersFilter.all) return orders;

    if (f == OrdersFilter.active) {
      return orders.where((o) => !['delivered', 'canceled'].contains(o.status)).toList();
    }

    if (f == OrdersFilter.delivered) {
      return orders.where((o) => o.status == 'delivered').toList();
    }

    return orders.where((o) => o.status == 'canceled').toList();
  }

  /// خطوات التتبع (على حسب status)
  List<OrderStatusStep> buildTrackingSteps(OrderModel o) {
    // ترتيب الخطوات القياسية
    final steps = <OrderStatusStep>[
      const OrderStatusStep(key: 'pending', title: 'تم استلام الطلب'),
      const OrderStatusStep(key: 'confirmed', title: 'تم تأكيد الطلب'),
      const OrderStatusStep(key: 'shipped', title: 'خرج للتوصيل'),
      const OrderStatusStep(key: 'delivered', title: 'تم التسليم'),
    ];

    // لو ملغي
    if (o.status == 'canceled') {
      return [
        const OrderStatusStep(key: 'pending', title: 'تم استلام الطلب'),
        const OrderStatusStep(key: 'canceled', title: 'تم إلغاء الطلب', subtitle: 'تم الإلغاء من قبل المستخدم/النظام'),
      ];
    }

    return steps;
  }

  void _seedMock() {
    orders.assignAll([
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
    ]);
  }
}