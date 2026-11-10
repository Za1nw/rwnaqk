# Phase 08.1 — Architectural Document 02: Cart Quote & Coupon Calculation Contracts

## 1. Authoritative Server Calculation Model

Client-side calculations are strictly non-authoritative. The server recalculates all lines, product discounts, coupon reductions, and geographic delivery fees via `CartQuoteEngineService`.

### Processing Sequence
```
Client Request (address_id, items, coupon_code, shipping_option_id)
      │
      ▼
1. Address Validation: verify address belongs to authenticated user and has geographic resolution.
      │
      ▼
2. Item Merging & Verification: merge duplicate variations, check status=true and non-deleted.
      │
      ▼
3. Unit Pricing & Product Discounts: calculate time-bound promotional discounts (percent/fixed).
      │
      ▼
4. Coupon Evaluation: check min_spend, max_discount cap, max_uses_per_user against past orders.
      │
      ▼
5. Logistics & Geographic Delivery Tiers: resolve zone shipping rates via OrderQuoteService.
      │
      ▼
6. Server-Authoritative Grand Total: max(0, netSubtotal - couponDiscount + shippingFee).
```

---

## 2. Request & Response Payload Specifications

### 2.1 Cart Quote Endpoint (`POST /api/v1/customer/cart/quote`)

#### Request Schema
```json
{
  "address_id": 211,
  "items": [
    {
      "product_variation_id": 3,
      "qty": 2
    }
  ],
  "coupon_code": "RAWNAQ",
  "shipping_option_id": "standard"
}
```

#### Successful Response Schema (HTTP 200 OK)
```json
{
  "status": "success",
  "message": "تم احتساب عرض سعر السلة بنجاح.",
  "data": {
    "currency": "YER",
    "currency_symbol": "ر.ي",
    "is_serviceable": true,
    "address_id": 211,
    "items": [
      {
        "product_id": 3,
        "product_variation_id": 3,
        "name": "بنطال جينز أسود بقصّة قصة ضيقة وخمسة جيوب",
        "sku": "SKU-JEANS-003",
        "qty": 2,
        "unit_price": 15000.0,
        "unit_discount": 0.0,
        "effective_unit_price": 15000.0,
        "line_subtotal": 30000.0,
        "line_product_discount": 0.0,
        "line_total": 30000.0
      }
    ],
    "subtotal": 30000.0,
    "product_discount_total": 0.0,
    "net_subtotal": 30000.0,
    "coupon_code": "RAWNAQ",
    "coupon_discount_total": 4500.0,
    "shipping_fee": 1000.0,
    "grand_total": 26500.0,
    "shipping_options": [
      {
        "id": "standard",
        "name": "التوصيل المباشر - صنعاء",
        "zone_name": "أمانة العاصمة",
        "fee": 1000.0,
        "formatted_fee": "1,000 ر.ي",
        "duration_minutes": 35,
        "duration_text": "35 دقيقة تقريباً"
      }
    ],
    "selected_shipping_option": {
      "id": "standard",
      "name": "التوصيل المباشر - صنعاء",
      "zone_name": "أمانة العاصمة",
      "fee": 1000.0,
      "formatted_fee": "1,000 ر.ي",
      "duration_minutes": 35,
      "duration_text": "35 دقيقة تقريباً"
    },
    "message": "تم تفعيل كود الخصم (RAWNAQ) بنجاح (خصم 15%)."
  }
}
```

---

## 3. Coupon Rules & Anti-Abuse Specifications

Active coupons in `CartQuoteEngineService`:

| Coupon Code | Discount % | Minimum Spend | Maximum Cap | Per-User Limit | Notes |
|---|---|---|---|---|---|
| `RAWNAQ` | 15% | 5,000 YER | 10,000 YER | 3 orders | Welcome & active customer discount |
| `RWNAQK` | 15% | 5,000 YER | 10,000 YER | 3 orders | App-wide promotional alias |
| `RWNAQK15` | 15% | 5,000 YER | 10,000 YER | 3 orders | Fixed campaign code |
| `WELCOME` | 20% | 3,000 YER | 5,000 YER | 1 order | New customer first purchase |
| `EID2026` | 10% | 10,000 YER | 15,000 YER | 5 orders | Seasonal holiday promotion |

### Enforcement Mechanisms:
1. **Minimum Spend Check**: If `netSubtotal < min_spend`, coupon discount is 0.0 and a user-friendly guidance message is returned.
2. **Per-User Usage Check**: Enforced via `Order::where('user_id', $customer->id)->where('applied_coupon_code', $code)->count()`.
3. **Discount Ceiling (Cap)**: Disallow discounts exceeding `max_discount` using `min($coupon['max_discount'], $calculatedDiscount)`.

