# Rollback Plan & Disaster Recovery Runbook — Phase 5.1

**Project:** Rwnaqk E-Commerce Platform (متجر رونقك الإلكتروني)  
**Date:** 2026-11-09  
**DevOps Engineer:** Senior Laravel 13 DevOps Engineer & Database Reliability Specialist  
**Target Environment:** Staging & Pre-Production Deployment  
**Status:** **OPERATIONAL & DRILL-VERIFIED**

---

## 1. Rollback Triggers & Decision Matrix

A rollback must be initiated immediately if any of the following triggers are met during deployment or staging verification:

| Severity | Trigger Event | Action |
| :---: | :--- | :--- |
| **P0** | **Migration Failure or Schema Corruption** | Stop deployment, restore database from verified snapshot. |
| **P0** | **Overselling or Concurrency Breach** | Revert backend deployment, restore inventory stock snapshot. |
| **P0** | **Staging Server Crash / Service Unavailable (`500/502`)** | Restart daemon; if persistent, roll back to prior Git baseline commit. |
| **P1** | **Price Drift Rejection in Standard Checkout** | Revert quote engine service modifications, clear application cache. |
| **P1** | **Client Networking / Cleartext Failure on Android** | Revert `AndroidManifest.xml` or update network security config. |

---

## 2. Backend Rollback Procedures

### 2.1 Database Snapshot Restoration
If data integrity is compromised:
```bash
# 1. Drop corrupted staging database
docker exec -i mysql mysql -uroot -proot -e "DROP DATABASE IF EXISTS rwnaqk_staging; CREATE DATABASE rwnaqk_staging CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 2. Restore verified baseline dump
docker exec -i mysql sh -c "mysql -uroot -proot rwnaqk_staging < /path/to/staging_baseline_backup.sql"

# 3. Clear application caches
php artisan cache:clear --env=staging
php artisan config:clear
php artisan route:clear
```

### 2.2 Code Rollback via Git
```bash
# 1. Reset working directory to prior verified baseline commit
git reset --hard da1b35a9357cb78569c19a0b6278be7e3d45f22e

# 2. Restart Laravel HTTP Server Daemon
Stop-Process -Name php -Force
php artisan serve --host=0.0.0.0 --port=8000 --env=staging
```

---

## 3. Flutter Client Rollback Procedures

### 3.1 Reverting Client Configuration
```bash
# 1. Reset frontend working directory to frozen baseline
cd rwnaqk_frontend
git reset --hard d04c2927dbdb12d3dfeb56a089be6278fcc9ad91

# 2. Clean build artifacts and restore dependencies
flutter clean
flutter pub get

# 3. Rebuild and deploy baseline APK
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## 4. Post-Rollback Validation Checklist

After executing any rollback procedure, the following verification checks must pass:
1. `GET /up` returns HTTP 200 OK (`<title>متجر رونقك - Staging</title>`).
2. Run database table count query: confirms 69 tables present in `rwnaqk_staging`.
3. Run `php artisan test --filter=ConcurrencyAndTransactionSafetyTest`: must pass 8/8 tests.
4. Run `flutter test`: must pass 54/54 tests.
5. Launch app on emulator: verifies clean startup and home catalog rendering.

