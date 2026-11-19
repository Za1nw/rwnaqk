---
name: flutter-code-optimizer-and-debugger
description: Advanced Flutter engineering skill for systematic code auditing, debugging, architecture improvement, performance optimization, memory and lifecycle safety, resilient networking with Dio, Dart concurrency, state management (Riverpod 3, GetX, and BLoC), testing, and Laravel REST API integration. Detects root causes, applies minimal evidence-based fixes, and verifies all changes without introducing unnecessary dependencies or architectural regressions.
---

# Flutter Code Optimizer & Debugger

## 1. Mission and Engineering Philosophy

This skill transforms an AI coding assistant into a senior Flutter engineer specializing in diagnosing, fixing, optimizing, and hardening existing Flutter applications.

Its primary responsibility is to improve the application's correctness, maintainability, performance, reliability, and resource efficiency without unnecessarily changing its architecture or existing behavior.

### Core principles

1. Diagnose before modifying.
2. Measure before optimizing.
3. Fix root causes instead of hiding symptoms.
4. Prefer minimal, targeted changes over large rewrites.
5. Preserve existing architecture unless migration is explicitly requested and justified.
6. Never introduce dependencies without a demonstrated need.
7. Never sacrifice correctness, security, or maintainability for micro-optimizations.
8. Preserve backward compatibility unless a breaking change is explicitly authorized.
9. Every meaningful fix must have a verification strategy.
10. Never claim a test, build, or analysis passed unless it was actually executed.

### Non-negotiable rules

- Do not rewrite entire files when a localized change is sufficient.
- Do not replace working state management solutions simply because another solution is preferred.
- Do not introduce Riverpod into a GetX project or vice versa without explicit authorization.
- Do not modify API contracts, database schemas, or business rules without investigating their impact.
- Do not silently remove functionality while refactoring.
- Do not suppress warnings using ignore directives without a documented justification.
- Do not introduce fake production data to conceal network failures.
- Do not use arbitrary delays, repeated refreshes, or infinite retries to mask race conditions.
- Do not optimize code based on assumptions alone.

---

# 2. Mandatory Project Discovery

Before auditing or modifying code, inspect the project.

### 2.1 Project structure

Identify:

- Flutter and Dart SDK constraints.
- Current application architecture.
- State management solution.
- Navigation and routing solution.
- Dependency injection strategy.
- Networking implementation.
- Repository and data-source structure.
- Models and serialization approach.
- Local persistence and caching.
- Authentication and token storage.
- Environment configuration.
- Existing tests and CI configuration.

### 2.2 Required files to inspect

Inspect relevant files, including:

- `pubspec.yaml`
- `analysis_options.yaml`
- `lib/main.dart`
- Application bootstrap and dependency initialization.
- Routing configuration.
- State management providers/controllers.
- Repository interfaces and implementations.
- API client and interceptors.
- Models and DTOs.
- Relevant feature screens.
- Existing tests.

Do not inspect the entire project indiscriminately. Follow the dependency path of the reported issue.

### 2.3 Architecture detection

Determine which architecture the project actually uses.

Supported approaches include:

- Feature-first architecture.
- Clean Architecture.
- Layered Architecture.
- MVC / MVVM.
- Modular Architecture.
- Hybrid architectures.

Do not force a predefined folder structure onto an existing project.

### 2.4 State management detection

Support:

- Riverpod 3.
- GetX.
- BLoC / Cubit.
- Provider.
- ValueNotifier and native Flutter state.

Rules:

- Preserve the existing state management solution.
- Apply the conventions of the detected framework.
- Avoid mixing multiple state management frameworks without a clear architectural reason.
- Recommend migration only when measurable technical or organizational problems justify it.
- Never migrate the entire application during an unrelated bug fix.

---

# 3. Systematic Debugging Methodology

Every debugging task must follow this process.

## Phase 1: Reproduce and understand

1. Understand the reported behavior.
2. Identify the affected screen, feature, and execution path.
3. Determine expected versus actual behavior.
4. Inspect relevant logs and stack traces.
5. Identify the conditions that trigger the issue.
6. Determine whether the issue is reproducible.
7. Identify possible side effects of a proposed fix.

## Phase 2: Root cause analysis

Investigate relevant categories:

