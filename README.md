# NepalLend

Peer-to-peer lending marketplace for Nepal (Android / Flutter). Borrowers
request verified loans, lenders fund them in fractions, repayments are split
across stakes, and every paisa is recorded in an append-only double-entry
ledger. NepalLend never lends its own money and never holds lender funds.

**Source of truth:** `NepalLend – Build-From-Scratch Blueprint.docx`
**Execution plan:** [`BUILD_PLAN.md`](BUILD_PLAN.md)
**Decisions:** [`docs/decisions.md`](docs/decisions.md)

## Current status — Phases 1–8 + Firebase auth/FCM ✅

Implemented so far:

- Riverpod 3 state management, `go_router` navigation with auth → role → KYC
  redirect guards, and borrower/lender bottom-nav shells.
- Design tokens and component library (`AppButton`, `AppCard`, `RiskBadge`,
  `FundingProgress`, `AmountText`, `StatusChip`, `EmptyState`, `ErrorState`,
  `SkeletonLoader`, `BottomSheetScaffold`, `StepIndicator`) plus a live
  `/style-guide` screen.
- Exact integer money utilities: NPR parsing, lakh grouping (`1,25,000`),
  BigInt EMI calculation, reducing-balance schedules, largest-remainder
  pro-rata splits, and fee calculation.
- `ApiClient` (Dio) with token interceptor, 401 retry hook, idempotency-key
  support and a `MockAdapter` so the app works with no backend.
- Session restore through Firebase Auth; the local profile row keeps role/KYC
  state while the mock API serves ledgers, loans, wallet and notifications.
- A mock API for
  `/health`, `/auth/session`, `/me`, `/me/kyc`, loan applications/agreements,
  `/wallet`, `/loans/:id/repay`, `/notifications` and the `/jobs/*` endpoints.
- Auth slice: onboarding slides, phone entry with `+977` validation, 6-digit
  SMS OTP with a 60-second resend timer, inline error states, role selection,
  and Firebase session restore across restarts.
- `AuthRepository` interface with a Firebase Phone OTP implementation. The mock
  implementation remains only for backend-free unit/widget tests.
- KYC slice: four-step checklist, document capture with local preview,
  personal-details form, rejected-step retry, demo approve/reject controls,
  and a provider-level `kyc_required` gate for loan and funding actions.
- Mock KYC API (`GET /me/kyc`, document record, step submit, admin decision)
  backed by `MockDb`; verification is derived only from all four steps.
- Money core: append-only zero-sum journals, derived wallet balances, reversal
  helper, payment intents with idempotency replay, and a simulated payment
  provider with a failure toggle.
- Wallet slice: balance + history, top-up/withdraw with a confirmation sheet,
  receipts with ledger entries, and a provider-level KYC gate on every money
  move.
- Borrower loan slice: rule-based risk grade with plain-sentence factors, exact
  integer-paisa repayment preview, grade-D/high-value review flag, agreement
  version/hash with typed e-sign, and a 12-instalment schedule created on
  signing.
- Mock loan API and repository with borrower/role/KYC gates; signing posts an
  idempotent zero-sum `loan_escrow → user_wallet` disbursement journal, but only
  after lenders have fully funded the loan.
- Lender funding slice: browse filters/sort, loan details, amount sheet with
  wallet-after and interest/fee preview, portfolio, and stake receipts.
  `FundingService` serializes money moves, recomputes remaining before commit,
  posts `user_wallet → loan_escrow`, creates a stake, and is idempotent by key.
  Expired loans reverse escrow back to lenders exactly once.
- Repayment slice: `/borrower/repay` with instalment schedule, simulated
  eSewa/Khalti confirmation and receipt. `RepaymentService` splits each payment
  across lender stakes with largest-remainder pro-rata, books one zero-sum
  journal (borrower wallet → lender wallets + platform fee), marks the
  instalment paid, closes the loan on the final instalment, and is idempotent
  by key.
- Notifications slice: persisted rows plus a single `NotificationEventBus`.
  Local events and Firebase Cloud Messaging payloads share the same inbox,
  unread badge, mark-one/mark-all-read and deep links. Foreground FCM messages
  are displayed with `flutter_local_notifications`; funding, disbursement,
  repayment, reminders and overdue events write through one `NotificationService`.
