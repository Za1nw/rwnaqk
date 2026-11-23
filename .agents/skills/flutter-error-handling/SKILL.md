---
name: flutter-error-handling
description: Enforces meaningful, observable, user-safe error handling in Flutter/Dart applications. Use whenever creating, reviewing, or modifying try/catch, catchError, Future error handling, Riverpod providers/notifiers, repositories, Dio requests, authentication/session flows, storage, or Sentry reporting.
---

# Flutter Error Handling — Mandatory Skill

## Mission

Every caught error must have a deliberate outcome. Never add `try/catch` merely to silence an exception, avoid a red screen, satisfy a test, or keep execution moving while hiding a failed operation.

The goal is **stability with truthful state**, not "never crash at any cost". The app should remain usable where possible, but it must never pretend that a failed operation succeeded or show fabricated/stale data as current data.

## Mandatory rules

### 1. Empty and meaningless catches are forbidden

Never write any of these:

```dart
try {
  await operation();
} catch (_) {}

try {
  await operation();
} catch (e) {}

try {
  await operation();
} catch (_) {
  return;
}

try {
  final result = await operation();
  // ...
} catch (_) {
  return const [];
}
```

The last pattern is also forbidden when it converts a failed remote request into a successful-looking empty result.

A catch is acceptable only if it performs a meaningful, explicit action, such as:
- maps a known exception to a domain/UI state;
- shows or stores a safe, useful user-facing error;
- records an unexpected failure with the approved diagnostics/monitoring path;
- performs a justified fallback that is documented, observable, and cannot misrepresent data;
- rethrows the original exception when the current layer cannot handle it.

Logging alone does not make an operation successful. After logging, the code must still choose a correct state transition, fallback, or rethrow.

### 2. Handle errors at the correct layer

- **Data source / Dio:** Convert transport failures into the project's established exception types once. Preserve status code, server validation payload, cancellation semantics, and stack trace where applicable.
- **Repository:** Translate infrastructure details only when the repository owns that translation. Do not turn `ApiException`, `ValidationException`, `UnauthorizedException`, or other known domain exceptions into a generic `NetworkException(500)`.
- **Notifier / Riverpod:** Update state to a truthful failure state, preserve existing valid data when appropriate, and expose a safe display message. Do not leave `isLoading` true after failure.
- **UI:** Catch only when the UI must provide immediate feedback or recover locally. Show a localized, actionable message; do not expose raw stack traces, tokens, request headers, or internal exception dumps.
- **Global handlers:** Keep them as a last-resort safety net, not as a substitute for local handling.

### 3. Preserve application stability without hiding failure

For each catch, explicitly decide:
1. Is this an expected/known failure (validation, unauthorized, forbidden, cancellation, offline, timeout, not-found)?
2. Can this layer recover safely?
3. What should the user see?
4. What state should Riverpod hold?
5. Should the error be reported to monitoring?
6. If it cannot be handled here, should it be rethrown?

Never leave state inconsistent or claim success after failure.

Examples:
- A failed checkout must not be represented as a successful order.
- A failed wishlist refresh must not overwrite a valid local cache with an empty list.
- A failed order-details request must not silently display fake/mock order data in production.
- A failed token write must not leave the app marked authenticated with no durable credential.
- A failed profile fetch must never load another account's cached profile.

### 4. Preserve exception identity and stack trace

- Prefer `rethrow;` when handling is not complete and the original exception must continue upward.
- Do not use `throw e;` to rethrow an existing exception; it can reset the stack trace.
- If wrapping is required, retain the cause and original stack trace using the project's supported exception model or `Error.throwWithStackTrace`.
- Do not wrap known API/domain exceptions in generic errors.
- Handle `DioException` cancellation explicitly; cancellation is not automatically a server failure and should not trigger misleading error UI or Sentry noise.

### 5. Asynchronous operations must be awaited or deliberately supervised

- A synchronous `try/catch` does not catch a Future error unless the Future is awaited inside the try.
- Do not launch critical operations with `unawaited()` unless there is an explicit error handler attached and the operation is genuinely safe to run in the background.
- Never fire-and-forget token writes/deletes, order creation, payment, account switching, or other integrity-critical operations.
- If `unawaited()` is justified, document why and attach a deliberate error-reporting/recovery path. Do not use it to bypass awaiting.

### 6. Fallbacks must be safe, explicit, and observable

A fallback is permitted only when all conditions hold:
- it is appropriate for that operation;
- it cannot be confused with a successful fresh server response;
- it does not destroy valid local data;
- it is restricted to the intended environment/feature flag;
- its use is diagnosable (structured log/monitoring as appropriate);
- the UI can distinguish stale/offline/fallback data from fresh data when that distinction matters.

