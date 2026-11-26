# NepalLend — Build Plan

**Source:** `NepalLend – Build-From-Scratch Blueprint.docx` (v2.0, 23 Nov 2026)
**Prepared:** 23 Nov 2026
**Repository state at planning time:** default Flutter starter project (`lib/main.dart` only, Dart SDK `^3.13.4`, `flutter_lints`, no backend, no tests).

---

## 1. Read of the situation

The blueprint describes a **full production product**: Flutter app + Firebase Auth + Node/TypeScript API + Prisma/PostgreSQL on Render, with a payments partner, KYC, an append-only ledger, FCM, Sentry, and a 15-week roadmap with a legal/regulatory track.

The current folder is a **fresh Flutter assignment project**, so nothing from the blueprint has been built yet. That is an advantage: we can set the structure correctly from day one instead of refactoring.

### Scope decision (read this first)

| Track | What it delivers | When to choose it |
|---|---|---|
| **A — Demo app (recommended for this assignment)** | Fully clickable Android app, all main screens, **mock backend** (`ENV=mock`), integer-paisa money math, ledger/risk/EMI logic in Dart, local persistence, widget + unit tests. No cloud bills, no SMS, no legal gate. | Now — college assignment / portfolio demo / prototype |
| **B — Production system** | Blueprint exactly: Firebase phone auth, Node API, Postgres on Render, real KYC storage, partner payments, CI/CD, admin console, release/beta. | Only after Track A is green **and** you have Blaze billing, a Render paid plan, and counsel/partner sign-off |

**This plan details Track A end-to-end and keeps Track B as a clearly marked extension in §9.** Every Track A component is designed so it can be swapped for the real HTTP/Firebase implementation without rewriting screens.

If you actually want Track B as the primary target, start at §9 and use the blueprint's stages 2–12 — but do not begin it before the Stage 0 decisions in §3 are settled.

---

## 2. Product in one paragraph

NepalLend is a P2P lending marketplace: **borrowers** (KYC-verified) request small loans, **lenders** fund them fully or in fractions, borrowers repay in instalments with interest, and every paisa is recorded in an append-only double-entry ledger. NepalLend itself never lends or holds money — a licensed payments partner does. The app must therefore make **trust, exact amounts, and clear risk** visible on every screen.

### Non-negotiable rules (from blueprint §5.1, §6.1, §7.1, §11)

1. **Integer paisa only** — never `double` for money. 1 NPR = 100 paisa. Rates in basis points (14% = 1400).
2. **Every journal sums to zero** — balances are derived from ledger entries, never from a mutable balance field (a cached value is only an optimisation).
3. **Confirmation + receipt** for every money move; summary shows amount, fee, interest, total.
4. **Risk is never colour alone** — colour + letter grade (A–D) + text label.
5. **Role and KYC are enforced in the data/provider layer**, not by hiding buttons in the UI.
6. **Phone number comes from the verified token** when Firebase is added — never from a request body.
7. All lists have loading / empty / error / offline states; strings go in ARB files from day one (Nepali-ready).
8. Minimum 48 dp touch targets, bottom primary actions, works at 360 dp width and 1.3× font scale.
9. No secrets in git. No hard-coded OTP in any production API.

---

## 3. Stage 0 — Decisions & setup (before writing feature code)

Settle these in `docs/decisions.md`; the blueprint lists them as open (§13):

- [ ] Interest model + platform fee: reducing balance with a share of interest, **or** origination fee. *(Recommended for demo: reducing balance, 10% of interest as fee — set in one constants file.)*
- [ ] Risk grades/rates: A 12%, B 14%, C 17%, D 20% p.a.; A ≥80, B 65–79, C 50–64, D 35–49, <35 rejected. *(Blueprint examples — confirm before coding the risk service.)*
- [ ] Funding window (e.g. 14 days), late fee, default policy.
- [ ] Languages at launch: English first, ARB scaffold for Nepali.
- [ ] Repo layout decision (see below).

