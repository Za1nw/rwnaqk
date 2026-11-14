# Modern GetX → Riverpod 3.5 migration notes

For API calls, read sibling skill `.agents/skills/riverpod3-flutter-state/references/riverpod3-apis.md` and `.agents/skills/riverpod3-flutter-state/references/riverpod3-35-release-and-compatibility.md`, and official https://riverpod.dev/docs/3.0_migration.

- Run `flutter --version` and `dart --version` before installing packages.
- Riverpod 3.5.0 requires Dart >= 3.12, while riverpod_lint 3.2.0 requires 3.13 dev. Don't upgrade Flutter without user approval.
- Bootstrap one `ProviderScope` around current GetMaterialApp; do not remove GetX dependencies/routes yet.
- Use `Notifier` / `AsyncNotifier`; avoid Riverpod 2 `StateNotifierProvider` or `FamilyNotifier` examples.
- `Ref.mounted` for late responses, `ProviderObserverContext` for logs, automatic retries for provider computations.
- Keep mutation POSTs explicit, no implicit retries, preserve checkout idempotency; use Repo provider overrides for tests.
- One Module per commit/gate, test both fake and real API for high-risk modules, delete unused legacy only after zero references + rerun tests.
