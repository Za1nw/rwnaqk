# Phase 08.1 — Architectural Document 01: Laravel Backend Route & Endpoint Audit

## 1. Executive Summary & Context

During Phase 07.1 and Phase 08, architectural verification revealed that while Flutter had migrated to Riverpod 3.5.0 for cart quoting, checkout workflows, and order state, the backend integration contracts required formalization and real transactional verification against Laravel.

In **Phase 08.1**, a full audit and end-to-end integration of the Laravel modular backend (`Modules/Shop`, `Modules/Customer`, `Modules/Geo`) was completed. All commerce routes are registered, validated, authenticated, and thoroughly verified against an isolated MySQL staging environment.

---

## 2. API Route Inventory & Endpoint Topology

All commerce endpoints reside under the `/api/v1` namespace and are protected by `auth:sanctum` middleware where customer context is mandatory:

| Route Path | HTTP Method | Route Name | Controller Action | Middleware Pipeline | Status & Purpose |
|---|---|---|---|---|---|
| `/api/v1/customer/cart/quote` | `POST` | `api.customer.cart.quote` | `Modules\Shop\Http\Controllers\Api\CartApiController@quote` | `api`, `auth:sanctum` | **Production Ready**: Authoritative server pricing, discounts, tiered shipping calculation |
| `/api/v1/customer/cart/validate-coupon` | `POST` | `api.customer.cart.validate-coupon` | `Modules\Shop\Http\Controllers\Api\CartApiController@validateCoupon` | `api`, `auth:sanctum` | **Production Ready**: Standalone coupon validity check with financial threshold enforcement |
| `/api/v1/customer/orders` | `POST` | `api.customer.orders.store` | `Modules\Shop\Http\Controllers\Api\CustomerOrderApiController@store` | `api`, `auth:sanctum` | **Production Ready**: Transactional order creation, atomic stock lock, idempotency guard |
| `/api/v1/customer/orders` | `GET` | `api.customer.orders.index` | `Modules\Shop\Http\Controllers\Api\CustomerOrderApiController@index` | `api`, `auth:sanctum` | **Production Ready**: Tenant-isolated customer order listing with pagination |
| `/api/v1/customer/orders/{id}` | `GET` | `api.customer.orders.show` | `Modules\Shop\Http\Controllers\Api\CustomerOrderApiController@show` | `api`, `auth:sanctum` | **Production Ready**: Order details inspection, multi-item breakdown & status tracking |
| `/api/v1/customer/orders/{id}/cancel` | `POST` | `api.customer.orders.cancel` | `Modules\Shop\Http\Controllers\Api\CustomerOrderApiController@cancel` | `api`, `auth:sanctum` | **Production Ready**: Customer order cancellation, atomic stock restoration, double-cancel guard |

---

## 3. Route Registration & Middleware Pipeline Verification

The routes are registered in `Modules/Shop/routes/api.php` under explicit route grouping:

```php
Route::prefix('v1/customer')
    ->middleware(['api', 'auth:sanctum'])
    ->name('api.customer.')
    ->group(function () {
        // Cart & Quote
        Route::post('cart/quote', [CartApiController::class, 'quote'])->name('cart.quote');
        Route::post('cart/validate-coupon', [CartApiController::class, 'validateCoupon'])->name('cart.validate-coupon');

        // Customer Orders
        Route::post('orders', [CustomerOrderApiController::class, 'store'])->name('orders.store');
        Route::get('orders', [CustomerOrderApiController::class, 'index'])->name('orders.index');
        Route::get('orders/{id}', [CustomerOrderApiController::class, 'show'])->name('orders.show');
        Route::post('orders/{id}/cancel', [CustomerOrderApiController::class, 'cancel'])->name('orders.cancel');
    });
```

### Security & Isolation Controls
1. **Sanctum Authentication (`auth:sanctum`)**: Rejects unauthenticated requests with HTTP 401 Unauthorized before reaching any controller action.
2. **Tenant Scoping**: All operations bind directly to `$request->user()->id`. Customers cannot inspect, quote, order for, or cancel orders belonging to other users.
3. **Idempotency Header Detection**: Handled in `CustomerOrderApiController@store` supporting standard variants: `X-Idempotency-Key`, `Idempotency-Key`, and lowercase `x-idempotency-key`.

