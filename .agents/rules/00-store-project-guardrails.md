---
trigger: always_on
description: "Mandatory guardrails for this existing Flutter e-commerce app using GetX and a Laravel API under a near-term release deadline."
---
# Store project — non-negotiable rules

## Current baseline
- This is an **existing, largely designed Flutter storefront** using **GetX**. Laravel API integration is still being implemented. Preserve existing functionality and user-visible UI as the default.
- **Do not migrate** to Riverpod, BLoC, Provider, or a new router, rewrite navigation, change the Flutter app structure wholesale, or upgrade GetX/Flutter/Dart without explicit user request. Future migration readiness is a goal; current migration is not.
- Inspect the real repository (`pubspec.yaml`, `pubspec.lock`, directories, bindings, routes, controllers, API shape, tests) before making technical claims. **Do not assume** backend endpoints or features exist. If an artifact is absent, call it out as missing rather than fabricating it.
- Prioritize **shipping a safe end-to-end order**: catalog → product → cart → address/shipping → server-side quote → order → confirmation. Defer cosmetic refactoring, optional features, and dependency churn.

## Mandatory workflow
1. For analysis/audit requests, **read only**: report concrete findings with `path:line`, priority, and smallest viable fix. Do not change code.
2. For implementation tasks, inspect relevant code and choose **minimal, localized changes**. Preserve existing routes, widget contracts, names, behavior, and styles unless specifically asked to change them.
3. Do not silently reorganize files, rename controller public methods, reformat the whole project, modify schema, remove packages, or change public API contracts.
4. Distinguish confirmed observations from assumptions. If needed, document the smallest proposed API contract for backend agreement; never claim a proposed endpoint already works.
5. Add tests for materially affected behavior. Run or suggest focused `dart format`, `flutter analyze`, and relevant `flutter test` (Windows PowerShell instructions when local execution is unavailable). Do not claim checks passed if not run.
6. Summarize changed files, retained behavior, risks, checks actually run, and any pending backend dependencies.

## Security & change safety
- Never print, commit, hardcode, or copy secrets, signing credentials, access tokens, private environment values, or personal customer information into logs or reports.
- No destructive commands, data migrations, production deployment, payments, actual production orders, or edits to remote systems without explicit approval.
- Do not expose customer information in debug logs or error UI. Never put admin/service credentials in Flutter.
- Respect existing translation, RTL, theme, accessibility, responsive behavior, and release build configuration.

## Scope of this ruleset
- These are **project rules**, not an instruction to run an automatic migration or launch a full audit on every message.
- When installed, the separately provided `/flutter-getx-migration-ready` skill may be used for deeper GetX audits or workflows. Rules remain active without that skill.