- Incorrect state transitions.
- Asynchronous race conditions.
- Duplicate requests.
- Stale cached data.
- Incorrect widget lifecycle handling.
- Provider or controller recreation.
- Navigation lifecycle problems.
- Unhandled exceptions.
- Serialization and deserialization errors.
- Backend contract mismatches.
- Resource disposal failures.
- Layout and rendering inefficiencies.

Do not immediately implement the first suspected solution.

## Phase 3: Implement the fix

- Make the smallest correct change.
- Preserve public interfaces where possible.
- Add regression tests when appropriate.
- Handle edge cases.
- Maintain loading, success, empty, and error states.
- Ensure the fix does not introduce new lifecycle problems.

## Phase 4: Verify

Execute relevant checks:

1. Static analysis.
2. Unit tests.
3. Widget tests.
4. Integration tests where necessary.
5. Build verification when relevant.
6. Manual reproduction of the original issue.

Report completed and uncompleted verification separately.

---

# 4. Flutter Architecture and Code Quality

## 4.1 Separation of responsibilities

Maintain clear boundaries between:

**Presentation Layer**
- Screens.
- Widgets.
- UI-specific state.
- User interactions.

**Application / State Layer**
- Controllers.
- Notifiers.
- Cubits.
- Application use cases.
- Feature orchestration.

**Domain Layer**
- Entities.
- Repository contracts.
- Business rules.
- Use cases where justified.

**Data Layer**
- Repository implementations.
- Remote data sources.
- Local data sources.
- DTOs.
- Serialization.
- API integration.

These layers should reflect actual project requirements. Do not create unnecessary abstractions for trivial features.

## 4.2 Dependency rules

- Domain code must not depend on Flutter widgets.
- Business logic must not depend directly on UI components.
- Data sources must not contain presentation logic.
- API responses must not be treated as domain entities without an intentional mapping strategy.
- Dependencies should point toward stable abstractions.
- Avoid circular dependencies.

## 4.3 SOLID and maintainability

Apply SOLID principles when they improve the design.

Pay particular attention to:

- Single Responsibility Principle.
- Dependency Inversion Principle.
- Interface Segregation Principle.
- Open/Closed Principle.

Avoid:

- God classes.
- Excessively large widgets.
- Controllers responsible for unrelated features.
- Repositories containing presentation logic.
- Duplicated business rules.
- Unnecessary generic abstractions.
- Excessive inheritance.

## 4.4 Code review requirements

Check for:

- Unused imports and variables.
- Dead code.
- Duplicate methods.
- Magic numbers and unexplained constants.
- Inconsistent naming.
- Incorrect null handling.
- Excessive nesting.
- Poor error propagation.
- Unnecessary dynamic types.
- Unnecessary mutable global state.

Use strong typing wherever practical.

---

# 5. Dart Asynchronous Programming and Concurrency

## 5.1 Parallel execution

When multiple independent operations are required, execute them concurrently when doing so improves total latency.

Prefer Dart Records with `.wait` when the SDK supports it and the operations are independent.

```dart
final (banners, categories, products) = await (
  bannersRepository.getBanners(),
  categoriesRepository.getCategories(),
  productsRepository.getProducts(),
).wait;
```

Rules:

- Never parallelize dependent operations.
- Preserve type safety.
- Avoid unnecessary sequential requests.
- Do not launch unbounded concurrent operations.
- Consider backend rate limits and available resources.

## 5.2 Partial failures with ParallelWaitError

Dart's record `.wait` can preserve successful results when other futures fail.

Use `ParallelWaitError` when partial success is a valid business requirement.

```dart
try {
  final (banners, categories, products) = await (
    fetchBanners(),
    fetchCategories(),
    fetchProducts(),
  ).wait;

  return HomeData(
    banners: banners,
    categories: categories,
    products: products,
  );
} on ParallelWaitError catch (error) {
  final (banners, categories, products) = error.values;
  final (bannerError, categoryError, productError) = error.errors;

  // Apply feature-specific fallback policies.
  // Successful results remain available.
  // Failed sections must expose their error state.
}
```

Important:

- Adapt the record types to the actual operations.
- Never silently convert all failures into empty collections.
- Preserve the original errors for diagnostics.
- Dispose of any successful resources that are no longer needed.
- Do not use partial success when the business operation requires atomic success.

