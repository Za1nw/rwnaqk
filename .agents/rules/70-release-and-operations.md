---
trigger: model_decision
description: "Use for release readiness, store submission, staging/production builds, environment setup, signing, crash handling, privacy, or urgent scope cuts."
---
# Release mode: shipping safely, not polishing forever

## Scope & ordering
- P0 order: Catalog → detail/variant → cart → auth/guest as required → address/shipping → server price validation → order create → confirmation/order detail.
- P1: only essential discovery and usability gaps. P2: cosmetic animations, reviews, nonessential notifications, optional promo logic. Remove/disable incomplete clickable features from production instead of presenting a false success.
- Start app-store account/testing/review preparation in parallel; never promise an exact store approval date.

## Environment gates
- Verify prod/staging base URLs, TLS, token storage, permissions, app ID, signing, version/build number, supported platform settings and privacy disclosures. **Do not print signing keys, tokens, or passwords.**
- Ensure errors do not reveal internal paths or headers; disable excessive debug logging in release.
- Check production-like API latency and cart/order race conditions using test/staging accounts. Never submit live orders or financial transactions without permission.
- Before final handoff: launch cold/warm, log in/out, add cart, purchase flow, offline recovery, profile/RTL, low-end Android, and released build smoke test.
- If deadline is near and core checkout is broken, halt P2 work and report a `NO-GO` recommendation until P0 is resolved. A build succeeding alone does not mean the release is ready.
- Do not deploy, upload stores, change DNS or apply backend migrations without explicit user approval.

## Final report format
`Ready/blocked → P0 status → verified build/tests → pending backend endpoints → submission dependencies → safe next action`.
