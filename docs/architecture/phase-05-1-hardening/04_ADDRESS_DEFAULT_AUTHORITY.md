# Address Default Authority & Backend Integrity

## 1. Problem Statement: Client-Side Fabrication

Prior to Phase 05.1, the frontend contained logic that automatically promoted remaining customer addresses to "default" if the designated default address was deleted:
```dart
// Legacy client-side fallback:
list[0] = list[0].copyWith(isDefault: true);
```
Additionally, `AddressesState.defaultAddress` contained a fallback:
```dart
// Legacy fallback:
ShippingAddress? get defaultAddress {
  try {
    return addresses.firstWhere((a) => a.isDefault);
  } catch (_) {
    return addresses.isNotEmpty ? addresses.first : null;
  }
}
```

### Risks of Client-Side Elevation:
1. **Contract Inconsistency**: Laravel's database might have distinct business rules regarding default addresses (e.g., leaving default unset until the customer explicitly designates one, or managing it via backend database triggers).
2. **Checkout Misrouting**: If a customer deletes their primary home address and has a work address, silently elevating the work address to default could cause accidental shipments to unintended locations.
3. **State Desynchronization**: The client would assume an address is default when the backend database considers it non-default, causing mismatched display and payload errors.

---

## 2. Architectural Corrections

### A. Strict Backend Authority in `AddressesNotifier`
When an address is deleted via `AddressesNotifier.deleteAddress(id)`:
```dart
// lib/modules/customer/providers/addresses_providers.dart
final nextList = state.addresses.where((a) => a.id != addressId).toList();
state = state.copyWith(
  addresses: nextList,
  selectedAddress: state.selectedAddress?.id == addressId ? null : state.selectedAddress,
  isLoading: false,
);
```
No remaining address is promoted to `isDefault: true` on the client. The frontend strictly reflects the data returned by Laravel.

### B. Pure Nullable Default Getter in `AddressesState`
`AddressesState.defaultAddress` returns `null` if no address in `addresses` explicitly has `isDefault == true`:
```dart
// lib/modules/customer/models/addresses_state.dart
ShippingAddress? get defaultAddress {
  try {
    return addresses.firstWhere((a) => a.isDefault);
  } catch (_) {
    return null;
  }
}
```

### C. Clean Selected Address Invalidation
When the currently selected checkout address is deleted, `selectedAddress` is set to `null`, requiring the user to explicitly select an address or confirm a default address during checkout.

---

## 3. Decision Matrix

| Scenario | Previous Behavior | Corrected Behavior (Phase 05.1) | Rationale |
|---|---|---|---|
| Delete non-default address | Removed from list | Removed from list | Unchanged |
| Delete default address | Elevated `addresses[0]` to default | Default becomes `null` unless backend returns new default | Backend remains sole source of truth |
| Delete selected address | Silently fell back to `addresses.first` | `selectedAddress` cleared to `null` | Eliminates accidental order misrouting |
| Empty address list | `defaultAddress` is `null` | `defaultAddress` is `null` | Consistent |

---

## 4. Test Evidence

Validated in `test/phase5_1_hardening_test.dart`:
- `Deleting default address does NOT fabricate a client-side default`: **PASSED**.
- `Deleting selected checkout address clears selection instead of silently picking arbitrary address`: **PASSED**.

