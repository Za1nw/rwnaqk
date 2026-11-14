# Phase 08.1 — Architectural Document 04: Idempotency, Duplicate Prevention & Crash Recovery

## 1. Idempotency Architecture Overview

Mobile networks frequently experience connection timeouts, retry bursts, or packet loss during checkout submission. Without durable server-side idempotency, a client retrying a request after a network drop could create duplicate orders and multiply deductions.

### Idempotency Schema (`idempotent_requests`)
The system tracks requests in a dedicated database table:
- `user_id` (unsigned big integer, indexed, foreign key to `users`)
- `key` (string 100, composite index with `user_id`)
- `request_hash` (char 64, SHA-256 of canonicalized request payload)
- `status` (`pending`, `completed`, `failed`)
- `order_group_id` (nullable foreign key to `order_groups`)
- `response_code` (nullable integer, e.g. 201)
- `response_body` (json, full cached response payload)
- `locked_at` (timestamp, records when execution started)

---

## 2. Replay & Conflict Semantics

### Scenario 1: Exact Network Retry (Replay)
- **Conditions**: Same `user_id`, same `key`, identical `request_hash`, and status is `completed`.
- **Action**: Return cached `response_body` with HTTP 200 OK.
- **Stock Impact**: Zero stock is deducted. No duplicate order records are created.

### Scenario 2: Key Misuse with Modified Payload (Conflict)
- **Conditions**: Same `user_id`, same `key`, but different `request_hash`.
- **Action**: Immediate HTTP 409 Conflict rejection:
  ```json
  {
    "message": "تم استخدام نفس مفتاح العملية (Idempotency Key) مع بيانات طلب مختلفة."
  }
  ```

### Scenario 3: Stale Lock & Crash Recovery (Atomic CAS)
If a worker crashes or times out while processing an order, a record may remain in `pending` status.
- **Policy**: Locks older than 120 seconds are eligible for atomic recovery.
- **Atomic Compare-And-Swap (CAS)**:
  ```php
  $affected = IdempotentRequest::query()
      ->where('id', $existing->id)
      ->where('status', 'pending')
      ->where('locked_at', $existing->locked_at)
      ->update([
          'locked_at' => now(),
          'request_hash' => $payloadHash,
      ]);
  ```
- If `$affected > 0`, the current process acquires the stale lock safely without race conditions. If `$affected === 0`, another process won the race and HTTP 409 is returned.