- Mock scheduled jobs: reminders, overdue marking and nightly journal
  reconciliation, exposed through `POST /jobs/*` and a mock-only demo tools
  panel with a fast-forward clock (`+1 day`, `+7 days`, `+1 month`).
- Unit/widget/property tests for money math, auth, redirects, KYC, ledger
  invariants, idempotency, risk scoring, loan state transitions, wallet and
  loan controllers, repositories, funding concurrency, repayments, jobs,
  notifications, and screens.
- Full UI localisation through Flutter `gen-l10n`: English ARB is the source
  of truth, a sample Nepali ARB proves readiness, and `L10n.of(context)`
  falls back to English in isolated widget tests.
- Four screen states (loading, empty, error, offline) behind one shared
  `ScreenStateView`, with a mock-only switcher in the demo tools panel so
  every state can be inspected without a backend.
- Accessibility pass: ≥48 dp touch targets, semantics on tappable cards,
  `RiskBadge`, funding progress and status chips, plus 360 dp / 1.3×
  font-scale checks in widget tests.

`flutter analyze` → **No issues found**. `flutter test --concurrency=1` →
**144/144 tests passing**. `flutter build apk --debug` →
**build/app/outputs/flutter-apk/app-debug.apk**.

> Android build notes: this project lives on `D:` while the pub/Gradle caches
> are on `C:`. Kotlin incremental compilation fails across drives, so
> `android/gradle.properties` sets `kotlin.incremental=false`.
> `flutter_local_notifications` 23 and `androidx.core` 1.19 require
> `compileSdk = 37` and core library desugaring, both configured in
> `android/app/build.gradle.kts`.

## Setup

```powershell
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=ENV=mock
```

### Firebase setup (already applied in this repo)

- Project: `nepal-lend` (number `561524440176`), account
  `rohan15december2005shrestha@gmail.com`.
- Android application ID: `com.example.nepal_lend`.
- Config: `android/app/google-services.json` and `lib/firebase_options.dart`
  (generated by `flutterfire configure`).
- Debug SHA-1 registered:
  `7A:9C:E7:AB:D3:7E:FA:28:39:54:86:09:D0:9D:D4:F5:7B:65:33:5E`.
- **Manual console step still required:** Firebase console → *Build →
  Authentication → Sign-in method* → enable **Phone**. Add any test phone
  numbers there if you do not want to receive SMS while grading.

`ENV=mock` controls only the local data layer (ledgers, loans, KYC, jobs).
Phone sign-in is always Firebase when the app starts normally; `flutter test`
uses the mock repository because Firebase is not initialised in the test VM.

To point the app at a real API later:

