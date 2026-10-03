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
