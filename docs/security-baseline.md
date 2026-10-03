# Security baseline (v1)

Working baseline for Foundations Week 1–2. Items marked *(planned)* are
designed but not yet implemented; the rest are live in the repo today.

## Secrets & repository hygiene

- No secrets in the repo; `.env`, `key.properties`, `*.jks`, `*.pem` gitignored
  (`.gitignore`); templates provided (`.env.example`, `key.properties.example`).
- **gitleaks** secret scan in CI (Docker image — the licensed gitleaks *action*
  is not used because the owner is a GitHub Organization) plus a verified
  local pre-scan (8.30.1: 11 commits, no leaks).
- Android release signing falls back to debug keys until a real keystore
  exists — release Play builds must not ship until `key.properties` is in place.

## Authentication & session

- Phone-OTP login/registration (contract: `/auth/otp/*`); OTP TTL + rate
  limiting *(planned)*; dev/mock accepts `123456`.
- Bearer access tokens + refresh tokens (rotation *(planned)*).
- Mobile stores session role/state via `flutter_secure_storage`
  (Keychain/Keystore-backed), never in plain prefs. Global mutable session
  statics were removed in favour of the Riverpod `AuthController`.
- Admin console will require 2FA *(planned)*.

## Money integrity

- **Integer paisa everywhere** in the API and ledger — never floats.
- Append-only double-entry ledger *(planned)*; wallet transactions are
  immutable entries, corrections by reversal, not edit.
- Repayment/funding endpoints will be idempotency-keyed *(planned)* to make
  retries safe on flaky mobile networks.

## Payments

- **No custody:** lender funds move through a licensed partner; NepalLend
  never holds money. `PaymentProvider` interface is swappable
  (`PAYMENT_MODE=simulated|partner|tracker`), default **simulated** until
  partner contracts + compliance sign-off exist.
- Webhook authenticity: signature verification on partner callbacks
  *(planned)*.

## Data protection (KYC / PII)

- KYC documents and personal data are sensitive: encrypted at rest, access
  logged, retention limits defined before real data lands *(planned)*.
- API error responses never leak stack traces or internal IDs (structured
  `{error, message}` only).
- Profile phone masked in UI (`9841***567` convention).

## API hardening

- Input validation against the OpenAPI schemas *(planned middleware)*.
- HTTPS-only in staging/prod (local dev is HTTP on localhost).
- Rate limiting on auth endpoints *(planned)*.
- Dependency gates: `npm audit --audit-level=high` in CI (currently 0 after
  `overrides` for Prisma's transitive ranges); lockfiles committed for npm and
  pub; Flutter deps pinned by `pubspec.lock`.

## Delivery pipeline

- CI on every push/PR: Flutter analyze+test, API typecheck+test+audit, spec
  mock boot, secret scan (`.github/workflows/ci.yml`).
- Per-step local gate discipline: `flutter analyze` = 0, `flutter test` = 30,
  `tsc --noEmit` = 0, API tests = 3.

## Open items before any real-money beta

1. Threat model workshop (STRIDE) covering auth, ledger and payment callbacks.
2. External penetration test.
3. Lawyer/regulatory review sign-off (offline track).
4. Key management for production signing secrets + rotation runbook.
