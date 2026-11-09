# Staging Deployment Plan & Execution Guide — Phase 5.1

**Project:** Rwnaqk E-Commerce Platform (متجر رونقك الإلكتروني)  
**Date:** 2026-11-09  
**DevOps Engineer:** Senior Laravel 13 DevOps Engineer & Flutter Release Specialist  
**Execution Target:** Isolated Staging Environment (`rwnaqk_staging` on Docker MySQL + Android Emulator)  
**Status:** **APPROVED & FULLY EXECUTED**

---

## 1. Deployment Architecture Overview

```text
+-------------------------------------------------------------------------+
|                        STAGING ARCHITECTURE TOPOLOGY                    |
+-------------------------------------------------------------------------+
|                                                                         |
|  +--------------------------------+   HTTP (Cleartext permitted)        |
|  |     Flutter GetX Client        | <============================+      |
|  |     (Android Emulator 5554)    |                              |      |
|  |     Package: com.example.      |                              |      |
|  |     rwnaqk_frontend            |                              |      |
|  +--------------------------------+                              |      |
|                 ||                                               |      |
|                 || (Routes: 10.0.2.2:8000 & 192.168.8.138:8000)   |      |
|                 \/                                               |      |
|  +------------------------------------------------------------+  |      |
|  |              Laravel 13 Application (Staging)              |==+      |
|  |    Daemon Process: php artisan serve --port=8000           |         |
|  |    Environment: APP_ENV=staging, APP_DEBUG=false           |         |
|  |    Health Endpoint: GET /up (HTTP 200 OK)                  |         |
|  +------------------------------------------------------------+         |
|                 ||                                                      |
|                 || TCP / Port 3306 (Docker)                             |
|                 \/                                                      |
|  +------------------------------------------------------------+         |
|  |                 MySQL 8.x InnoDB Container                 |         |
|  |    Database: rwnaqk_staging (69 Migrated Tables)           |         |
|  |    InnoDB Row-Level Locking (lockForUpdate)                |         |
|  +------------------------------------------------------------+         |
|                                                                         |
+-------------------------------------------------------------------------+
```

---

## 2. Step-by-Step Deployment Execution Workflow

### Step 1: Pre-Flight Verification & Cleanliness
- Verify Git workspace status for both `rwnaqk-backend` and `rwnaqk_frontend`.
- Confirm `da1b35a9357cb78569c19a0b6278be7e3d45f22e` (backend) and `d04c2927dbdb12d3dfeb56a089be6278fcc9ad91` (frontend) baselines.
- Ensure all sensitive environment files (`.env.staging`, `.env.production`) are listed in `.gitignore`.

### Step 2: Staging Database Creation
- Connect to Docker MySQL instance on port 3306.
- Issue command:
  ```sql
  CREATE DATABASE IF NOT EXISTS rwnaqk_staging CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  ```

### Step 3: Backend Configuration Provisioning
- Instantiate `.env.staging` with isolated settings:
  ```ini
  APP_NAME="متجر رونقك - Staging"
  APP_ENV=staging
  APP_DEBUG=false
  DB_DATABASE=rwnaqk_staging
  SESSION_DRIVER=database
  QUEUE_CONNECTION=database
  CACHE_STORE=database
  MAIL_MAILER=log
  ```
- Generate and assign independent `APP_KEY`.

### Step 4: Schema Migration
- Execute all pending database migrations against `rwnaqk_staging`:
  ```bash
  php artisan migrate --env=staging --force
  ```
- Verify 69 tables created successfully without errors.

### Step 5: Controlled Test Data Seeding
- Execute `StagingDatabaseSeeder`:
  - Administrative backoffice user: `admin@rwnaqk.com` / `password123`.
  - Customer profile: `customer@example.com` / `password123` with verified primary address in Sana'a.
  - Geo entities: Sana'a Governorate (`radius_meters = 50000`) and Bani Matar District (`radius_meters = 25000`).
  - Logistic Zone: Sana'a Urban Zone (Base Delivery Fee = 1,500 YER).
  - Product Catalog: Categories, brands, variations, and stocks (`stock_qty = 50`).

### Step 6: Backup & Disaster Recovery Verification Drill
- Run non-destructive backup drill:
  ```bash
  mysqldump --set-gtid-purged=OFF --single-transaction rwnaqk_staging > /tmp/staging_backup.sql
  mysql rwnaqk_staging_restore_test < /tmp/staging_backup.sql
  ```
- Compare table counts: both must equal exactly 69 tables.
- Drop temporary verification database `rwnaqk_staging_restore_test`.

### Step 7: Application Server Launch
- Start background HTTP server bound to `0.0.0.0`:
  ```bash
  php artisan serve --host=0.0.0.0 --port=8000 --env=staging
  ```
- Verify health check response via `GET /up`: returns 200 OK.

### Step 8: Client (Flutter) Configuration & Assembly
- In `rwnaqk_frontend/.env`, set:
  ```ini
  APP_ENV=staging
  ENABLE_MOCK_DATA=false
  API_BASE_URL=http://10.0.2.2:8000
  ```
- Add `<uses-permission android:name="android.permission.INTERNET"/>` and `android:usesCleartextTraffic="true"` to `android/app/src/main/AndroidManifest.xml`.
- Execute static analysis: `flutter analyze` (Must report 0 issues).
- Assemble Android APK:
  ```bash
  flutter build apk --debug
  ```
- Deploy to connected Android emulator (`emulator-5554`):
  ```bash
  adb install -r build/app/outputs/flutter-apk/app-debug.apk
  adb shell am start -n com.example.rwnaqk_frontend/.MainActivity
  ```

### Step 9: Real HTTP End-to-End Acceptance Test
- Execute automated HTTP verification script `test_staging_e2e_real_http.php` covering all 15 checkout, payment, idempotency, security, and cancellation scenarios.
- Verify 100% pass rate.

---

## 3. Rollback & Contingency Plan Summary

- If migration fails: restore snapshot using verified `mysqldump` script.
- If HTTP server fails: inspect `storage/logs/laravel.log`, verify port 8000 availability, and restart process.
- If Flutter client encounters cleartext rejection: verify `android:usesCleartextTraffic="true"` in `AndroidManifest.xml`.

