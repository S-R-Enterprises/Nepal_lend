# Stage 1 — First build & fix pass findings (branch `foundation/w1`)

Date: 2026-10-03

## Environment (flutter doctor -v)

| Item | Status | Impact |
|---|---|---|
| Flutter 3.47.5 stable / Dart 3.13.4 | ✓ | Matches `pubspec.yaml` `^3.13.4` |
| Windows 11 26H2 | ✓ | — |
| Android SDK 36 @ `%LOCALAPPDATA%\Android\sdk` | [!] | `cmdline-tools` missing, licence status unknown → risk for fresh APK build |
| Chrome | ✗ | Irrelevant (web not in v1 scope) |
| Visual Studio C++ components | [!] | Irrelevant (Windows desktop not in v1 scope) |
| Network resources | ✓ | — |

Note: Flutter SDK lives inside OneDrive (`OneDrive\Documents\flutter`) — file-lock/sync risk; consider moving to `C:\dev\flutter` (not blocking).

PATH: Flutter was not on user PATH; added `C:\Users\maske\OneDrive\Documents\flutter\bin` (persistent).

## Baseline (before edits)

- `flutter pub get` → exit 0 (30 packages; 5 outdated-but-incompatible noted)
- `flutter analyze` → **No issues found**
- `flutter test` → **24/24 passed**

## Fix pass (this commit)

| # | File | Change |
|---|---|---|
| 1 | `android/app/build.gradle.kts` | `namespace` + `applicationId`: `com.example.nepal_lend` → `np.nepallend.app`; removed template TODO |
| 2 | `android/app/build.gradle.kts` | Release signing now loads `android/key.properties` when present, falls back to debug keys |
| 3 | `android/.../MainActivity.kt` | Moved `kotlin/com/example/nepal_lend/` → `kotlin/np/nepallend/app/`, package updated |
| 4 | `AndroidManifest.xml` | launcher label `nepal_lend` → `NepalLend` |
| 5 | `web/index.html` | description, apple title, `<title>` → NepalLend |
| 6 | `web/manifest.json` | name/short_name/description → NepalLend |
| 7 | `linux/CMakeLists.txt` | `APPLICATION_ID` → `np.nepallend.app` |
| 8 | `.gitignore` | + `/android/key.properties`, `*.jks`, `*.keystore` (secret hygiene) |
| 9 | `android/key.properties.example` | new — release signing template |
| 10 | `README.md` | stock Flutter template → real project description |

## Known gaps (deliberately deferred — Stage 2/3 scope)

- **Dart package name** still `nepal_lend` (renaming touches every import; pairs with monorepo move)
- iOS `CFBundleDisplayName`/bundle id still template (iOS deferred until after Android launch)
- Desktop display names (`windows/`, `macos/`, `linux/` titles) still `nepal_lend` (desktop not in v1)
- Release signing falls back to **debug keys** until a real keystore + `key.properties` exist
- No flavors yet (Stage 3), no CI (Stage 6)

---

# Stage 3–4 — Environment & tooling findings

Date: 2026-10-03

- **Flutter `resValue` trap:** `productFlavors { resValue(...) }` fails with
  *"custom resource values, but the feature is disabled"* (Flutter's Gradle
  plugin disables AGP build feature `resvalues`). Fix: per-flavor source sets
  (`src/<flavor>/res/values/strings.xml`) instead.
- **Prisma npm tags:** `latest` = `8.0.0-rc.19` (pre-release). Stable line is
  `7.10.0` (dist-tag `prev`). Use `prisma@^7.10.0` + `@prisma/client@^7.10.0`.
- **Prisma 7 setup:** driver adapter mandatory (`@prisma/adapter-better-sqlite3`
  for SQLite), `prisma-client` generator with `output`, `prisma7.config.ts`
  holds the datasource URL (schema `datasource` block has no `url`), ESM only
  (`"type": "module"`).
- **TypeScript:** npm `latest` is 7.0.2 (native compiler); used for `tsc --noEmit`
  gate. `res.json()` is typed `unknown` — cast in tests.
- **npm audit (apps/api):** 4 highs were transitive Prisma CLI deps
  (`deepmerge-ts@7` via `@prisma/config`, `mysql2@3.15` via `prisma`), reported
  even with `--omit=dev`. **Resolved in Stage 6** with npm `overrides`
  (`deepmerge-ts ^8.0.2`, `mysql2 ^3.24.5`): audit = 0; Prisma
  generate/migrate/typecheck/tests re-verified green under the overrides.