```powershell
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

The Android emulator reaches your computer at `10.0.2.2`, not `localhost`.
On a physical phone use your machine's LAN IP.

## Demo walkthrough (mock mode)

1. App opens on the splash screen and restores any saved session.
2. Onboarding → **Get started** → phone entry.
3. Enter a valid Nepali mobile (e.g. `9800000000`) → **Send code**. Firebase
   sends a real SMS via `+977`; in Firebase console you can add a test number
   with a fixed verification code instead.
4. Enter the SMS code → role selection. Wrong/expired codes and rate limits are
   reported inline through the mapped Firebase Auth error codes.
5. Choose **borrower** or **lender** (the choice is saved and locked).
6. The four-step verification checklist opens. Submit citizenship, selfie,
   personal details, and bank statement. In mock mode use **Approve all steps**
   (or approve/reject each step from its detail screen) → the matching shell
   opens only after all four steps are verified.
7. As a verified borrower, open **Borrower home** → **Request a loan**. Enter
   purpose `Business inventory`, amount `200000`, tenor `12`, income `50000`,
   then **See my risk grade**. The review screen shows grade A at 12% p.a. and
   the exact monthly instalment. A grade-D or high-value request is flagged
   for review; use **Demo approve request** to continue.
8. As a verified lender, open **Browse loans**. Filter by risk band, amount or
   tenor, open a loan, then **Fund this loan**. Enter at least NPR 1,000 (the
   remaining amount is prefilled); the sheet shows your interest share, the
   10% fee and wallet-after. Confirm to open a stake receipt with links to the
   funding journal and `/stakes/:id`. **Portfolio** lists your stakes.
   Funding debits the lender wallet and credits `loan_escrow:<loanId>`; a
   replayed idempotency key never posts a second journal.
9. Two lenders (or ten parallel calls in the tests) can fill one loan. At
   100% the loan status becomes **funded** and the escrow equals the loan
   amount. A loan past its 14-day deadline can be expired with
   `POST /jobs/expire-loans`, which reverses escrow back to each lender once.
10. As the verified borrower, continue to the agreement, tick the terms
    checkbox, type your full name and sign. Signing is blocked until the loan
    is funded; after that the loan becomes **active**, 12 instalments are
    generated, and a disbursement receipt opens with the balanced
    escrow→wallet journal. A retry never disburses twice.
11. In the lender **Wallet** tab, **Top up** `10000`, review, confirm, then
    **Withdraw** `2500`. The balance becomes **NPR 7,500** and each transaction
    opens a receipt with its balanced journal entries.
12. As the borrower, tap **Make a repayment** on the home screen (or any active
    loan). Review the instalment preview — principal, interest and the 10%
    platform fee — choose eSewa or Khalti, then pay. The receipt shows one
    zero-sum journal: your wallet is debited, lender wallets are credited
    pro-rata by stake, and the fee goes to `platform_fee`. Replaying the same
    idempotency key never pays twice. The final instalment closes the loan.
13. Open the bell badge (borrower or lender home) → `/notifications`. Use the
    mock **Demo tools** panel to advance the clock by a day/week/month and run
    **Reminders**, **Mark overdue** and **Reconcile**. Watch the right
    notifications appear ("Payment in 3 days", "Payment overdue", "Loan fully
    repaid"), mark them read, and use **Reconcile** to verify all journals are
    balanced. Track B replaces the panel with trusted server time and real
    schedulers.
14. In the same **Demo tools** panel, use **Screen state** to force Loading,
    Empty, Error or Offline on any list/detail screen, then return to Normal.
15. Open `/style-guide` from the router or a deep link to inspect every
    component (reachable while signed in).

> Role is locked after step 5. To walk both sides in one app session, sign out
> and sign in with a different phone for the lender, or clear app data between
> borrower and lender runs. The automated tests seed both roles directly.

No backend server is needed: wallet moves, lender funding, loan disbursement
and repayments are simulated ledger entries and no real money moves. Firebase
Phone Auth and FCM are live, so a project with Phone sign-in enabled and a
reachable device are required for the sign-in step. Use Firebase test numbers
to avoid SMS costs. The fast-forward clock changes only demo timestamps.

If the splash screen ever appears stuck, the demo restores its session from
`MockDb` with a 3-second timeout and then falls back to the login screen. No
secure-storage plugin is used in `ENV=mock`, so old Android devices cannot block
startup with a biometric/storage plugin error.

## Architecture

```
lib/
  core/
    config/    env.dart, product_rules.dart
    firebase/  firebase_bootstrap.dart (initializeApp + FCM background handler)
    network/   api_client.dart, mock_adapter.dart
    router/    app_router.dart, app_shell.dart
    theme/     app_theme.dart, ui.dart (component library)
    utils/     money.dart, demo_clock.dart, demo_ui_state.dart,
               format_npr.dart, error_mapper.dart
  l10n/        app_en.arb, app_ne.arb, generated app_localizations*.dart,
               l10n.dart (test-safe lookup)
  data/
    mock/      mock_db.dart
    models/    app_user.dart, app_notification.dart, enums.dart, kyc.dart,
               loan.dart, ledger.dart, payment_intent.dart
    repositories/ ledger_repository.dart, loan_repository.dart,
                 funding_repository.dart, repayment_repository.dart
  features/
    auth/      data/auth_controller.dart, auth_repository.dart,
               firebase_auth_repository.dart, firebase_token_provider.dart,
               mock_auth_repository.dart (tests only)
    kyc/       data/kyc_controller.dart, kyc_gate.dart,
               presentation/kyc_checklist_screen.dart, kyc_step_screen.dart
    wallet/    data/wallet_controller.dart, payment_provider.dart,
               presentation/wallet_screen.dart, wallet_action_screen.dart,
               wallet_confirmation_sheet.dart, transaction_receipt_screen.dart
    loans/     data/loan_controller.dart, risk_service.dart, loan_terms.dart,
               presentation/borrower_home_screen.dart, request_loan_screen.dart,
               risk_review_screen.dart, loan_agreement_screen.dart, loan_ui.dart
    lending/   data/funding_service.dart, lending_controller.dart,
               presentation/lender_home_screen.dart, lender_browse_screen.dart,
               loan_details_screen.dart, fund_loan_screen.dart,
               lender_portfolio_screen.dart, stake_detail_screen.dart,
               lending_ui.dart
    repayments/ data/repayment_service.dart, repayment_controller.dart,
               presentation/repayment_screen.dart
    notifications/ data/notification_service.dart, notification_event_bus.dart,
               push_notification_service.dart, push_registration.dart,
               notifications_controller.dart,
               presentation/notifications_screen.dart, demo_tools_panel.dart,
               notification_badge.dart
    styleguide/presentation/style_guide_screen.dart
  shared/      widgets/placeholder_screen.dart
