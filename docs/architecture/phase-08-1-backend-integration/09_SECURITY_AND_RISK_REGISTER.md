# Phase 08.1 — Architectural Document 09: Security & Risk Register

## 1. Security Threat Model & Mitigations

| Risk ID | Vulnerability Vector | Severity | Mitigation Architecture | Verification Method | Status |
|---|---|---|---|---|---|
| **SEC-081-01** | Price Tampering (Client sends manipulated total) | **P0 (Critical)** | Authoritative server recalculation. Expected grand total matched against server calculation with 0.05 tolerance. | `CustomerOrdersApiTest::test_price_mismatch` | **CLOSED** |
| **SEC-081-02** | Inventory Overselling (Concurrent race condition) | **P0 (Critical)** | InnoDB pessimistic locking (`lockForUpdate`) inside DB transaction. | `ConcurrencyAndTransactionSafetyTest::race_condition` | **CLOSED** |
| **SEC-081-03** | Order Duplication (Network retry / double tap) | **P0 (Critical)** | Server-side `idempotent_requests` table keyed by user and UUID. Duplicate replay returns cached response. | `ConcurrencyAndTransactionSafetyTest::idempotency` | **CLOSED** |
| **SEC-081-04** | Deadlock under High Concurrent Multi-Item Checkout | **P1 (High)** | Ascending sort on `product_variation_id` before lock acquisition. | `ConcurrencyAndTransactionSafetyTest::deadlock` | **CLOSED** |
| **SEC-081-05** | Unauthorized Address Exploitation (Bypassing coverage/tenant) | **P1 (High)** | Address ownership strictly verified against authenticated user (`$customer->addresses()->find(...)`). | `CartQuoteApiTest::test_cross_customer_address` | **CLOSED** |
| **SEC-081-06** | Coupon Stacking & Abuse | **P1 (High)** | Enforced `min_spend`, `max_discount` ceiling, and usage limit counted against orders table. | `CartQuoteApiTest::test_coupon_rules` | **CLOSED** |
| **SEC-081-07** | Fraudulent Receipt URL Injection | **P1 (High)** | Strict validation requiring receipt URL to reside in `temporary/images/`. | `CustomerOrdersApiTest::test_bad_receipt` | **CLOSED** |
| **SEC-081-08** | Duplicate Receipt Re-use across Orders | **P1 (High)** | Query on `manual_payment_details->receipt_image_url` rejects previously used slips. | `CustomerOrdersApiTest::test_reused_receipt` | **CLOSED** |
| **SEC-081-09** | Double Order Cancellation | **P2 (Medium)** | Status checks allow cancellation only for `order_placed` or `confirmed`. Duplicate returns 409. | `CustomerOrdersApiTest::test_cancel` | **CLOSED** |
| **SEC-081-10** | Stale Idempotency Lock Hangs | **P2 (Medium)** | 120-second timeout with atomic Compare-And-Swap (CAS) lock reclamation. | `ConcurrencyAndTransactionSafetyTest::stale_lock` | **CLOSED** |

---

## 2. OWASP API Security Top 10 Compliance Check

- **API1:2023 Broken Object Level Authorization (BOLA)**: Passed. Orders and addresses verified against `$request->user()->id`.
- **API2:2023 Broken Authentication**: Passed. Sanctum tokens with automatic teardown on 401.
- **API3:2023 Broken Object Property Level Authorization**: Passed. Eloquent Resource transformations hide internal costs, merchant margins, and administrative keys.
- **API4:2023 Unrestricted Resource Consumption**: Passed. Limits capped at 50 per page, payload sizes validated.
- **API6:2023 Server Side Request Forgery (SSRF)**: Passed. Receipt URLs validated strictly against internal temporary storage paths.

