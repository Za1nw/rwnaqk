---
trigger: model_decision
description: "Use when connecting or changing Flutter calls to Laravel REST endpoints, DTOs, authentication, pagination, caching, networking, or error handling."
---
# Laravel integration contracts — implementation rules

## Discover actual contracts
- Before coding, inspect real Laravel routes/controllers/API resources/OpenAPI or documented responses when available. Record HTTP method, path, auth, request body, response schema, pagination, error format, and version. If backend is unavailable, mark any contract as **proposed** and use replaceable fake data sources for UI work.
- Keep existing public URL paths/JSON field names unless coordinated. Do not invent production endpoints or silently rename fields.
- Use the app's **existing** networking library; prefer a single configured Dio client if already present or approved. Define base URL per environment (dev/staging/prod) outside widgets; never store a secret in the mobile binary.
- Normalize HTTP failures, validation errors (including Laravel 422), 401/403, 404, 429, timeouts, connection errors and 5xx into app-understandable error types. UI must provide actionable retry/feedback without exposing secrets or stack traces.
- Map API DTOs to typed, plain domain models. Handle optional fields, image URL nullability, decimal money representation, pagination cursors/meta, and backward-compatible fields deliberately.
- Auth: use an approved token/session method consistent with the existing backend; store sensitive tokens in secure storage rather than plaintext preferences. On 401 expire/refresh sessions according to verified backend behavior; don't invent a refresh endpoint.
- Avoid blind retries for mutations. GET retry can be bounded and user-aware; POST/checkout/payment retries need backend idempotency guarantees.
- Tie cancel tokens, search debouncing, stale response guarding and concurrent requests to the owning feature lifecycle.

## Caching & UI state
- Keep catalog caches bounded and invalidatable. Clearly distinguish locally displayed cached estimates from server-confirmed availability/price.
- Ensure loading, empty, error and success states exist without rebuilding the complete screen layout.
- Do not trust mobile-submitted order totals or item unit prices as final. Cart/order details must be verified by Laravel.

## Delivery contract when integrating a feature
- List actual endpoint(s) inspected and known/unknown fields.
- Show which DTO, repository, controller and view changed.
- Confirm tested success + failure behavior; flag untested backend cases.
