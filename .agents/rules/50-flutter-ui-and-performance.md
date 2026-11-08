---
trigger: glob
description: "Flutter/Dart widget changes must preserve the approved storefront UI and avoid GetX reactive overbuilds."
globs: "lib/**/*.dart, test/**/*.dart, integration_test/**/*.dart"
---
# Flutter UI, localization, and performance

- Preserve existing design tokens, spacing, typography, navigation semantics, light/dark modes, assets, RTL/Arabic and current interaction flows unless the task explicitly changes them. No visual redesign when wiring an API.
- Prefer small reusable widgets where they improve clarity; do not change dozens of stable screens to enforce stylistic preferences.
- Use `const` constructors where appropriate, `ListView.builder`/slivers for long product lists, and correctly sized/cached images with loading and error placeholders.
- Scope `Obx` around the smallest practical changing subtree; ensure the observable is read inside that builder. Avoid nested `Obx` without a concrete need and avoid creating controller instances inside `build()`.
- For input search, consider debounce and stale-request handling instead of firing a network request on every keystroke. Dispose owned listeners, controllers, Workers and subscriptions.
- Show informative loading/empty/error/retry states without layout jumps, broken navigation, or fake success. Ensure accessibility labels, tappable targets and text scaling remain usable.
- Test small Android devices and RTL; do not assume a single emulator size. Avoid clipping, overflowing content, repeated animations or blocking UI on heavy synchronous operations.
- Before optimizing, identify a real bottleneck from Flutter DevTools profile traces or a reproducible regression. Don't claim an optimization improved frame time without measurement.
