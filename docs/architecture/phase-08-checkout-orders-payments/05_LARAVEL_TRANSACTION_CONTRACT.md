# مواصفات عقود المعاملات مع خادم Laravel API
# Laravel Transaction & Checkout API Contract Specification

## 1. ملخص الوضع الفعلي لخادم Laravel (`rwnaqk-backend`)

كما تم توثيقه في مراجعة Phase 07.1 الميدانية، فإن مسارات التجارة الإلكترونية المعقدة لم يتم تفعيلها بعد في `routes/api.php` في مستودع الباك إند الحقيقي. 

يقدم هذا المستند العقد المعياري المتوافق بالكامل بين تطبيق فلاتر المحدث وخادم Laravel لضمان سلاسة الربط بمجرد إتاحة المسارات.

---

## 2. عقد إنشاء واعتماد الطلب (`POST /api/v1/customer/orders`)

### ترويسات الطلب (Request Headers):
```http
POST /api/v1/customer/orders HTTP/1.1
Host: api.rawnaqk.com
Authorization: Bearer <customer_sanctum_token>
X-Idempotency-Key: 9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d
Content-Type: application/json
Accept: application/json
```

### جسم الطلب (Request Payload):
```json
{
  "address_id": 10,
  "items": [
    {
      "product_id": 10,
      "product_variation_id": 105,
      "qty": 2
    }
  ],
  "payment_method": "wallet",
  "coupon_code": "RWNAQK15",
  "shipping_option_id": "standard",
  "expected_grand_total": 325.0,
  "wallet_account": {
    "company": "الكريمي - إم فلوس",
    "number": "777000000",
    "name": "متجر رونقك الإلكتروني"
  },
  "receipt_image_url": "https://rwnaqk.com/storage/temporary/images/rec_abc123.jpg",
  "notes": "يرجى الاتصال قبل التوصيل"
}
```

### استجابة الخادم الناجحة (`201 Created`):
```json
{
  "status": true,
  "message": "تم إنشاء الطلب بنجاح وهو قيد المراجعة والتحقق.",
  "data": {
    "id": "10045",
    "order_code": "RW-10045",
    "created_at": "2026-11-09T22:30:00Z",
    "status": "pending",
    "payment_status": "unpaid",
    "payment_method": "wallet",
    "total": 325.0,
    "items_count": 2,
    "shipping_fee": 25.0,
    "coupon_discount": 15.0
  }
}
```

---

## 3. عقد استعراض الطلبات (`GET /api/v1/customer/orders`)

### استجابة الخادم (`200 OK`):
```json
{
  "status": true,
  "data": [
    {
      "id": "10045",
      "order_code": "RW-10045",
      "created_at": "2026-11-09T22:30:00Z",
      "status": "pending",
      "total": 325.0,
      "items_count": 2
    }
  ]
}
```

---

## 4. عقد إلغاء الطلب (`POST /api/v1/customer/orders/{id}/cancel`)

### استجابة الخادم (`200 OK`):
```json
{
  "status": true,
  "message": "تم إلغاء الطلب بنجاح واستعادة المخزون.",
  "data": {
    "id": "10045",
    "order_code": "RW-10045",
    "status": "cancelled",
    "total": 325.0,
    "items_count": 2
  }
}
```