test/          core, data, features, widget tests
```

Every money change will pass through a ledger service inside one transaction;
screens never mutate balances directly. See `BUILD_PLAN.md` §2 for the full
rule set and §4 for the remaining phases.

## Routes (current)

| Route | Screen |
|---|---|
| `/splash` | Session restore |
| `/onboarding`, `/login`, `/otp` | Onboarding, phone entry, OTP |
| `/role-selection` | Borrower / lender choice (set once) |
| `/kyc` | Four-step verification checklist |
| `/kyc/:step` | Document capture or personal-details form |
| `/borrower/home`, `/borrower/profile` | Borrower shell (`home` lists applications) |
| `/borrower/loans` | Placeholder loan list |
| `/borrower/request-loan` | Loan request form |
| `/borrower/risk-review/:id` | Grade, factors, rate and exact instalment |
| `/borrower/loan-agreement/:id` | Terms, e-sign and disbursement receipt |
| `/borrower/repay`, `/borrower/repay/:id` | Repayment preview, simulated payment and receipt |
| `/lender/home`, `/lender/browse`, `/lender/portfolio`, `/lender/wallet`, `/lender/profile` | Lender shell; browse has filters/sort |
| `/lender/loan-details/:id` | Risk factors, progress and verified borrower reference |
| `/lender/fund-loan/:id` | Stake sheet with interest, fee and wallet-after |
| `/stakes/:id` | Stake detail with funding/reversal receipt links |
| `/lender/wallet/topup`, `/lender/wallet/withdraw` | Simulated money moves with confirmation |
| `/wallet/transactions/:id` | Receipt with balanced journal entries |
| `/style-guide` | Component gallery |
| `/notifications` | Live inbox, unread badge, read actions and mock demo tools |
| `/help` | Shared stub |

## Localisation and demo state switcher

All user-facing copy lives in `lib/l10n/app_en.arb`; `app_ne.arb` is a sample
Nepali translation proving the setup. `flutter pub get` regenerates
`app_localizations.dart` automatically because `l10n.yaml` and
`flutter: generate: true` are configured. Switch the device locale to `ne`
to see the sample translations; everything else falls back to English.

In mock mode the notifications screen's **Demo tools** panel includes a
**Screen state** switcher (Normal / Loading / Empty / Error / Offline). It
feeds the shared `ScreenStateView` used by list and detail screens, so all four
states are inspectable without disconnecting the network. Track A always reads
real async state when the switch is on **Normal**; Track B omits the panel.

## What is not built yet

Phases 1–8 are complete: borrower/loan, ledger/wallet, funding/escrow,
repayments, notifications, mock jobs, localisation and the final QA pass all
work in `ENV=mock`. Firebase Phone OTP and FCM are now wired in; the remaining
Track B work is the Node API, PostgreSQL on Render, real KYC storage/admin
console and payments partner, documented in `BUILD_PLAN.md` §9.
