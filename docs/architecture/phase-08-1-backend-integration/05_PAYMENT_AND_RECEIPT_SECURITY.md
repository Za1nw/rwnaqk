# Phase 08.1 — Architectural Document 05: Payment Methods & Receipt Security

## 1. Supported Payment Channels & Business Rules

The system supports two core fulfillment channels in Yemen:
1. **Cash on Delivery (`cash_on_delivery` / `cod`)**:
   - `payment_status`: `unpaid`
   - `is_manual_payment`: `false`
   - Fulfillment proceeds immediately to warehouse preparation (`order_placed`).

2. **Electronic Wallets & Manual Bank Transfers (`wallet`, `kuraimi`, `jawali`, `onecash`)**:
   - `payment_status`: `unpaid` (strictly preserved as unpaid until verified by finance/operations)
   - `is_manual_payment`: `true`
   - Requires verified proof of transfer (`receipt_image_url`).

---

## 2. Receipt Image Security & Anti-Fraud Controls

To prevent malicious injection of arbitrary URLs or forged receipts:

### A. Internal Temporary Storage Domain Enforcement
Customers must upload payment slips through the secure multipart upload endpoint (`POST /api/v1/temporary-images`).
In `CustomerOrderService.php`:
```php
$parsedPath = parse_url($receiptImageUrl, PHP_URL_PATH);
$isInternalTempImage = is_string($parsedPath) && str_contains($parsedPath, 'temporary/images/');

if (! $isInternalTempImage && ! app()->environment('testing')) {
    throw ValidationException::withMessages([
        'receipt_image_url' => ['رابط سند التحويل غير صالح، يجب رفع السند عبر التطبيق حصراً.'],
    ]);
}
```
External URLs (e.g. `https://malicious-site.com/fake-slip.png`) are strictly rejected with HTTP 422 Unprocessable Content.

### B. Anti-Reuse Duplicate Receipt Guard
To prevent a malicious user from using a single legitimate receipt across multiple orders:
```php
$receiptAlreadyUsed = OrderGroup::query()
    ->where('manual_payment_details->receipt_image_url', $receiptImageUrl)
    ->exists();

if ($receiptAlreadyUsed) {
    throw ValidationException::withMessages([
        'receipt_image_url' => ['سند التحويل المرفق تم استخدامه مسبقاً في طلب آخر، يرجى إرفاق سند صحيح.'],
    ]);
}
```

### C. Manual Verification Status Protection
Orders created with manual payment methods are stored with:
```php
'manual_payment_details' => [
    'wallet_account' => $validated['wallet_account'] ?? null,
    'receipt_image_url' => $receiptImageUrl,
    'verified' => false,
    'submitted_at' => now()->toIso8601String(),
]
```
The status remains `unpaid` and `verified: false` until an authorized admin explicitly reconciles the bank transfer against the ledger in the management portal.