### Repo layout decision

The blueprint assumes a monorepo (`apps/mobile`, `apps/api`, `packages/api-spec`, `infra`, `docs`, `.github/workflows`). Since this repo is a fresh single Flutter app and the deliverable is an Android assignment, **keep Flutter at the root** and add the other folders alongside it. Map the blueprint names like this:

| Blueprint path | This repo |
|---|---|
| `apps/mobile/**` | root (`lib/`, `android/`, `pubspec.yaml`, `test/`) |
| `packages/api-spec/openapi.yaml` | `spec/openapi.yaml` (Track B) |
| `apps/api/**` | `api/**` (Track B) |
| `infra/**` | `infra/**` (Track B) |
| `docs/**` | `docs/**` |
| `.github/workflows/**` | `.github/workflows/**` |

Do this only once. If you later want to follow the blueprint byte-for-byte, move the Flutter files into `apps/mobile/` before Stage 1 — not after.

### Tooling check

- [ ] `flutter --version` → Flutter 3.47.x / Dart 3.13.x (matches `pubspec.yaml`).
- [ ] Android SDK + cmdline-tools licences accepted; `flutter doctor` clean for Android.
- [ ] Git initialised; `.gitignore` covers `.env`, `key.properties`, `*.jks`, service-account JSON, `google-services.json`, `build/`, `.dart_tool/`.
- [ ] Create `docs/decisions.md` with the Stage 0 answers above.

**Exit check:** `flutter doctor` passes for Android; decisions recorded; `.gitignore` verified.

---

## 4. Track A — Phase-by-phase build

Work each phase as a **vertical slice**: model → provider/service → screen → mock data → tests → `flutter analyze` green. Do not build all screens first and wire logic later.

### Phase 1 — Foundation: dependencies, design system, navigation shell

**Goal:** app boots into a themed shell with routing and a mock data layer; no feature logic yet.

- [ ] Add dependencies to `pubspec.yaml`:
  `flutter_riverpod`, `go_router`, `dio`, `intl`, `flutter_secure_storage`, `shared_preferences`, `image_picker`, `uuid`, `collection`; dev: `mocktail`.
  *(Firebase packages are Track B only — do not add them yet.)*
- [ ] Create folder tree:
  ```
  lib/
    main.dart                 entry: Environment + Firebase-less bootstrap
    app.dart                  ProviderScope + MaterialApp.router
    core/
      config/env.dart         ENV=mock|dev|staging|prod, base URL, amount caps
      network/api_client.dart Dio with auth-token interceptor + 401 retry
      network/mock_adapter.dart  HttpClientAdapter returning seeded responses
      router/app_router.dart   go_router routes + auth/KYC/role redirects
      theme/app_theme.dart     colour roles, typography, spacing, radius
      theme/ui.dart            shared component library
      utils/money.dart         parse/format integer paisa, EMI, pro-rata
      utils/format_npr.dart    lakh grouping: 1,25,000
      utils/error_mapper.dart  error code → user message
    data/
      models/                 User, KycStep, Loan, Stake, Instalment, Txn, ...
      mock/mock_db.dart       seeded JSON state in SharedPreferences
      repositories/           interfaces + mock implementations
    features/                 auth, kyc, borrower, lender, wallet,
                              notifications, profile, help  (each:
                              presentation/ + data/)
  ```
- [x] Design tokens in `core/theme/app_theme.dart`: primary, surface, background, outline, success, warning, error, risk-low/medium/high; display/title/body/label/caption; spacing 4/8/12/16/24/32; radius 8/16.
- [x] Components in `core/theme/ui.dart`: `AppButton`, `AppInput`, `AppCard`, `RiskBadge`, `ProgressBar`, `AmountText`, `StatusChip`, `EmptyState`, `ErrorState`, `SkeletonLoader`, `BottomSheetScaffold`, `StepIndicator`.
- [x] Live `/style-guide` screen showing every component (blueprint §5.2).
- [x] `go_router` route map from blueprint §5.3/§5.4 with redirect guards (auth → KYC → role → shell). Stub screens are fine for now.
- [x] `formatNPR` + `Money` unit tests (lakh grouping, rounding, no float drift).

