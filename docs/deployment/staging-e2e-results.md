# Real End-to-End Acceptance Results on Staging — Phase 5.1

**Project:** Rwnaqk E-Commerce Platform (متجر رونقك الإلكتروني)  
**Date:** 2026-11-09  
**DevOps Engineer:** Senior Laravel 13 DevOps Engineer & Flutter Release Specialist  
**Test Harness:** Real HTTP/cURL Client against Live Laravel Server (`http://127.0.0.1:8000` / `10.0.2.2:8000`)  
**Target Database:** `rwnaqk_staging` on Docker MySQL 8.x InnoDB (Port 3306)  
**Result:** **15 / 15 TESTS PASSED (100% SUCCESS)**

---

## 1. Execution Log & Verification Evidence

```text
======================================================================
    PHASE 5.1 — REAL HTTP E2E ACCEPTANCE ON STAGING SERVER           
======================================================================
Step 1: Health check (/up)... PASSED (200 OK)
Step 2: Customer Authentication (/api/v1/customer/auth/login)... PASSED (Bearer token acquired)
Step 3: Customer Profile (/api/v1/customer/auth/me)... PASSED (Customer: عميل تجريبي)
Step 4: Public Catalog Categories & Brands... PASSED (Categories & Brands loaded)
Step 5: Product Listing & Details (/api/v1/products)... PASSED (Product ID #3: 'بنطال جينز أسود بقصّة قصة ضيقة وخمسة جيوب')
Step 6: Customer Addresses (/api/v1/customer/addresses)... PASSED (Address ID #3, Serviceable: YES)
Step 7: Server Cart Quote Calculation (/api/v1/customer/cart/quote)... PASSED (Subtotal: 30000, Delivery: 1500, Total: 31500 YER)
Step 8: Scenario A — Cash on Delivery Checkout (/api/v1/customer/orders)... PASSED (OrderGroup #100003 Created, Status: unpaid, Method: cod)
Step 9: Idempotency Replay on Duplicate Submission... PASSED (Cached response returned without duplicate order creation)
Step 10: Scenario B — Wallet Transfer + Temporary Receipt Image... PASSED (OrderGroup #100004 Created with Receipt, Status: unpaid)
Step 11: Security — Malicious External Receipt URL Injection... PASSED (422 Unprocessable Content — External URL rejected!)
Step 12: Order History Listing (/api/v1/customer/orders)... PASSED (Orders in history retrieved successfully)
Step 13: Single Order Details Inspection... PASSED (OrderGroup #100003 verified with tracking & address)
Step 14: Order Cancellation & Inventory Restoration... PASSED (Order #100003 cancelled, inventory safely restored)
Step 15: Double Cancellation Guard... PASSED (409 Conflict — Double cancellation rejected, stock safe)
======================================================================
    ALL 15 REAL E2E ACCEPTANCE STEPS PASSED SUCCESSFULLY ON STAGING! 
======================================================================
```

---

## 2. Database Verification in `rwnaqk_staging`

Direct query to MySQL container:
```sql
SELECT id, order_code, payment_method, payment_status, sub_total_amount, total_shipping_cost, grand_total_amount, is_manual_payment 
FROM rwnaqk_staging.order_groups 
ORDER BY id DESC LIMIT 5;
```

### 2.1 Database State Output
| ID | Order Code | Payment Method | Payment Status | Subtotal (YER) | Delivery (YER) | Grand Total (YER) | Manual Payment |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **5** | `100004` | `wallet` (Kuraimi) | **`unpaid`** | 15,000.00 | 1,500.00 | **16,500.00** | **1** (Receipt Stored) |
| **4** | `100003` | `cash_on_delivery` | **`refunded`** (Cancelled) | 30,000.00 | 1,500.00 | **31,500.00** | 0 |
| **3** | `100002` | `cash_on_delivery` | **`unpaid`** | 30,000.00 | 1,500.00 | **31,500.00** | 0 |
| **2** | `100001` | `wallet` (Kuraimi) | **`unpaid`** | 15,000.00 | 1,500.00 | **16,500.00** | **1** (Receipt Stored) |
| **1** | `100000` | `cash_on_delivery` | **`refunded`** (Cancelled) | 30,000.00 | 1,500.00 | **31,500.00** | 0 |

### 2.2 Inventory Stock Verification
```sql
SELECT id, product_variation_id, location_id, stock_qty 
FROM rwnaqk_staging.product_variation_stocks 
WHERE product_variation_id = 3;
```
- Initial inventory: 50 items.
- Decrement during checkout: deducted 2 items -> 48 items.
- Atomic restoration during cancellation: restored 2 items -> **50 items**.
- Double-cancellation prevented: stock remained strictly at 50 without over-incrementing.

---

## 3. Idempotency & Replay Verification

- **Idempotency Key:** `staging-test-cod-e0050800bba6`
- **First Call:** Returned HTTP 201 Created with order payload.
- **Repeated Call (Replay):** Returned HTTP 200 OK with identical payload and cached body.
- **Payload Tampering Protection:** Attempting to alter order items with the same key threw HTTP 409 Conflict.
- **Stale Lock Recovery (CAS):** 120-second stale locks reclaimed atomically using optimistic timestamp comparison (`where('locked_at', $existing->locked_at)`), preventing worker collision.

---

## 4. Payment Receipt Security & Verification

1. **Approved Temporary Path:** Validated `temporary/images/receipt_test_*.jpg` and stored in `order_groups.manual_payment_details`.
2. **Payment Status Protection:** All wallet orders initialize strictly with `payment_status = 'unpaid'` and require backoffice accounting approval.
3. **Receipt Anti-Reuse:** Re-submitting an already used receipt URL threw HTTP 422 Unprocessable Content (`سند التحويل المرفق تم استخدامه مسبقاً في طلب آخر`).
4. **Malicious External URL:** Supplying an external arbitrary URL (`https://malicious-external-site.com/fake-slip.png`) threw HTTP 422 Unprocessable Content (`رابط سند التحويل غير صالح، يجب رفع السند عبر التطبيق حصراً`).

---

## 5. Acceptance Conclusion

The complete customer purchasing journey, zero-trust server pricing, atomic inventory locking, idempotency replay, receipt security, and order cancellation lifecycle have been verified on real live HTTP endpoints connected to MySQL 8.x InnoDB.

