# NepalLend

**Peer-to-peer lending marketplace for Nepal** — verified borrowers, fractional funding and explainable risk.

Lenders browse verified loan requests, fund them fully or in fractions, and earn interest as borrowers repay. Borrowers apply for small loans, receive an explainable risk rating, and repay through the app. NepalLend never lends its own money: it connects people, checks who they are, scores the risk, records the agreement and keeps an exact ledger of who is owed what.

> ⚠️ **Status:** pre-alpha. The mobile client renders hard-coded sample data; the API is a scaffold (health endpoint only, no lending endpoints yet). Not a lending offer.

## Stack

| Layer | Choice |
|---|---|
| Mobile app | Flutter (Dart), Android first |
| Backend | Node.js + Express + TypeScript + Prisma — SQLite for dev, PostgreSQL in production |
| Money | Integer paisa + append-only double-entry ledger *(planned)* |
| Payments | Behind a swappable provider interface; NepalLend never custodies lender funds *(regulated partner holds funds)* |

## Repository layout

```
nepallend/
├── apps/mobile/       # this Flutter app ✓
├── apps/api/          # Express + Prisma backend ✓ (health scaffold; lending APIs pending OpenAPI, Stage 5)
├── apps/admin/        # KYC/loan review console (planned)
├── packages/api-spec/ # OpenAPI 3.1 contract + Prism mock ✓ (npm run mock :4001)
└── docs/              # scope, security baseline, decisions
```

## Getting started

```bash
# Requires Flutter 3.47+ (Dart 3.13+)
cd apps/mobile
flutter pub get
flutter analyze        # 0 issues
flutter test           # 30 tests
flutter run --flavor dev --dart-define=ENV=dev   # Android emulator or device

# Flavors (android/app/build.gradle.kts): dev -> .dev id, staging -> .staging,
# prod -> np.nepallend.app. Pair each with the matching --dart-define=ENV.
# ENV=mock serves canned API responses (no backend needed).

# API (Node 22+)
cd apps/api
npm install
npm run dev            # http://localhost:3000  (see apps/api/README.md)
```

### Android release signing

Release builds use debug keys until you create `apps/mobile/android/key.properties`
(see `apps/mobile/android/key.properties.example`). The file and any `*.jks` keystore are gitignored.

## Product scope (v1)

- **Borrower:** phone OTP signup, KYC, income-based loan request, explainable risk rating, e-signed agreement, repayment schedule (eSewa / Khalti / ConnectIPS / bank)
- **Lender:** wallet, browse risk-graded loans, fractional funding, portfolio and payouts
- **Admin:** KYC review, flagged-request approval, overdue monitoring, audit log

Full scope, risk engine, security plan and roadmap live in the project plan document (`docs/` once published).

## Conventions

- Design system lives in `apps/mobile/lib/shared/widgets/ui.dart`; style guide runs at the `/style-guide` route
- Amounts are formatted NPR with lakh grouping (`formatNPR` in `apps/mobile/lib/shared/widgets/ui.dart`)
- Tests: per-screen render smoke tests in `apps/mobile/test/screens_smoke_test.dart`

## License

Private / unlicensed — all rights reserved (until the team decides otherwise).