**Exit check:** `flutter analyze` and `flutter test` green; app runs with `flutter run --dart-define=ENV=mock`; style-guide screen renders; deep links to every route work.

### Phase 2 — Auth & role slice (Firebase Phone OTP)

**Goal:** sign-in flow works end-to-end with a real SMS code, persists across restarts, role gates the shell.

- [x] Screens: `/splash`, `/onboarding`, `/login` (phone entry, `+977` prefix, validation), `/otp` (6-digit, resend timer, error states), `/role-selection`.
- [x] `AuthRepository` interface with `FirebaseAuthRepository` as the default at runtime; `MockAuthRepository` retained only for tests without Firebase.
- [x] Firebase project `nepal-lend`, Android app `com.example.nepal_lend`, generated `firebase_options.dart` / `google-services.json`, debug SHA-1 registered.
- [x] Firebase Auth exception codes mapped to stable `AppFailure` codes/messages; ID token attached by `ApiClient` and refreshed on 401.
- [x] FCM permission/token registration and foreground notification display; payloads share the in-app `NotificationEventBus`.
- [x] `POST /auth/session`, `GET/PATCH /me` mock endpoints in `mock_adapter.dart`; user upsert keyed by phone.
- [x] Splash redirect from auth state stream; role stored in the user model, set once.
- [x] Widget tests: phone validation, wrong code, resend timer, role selection; provider tests for redirect logic.

**Exit check:** sign in with demo number, pick borrower, kill app, reopen → still signed in on the correct shell; switching to lender shows lender tabs.

### Phase 3 — KYC slice

**Goal:** four-step KYC checklist with document capture and review states; verified state unlocks borrowing/funding.

- [x] `data/models/kyc.dart`: four steps — citizenship, selfie, personal_details, bank_statement; statuses `not_started | in_review | verified | rejected`.
- [x] Screens: `/kyc` checklist with progress, `/kyc/:step` capture form (`image_picker`, preview, retry, upload progress). Files stored locally in mock mode; Cloud Storage signed URLs in Track B.
- [x] `MockKycRepository`: `GET /me/kyc`, document record creation, step submit, simulated admin decision (a dev-only "approve all" action shown only in mock mode).
- [x] Rule: `kycState == verified` only when all four steps verified; `requireVerifiedUserProvider` enforces `kyc_required` for loan/funding actions.
- [x] Tests: state machine transitions, rejected-step retry, controller/repository actions, gate, and checklist/step widget states.

**Exit check:** submit four steps, approve, state turns verified; unverified users cannot reach the borrower/lender shells, and `requireVerifiedUserProvider` throws `kyc_required` before any loan or funding action. The actual **Request a loan** and **Fund** buttons arrive with Phases 5–6 and will call that gate.

### Phase 4 — Ledger & wallet simulation

**Goal:** the money core — the most important part to get right.

- [x] `core/utils/money.dart` + `data/repositories/ledger_repository.dart`:
  - accounts: `user_wallet`, `loan_escrow`, `platform_fee`
  - `postJournal(kind, entries)` asserting Σ amount = 0; append-only list in `MockDb`; reversal helper.
  - balance query = sum of entries for account (no mutable balance column).
- [x] `data/models/payment_intent.dart` + idempotency key store (uuid per money action; replay returns stored receipt).
- [x] `PaymentProvider` interface + `SimulatedPaymentProvider` (instant success + a failure toggle for testing).
- [x] Screens: `/lender/wallet` (balance + history), `/lender/wallet/topup`, withdraw, `/wallet/transactions/:id`.
- [x] Confirmation sheet + receipt screen for top-up/withdraw.
- [x] Property tests: random journal sequences always sum to 0; wallet balances never negative; idempotent replay posts no second journal.