Never use empty list, `null`, `false`, zero, or a default model as a generic error fallback without proving that the value has the same business meaning as a real result.

Mock data must never be used as a silent production fallback.

### 7. Sentry and diagnostics policy

- Report unexpected, actionable failures that need developer investigation.
- Do not report every expected validation error, user cancellation, routine offline state, or handled 401 as an unhandled incident unless the project explicitly requires it.
- Avoid duplicate reporting across layers. Choose one reporting owner for a given failure path.
- Include the original exception and stack trace.
- Add safe contextual metadata (operation name, feature, non-sensitive identifiers if approved).
- Never send access tokens, passwords, payment secrets, full personal profiles, or sensitive request/response bodies.
- `debugPrint` alone is not production monitoring.
- A caught error that is intentionally recovered should still be observable when it indicates a real operational defect.

### 8. Cleanup belongs in `finally`, not an empty catch

Use `finally` for deterministic cleanup such as resetting loading flags, closing resources, or releasing locks. Do not catch an exception just to execute cleanup.

```dart
try {
  await performOperation();
} catch (error, stackTrace) {
  // Meaningful handling or reporting.
  rethrow;
} finally {
  state = state.copyWith(isLoading: false);
}
```

Only use this shape when rethrowing is correct for that layer; a notifier may instead convert the error into a failure state.

### 9. Do not make architectural or dependency changes without approval

For the Rwnaqk project:
- Preserve Flutter + Riverpod 3 + Dio 5.7.0 and existing project conventions.
- Do not migrate state management, rewrite layers, rename unrelated files, or add packages as part of error-handling work unless explicitly approved.
- Reuse existing `ApiException` types, `ApiErrorUtils`, Sentry setup, providers, and test utilities after inspecting their actual implementation.
- Do not assume a report's line numbers or proposed fix are still current; reopen and inspect the current source and all relevant call sites.

## Required workflow for every task

### Phase A — Read-only audit first
1. Search the full relevant scope for `try`, `catch`, `on`, `finally`, `.catchError`, `rethrow`, `throw`, `unawaited`, and unawaited Futures.
2. Inspect complete functions and call sites, not isolated matching lines.
3. Classify every catch:
   - A: meaningful handling;
   - B: justified fallback with observability;
   - C: rethrow-only / redundant;
   - D: silent or misleading swallowing;
   - E: async error escape / unhandled Future.
4. Record file, line, operation, exception type, current behavior, impact, and recommended handling.
5. Identify duplicate reporting and sensitive-data exposure risks.
6. Do not edit files during the audit.

### Phase B — Plan and approval
1. Group changes by risk and business flow.
2. Propose the smallest safe patch per phase.
3. Identify tests and regression risks.
4. Wait for explicit approval before editing when the user requested staged execution or approval gates.

### Phase C — Implement narrowly
1. Fix one approved phase only.
2. Keep diffs minimal and scoped.
3. Do not replace every catch with Sentry capture or rethrow blindly.
4. Ensure every catch has an explicit, justified outcome.
5. Preserve existing data and session isolation.
6. Add/adjust tests for both the error and recovery path.

### Phase D — Verify
Run the relevant tests first, then broader checks as appropriate:
- targeted unit/provider/widget tests;
- regression tests for affected flows;
- `flutter analyze`;
- relevant build command when requested or necessary.

Do not claim verification unless the command actually ran and its result is known. `flutter analyze` passing alone does not prove runtime correctness.

## Required review checklist

Before finishing, verify:
- [ ] No newly introduced empty catch.
- [ ] No catch that only suppresses an error.
- [ ] No failed operation represented as success.
- [ ] No generic exception conversion that destroys API/domain error details.
- [ ] Original stack trace preserved when rethrowing/wrapping.
- [ ] Every Future error is awaited or deliberately supervised.
- [ ] Loading flags, locks, and resources are cleaned up.
- [ ] Existing valid cache/data is not erased because a refresh failed.
- [ ] Mock/fallback data cannot masquerade as production data.
- [ ] User-facing messages are safe, localized, and actionable.
- [ ] Sentry reporting is useful, non-duplicated, and sanitized.
- [ ] Tests cover failure, recovery, and state consistency.
- [ ] No unrelated architecture/dependency changes.

## Required final report

Provide:
1. What was inspected and the exact scope.
2. Findings by severity with file and line references.
3. What was changed (or clearly state that no files were changed).
4. Why each catch now has meaningful behavior.
5. Tests/commands actually executed and their exact outcomes.
6. Remaining risks and deferred work.
7. Explicit confirmation that no empty/meaningless catch was introduced.
