# Product decisions

Source: blueprint §8.2 and §13. These are the values used by the current code.
They are **provisional for the demo** — confirm them with your advisor or
lawyer before any real money moves.

| Decision | Chosen value | Where it lives |
|---|---|---|
| Delivery track | A — demo app with `ENV=mock` first; production extension later | `BUILD_PLAN.md` |
| Repo layout | Flutter app at repo root; `api/`, `spec/`, `infra/`, `docs/` added later | `BUILD_PLAN.md` §3 |
| Interest model | Reducing balance, equal instalments, integer paisa; final instalment absorbs rounding | `lib/core/utils/money.dart` |
| Platform fee | 10% of the interest portion of each instalment (`1000` bps of interest) | `lib/core/config/product_rules.dart` |
| Risk grades | A ≥80, B 65–79, C 50–64, D 35–49, <35 rejected | `lib/core/config/product_rules.dart` |
| Rates by grade | A 12%, B 14%, C 17%, D 20% p.a. | `lib/core/config/product_rules.dart` |
| Minimum stake | NPR 1,000 (100000 paisa) | `lib/core/config/product_rules.dart` |
| Minimum loan | NPR 10,000; cap NPR 5,00,000 in beta | `lib/core/config/product_rules.dart` |
| Funding window | 14 days; expired loans reverse escrow to lenders | `lib/core/config/product_rules.dart` |
| Risk factors | Affordability, size vs income, tenor, KYC strength, history | `lib/features/loans/data/risk_service.dart` |
| Risk model | `v1`, 100 points: affordability 30, amount 20, tenor 10, KYC 20, history 20; grade/rate stored with the assessment | `lib/features/loans/data/risk_service.dart` |
| Loan state machine | `draft → pending_review → open → funded → active → repaid`; illegal jumps rejected in code | `lib/data/models/loan.dart` |
| Agreement | Deterministic terms `v1` plus FNV-1a hash; typed name is the demo e-signature | `lib/features/loans/data/loan_terms.dart` |
| Signing prerequisite | Agreement signing requires `status == funded` and `fundedPaisa >= amountPaisa`; unfunded loans are rejected in the mock API | `lib/data/models/loan.dart`, `lib/core/network/mock_adapter.dart` |
| Disbursement | Signing then posts a zero-sum `loan_escrow:<loanId> → user_wallet:<borrowerId>` journal, idempotent by loan id | `lib/core/network/mock_adapter.dart` |
| Lender funding | Stake debits `user_wallet:<lenderId>` and credits `loan_escrow:<loanId>` as a zero-sum `fund` journal; a `Stake` row and `fundedPaisa` update commit together, idempotent by key | `lib/features/lending/data/funding_service.dart` |
| Parallel funding | Mutations are serialized; remaining amount is recomputed inside the lock so 10 parallel NPR 20,000 stakes cannot over-fund a NPR 2,00,000 loan | `lib/features/lending/data/funding_service.dart` |
| Expiry reversal | `POST /jobs/expire-loans` reverses active stakes back to lender wallets once, marks stakes `returned`, resets `fundedPaisa`, and sets status `expired` | `lib/features/lending/data/funding_service.dart`, `lib/core/network/mock_adapter.dart` |
| Lender gates | Browse/fund/stake endpoints require `UserRole.lender` and verified KYC; the controller repeats the gate before changing state | `lib/core/network/mock_adapter.dart`, `lib/features/lending/data/lending_controller.dart` |
| Languages | Flutter `gen-l10n` with `lib/l10n/app_en.arb` (source of truth) and a sample `app_ne.arb`; `L10n.of(context)` falls back to English outside the app for tests | `l10n.yaml`, `lib/l10n/`, `lib/app.dart` |
| UI states | Shared `ScreenStateView` resolves real loading/error/empty plus a mock-only forced loading/empty/error/offline override; production builds ignore the override | `lib/core/theme/ui.dart`, `lib/core/utils/demo_ui_state.dart`, `lib/features/notifications/presentation/demo_tools_panel.dart` |
| Accessibility | ≥48 dp touch targets, ≥360 dp/1.3× font-scale layouts, semantics on tappable cards, `RiskBadge` and status/funding indicators | `lib/core/theme/ui.dart`, `test/widget/phase8_polish_test.dart` |
| Money storage | Integer paisa only; no `double` in ledgers or balances | `lib/core/utils/money.dart` |
| Identity | Firebase Phone OTP is the default when `Firebase.initializeApp()` has run; `MockAuthRepository` is retained only for backend-free tests. Firebase UID and phone are copied into the local profile row, and the ID token is the API bearer credential | `lib/features/auth/data/firebase_auth_repository.dart`, `lib/features/auth/data/auth_repository.dart` |
| Firebase project | `nepal-lend` under `rohan15december2005shrestha@gmail.com`; Android ID `com.example.nepal_lend`; debug SHA-1 registered. Phone sign-in must be enabled in the Firebase console because the CLI does not expose that provider toggle | `lib/firebase_options.dart`, `android/app/google-services.json` |
| Session storage | Firebase owns the persistent session. `MockDb` caches role/KYC/profile fields keyed by `firebaseUid`; startup restore has a 3 s timeout and falls back to signed-out so a plugin failure cannot trap the splash screen | `lib/features/auth/data/firebase_auth_repository.dart`, `lib/features/auth/data/auth_controller.dart` |
| Router refresh | `GoRouter.refreshListenable` is driven by a Riverpod listener on `authProvider`, so the splash redirect re-runs when restore/login/role/KYC changes without rebuilding the router | `lib/core/router/app_router.dart`, `test/widget/app_router_test.dart` |
| KYC (demo) | Four steps; verified only when all four are approved; mock reviewer and `kyc_required` provider gate | `lib/data/models/kyc.dart`, `lib/features/kyc/data/kyc_gate.dart` |
| Payments (demo) | Simulated provider with failure toggle; licensed partner only after legal clearance | `lib/features/wallet/data/payment_provider.dart` / Track B |
| Ledger writes | Append-only zero-sum journals; balances are derived from entries; every money action carries an idempotency key | `lib/data/models/ledger.dart`, `lib/data/mock/mock_db.dart` |
| Repayment journal | One zero-sum `JournalKind.repayment` per instalment: borrower wallet debit, net lender wallet credits and a `platform_fee` credit; idempotent by key | `lib/features/repayments/data/repayment_service.dart` |
| Repayment split | Principal and interest split by `Money.splitProRata()` (largest remainder) so parts sum exactly; fee is 10% of interest, split across lender interest shares | `lib/core/utils/money.dart`, `lib/features/repayments/data/repayment_service.dart` |
| Loan closure | Final instalment moves `overdue → active → repaid` (the state machine forbids `overdue → repaid` directly); the loan is fully repaid only when all instalments are paid | `lib/data/models/loan.dart`, `lib/features/repayments/data/repayment_service.dart` |
| Repayment gates | `POST /loans/:id/repay` requires `UserRole.borrower` and verified KYC; the repository and controller repeat the gate | `lib/core/network/mock_adapter.dart`, `lib/features/repayments/data/repayment_controller.dart` |
| Notifications | Persisted rows and FCM payloads are converted to one `AppNotification` stream. FCM tokens are registered to `/me/devices` after sign-in; foreground messages are shown through `flutter_local_notifications` | `lib/features/notifications/data/notification_event_bus.dart`, `push_notification_service.dart`, `push_registration.dart` |
| Mock jobs | Reminders, overdue marking and nightly reconciliation run through `POST /jobs/*` and read a single fast-forwardable `DemoClock` | `lib/core/utils/demo_clock.dart`, `lib/features/repayments/data/repayment_service.dart`, `lib/features/notifications/presentation/demo_tools_panel.dart` |

## Open items to settle before Track B

- Interest/fee model final sign-off (affects estimate screen and ledger).
- Production funding row lock / transaction boundary (demo uses an in-process queue).
- Production risk rule weights and rate bands (demo `v1` is fixed for now).
- Late fee and default timing (lawyer).
- Admin console stack (React web recommended by blueprint).
- File storage (Firebase Storage vs Cloudflare R2).
- SMS fallback if Firebase delivery is poor on Nepali carriers.
- Payments partner (eSewa / Khalti / ConnectIPS via a licensed partner).
