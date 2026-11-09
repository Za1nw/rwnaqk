# Staging Configuration Checklist — Phase 5.1

**Project:** Rwnaqk E-Commerce Platform (متجر رونقك الإلكتروني)  
**Date:** 2026-11-09  
**DevOps Engineer:** Senior Laravel 13 DevOps Engineer & Flutter Release Specialist  
**Status:** **100% COMPLIANT**

---

## 1. Laravel 13 Staging Configuration Checklist

| Configuration Key | Requirement | Staging Value | Verification Status |
| :--- | :--- | :--- | :---: |
| `APP_NAME` | Meaningful staging identifier | `"متجر رونقك - Staging"` | **COMPLIANT** |
| `APP_ENV` | Must be strictly staging | `staging` | **COMPLIANT** |
| `APP_KEY` | Independent cryptographic key | `base64:rNW5t3aJ/Fv...` | **COMPLIANT** |
| `APP_DEBUG` | Must be disabled for realistic testing | `false` | **COMPLIANT** |
| `APP_URL` | Staging host address | `http://192.168.8.138:8000` | **COMPLIANT** |
| `DB_CONNECTION` | Relational MySQL driver | `mysql` | **COMPLIANT** |
| `DB_HOST` | Database host | `127.0.0.1` | **COMPLIANT** |
| `DB_PORT` | MySQL port | `3306` | **COMPLIANT** |
| `DB_DATABASE` | Isolated staging database | `rwnaqk_staging` | **COMPLIANT** |
| `SESSION_DRIVER` | Database-backed sessions | `database` | **COMPLIANT** |
| `QUEUE_CONNECTION` | Database-backed queues | `database` | **COMPLIANT** |
| `CACHE_STORE` | Database-backed caching | `database` | **COMPLIANT** |
| `CACHE_PREFIX` | Staging isolated prefix | `rwnaqk_staging_` | **COMPLIANT** |
| `FILESYSTEM_DISK` | Local storage with public link | `local` | **COMPLIANT** |
| `MAIL_MAILER` | Safe log driver (no real emails sent) | `log` | **COMPLIANT** |
| `SANCTUM_STATEFUL_DOMAINS` | Allow emulator & local IP access | `localhost,127.0.0.1,10.0.2.2,192.168.8.138` | **COMPLIANT** |

---

## 2. Flutter Client Staging Configuration Checklist

| Configuration Key | Requirement | Staging Value | Verification Status |
| :--- | :--- | :--- | :---: |
| `APP_NAME` | Display name | `رونقك` | **COMPLIANT** |
| `APP_ENV` | Environment identifier | `staging` | **COMPLIANT** |
| `ENABLE_MOCK_DATA` | Mock data explicitly disabled | `false` | **COMPLIANT** |
| `API_BASE_URL` | Android Emulator gateway | `http://10.0.2.2:8000` | **COMPLIANT** |
| `API_TIMEOUT_SECONDS` | Network timeout | `30` | **COMPLIANT** |
| `API_VERSION_PREFIX` | API versioning | `/api/v1` | **COMPLIANT** |
| `CUSTOMER_AUTH_PREFIX`| Authentication route prefix | `/api/v1/customer/auth` | **COMPLIANT** |
| `GEO_LOOKUP_PREFIX` | Geographic lookup prefix | `/api/v1/geo` | **COMPLIANT** |
| `STORAGE_AUTH_TOKEN_KEY` | Token key name in secure storage | `auth_token` | **COMPLIANT** |

---

## 3. Android Platform & Network Security Checklist

| Item | Requirement | Verification Method | Status |
| :--- | :--- | :--- | :---: |
| **INTERNET Permission** | Required for network requests | `<uses-permission android:name="android.permission.INTERNET"/>` in main manifest | **COMPLIANT** |
| **Cleartext Traffic** | Allowed for local staging testing (`10.0.2.2:8000`) | `android:usesCleartextTraffic="true"` in main manifest | **COMPLIANT** |
| **Emulator Reachability** | `10.0.2.2` loopback responding | Verified via `nc` and HTTP request | **COMPLIANT** |
| **App Startup** | Launches without crashes | Tested on `emulator-5554` (PID 6779) | **COMPLIANT** |
| **Secure Token Storage**| Tokens persisted via FlutterSecureStorage | Verified by unit & repository suites | **COMPLIANT** |
| **Zero Server Secrets** | No private API keys or database passwords compiled | Codebase audit of `rwnaqk_frontend/lib` | **COMPLIANT** |

---

## 4. Git Hygiene & Secret Exclusion Checklist

- [x] `.env.staging` added to `.gitignore` and verified uncommitted.
- [x] No database passwords or private API tokens in git status.
- [x] Release Candidate commit hashes recorded:
  - Backend: `da1b35a9357cb78569c19a0b6278be7e3d45f22e`
  - Frontend: `d04c2927dbdb12d3dfeb56a089be6278fcc9ad91`
- [x] Old Git tags (`v0.1.0-mock-frontend-frozen`) preserved intact without modification.