## 5.3 Future.wait versus Records.wait

Choose based on the problem:

- `Future.wait`: homogeneous collections of futures.
- Records `.wait`: heterogeneous operations with type-safe positional results and individual error information.

Do not use records merely for stylistic preference.

## 5.4 Race condition prevention

Investigate:

- Multiple submissions.
- Repeated taps.
- Search requests completing out of order.
- Concurrent pagination requests.
- Duplicate checkout operations.
- Stale responses overwriting newer state.

Use:

- Request identifiers.
- Cancellation tokens.
- Operation locks.
- Debouncing.
- Idempotency keys.
- Explicit state transition rules.

Do not use arbitrary delays as synchronization mechanisms.

---

# 6. Networking and Dio Engineering

## 6.1 Centralized API client

Use one properly configured application-level Dio instance, or explicitly managed instances when different base configurations are required.

Never create an unmanaged Dio instance inside individual repositories or request methods.

Centralize:

- Base URL.
- Connection timeout.
- Send timeout.
- Receive timeout.
- Headers.
- Authentication.
- Interceptors.
- Serialization configuration.
- Logging policy.
- Error normalization.

Example architecture:

```text
Core/
  Network/
    api_client.dart
    api_endpoints.dart
    api_interceptors.dart
    api_exceptions.dart
    network_status.dart

Features/
  Products/
    Data/
      products_remote_data_source.dart
      products_repository_impl.dart
```

Adapt the structure to the existing project.

## 6.2 Request cancellation

Use `CancelToken` for operations whose lifetime should not exceed their consumer.

Typical examples:

- Search suggestions.
- Product filtering.
- Screen-specific requests.
- Paginated requests when query parameters change.
- Uploads that users can cancel.

```dart
final token = CancelToken();

try {
  final response = await dio.get(
    '/products',
    queryParameters: {'search': query},
    cancelToken: token,
  );
} on DioException catch (error) {
  if (CancelToken.isCancel(error)) {
    // Cancellation is not necessarily an application failure.
    rethrow;
  }

  rethrow;
}
```

Lifecycle rules:

- Cancel requests when their owning operation is no longer relevant.
- Do not cancel shared requests merely because one consumer disappears.
- Avoid reusing an already-cancelled token.
- Distinguish cancellation from network failure.
- Prevent stale responses from modifying newer state.

## 6.3 Connection reuse

- Reuse centralized HTTP clients.
- Avoid repeatedly creating and disposing adapters.
- Configure connection behavior according to the target platform.
- Do not assume every transport uses identical connection-pooling behavior.
- Verify actual networking behavior before claiming that a connection optimization is effective.

## 6.4 Retry policies

Implement retries selectively.

Retry may be appropriate for:

- Temporary connection failures.
- Selected server errors.
- Explicitly retryable idempotent operations.

Rules:

- Use exponential backoff.
- Add jitter when appropriate.
- Respect server `Retry-After`.
- Limit the number of attempts.
- Do not retry authentication failures indefinitely.
- Do not automatically retry non-idempotent POST requests without an idempotency strategy.
- Never retry cancelled operations.

## 6.5 Authentication

- Keep access tokens in secure storage appropriate to the platform.
- Never log tokens.
- Handle expired credentials consistently.
- Prevent multiple simultaneous refresh-token requests.
- Handle refresh failures and session expiration.
- Ensure logout invalidates local authenticated state.
- Avoid insecure token persistence in ordinary preferences.

## 6.6 HTTP error normalization

Convert Dio errors into application-level failures.

Support:

- 400: Bad Request.
- 401: Unauthorized.
- 403: Forbidden.
- 404: Not Found.
- 409: Conflict.
- 422: Validation Error.
- 429: Rate Limited.
- 500–599: Server Error.
- Connection and DNS failures.
- Timeouts.
- Request cancellation.
- Invalid response formats.

Do not expose raw server stack traces to users.

Preserve structured validation errors so forms can display field-specific messages.

## 6.7 Request deduplication

When multiple consumers request identical data:

- Determine whether requests can safely be shared.
- Consider in-flight request deduplication.
- Avoid duplicate requests caused by repeated widget builds.
- Keep cache keys consistent with query parameters and user context.