**Exit check:** top up NPR 10,000 → wallet shows 10,000; withdraw 2,500 → 7,500; ledger query matches; duplicate idempotency key creates no extra entry. ✅ Verified by `test/features/ledger_repository_test.dart` and `test/data/ledger_property_test.dart`.

### Phase 5 — Borrower flow: request, risk, agreement

**Goal:** verified borrower requests a loan and sees an explainable risk grade and EMI schedule.

- [x] Models: `Loan` (status machine `draft → pending_review → open → funded → active → repaid`, plus rejected/expired/cancelled/overdue/defaulted), `RiskAssessment`, `RiskFactor`, `Agreement`, `Instalment`.
- [x] `RiskService` v1 (rule-based, integer math): affordability (instalment/income <25% good, 25–40% neutral, >40% bad), amount vs 12× income, tenor, KYC strength, history. Returns score, grade, rate bps, and **plain-sentence factors** (`model_version` stored).
- [x] `EMISchedule` generator in integer paisa; last instalment absorbs rounding so the schedule sums exactly to principal + interest.
- [x] Screens: `/borrower/home`, `/borrower/request-loan` (purpose, amount, tenor, income), `/borrower/risk-review` (grade + band + factors + rate), `/borrower/loan-agreement` (terms version/hash, e-sign, triggers disbursement journal + schedule creation).
- [x] Flag grade D / high amount → `pending_review` (mock admin approval action).
- [x] Tests: risk boundary values, EMI schedule totals, status transitions reject illegal jumps.

**Exit check:** verified borrower requests NPR 2,00,000 / 12 months, sees grade + rate + exact instalment; after Phase 6 funding completes, signs agreement, loan becomes `active` with 12 instalments and the escrow→wallet journal recorded. ✅ Verified by `test/features/loan_repository_test.dart`, `test/features/risk_service_test.dart`, and `test/features/loan_controller_test.dart`.

### Phase 6 — Lender flow: browse, fund, portfolio

**Goal:** lenders discover loans, fund fractions, and track stakes.

- [x] Screens: `/lender/home`, `/lender/browse` (filters risk band, amount range, tenor; sort), `/lender/loan-details` (risk factors, funding progress, verified borrower reference), `/lender/fund-loan` (amount sheet min NPR 1,000, interest, wallet-after, fee, confirm), receipt, `/lender/portfolio`, `/stakes/:id`.
- [x] `FundingService`: min stake, remaining-amount guard in one transaction-like operation, journal `wallet → loan_escrow`, stake row, `fundedPaisa` update, idempotent by key.
- [x] Mock deadline/expiry job: unfunded loan past deadline → escrow reversed to lenders, status `expired`.
- [x] Concurrency-minded logic even in mock: recompute remaining before committing; test 10 parallel fund calls never exceed the loan amount.
- [x] Tests: over-funding, below-minimum, insufficient balance, exact escrow total, status → `funded`, role/KYC gates, lender widget flow.

**Exit check:** two lenders fund one loan to 100%; escrow equals amount; status `funded`; borrower can now sign the agreement. ✅ Verified by `test/features/funding_service_test.dart`, `test/features/funding_repository_test.dart`, `test/features/loan_repository_test.dart`, and `test/widget/lending_screens_test.dart`.

### Phase 7 — Repayments & notifications

**Goal:** close the money loop.

