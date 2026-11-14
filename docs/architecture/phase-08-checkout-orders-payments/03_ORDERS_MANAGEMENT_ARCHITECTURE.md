# معمارية إدارة وتتبع الطلبات في Riverpod 3
# Orders Management & Tracking Architecture

## 1. نموذج حالة الطلبات الموثق (OrdersState Structure)

يحتوي `OrdersState` على البيانات التشغيلية لقائمة طلبات المستخدم:
- `orders: List<OrderModel>`: قائمة الطلبات غير القابلة للتعديل المباشر.
- `status: OrdersStatus`: آلة الحالة (`initial`, `loading`, `loaded`, `error`).
- `filter: OrdersFilter`: فلتر العرض النشط (`all`, `active`, `delivered`, `canceled`).
- `activeUserId: String?`: معرّف المستخدم المالك للجلسة.
- `sessionGeneration: int`: رقم جيل الجلسة لمنع أي تسريب بين المستخدمين.

---

## 2. آلة التصفية الذكية (Smart Filter Logic)

توفر خاصية `filteredOrders` تصفية فورية وسلسة دون تكرار نداءات الشبكة:

```dart
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
```

---

## 3. دورة حياة إلغاء الطلب (Order Cancellation Lifecycle)

عند قيام العميل بإلغاء طلب مؤهل (مثلاً بحالة `pending` أو `processing`):
1. يستدعي `ordersProvider.notifier.cancelOrder(orderId)`.
2. يتم إرسال طلب `POST /api/v1/customer/orders/{id}/cancel` إلى خادم Laravel.
3. يعيد الخادم كائن `OrderModel` المحدث بحالة `cancelled`.
4. يقوم `OrdersNotifier` بتحديث السجل محلياً في مصفوفة `orders` بشكل غير قابل للتعديل المباشر (Immutable Replacement)، مما يعكس الحالة فوراً في شاشة تتبع الطلبات وقائمة الطلبات دون الحاجة لإعادة جلب القائمة كاملة.

