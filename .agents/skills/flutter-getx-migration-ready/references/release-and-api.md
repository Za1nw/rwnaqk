# Laravel API integration and fast-release protocol

## Short deadline mode

- Scope: existing Flutter UI + GetX; keep it. Prioritize backend connection and completed checkout flow over architecture polish.
- Day 1: inventory API contracts and client-side placeholder data. Confirm how checkout works (COD, bank transfer, online), address and auth requirements.
- Day 2: shared Dio client; standardized error parser; authentication and environment config.
- Days 3–5: products, search if essential, auth, cart, shipping endpoints. Work with contracts/mocks if backend work is concurrent.
- Days 6–8: order preview, submit, idempotency and order status. Run genuine test orders against isolated test data.
- Days 9–11: test failure modes, preserve carts, secure credentials, regression and performance.
- Remaining days: fix critical bugs, freeze scope, build/release and submit for review. Store review timelines outside app control.

Do not promise a date if Laravel core or production accounts are not ready.

## HTTP contracts

Before writing Retrofit/Dio models:
1. Read Laravel route definitions and actual JSON responses, including errors and pagination.
2. Check versions of API endpoints and naming; avoid assumptions about `/api/v1`.
3. Check authentication (Sanctum or existing), bearer/cookie conventions, 401 refresh/logout, and 422 validation fields.
4. Confirm API error encoding, pagination metadata, currency minor units, image URLs, shipping options, discounts and stock representation.
5. Build pure DTO mappers in `data/`; use domain models in controllers.

## Sample endpoint list (PROPOSED ONLY, never assumed to exist)

```text
GET    /api/v1/products
GET    /api/v1/products/{id}
GET    /api/v1/categories
GET    /api/v1/cart
POST   /api/v1/cart/items
PATCH  /api/v1/cart/items/{id}
DELETE /api/v1/cart/items/{id}
POST   /api/v1/orders/preview
POST   /api/v1/orders
GET    /api/v1/orders
```

## Operational acceptance

Release candidate must demonstrate: catalog -> cart -> address/shipping -> server quote -> order submission -> server order confirmation -> order detail. Protect against duplicate orders and backend validation errors. For a physical goods store, acceptable payment modes depend on actual merchant policy and app store requirements; do not invent them.
