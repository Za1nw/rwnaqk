# عقود الاتصال مع واجهات Laravel API
# Laravel API Contracts & Payload Documentation

**المرحلة:** Phase 07 Cart Migration  
**نقاط النهاية:** `/api/v1/customer/cart/quote`, `/api/v1/customer/cart/validate-coupon`

---

## 1. عقد طلب عرض السعر (Cart Quote API)

- **المسار:** `POST /api/v1/customer/cart/quote`
- **الرؤوس (Headers):**
  - `Accept: application/json`
  - `Authorization: Bearer <customer_token>` (إذا كان مسجلاً)
  - `X-Session-Generation: <int>`

### هيكل الطلب (Request Payload)
```json
{
  "address_id": 101,
  "items": [
    {
      "product_id": 10,
      "product_variation_id": 105,
      "qty": 2
    },
    {
      "product_id": 20,
      "qty": 1
    }
  ],
  "coupon_code": "WELCOME",
  "shipping_option_id": "standard"
}
```

### هيكل الاستجابة الناجحة (Response Payload - 200 OK)
```json
{
  "status": "success",
  "data": {
    "currency": "YER",
    "currency_symbol": "ر.ي",
    "is_serviceable": true,
    "address_id": 101,
    "items": [
      {
        "product_id": 10,
        "product_variation_id": 105,
        "name": "عباية مخملية ملكية",
        "sku": "ABY-BLK-54",
        "qty": 2,
        "unit_price": 200.0,
        "unit_discount": 20.0,
        "effective_unit_price": 180.0,
        "line_subtotal": 400.0,
        "line_product_discount": 40.0,
        "line_total": 360.0
      }
    ],
    "subtotal": 750.0,
    "product_discount_total": 40.0,
    "net_subtotal": 710.0,
    "coupon_code": "WELCOME",
    "coupon_discount_total": 50.0,
    "shipping_fee": 25.0,
    "grand_total": 685.0,
    "shipping_options": [
      {
        "id": "standard",
        "title": "شحن قياسي",
        "fee": 25.0,
        "formatted_fee": "25 ر.ي",
        "eta": "2-4 أيام"
      }
    ],
    "selected_shipping_option": {
      "id": "standard",
      "title": "شحن قياسي",
      "fee": 25.0,
      "formatted_fee": "25 ر.ي"
    },
    "message": null
  }
}
```

---

## 2. عقد التحقق من الكوبون (Coupon Validation API)

- **المسار:** `POST /api/v1/customer/cart/validate-coupon`
- **هيكل الطلب:**
```json
{
  "coupon_code": "WELCOME",
  "subtotal": 750.0
}
```
- **هيكل الاستجابة:**
```json
{
  "status": "success",
  "data": {
    "is_valid": true,
    "discount_type": "percentage",
    "discount_value": 15,
    "discount_amount": 50.0,
    "message": "تم تطبيق الخصم بنجاح"
  }
}
```

