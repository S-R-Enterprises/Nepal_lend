# NepalLend API

Express + TypeScript + Prisma (Prisma 7, driver adapters). Node 22+.

## Commands

```bash
npm install            # also runs `prisma generate` (postinstall)
npm run dev            # tsx watch, http://localhost:3000
npm test               # vitest (boots the app on an ephemeral port)
npm run typecheck      # tsc --noEmit (strict)
npm run prisma:migrate # create/apply migrations (SQLite dev.db)
npm run prisma:studio  # browse the dev database
```

`.env` (gitignored) is copied from `.env.example` — `DATABASE_URL="file:./dev.db"`
creates `apps/api/dev.db`.

## Endpoints

| Route | Notes |
|---|---|
| `GET /` | service name + env |
| `GET /api/v1/health` | 200 `{status:"ok", db:"ok"}` / 503 if DB unreachable |

All lending endpoints arrive with the OpenAPI contract (Stage 5+); the mobile
app runs against `ENV=mock` until then.

## Environment

`ENV=dev|staging|prod` is read by the server (`.env`) and reported in `/health`.
It mirrors the mobile app's `--dart-define=ENV`.

## Database

- **Local dev:** SQLite via `@prisma/adapter-better-sqlite3`.
- **Production:** planned Postgres — change `provider = "sqlite"` in
  `prisma/schema.prisma` to `postgresql`, point `DATABASE_URL` at the server,
  and swap the adapter in `src/db.ts` for `@prisma/adapter-pg`. Migrations
  carry over; SQLite-only types (none used so far) would need reviewing.
- Schema: `prisma/schema.prisma` (currently `User` only). Generated client
  lands in `generated/prisma/` (gitignored, regenerated on install).

## Known notes

- Audit is clean: npm `overrides` pin `deepmerge-ts@^8` and `mysql2@^3.24`
  above Prisma's vulnerable transitive ranges (verified: generate/migrate/
  typecheck/tests green under the overrides, `npm audit` = 0).
- `prisma` is pinned to 7.x: the npm `latest` tag currently points at an
  8.0.0-rc pre-release.