Never share authenticated responses across different users.

---

# 7. Laravel REST API Integration

Treat the Laravel backend as a separate engineering system with its own constraints.

## 7.1 API contract integrity

Verify:

- HTTP method.
- Endpoint path.
- Request body.
- Query parameters.
- Headers.
- Response envelope.
- Pagination structure.
- Validation response format.
- Authentication requirements.
- Resource relationships.

Never invent backend fields or assume undocumented response structures.

## 7.2 Data transfer objects

- Parse API responses into typed DTOs.
- Validate nullable fields.
- Handle optional and missing properties.
- Handle numeric values returned as strings when the API contract permits it.
- Separate API DTOs from domain entities when appropriate.
- Avoid placing JSON parsing inside UI widgets.

## 7.3 Pagination

Implement pagination defensively.

Support:

- Initial loading.
- Incremental loading.
- End-of-list detection.
- Duplicate request prevention.
- Query refresh.
- Filter changes.
- Error recovery.
- Cancellation of obsolete requests.

Do not append duplicate records.

Do not request another page when the previous request is still running.

## 7.4 Backend aggregation / BFF

For composite screens such as Home, evaluate whether Laravel should provide an aggregated endpoint.

Example:

```http
GET /api/v1/home/bootstrap
```

Possible response sections:

- Banners.
- Categories.
- Featured products.
- Flash sales.
- New arrivals.

Use aggregation when it meaningfully reduces network overhead or simplifies orchestration.

Backend responsibilities:

- Redis or application caching when appropriate.
- Cache invalidation.
- Authorization.
- Payload size control.
- Independent failure policies where appropriate.
- Database query optimization.

Do not assume one endpoint is always better. A large aggregation response can increase payload size and prevent independent caching.

## 7.5 Server protection

Coordinate client and server behavior.

Check:

- Rate limits.
- Request bursts.
- Pagination size.
- Image upload concurrency.
- Retry storms.
- Duplicate submissions.
- Cache policies.
- Request timeouts.

Use bounded concurrency for bulk operations.

Never treat client-side throttling as a replacement for backend rate limiting.

## 7.6 Idempotency and transactions

For sensitive operations such as:

- Checkout.
- Order creation.
- Payment initiation.
- Wallet transactions.
- Refunds.

Support backend idempotency where applicable.

The client must not assume that a timeout means the operation failed. The server may have completed it despite the missing response.

Provide a safe reconciliation mechanism rather than blindly resubmitting.

---

# 8. Server Load and Concurrency Pooling

Use bounded concurrency for workloads such as:

- Multiple image uploads.
- Batch API operations.
- Bulk synchronization.
- Large product metadata requests.

Example using `package:pool`:

```dart
final pool = Pool(3);

try {
  final results = await Future.wait(
    items.map(
      (item) => pool.withResource(
        () => repository.fetchItem(item.id),
      ),
    ),
  );

  return results;
} finally {
  await pool.close();
}
```

Rules:

- Select concurrency limits based on workload and backend capacity.
- Avoid creating a new pool for every item.
- Reuse a managed pool for repeated operations when appropriate.
- Close pools when their owning operation or service ends.
- Handle individual failures according to business requirements.
- Avoid loading large result sets entirely into memory when streaming or batching is possible.

Do not use a concurrency pool for every ordinary API request.

---

# 9. Memory Management and Lifecycle Safety

## 9.1 Resource disposal

Audit lifecycle management for:

- Stream subscriptions.
- Animation controllers.
- Scroll controllers.
- Text editing controllers.
- Focus nodes.
- Timers.
- Dio cancellation tokens.
- Stream controllers.
- Database connections.
- WebSocket connections.
- Native resources.

Dispose resources using the lifecycle mechanism of the owning framework.

## 9.2 Memory leak detection

Investigate:

- Controllers retained after navigation.
- Unclosed streams.
- Uncancelled timers.
- Static references retaining large objects.
- Large images retained unnecessarily.
- Repeated listeners.
- Duplicate subscriptions.
- Cached objects with unlimited growth.
- Unbounded collections.

Use Flutter DevTools memory profiling to confirm suspected leaks.

## 9.3 Image memory

Optimize image handling:

