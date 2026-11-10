# Release-aware Riverpod 3.5 compatibility (checked 2026-11-09)

Riverpod 3.5.0 was published on 2026-11-06. It fixes lifecycle and listener edge cases, introduces ProviderDisposedException for disposed provider futures, and updates DevTools. See https://pub.dev/packages/flutter_riverpod/changelog and https://pub.dev/packages/riverpod/changelog.

## Check first

```powershell
flutter --version
dart --version
flutter pub outdated
```

Version decisions are subject to the project's SDK and dependency resolver. Latest stable versions in pub.dev at review: `flutter_riverpod 3.5.0`, `riverpod_annotation 4.0.8`, `riverpod_generator 4.0.10`. Minimum Dart 3.12 for these packages. The latest `riverpod_lint 3.2.0` requires Dart 3.13 (dev), **so do not blindly add it**.

**At Dart 3.7–3.11**, evaluate Flutter Riverpod 3.3.2 and compatible annotation/generator if upgrade not safe; validate with `flutter pub get`, never downgrade unrelated packages silently.

## API traps

1. New providers must not import legacy providers unless migrating a legacy implementation.
2. `ProviderObserverContext` replaces old observer parameter trio.
3. `AsyncValue` transition and provider automatic retry must not accidentally resend non-idempotent operations.
4. `Ref.mounted` guards late async updates. A disposed provider's `.future` can throw ProviderDisposedException in 3.5; this isn't an HTTP 500.
5. Legacy `.autoDispose` subclasses (`AutoDisposeAsyncNotifier`, etc.) are obsolete for modern Riverpod 3.
6. Prefer non-generated providers for the first pilot; generator adds a separate toolchain.
7. Scoping and invalidation should avoid cross-user cache leakage.

## Source links

https://pub.dev/packages/flutter_riverpod/versions
https://pub.dev/packages/riverpod_annotation/versions
https://pub.dev/packages/riverpod_generator/versions
https://pub.dev/packages/riverpod_lint/versions
https://riverpod.dev/docs/3.0_migration
