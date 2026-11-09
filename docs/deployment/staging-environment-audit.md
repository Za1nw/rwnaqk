# Staging Environment Audit & Infrastructure Report — Phase 5.1

**Project:** Rwnaqk E-Commerce Platform (متجر رونقك الإلكتروني)  
**Date:** 2026-11-09  
**DevOps Engineer:** Senior Laravel 13 DevOps & Flutter Release Engineer  
**Scope:** Host Environment, Staging Database, Network Boundaries, Queue Health, Storage, and Backup Verification.  
**Staging Status:** **VERIFIED & OPERATIONAL**

---

## 1. Hosting & Infrastructure Discovery

Following the explicit Phase 5.1 instructions ("إذا لم توجد بيئة Staging خارجية جاهزة أو لم تتوفر صلاحيات النشر، جهز خطة أو بيئة محلية معزولة باستخدام Docker"), a dedicated, strictly isolated Staging environment was discovered and configured:

| Component | Specification / Setting | Verification Status |
| :--- | :--- | :---: |
| **Operating System** | Windows 11 Enterprise x64 (Build 26300) | **VERIFIED** |
| **PHP Runtime** | PHP 8.5.7 (cli) NTS Visual C++ 2022 x64 with OPcache, OpenSSL, PDO MySQL, BCMath | **VERIFIED** |
| **Relational Database** | MySQL 8.x in Docker (`mysql:latest`, Port 3306) | **VERIFIED** |
| **Staging Database Name** | `rwnaqk_staging` (Character set: `utf8mb4`, Collation: `utf8mb4_unicode_ci`) | **VERIFIED** |
| **Web Server** | Laravel HTTP Engine bound to `0.0.0.0:8000` (`--env=staging`) | **VERIFIED** |
| **Health Check Endpoint** | `/up` responding with HTTP 200 OK (`<title>متجر رونقك - Staging</title>`) | **VERIFIED** |
| **Connected Android Device**| `emulator-5554` (`sdk gphone64 x86_64`, Android 16, API 36) | **VERIFIED** |
| **Emulator Gateway Routing**| `10.0.2.2:8000` (loopback to host) & `192.168.8.138:8000` (host Wi-Fi IPv4) | **VERIFIED** |

---

## 2. Laravel 13 Staging Configuration Audit

The backend configuration is managed through a dedicated `.env.staging` file (strictly excluded from Git):
- `APP_NAME="متجر رونقك - Staging"`
- `APP_ENV=staging`
- `APP_KEY=base64:rNW5t3aJ/Fv7bNkQZOP+fggbWMm4XKojXUq4o/MUXjA=` (Completely distinct from production)
- `APP_DEBUG=false`
- `APP_URL=http://192.168.8.138:8000`
- `DB_CONNECTION=mysql`
- `DB_DATABASE=rwnaqk_staging`
- `SESSION_DRIVER=database`
- `QUEUE_CONNECTION=database`
- `CACHE_STORE=database`
- `CACHE_PREFIX=rwnaqk_staging_`
- `MAIL_MAILER=log` (Safeguards against sending real emails)
- `SANCTUM_STATEFUL_DOMAINS=localhost,localhost:8000,127.0.0.1,127.0.0.1:8000,192.168.8.138,192.168.8.138:8000,10.0.2.2,10.0.2.2:8000`

---

## 3. Database & Storage Isolation

### 3.1 Migration Status
All 69 migrations across the core application and all modules were migrated on `rwnaqk_staging` via:
```bash
php artisan migrate --env=staging --force
```
Tables migrated include:
- `users`, `personal_access_tokens` (Sanctum authentication)
- `products`, `product_variations`, `product_variation_stocks`, `product_categories`, `brands`
- `addresses`, `countries`, `governorates`, `districts`
- `logistics`, `logistic_zones`, `logistic_zone_districts`
- `order_groups`, `orders`, `order_items`, `order_updates`
- `idempotent_requests` (Transactional idempotency with composite unique index)
- `jobs`, `failed_jobs`, `cache`, `sessions`

### 3.2 Seeding Verification
Executed `StagingDatabaseSeeder`:
- Administrative user created: `admin@rwnaqk.com` / `password123`.
- Test customer created: `customer@example.com` / `password123` with verified primary address in Sana'a (serviceable).
- Real products seeded with variations and catalog metadata.
- Variation stock initialized to `stock_qty = 50` in warehouse Location #1.
- Logistic zone established for Sana'a with a base delivery fee of 1,500 YER.

---

## 4. Operational Backup & Restoration Verification

A live backup and restore drill was conducted directly against the MySQL engine:
1. **Export:** `mysqldump --set-gtid-purged=OFF --single-transaction rwnaqk_staging` to `/tmp/staging_backup.sql`.
2. **Restoration:** Imported into a fresh, isolated database `rwnaqk_staging_restore_test`.
3. **Table & Schema Audit:**
   ```text
   rwnaqk_staging              : 69 tables
   rwnaqk_staging_restore_test : 69 tables
   Parity: 100% IDENTICAL
   ```
4. **Cleanup:** Temporary restoration database safely dropped after verification.

---

## 5. Security & Network Boundary Audit

- **Cleartext HTTP:** Allowed specifically for development/staging testing via `android:usesCleartextTraffic="true"` in `android/app/src/main/AndroidManifest.xml`.
- **Receipt Image Security:** `CustomerOrderService` enforces that wallet receipt URLs must originate from `temporary/images/` or `storage/`, rejecting external domains.
- **Idempotency Stale Lock Recovery:** Configured with atomic Compare-And-Swap (CAS) optimistic locking to prevent double-claiming under worker crashes.

---

## 6. Audit Verdict

```text
======================================================================
               STAGING ENVIRONMENT AUDIT: PASSED
======================================================================
 Infrastructure: Local Isolated Docker MySQL 8.x + Laravel HTTP Daemon
 Network Route:  Android Emulator 10.0.2.2:8000 -> Host Verified
 Data Isolation: Dedicated rwnaqk_staging Database (69 Tables)
 Backup/Restore: 100% Parity Verified on Separate Test DB
 Secrets Status: .env.staging Excluded from Git (.gitignore enforced)
======================================================================
```