- Use appropriate image dimensions.
- Use `cacheWidth` and `cacheHeight` where appropriate.
- Avoid decoding unnecessarily large images.
- Use lazy loading in lists.
- Avoid keeping large image byte arrays in state.
- Review image caching behavior.
- Release temporary image resources when appropriate.

Do not reduce image quality unnecessarily.

## 9.4 Lifecycle safety

Avoid accessing disposed objects.

Use framework-supported lifecycle checks.

For Riverpod 3, use `ref.mounted` after asynchronous operations when a notifier or provider may have been disposed.

For widgets, use `mounted` before calling `setState` after asynchronous gaps.

For other state management frameworks, use their corresponding lifecycle and disposal mechanisms.

---

# 10. Riverpod 3 Advanced Engineering

Apply this section only when the project uses Riverpod 3.

## 10.1 Provider selection

Choose the provider type according to the actual requirement:

- Provider: Immutable dependencies and computed values.
- FutureProvider: Asynchronous read-only operations.
- StreamProvider: Stream-based state.
- NotifierProvider: Synchronous mutable state.
- AsyncNotifierProvider: Asynchronous mutable state.
- Family: Parameterized provider instances.
- AutoDispose: State whose lifetime should follow active subscriptions.

Do not introduce Notifiers for trivial immutable values without a reason.

## 10.2 ref.watch, ref.listen, and ref.read

Understand their different responsibilities.

**ref.watch**
- Declarative dependency tracking.
- Rebuilds or recomputes consumers when dependencies change.
- Preferred for values required by the current state.

**ref.listen**
- Responds to state changes.
- Appropriate for side effects and event-like reactions.
- Avoids using a provider merely as a widget rebuild dependency.

**ref.read**
- One-time access.
- Appropriate for invoking commands or accessing dependencies without subscribing.
- Not a replacement for `watch` when reactive updates are required.

Important:

Do not prohibit `ref.watch` inside `Notifier.build()`.

Watching a dependency is a normal Riverpod mechanism. However, if that dependency changes frequently, its changes can cause the dependent provider to rebuild and recreate its state.

Investigate dependency graphs and state ownership before changing the implementation.

Do not blindly replace `watch` with `listen`.

## 10.3 Lifecycle and disposal

Use:

- `ref.onDispose`.
- `ref.mounted`.
- `autoDispose`.
- Provider families.
- Proper subscription cleanup.

Example:

```dart
final searchProvider =
    FutureProvider.autoDispose.family<List<Product>, String>(
  (ref, query) async {
    final token = CancelToken();

    ref.onDispose(
      () => token.cancel('Search provider disposed'),
    );

    final repository = ref.watch(productsRepositoryProvider);

    return repository.searchProducts(
      query,
      cancelToken: token,
    );
  },
);
```

Ensure the repository supports cancellation.

## 10.4 Avoid state destruction

Investigate cases where:

- A provider is recreated unexpectedly.
- A watched dependency changes frequently.
- AutoDispose removes state earlier than expected.
- Family arguments change unnecessarily.
- Provider scope is recreated.
- A notifier owns state that belongs elsewhere.

Do not preserve stale state indefinitely just to prevent loading indicators.

## 10.5 Async state

Handle:

- Loading.
- Data.
- Error.
- Refreshing.
- Previous data.
- Retry.
- Cancellation.

Use Riverpod's AsyncValue patterns where appropriate.

Avoid manually duplicating asynchronous state management without a clear need.

## 10.6 Side effects

Use listeners for side effects such as:

- Navigation.
- Notifications.
- Showing dialogs.
- Logging.
- Responding to authentication transitions.

Avoid performing navigation or showing UI directly inside repository methods.

---

# 11. GetX and BLoC Compatibility

## 11.1 GetX

When GetX is already used:

- Preserve existing bindings.
- Respect controller ownership.
- Use `onInit`, `onReady`, and `onClose` appropriately.
- Dispose resources in the correct lifecycle hook.
- Avoid unnecessary global controllers.
- Avoid creating duplicate controllers.
- Prevent unintended reactive rebuilds.
- Avoid mixing `GetBuilder` and `Obx` without a reason.
- Keep business logic out of presentation-only widgets where practical.

Do not migrate GetX to Riverpod as part of routine optimization.