- **CI (Stage 6):** `.github/workflows/ci.yml` — jobs: flutter (3.47.5
  analyze+test), api (npm ci + migrate deploy + typecheck + test + audit),
  spec (Prism boot + HTTP probes), secrets. Owner is a GitHub
  **Organization**, so the licensed `gitleaks/gitleaks-action` was avoided in
  favour of the free `zricethezav/gitleaks:latest` Docker image
  (`detect --source=/repo --redact`). Local pre-scan with gitleaks 8.30.1:
  11 commits, no leaks. `gh` CLI not installed on this machine; owner type
  checked via the public API.
- **No Docker / no local Postgres** on this machine → Prisma uses SQLite for
  dev (`apps/api/dev.db`, gitignored); Postgres swap documented in
  `apps/api/README.md`.
- **better-sqlite3@12.11.1** installed with prebuilt binary (VS C++ build
  tools absent per flutter doctor — did not need to compile).
- `npm install` in `apps/api` warns that install scripts (prisma, esbuild,
  better-sqlite3) are "not yet covered by allowScripts" (npm 11.19 supply-chain
  feature); scripts did run (client generated, native module loads).

---

# Auth vertical slice — findings

Date: 2026-10-03

- **Prisma 7 migrations:** `prisma migrate dev` does NOT regenerate the client
  (unlike v5/6) — run `npx prisma generate` manually after schema changes or
  the new models are missing from `@prisma/client` types.
- **KycStep composite key:** `@@id([userId, step])` needs an explicit
  back-relation field on `User` or Prisma errors on import.
- **Vitest + shared SQLite:** two test files opening `dev.db` concurrently can
  hit `SQLITE_BUSY`; `fileParallelism: false` in `vitest.config.ts` keeps the
  suite deterministic.
- **Dio interceptor order:** `LogInterceptor` added *before* the auth wrapper
  so dev logs don't print `Authorization` headers.
- **Mock adapter (in-process):** Dio drops the `/api/v1` base-path segment in
  `options.uri.path` for some requests → route with `endsWith('/auth/otp/…')`
  not `== '/api/v1/…'`. 204 responses must return an empty body **without**
  a JSON content-type or the transformer trips.
- **Bearer guard in mock:** `/me` + `/auth/logout` return 401 without
  `Authorization`, which is what proves the interceptor + `TokenStore` wiring
  in `test/auth_flow_test.dart` (mock otherwise ignores the token).
- **flutter_secure_storage in tests:** platform channel missing → static
  in-memory fallback in `TokenStore` (shared across instances, cleared in
  `setUp` to stop cross-test leakage).
- **Null-aware elements (Dart 3.13):** `{'name': ?name}` replaces
  `if (name != null) 'name': name` — the `use_null_aware_elements` lint is on
  by default and gates the analyze=0 CI job.
- **JWT:** `jose` (ESM, no deps) instead of `jsonwebtoken`; `AUTH_SECRET`
  defaults to a dev-only value in `src/config.ts` — production must set it.

---

# OTP delivery — findings

Date: 2026-10-03

- **No SMS was ever sent** (user-reported): `requestOtp` only logged the code.
  Added `SmsSender` (`src/services/sms.ts`): `console` (default) or `http`
  (POST `{to, from, text}` + `X-API_KEY`, provider chosen via `SMS_API_URL`).
  `SMS_PROVIDER=http` without `SMS_API_URL` throws; prod + `console` logs a
  loud one-time error (and never prints codes to prod logs).
- **`devCode` contract:** non-prod `/auth/otp/request` echoes the generated
  code (spec `OtpChallenge.devCode`) → the OTP screen shows a "tap to fill"
  dev hint, so registration is completable without SMS. Guarded by
  `config.isProd` on the server; the screen renders whatever it receives.
- **Send failures are 502:** `sms_failed` deletes the challenge (no
  undelivered guessable code) and maps to `502 {error:"sms_failed"}` — added
  to the spec as a response on `otp/request`.
- **DI for tests:** `setSmsSenderForTests()` lets `test/sms.test.ts` inject
  recording/broken senders; module state stays per-file (vitest isolation +
  `fileParallelism: false`).