- [x] `/borrower/repay`: next instalment (principal + interest split), schedule list, pay with simulated eSewa/Khalti, confirmation + receipt.
- [x] `RepaymentService`: pro-rata split across stakes by **largest remainder** so parts sum exactly; fee journal; mark instalment paid; close loan on last instalment; overdue marker the day after `due_date`.
- [x] `Notifier`: in-app notification rows on one `NotificationEventBus` (local events and FCM payloads); `/notifications`, mark one / mark all read; badge count.
- [x] Mock scheduled jobs: reminders (3 days before, on day, after), overdue marking, nightly reconciliation check that all journals sum to 0; mock-only demo panel drives a fast-forward clock.
- [x] Tests: pro-rata exactness with awkward ratios, late payment, loan closure, notification state, repayment/inbox widget flows and job endpoints.

**Exit check:** run a 3-month loan with a fast-forward demo clock; every paisa reconciles; notifications appear at the right steps. ✅ Verified by `test/features/repayment_service_test.dart`, `test/features/repayment_repository_test.dart`, and `test/widget/repayment_screens_test.dart`.

### Phase 8 — Polish, localisation & QA

**Goal:** meet blueprint §5.6 quality bar.

- [x] Loading / empty / error / offline states on every list and detail screen (toggle in mock menu to exercise each).
- [x] 360 dp and 1.3× font-scale checks; touch targets ≥48 dp; semantic labels on icons and `RiskBadge`.
- [x] Move all UI strings to `lib/l10n/*.arb` (English first; add a sample Nepali ARB to prove readiness).
- [ ] Widget test per screen: renders + main action; unit tests for all money logic; `flutter analyze` clean; coverage of services >80%.
- [x] `README.md` rewritten with actual setup/run/demo steps (replace the Flutter template text).
- [ ] Screenshot pass of the key screens for the assignment submission.

**Exit check:** `flutter analyze && flutter test` green; demo script runs without a backend; all screens have the four states.

---

## 5. Suggested screen/route inventory (Track A)

| Phase | Route | Screen |
|---|---|---|
| 1 | `/style-guide` | Component gallery |
| 2 | `/splash`, `/onboarding`, `/login`, `/otp`, `/role-selection` | Auth flow |
| 3 | `/kyc`, `/kyc/:step` | KYC checklist, document capture |
| 4 | `/lender/wallet`, `/lender/wallet/topup`, `/wallet/transactions/:id` | Wallet, top-up, withdraw, detail |
| 5 | `/borrower/home`, `/borrower/request-loan`, `/borrower/risk-review`, `/borrower/loan-agreement` | Borrower flow |
| 6 | `/lender/home`, `/lender/browse`, `/lender/loan-details`, `/lender/fund-loan`, `/lender/portfolio`, `/stakes/:id` | Lender flow |
| 7 | `/borrower/repay`, `/notifications` | Repay, notifications |
| shared | `/profile`, `/help`, `/settings` | Profile, help & safety, settings |

Shells: borrower tabs `Home | Loans | Profile`; lender tabs `Home | Browse | Portfolio | Wallet | Profile`.

---

## 6. Testing strategy

| Level | Tool | Focus |
|---|---|---|
| Unit | `flutter_test` + `mocktail` | money/EMI/pro-rata, risk scoring, ledger zero-sum, status machine, idempotency |
| Widget | `flutter_test` | render + main action per screen, states, 360 dp/1.3× font scale |
| Provider | `ProviderContainer` overrides | redirects, KYC/role gates |
| Mock flow | `ENV=mock` | full demo without Firebase/backend |
| CI (Track B) | GitHub Actions | `flutter analyze && flutter test`, API typecheck/test on Postgres, OpenAPI lint, npm audit, secret scan |

Property tests are mandatory for the ledger: generate random valid journals and assert each journal sums to zero.

---

## 7. Definition of done for the assignment (Track A)

- [ ] Fresh clone → `flutter pub get` → `flutter run --dart-define=ENV=mock` works.
- [ ] All screens in §5 reachable and usable with seeded demo data.
- [ ] Complete demo script: sign in → choose lender → KYC → top up → fund a loan → (switch borrower) request → risk review → sign → repay → receipt → notification.
- [ ] All money math uses integer paisa; tests prove zero-sum ledger and exact schedules.
- [ ] `flutter analyze` and `flutter test` pass with zero issues.
- [ ] README documents setup, demo steps, architecture, and known mock-mode limits.
- [ ] No secrets, no real user data, no hard-coded OTP in code.

