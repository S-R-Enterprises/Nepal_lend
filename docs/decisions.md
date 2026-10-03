# Decision log

ADR-lite: what we decided, when, and why. Newest last. Revisit by opening a
new entry rather than rewriting history.

## D1 — Android application id `np.nepallend.app`
Pre-alpha, changeable until Play Console publication. Template
`com.example.nepal_lend` removed in the Stage 1 fix pass.

## D2 — Monorepo layout
`apps/mobile`, `apps/api`, `apps/admin` (future), `packages/api-spec`,
`docs/`. Restructured in Week 1 *before* feature work so history stays clean
(100% renames, `git mv`).

## D3 — Mobile stack migration before features
Riverpod 3 (`Notifier`), go_router 18, Dio 5, flutter_secure_storage; feature
folders + core/shared split; global `Session` replaced by a persisted
`AuthController`. freezed models and l10n were **cut** from Week 1–2 (3.7/3.8
partial) — revisit when real API models arrive.

## D4 — Backend built from scratch, Node + Express + TS + Prisma
No legacy to preserve. Prisma **7.x** (pinned: npm `latest` tag is an 8.0.0-rc),
driver adapters mandatory. SQLite for local dev (`apps/api/dev.db`),
Postgres in production (swap documented in `apps/api/README.md`).

## D5 — Contract-first API
OpenAPI 3.1 at `packages/api-spec/openapi.yaml` is the source of truth for
server, client and mocks. Paths carry `/api/v1` so Express and the Prism mock
answer identically on their ports. Money: **integer paisa**, `*Paisa` fields.
List endpoints return plain arrays with `limit`/`offset`.

## D6 — Payments: operating structure B + C
B: a **licensed partner** holds all funds — NepalLend never custodies lender
money. C: internal tracker ledger as fallback of record. `PaymentProvider`
interface is swappable; `PAYMENT_MODE=simulated|partner|tracker`, default
simulated. Chosen for regulatory risk, revisited at partner contracting.

## D7 — Regulatory path: NRB sandbox cohort
Engage the NRB regulatory sandbox as the compliance route. Lawyer consultation
runs as an **offline, launch-gating track** (not code-blocking).

## D8 — Company registration deferred
Register at project completion, not during foundations.

## D9 — Android flavors `dev` / `staging` / `prod`
`applicationIdSuffix` for dev/staging (side-by-side installs), prod keeps
`np.nepallend.app`. Paired with `--dart-define=ENV=` which selects the API
base URL (`AppConfig`). Labels via flavor res source sets — `resValue` is
blocked by Flutter's Gradle plugin (build feature `resvalues` disabled).

## D10 — Mocking strategy
Two layers: (a) in-process mobile mock adapter for `ENV=mock` (offline demo),
(b) spec-driven Prism mock (`npm run mock` in `packages/api-spec`) as the
shared contract mock. Spec shapes are the source of truth; the in-process
adapter converges to them.

## D11 — CI/CD baseline
GitHub Actions: flutter job (pinned 3.47.5), api job (audit-gated), spec job
(Prism boot probes), gitleaks via **Docker image** (owner is an Organization →
the gitleaks action's paid org license does not apply). npm `overrides`
(`deepmerge-ts ^8`, `mysql2 ^3.24`) clear Prisma's transitive audit highs
without downgrading to Prisma 6.

## D12 — Money formatting
API/ledger: integer paisa. UI: format to rupees with lakh grouping
(`formatNPR`). No floats for money anywhere — enforced by convention + review.
