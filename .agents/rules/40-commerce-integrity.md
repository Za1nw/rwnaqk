---
trigger: model_decision
description: "Use when touching product options, cart, inventory, checkout, address, delivery, coupon, order, payment, user session, or monetary calculations."
---
# Ecommerce correctness and trust boundaries

- The Laravel backend is authoritative for product availability, selected variant, pricing, taxes (if any), discounts, delivery fees, order totals, ownership, order status and payment confirmation. Flutter may preview but must display the server-validated quote before final submit when the backend supports it.
- Never use client-calculated totals as the authoritative order price, even if a price appears in state or local storage.
- Use a stable product/variant identifier; quantity and stock validation must happen on the server. Define behavior when cart price/stock changes since it was loaded; show a clear user-facing resolution.
- Money: use backend-provided integer minor units or an explicitly agreed decimal representation/currency. **Do not compute financial totals with binary doubles**, convert currency implicitly, or assume every currency has two decimal places. Format amounts for display only.
- Order creation: prevent duplicate taps locally; the backend must enforce idempotency / duplicate-submit protection appropriate to its API. A network timeout is **not evidence** that a POST failed; query known order status before retry when supported.
- Payments: never mark an order paid because Flutter observed a success dialog. Use trusted backend confirmation, and webhooks or verified provider status on Laravel when applicable.
- Guest versus authenticated cart ownership must be defined. On login/logout/account switch, prevent leaking cart, addresses, orders or user profile between accounts. Don't store sensitive PII in debug output.
- Address, shipping method and payment method must be explicitly selected and validated. Handle out-of-delivery-area and unexpected shipping fee changes before order confirmation.
- Cart state should have one owner. Update global badge and cart screen from the same source rather than duplicating independently mutable totals.
- Return server validation errors in Arabic/user language where localization exists; preserve accessible and informative errors.

## P0 smoke test
1. Browse and open a real product.
2. Select valid variant and quantity; add/remove/update cart.
3. Sign in or use supported guest flow; choose address and shipping.
4. Review backend quote; submit once; verify a persisted order and correct total.
5. Test network interruption, repeated tap, price/stock conflict and resumed session.
6. Verify order detail/status; payment only if actually supported by the chosen business model.
