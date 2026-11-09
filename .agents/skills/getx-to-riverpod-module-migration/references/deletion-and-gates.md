# Gate-based deletion and rollback policy

## Before any deletion

1. Confirm a prior commit/tag and clean worktree or documented in-flight changes.
2. Identify all old-file import references, GetX registration/route references, tests, generated code, and dynamic lookup strings.
3. Prove new provider receives identical inputs and emits equivalent outputs/errors.
4. Unit/widget tests, core regressions, and real staging E2E for auth, cart, checkout, orders.
5. Rename/move/delete only necessary files in a separate cleanup diff. No blanket deletion of `lib/core`, `lib/modules` or `.dart_tool` as part of migration.
6. Run tests again **after deletion** and check `git diff --check`.
7. Update `docs/migration/migration-ledger.md` and module-state list.

## File decision table

| Condition | Decision |
|---|---|
| File still imported or instantiated | KEEP |
| Shared GetX object still used by any legacy module | KEEP + quarantine behind adapter |
| Pure repository/fake/data model needed by tests | KEEP, even if GetX-era file |
| Old controller no refs and new route/state validated | REMOVE in cleanup commit |
| Duplicate constants with differing endpoint values | STOP, reconcile contract first |
| Test fails after deletion | RESTORE file and rollback module cutover |
| `get` dependency still referenced anywhere | KEEP dependency |

## Go/No-Go per module

```text
[ ] Behavior and UI parity
[ ] State single writer
[ ] No GetX references within converted feature boundaries except documented bridge
[ ] All dependencies injected through providers/interfaces
[ ] No credentials in logs / UI provider state
[ ] No stale cross-user caches
[ ] Loading/error/empty/timeout states covered
[ ] flutter analyze PASS
[ ] flutter test PASS
[ ] relevant integration tests PASS
[ ] real staging API/Flutter acceptance for critical modules PASS
[ ] old file reference inventory CLEAN
[ ] deletion cleanup diff reviewed
[ ] rerun tests after deletion PASS
[ ] migration ledger updated
```

For each module, output an explicit gate result and stop. The final removal of GetX requires a separate whole-app quality gate (routing, i18n, deep links, overlays, navigation stack, widgets, all tests).
