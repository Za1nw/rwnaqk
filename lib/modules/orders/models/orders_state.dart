import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';

/// أنواع الفلاتر المتاحة لقائمة الطلبات
enum OrdersFilter {
  all,
  active,
  delivered,
  canceled,
}

/// حالات تحميل قائمة الطلبات
enum OrdersStatus {
  initial,
  loading,
  loaded,
  error,
}

/// حالة قائمة وتتبع الطلبات غير القابلة للتغيير المباشر (Immutable Orders State)
@immutable
class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.status = OrdersStatus.initial,
    this.filter = OrdersFilter.all,
    this.errorMessage,
    this.activeUserId,
    this.sessionGeneration = 0,
  });

  /// قائمة كافة الطلبات التابعة للمستخدم المصادق حالياً
  final List<OrderModel> orders;

  /// حالة التحميل
  final OrdersStatus status;

  /// الفلتر المعروض حالياً
  final OrdersFilter filter;

  /// رسالة الخطأ إن وُجدت
  final String? errorMessage;

  /// معرف المستخدم صاحب الجلسة لعزل الحسابات
  final String? activeUserId;

  /// رقم جيل الجلسة
  final int sessionGeneration;

  /// هل جاري تحميل الطلبات؟
  bool get isLoading => status == OrdersStatus.loading;

  /// هل تم تحميل الطلبات بنجاح؟
  bool get isLoaded => status == OrdersStatus.loaded;

  /// هل حدث خطأ أثناء الجلب؟
  bool get isError => status == OrdersStatus.error;

  /// هل قائمة الطلبات فارغة؟
  bool get isEmpty => orders.isEmpty;

  /// قائمة الطلبات المفلترة حسب الفلتر المختار
  List<OrderModel> get filteredOrders {
    if (filter == OrdersFilter.all) return orders;
    return orders.where((o) => _matchesFilter(o, filter)).toList();
  }

  static bool _matchesFilter(OrderModel order, OrdersFilter filter) {
    final s = order.status.toLowerCase();
    switch (filter) {
      case OrdersFilter.all:
        return true;
      case OrdersFilter.active:
        return s == 'processing' ||
            s == 'pending' ||
            s == 'shipped' ||
            s == 'out_for_delivery';
      case OrdersFilter.delivered:
        return s == 'delivered' || s == 'completed';
      case OrdersFilter.canceled:
        return s == 'cancelled' ||
            s == 'canceled' ||
            s == 'refunded' ||
            s == 'failed';
    }
  }

  OrdersState copyWith({
    List<OrderModel>? orders,
    OrdersStatus? status,
    OrdersFilter? filter,
    String? Function()? errorMessage,
    String? Function()? activeUserId,
    int? sessionGeneration,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      status: status ?? this.status,
      filter: filter ?? this.filter,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      activeUserId: activeUserId != null ? activeUserId() : this.activeUserId,
      sessionGeneration: sessionGeneration ?? this.sessionGeneration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdersState &&
          runtimeType == other.runtimeType &&
          listEquals(orders, other.orders) &&
          status == other.status &&
          filter == other.filter &&
          errorMessage == other.errorMessage &&
          activeUserId == other.activeUserId &&
          sessionGeneration == other.sessionGeneration;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(orders),
        status,
        filter,
        errorMessage,
        activeUserId,
        sessionGeneration,
      );
}