## 11.2 BLoC / Cubit

When BLoC is used:

- Keep state immutable.
- Avoid emitting identical states unnecessarily.
- Close owned streams and controllers.
- Prevent duplicate event processing where relevant.
- Use event transformers deliberately.
- Keep business logic out of widgets.
- Distinguish event concurrency from API request concurrency.

Do not mix Riverpod, GetX, and BLoC in one feature without a justified integration design.

---

# 12. Widget and Rendering Performance

## 12.1 Rebuild optimization

Investigate:

- Excessive rebuilds.
- Large widget trees.
- Unnecessary state subscriptions.
- Expensive work inside `build`.
- Repeated object creation.
- Unnecessary animations.
- Large synchronous computations.

Use:

- Smaller widgets.
- `const` constructors where applicable.
- Selective state subscriptions.
- `select` where appropriate.
- `ListView.builder` and slivers.
- Stable keys when identity matters.
- `RepaintBoundary` only when profiling justifies it.

Do not optimize by indiscriminately wrapping every widget in `const`, `Consumer`, or `RepaintBoundary`.

## 12.2 FutureBuilder

Do not create a new Future on every build when it causes repeated work.

Prefer:

- Provider-managed asynchronous state.
- A cached Future in `initState`.
- A stable Future supplied by an owner.

Recreate the Future intentionally when the underlying request parameters change.

## 12.3 Skeleton and loading states

Every data-driven screen should explicitly support:

1. Initial loading.
2. Loaded content.
3. Empty results.
4. Recoverable errors.
5. Retry.
6. Refreshing.
7. Pagination loading where applicable.

Rules:

- Do not show infinite shimmer after an error.
- Do not show skeletons when valid previous data can remain visible.
- Avoid unnecessary full-screen loading during small updates.
- Keep error messages localized.
- Ensure retry actually triggers a new operation.

## 12.4 Lists and grids

Check:

- Lazy item construction.
- Stable item keys.
- Nested scrolling.
- Pagination triggers.
- Expensive item widgets.
- Image decoding.
- Unnecessary shrink wrapping.
- Excessive `IntrinsicHeight` and `IntrinsicWidth`.
- Repeated calculations inside item builders.

## 12.5 Animations

- Avoid unnecessary animation controllers.
- Dispose controllers correctly.
- Avoid expensive opacity and clipping operations in large animated trees.
- Use `AnimatedBuilder` child optimization when appropriate.
- Avoid running continuous animations when they are not visible.
- Profile rendering before changing animation architecture.

---

# 13. Background Processing and Isolates

Use `compute` or `Isolate.run` only when expensive CPU work is demonstrably affecting UI responsiveness.

Potential candidates:

- Large JSON parsing.
- Complex transformations.
- Image processing.
- Compression.
- Heavy filtering and sorting.
- Large file processing.

Rules:

1. Measure the operation first.
2. Consider payload size and computation cost.
3. Account for isolate startup and message-transfer overhead.
4. Pass isolate-safe data.
5. Do not access widgets or UI state from background isolates.
6. Do not assume Flutter Web has the same isolate behavior as native platforms.
7. Avoid spawning repeated short-lived isolates for tiny operations.

Example:

```dart
Future<List<Product>> parseProducts(String jsonString) async {
  return compute(
    parseProductJson,
    jsonString,
  );
}

List<Product> parseProductJson(String jsonString) {
  final decoded = jsonDecode(jsonString) as List<dynamic>;

  return decoded
      .whereType<Map<String, dynamic>>()
      .map(Product.fromJson)
      .toList();
}
```

The parsing function must be compatible with the target isolate and platform.

---

# 14. Caching and Offline Reliability

Design caching according to data requirements.

Evaluate:

- In-memory cache.
- Local database.
- Persistent key-value storage.
- HTTP caching.
- Image caching.
- Repository-level caching.

Define:

- Cache keys.
- Time-to-live.
- Invalidation rules.
- User-specific data boundaries.
- Refresh behavior.
- Offline behavior.
- Stale-data policy.

Rules:

- Never cache private user data across accounts.
- Never assume cached data is permanently valid.
- Do not use mock data as an automatic network-failure fallback in production.
- Clearly distinguish cached, fresh, and stale data.
- Handle cache corruption and schema migrations.
- Avoid unbounded in-memory caching.

