---
trigger: model_decision
description: "Use when adding behavior, fixing defects, reviewing an implementation, writing tests, running analyzers, or preparing code for merge."
---
# Quality gates: fast, targeted, verifiable

- For each changed feature, test only the affected slice first. Do not force a whole-app rewrite or a huge suite before useful P0 integration work.
- Repository tests: fake HTTP responses and test success, malformed/empty data, 401/422/500, timeout and mapping. Never call live production HTTP in unit tests.
- GetX controller tests: inject fake repositories; cover loading, error, retry, stale request races, onClose cleanup, and auth/cart invalidation where applicable. Reset GetX global registrations between tests to prevent cross-test leakage.
- Widget tests: verify the actual main interaction and loading/error/empty states. For checkout, add integration or manual device testing of the full path.
- Use existing test tooling first. Add `mocktail`, codegen or extra packages only when justified and requested/approved.
- On Windows PowerShell, prefer:

```powershell
dart format path\to\changed_file.dart
flutter analyze
flutter test test\features\your_feature_test.dart
```

- Do not run `dart format .` or mutate unrelated files without permission. Run release builds only when the feature or deadline warrants them.
- Report test **commands and actual results**, or explicitly say they were not executed. Never label a task 'verified' because the code looks correct.
- When a check fails, classify whether it existed before the change or is a regression, with evidence.
