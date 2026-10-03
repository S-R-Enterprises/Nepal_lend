# Product scope (v1)

NepalLend is a peer-to-peer lending **marketplace** for Nepal: it connects
verified borrowers with lenders, prices risk transparently, records the
agreement and keeps an exact ledger. NepalLend never lends its own money and
never custodies lender funds.

## Personas

| Persona | Needs |
|---|---|
| Borrower | Small/medium loans (NPR 1k–500k), transparent pricing, fast decisions, simple repayment |
| Lender | Visible risk, fractional exposure, predictable returns, easy top-up/payout |
| Admin (internal) | KYC review, flagged-request approval, overdue monitoring, audit trail |

## V1 features

### Borrower
- Phone-OTP signup (98xxxxxxxx), role selection, profile
- KYC checklist: citizenship, selfie, personal details (manual/simulated review)
- Loan request: purpose, amount, tenor, income → estimate (rate/instalment)
- Explainable risk rating: grade (A…D), band (Low/Medium/High), factor breakdown
- e-signed agreement after the loan is funded
- Repayment schedule + repayments via eSewa / Khalti / ConnectIPS / bank
  (simulated until the payments partner is live)

### Lender
- Wallet: balance, top-up methods, transaction history (credit/debit)
- Browse open loans: filter by risk band, sort by rate/amount/tenor
- Loan detail: borrower ref, risk assessment, funding progress
- Fund fully or fractionally (min NPR 1,000), stake portfolio (active/repaid)
- Stake detail with payment history and interest received
- Payout/withdraw (partner-mediated; simulated in v1)

### Admin
- KYC review queue, flagged loan approval, overdue monitoring, audit log
  (console is a separate app — `apps/admin/`, post-v1 scope)

### Platform
- Health/readiness endpoint, structured errors, request logging
- OpenAPI contract as the single source of truth for client/server/mock

## Explicit non-goals (v1)

- iOS, web, desktop clients (Android first)
- Group/joint lending, credit-bureau integration, crypto
- Real money movement without the licensed payments partner
- NepalLend lending its own money or holding custodial balances
- Marketplace promo/algorithmic ranking (deterministic sort only)

## Regulatory posture

- Operating model **B + C**: a licensed partner holds all funds (NepalLend
  never custodies), with an internal tracker ledger as fallback of record.
- Path: **NRB regulatory sandbox cohort**; company registration deferred until
  project completion.
- Lawyer consultation is an offline, launch-gating track — legal review must
  clear before any real-money beta.

See `docs/decisions.md` for the numbered decisions behind this scope.