---

## 8. Risks & mitigations (condensed from blueprint §12)

| Risk | Mitigation in this plan |
|---|---|
| Money bugs | Integer paisa, zero-sum assertions, property tests, receipts, no mutable balances |
| Scope creep | Track A v1 list is fixed; iOS/web/group lending/credit bureau are out of scope |
| Mock mode feels fake | Seeded realistic data, failure toggles, all states implemented |
| Firebase SMS cost ~$0.21/SMS in Nepal (Track B) | Test numbers in dev/staging, region policy NP only, App Check, rate limits, billing alerts, persistent sessions |
| Free Render Postgres deleted after 30 days (Track B) | Paid instance for staging/prod; free only for throwaway prototypes |
| Regulatory/legal delay (Track B) | Simulated payments now; legal + partner track starts in parallel; no real money before sign-off |
| Firebase vendor lock-in (Track B) | Keep `firebase_uid` + phone in our own user table; only the auth middleware touches Firebase |

---

## 9. Track B — Production extension (blueprint stages, unchanged)

Only start after Track A's exit checks pass and the Stage 0 decisions are final. Follow the blueprint's own order; each stage ends with its stated exit check:

1. **Stage 1** monorepo/CI/local env (if you chose the monorepo layout in Stage 0) — `apps/mobile`, `apps/api`, `packages/api-spec`, `infra/docker-compose.yml`, GitHub Actions.
2. **Stage 2** Firebase projects (dev/staging/prod), per-flavor Android apps, SHA fingerprints, test numbers, NP-only SMS policy, App Check, private Storage bucket, service accounts; Render Postgres (paid, Singapore) + web service; `/api/v1/health` green.
3. **Stage 3** API foundation: config validation, Prisma 7 + pg adapter, firebase-admin, middleware (request id, logger, rate limit, token verify, loadUser, requireRole, requireKyc, validate, errors), first migration, Sentry.
4. **Stage 4** real auth (client side done): Firebase phone OTP, FIRAuth UID/phone profile mapping, ID-token interceptor and FCM token registration are in place. Remaining: server-side `POST /auth/session`, `/me`, logout and device-token persistence with `firebase-admin` verification.
5. **Stage 5** real KYC with signed upload URLs; admin decision endpoint; audit log of document access.
6. **Stage 6** real ledger schema (immutable tables, revoke UPDATE/DELETE), idempotency middleware, payment provider adapter + webhooks.
7. **Stage 7–9** loans/risk, funding (row lock), agreements, disbursement, repayments, pro-rata, jobs, FCM notifier.
8. **Stage 10** admin console (React web recommended) with 2FA plan.
9. **Stage 11–12** hardening (threat model, load test, Nepali strings, pen test, restore drill) and release (Play App Signing, Data Safety form, internal → closed → beta).
10. **Parallel from Week 1** lawyer/NRB sandbox, payments partner contract, company registration, terms/privacy/loan agreement, data retention plan.

Replace Track A's mock repositories with HTTP implementations behind the same interfaces; screens and providers stay unchanged.

---

## 10. Immediate next actions (in order)

Phases 1–8 plus the Firebase client integration are implemented: `flutter analyze`
is clean, localization/accessibility/states are in place, and the debug APK
builds. Next:

1. Enable **Phone** in Firebase console → Authentication → Sign-in method.
2. Verify OTP on a device/emulator with a real or Firebase test number.
3. Add a widget test per screen and check service coverage above 80%.
4. Take the screenshot pass and finalise the README for submission.
5. Run `flutter analyze` + `flutter test` + `flutter build apk --debug` again.

**Rule for every phase:** no phase is "done" until its exit check passes and CI is green.
