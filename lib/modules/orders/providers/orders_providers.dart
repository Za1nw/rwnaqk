import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_service.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/models/orders_state.dart';

export 'package:rwnaqk_frontend/modules/orders/models/orders_state.dart';

/// متحكم حالة الطلبات الموثق في Riverpod 3 [OrdersNotifier]
class OrdersNotifier extends Notifier<OrdersState> {
  IOrdersRepository get _repo => ref.read(ordersRepositoryProvider);

  /// عداد تعريفي لتسلسل طلبات التحميل لضمان عدم كتابة استجابة قديمة فوق استجابة أحدث
  int _activeRequestId = 0;

  @override
  OrdersState build() {
    return const OrdersState();
  }

  /// التحقق من أن طلب التحميل غير المتزامن ما زال صالحاً ولم تنتهِ صلاحيته بسبب تغير الجلسة أو تداخل الطلبات
  /// يعتمد على ref.mounted للتحقق الصريح من بقاء Notifier حياً دون كتم أو التقاط صامت للاستثناءات
  bool _isRequestValid(int requestId, int requestSessionGeneration) {
    if (!ref.mounted) {
      return false;
    }
    final currentSession = ref.read(authSessionProvider);
    return currentSession.isAuthenticated &&
        !currentSession.isGuest &&
        currentSession.sessionGeneration == requestSessionGeneration &&
        requestId == _activeRequestId;
  }

  /// تغيير فلتر العرض
  void setFilter(OrdersFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// تحميل الطلبات من المستودع المعتمد (مع الحماية الدفاعية الصارمة ضد استدعاءات الزائر وغير المسجل وسباق العمليات غير المتزامنة)
  Future<void> loadOrders({bool refresh = false}) async {
    final session = ref.read(authSessionProvider);
    if (!session.isAuthenticated || session.isGuest) {
      // الدفاع الموضعي: منع إرسال API Requests أو تعبئة Mock Orders للزائر أو غير الموثق
      if (state.orders.isNotEmpty || state.status != OrdersStatus.initial) {
        state = const OrdersState();
      }
      return;
    }

    final requestId = ++_activeRequestId;
    final requestSessionGen = session.sessionGeneration;

    if (AppEnv.enableMockData) {
      if (state.orders.isEmpty || refresh) {
        final service = OrdersService();
        state = state.copyWith(
          orders: service.seedMockOrders(),
          status: OrdersStatus.loaded,
        );
      }
      return;
    }

    state = state.copyWith(
      status: OrdersStatus.loading,
      errorMessage: () => null,
    );

    try {
      final list = await _repo.getOrders();
      if (!_isRequestValid(requestId, requestSessionGen)) {
        return;
      }
      state = state.copyWith(
        orders: list,
        status: OrdersStatus.loaded,
        errorMessage: () => null,
      );
    } catch (e) {
      if (!_isRequestValid(requestId, requestSessionGen)) {
        return;
      }
      debugPrint('[OrdersNotifier.loadOrders] error: $e');
      state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: () => e.toString(),
      );
    }
  }

  /// إضافة طلب جديد محلياً في قائمة الذاكرة بعد تأكيد الشراء
  void addOrder(OrderModel order) {
    final updated = List<OrderModel>.from(state.orders)..insert(0, order);
    state = state.copyWith(
      orders: updated,
      filter: OrdersFilter.all,
      status: OrdersStatus.loaded,
    );
  }

  /// إلغاء طلب من قبل العميل
  Future<bool> cancelOrder(String orderId) async {
    final session = ref.read(authSessionProvider);
    final requestSessionGen = session.sessionGeneration;

    state = state.copyWith(status: OrdersStatus.loading);
    try {
      final updatedOrder = await _repo.cancelOrder(orderId);
      if (!ref.mounted) {
        return false;
      }
      final currentSession = ref.read(authSessionProvider);
      if (!currentSession.isAuthenticated ||
          currentSession.isGuest ||
          currentSession.sessionGeneration != requestSessionGen) {
        return false;
      }
      final updatedList = state.orders.map((o) {
        if (o.id == orderId) return updatedOrder;
        return o;
      }).toList();

      state = state.copyWith(
        orders: updatedList,
        status: OrdersStatus.loaded,
        errorMessage: () => null,
      );
      return true;
    } catch (e) {
      if (!ref.mounted) {
        return false;
      }
      final currentSession = ref.read(authSessionProvider);
      if (!currentSession.isAuthenticated ||
          currentSession.isGuest ||
          currentSession.sessionGeneration != requestSessionGen) {
        return false;
      }
      state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  /// مزامنة حالة الطلبات مع حدود الجلسة (عزل تام لمنع تسريب طلبات مستخدم لآخر)
  void syncWithSession({
    required String? userId,
    required int generation,
  }) {
    _activeRequestId++;
    if (userId == null ||
        userId != state.activeUserId ||
        generation != state.sessionGeneration) {
      state = OrdersState(
        activeUserId: userId,
        sessionGeneration: generation,
      );
      try {
        _repo.clearLocalCache();
      } catch (_) {}
    }
  }

  /// تفريغ قائمة الطلبات بالكامل والكاش المحلي
  void clear() {
    _activeRequestId++;
    state = const OrdersState();
    try {
      _repo.clearLocalCache();
    } catch (_) {}
  }
}

/// موفر قائمة الطلبات المركزي المعتمد [ordersProvider]
final ordersProvider =
    NotifierProvider<OrdersNotifier, OrdersState>(OrdersNotifier.new);

/// موفر قائمة الطلبات المفلترة
final filteredOrdersProvider = Provider<List<OrderModel>>((ref) {
  return ref.watch(ordersProvider).filteredOrders;
});

/// موفر إجمالي عدد الطلبات
final ordersCountProvider = Provider<int>((ref) {
  return ref.watch(ordersProvider).orders.length;
});

