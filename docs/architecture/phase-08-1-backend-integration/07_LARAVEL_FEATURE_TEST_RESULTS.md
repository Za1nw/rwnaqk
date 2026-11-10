# Phase 08.1 — Architectural Document 07: Laravel Feature & Concurrency Test Results

## 1. Test Suite Summary

All test suites were executed against local staging using Pest / PHPUnit:

| Test Suite File | Test Count | Assertion Count | Execution Time | Verdict |
|---|---|---|---|---|
| `tests/Feature/Shop/CartQuoteApiTest.php` | 15 tests | 72 assertions | 26.49s | **PASS (100%)** |
| `tests/Feature/Shop/CustomerOrdersApiTest.php` | 12 tests | 63 assertions | 74.34s | **PASS (100%)** |
| `tests/Feature/Shop/ConcurrencyAndTransactionSafetyTest.php` | 8 tests | 36 assertions | 44.87s | **PASS (100%)** |
| `tests/Feature/Shop/PublicCatalogApiTest.php` | 15 tests | 127 assertions | 4.74s | **PASS (100%)** |
| **Total Backend Shop Feature Suite** | **50 tests** | **298 assertions** | **150.44s** | **ALL PASSED** |

---

## 2. Test Cases Breakdown

### 2.1 CartQuoteApiTest (15/15 Passed)
1. `it rejects unauthenticated requests to cart quote endpoints with 401`
2. `it validates required fields for cart quote request with 422`
3. `it rejects quote request when items array is empty or lacks variation/product id`
4. `it strictly rejects address belonging to another customer with 422`
5. `it calculates accurate unit prices, product discounts, line totals, and grand total`
6. `it automatically deduplicates and merges repeated product variations in cart items`
7. `it rejects quote request containing draft, unpublished, or soft-deleted products with 422`
8. `it applies valid coupon with percentage discount up to cap correctly in quote`
9. `it rejects coupon when net subtotal is below minimum spend requirement without failing quote`
10. `it enforces coupon per-customer usage limit against orders table`
11. `it handles invalid coupon code gracefully without breaking quote calculation`
12. `it handles out-of-coverage address gracefully with is_serviceable false`
13. `it validates coupon successfully via standalone validate-coupon endpoint`
14. `it returns 422 for invalid coupon on standalone validate-coupon endpoint`
15. `it returns 422 on standalone validate-coupon endpoint when subtotal is below minimum spend`

### 2.2 CustomerOrdersApiTest (12/12 Passed)
1. `it rejects unauthenticated requests to customer orders endpoints with 401`
2. `it creates a cash on delivery order successfully, deducts stock atomically, and logs initial update`
3. `it creates a wallet payment order with verified receipt image and preserves unpaid status until admin approval`
4. `it rejects wallet order when receipt image is missing or was reused in another order`
5. `it enforces idempotency and returns identical cached response on repeated request without duplicate stock deduction`
6. `it rejects reusing the same idempotency key with different payload with 409 conflict`
7. `it rejects order with 409 when requested quantity exceeds available stock and rolls back completely`
8. `it rejects order with 409 when expected_grand_total does not match recalculated server total`
9. `it rejects order when address belongs to another customer with 422`
10. `it lists customer orders with proper pagination and tenant isolation`
11. `it shows customer order details and prevents other customers from accessing it with 404`
12. `it cancels customer order, restores stock atomically once only, and rejects double cancellation`

### 2.3 ConcurrencyAndTransactionSafetyTest (8/8 Passed)
1. `it verifies real MySQL connection and InnoDB storage engine for transactional safety`
2. `it prevents overselling when two customers race to purchase the last item on MySQL`
3. `it enforces crash-safe atomic commit where business impact and idempotency result commit together`
4. `it enforces idempotency replay on repeated request and returns identical cached response with 200 OK`
5. `it rejects key reuse with different payload with 409 conflict on MySQL`
6. `it recovers from stale pending idempotency lock after simulated worker crash`
7. `it cancels order and restores stock atomically on MySQL and rejects double cancellation`
8. `it prevents deadlocks by sorting variation IDs in ascending order during multi-item lock`