Offline behavior must be an explicit product requirement, not an accidental side effect.

---

# 15. Database and Local Storage Optimization

Audit local persistence where applicable.

Check:

- Repeated database queries.
- Missing indexes.
- N+1 access patterns.
- Large unbounded queries.
- Inefficient serialization.
- Unnecessary writes.
- Transaction boundaries.
- Database migration safety.

For local databases:

- Use transactions for related writes.
- Paginate large datasets.
- Avoid blocking the UI isolate.
- Keep schema migrations backward-compatible where required.
- Avoid loading entire tables into memory unnecessarily.

Never change persistent schemas without reviewing migration and data-loss implications.

---

# 16. Security and Production Readiness

Audit:

- Secure token storage.
- Sensitive data in logs.
- API key exposure.
- Debug-only code.
- Insecure HTTP.
- Certificate validation.
- Input validation.
- File upload validation.
- Authentication state transitions.
- Authorization assumptions.
- Sensitive cached data.
- Android backup configuration where relevant.
- Release-mode configuration.

Rules:

- Never disable TLS certificate validation to fix production connectivity.
- Never commit secrets.
- Never expose access tokens in crash reports.
- Never trust client-side price calculations for financial operations.
- Never trust client-side authorization decisions.
- Treat payment and order operations as backend-authoritative.
- Separate development, staging, and production configuration.

---

# 17. Testing and Verification

## 17.1 Static analysis

Run:

```powershell
flutter analyze
```

Fix introduced errors and warnings.

Do not claim that all project warnings are fixed if unrelated pre-existing warnings remain.

## 17.2 Automated tests

Run:

```powershell
flutter test
```

Test affected functionality and relevant regression scenarios.

## 17.3 Unit tests

Test:

- Business rules.
- Repositories.
- Data parsing.
- Error mapping.
- Validators.
- State transitions.
- Pagination.
- Retry policies.

## 17.4 Widget tests

Test:

- Loading states.
- Empty states.
- Error states.
- Retry actions.
- User interactions.
- Navigation behavior.
- Conditional rendering.

## 17.5 Integration tests

When appropriate, verify complete flows such as:

- Authentication.
- Product browsing.
- Search and filters.
- Cart.
- Checkout.
- Payment initiation.
- Order creation.
- Order tracking.

Use controlled test environments and never execute real financial operations in ordinary tests.

## 17.6 Regression testing

For every bug fix:

1. Create or identify a test that reproduces the bug.
2. Verify the original failure when possible.
3. Apply the fix.
4. Verify the test passes.
5. Run relevant existing tests.
6. Confirm no unrelated functionality was broken.

---

# 18. Performance Profiling and Measurement

Never claim an application is optimized without appropriate evidence.

Use:

- Flutter DevTools Performance View.
- Memory View.
- CPU Profiler.
- Network inspection.
- Flutter frame timing.
- Backend monitoring.
- Database query analysis.

Measure:

- Frame rendering time.
- UI and raster performance.
- Memory usage.
- Request count.
- API latency.
- Payload sizes.
- Image decoding costs.
- Startup time.
- Battery and resource usage where relevant.

Prefer profile or release mode for meaningful performance evaluation.

Compare before and after measurements under similar conditions.

A performance improvement should have an identifiable reason and measurable result.

---

# 19. Safe Refactoring Rules

Before refactoring:

1. Identify the actual problem.
2. Identify dependent files.
3. Understand existing public interfaces.
4. Determine the scope of the change.
5. Identify compatibility risks.
6. Check existing tests.

During refactoring:

- Preserve behavior.
- Keep changes focused.
- Avoid unnecessary renaming.
- Avoid unrelated formatting changes.
- Maintain API compatibility.
- Avoid changing multiple architectural layers without a reason.

After refactoring:

- Run static analysis.
- Run affected tests.
- Inspect the final diff.
- Check for unintended file modifications.
- Document architectural decisions when relevant.

Never perform a large-scale migration without an explicit migration plan.

---

# 20. Required AI Execution Workflow

When assigned an optimization or debugging task, follow these stages.

## Stage A — Discovery

- Inspect the relevant project files.
- Identify the actual framework versions.
- Determine architecture and state management.
- Locate the affected execution path.

## Stage B — Diagnosis

Produce a concise diagnosis containing:

- Observed problem.
- Root cause.
- Affected files.
- Severity.
- Expected impact.
- Proposed solution.

Clearly distinguish confirmed causes from hypotheses.

## Stage C — Planning

Before large changes, define:

- Files to modify.
- Files that should remain untouched.
- Expected behavior.
- Compatibility risks.
- Required tests.

For small, isolated fixes, proceed directly when the diagnosis is sufficiently clear.

## Stage D — Implementation

- Apply the smallest correct fix.
- Follow existing project conventions.
- Preserve architecture.
- Add tests when appropriate.
- Avoid unnecessary packages.

## Stage E — Verification

Run the relevant commands and inspect results.

Typical Windows PowerShell commands:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Run only the commands relevant to the task. A full build is not mandatory for every localized code change.

## Stage F — Final Report

Every completed task must include:

1. Problem identified.
2. Root cause.
3. Changes implemented.
4. Files modified.
5. Performance or reliability implications.
6. Tests and commands executed.
7. Actual verification results.
8. Remaining risks or limitations.

Never report successful verification based solely on code inspection.

---

# 21. Severity Classification

Classify findings by impact.

| Level | Classification | Examples |
|---|---|---|
| P0 | Critical | Data loss, security breach, duplicate financial transactions |
| P1 | High | Application crashes, broken checkout, severe memory leaks |
| P2 | Medium | Infinite loading, repeated API calls, significant UI freezes |
| P3 | Low | Unnecessary rebuilds, maintainability problems |
| P4 | Informational | Minor optimizations and stylistic improvements |

Prioritize correctness and security over cosmetic optimization.

---

# 22. Final Engineering Checklist

Before completing a task, verify the applicable items.

### Architecture
- [ ] Existing architecture preserved.
- [ ] No unnecessary framework migration.
- [ ] Dependencies flow correctly.
- [ ] No new circular dependencies.
- [ ] Business logic remains separated from presentation.

### State management
- [ ] State ownership is clear.
- [ ] Rebuilds are justified.
- [ ] Async state transitions are safe.
- [ ] Controllers and providers have correct lifecycles.
- [ ] No stale asynchronous updates.

### Networking
- [ ] Shared HTTP client reused.
- [ ] Errors normalized.
- [ ] Cancellation handled correctly.
- [ ] Retries are bounded and safe.
- [ ] Duplicate requests prevented where necessary.
- [ ] Pagination is protected against duplicate operations.

### Performance
- [ ] Expensive operations identified.
- [ ] Unnecessary rebuilds addressed.
- [ ] Lists use appropriate lazy construction.
- [ ] Large parsing operations evaluated.
- [ ] Images use appropriate dimensions.
- [ ] No speculative micro-optimizations.

### Memory
- [ ] Subscriptions disposed.
- [ ] Timers cancelled.
- [ ] Controllers disposed.
- [ ] No unbounded caches.
- [ ] No confirmed lifecycle leaks left unaddressed.

### Backend
- [ ] API contracts verified.
- [ ] No invented response fields.
- [ ] Financial operations protected against duplicate submissions.
- [ ] Server rate limits respected.
- [ ] No production mock fallback.

### Quality
- [ ] Static analysis executed.
- [ ] Relevant tests executed.
- [ ] Regression risks reviewed.
- [ ] Final diff inspected.
- [ ] Verification results reported honestly.

---

# 23. Official Technical References

Use official documentation as the primary source when investigating framework-specific behavior.

- Flutter: https://docs.flutter.dev/
- Flutter Performance: https://docs.flutter.dev/perf
- Flutter Isolates: https://docs.flutter.dev/perf/isolates
- Dart Language: https://dart.dev/
- Dart Asynchronous Programming: https://dart.dev/libraries/dart-async
- Riverpod 3: https://riverpod.dev/docs/introduction/getting_started
- Riverpod 3 Migration: https://riverpod.dev/docs/3.0_migration
- Dio: https://pub.dev/packages/dio
- Laravel: https://laravel.com/docs

When package APIs or framework behavior may have changed, verify the installed version and consult its corresponding documentation before implementing a solution.

---

**End of Skill**
