# @nepallend/api-spec

OpenAPI 3.1 contract for the NepalLend API (`openapi.yaml`) plus a Prism mock.

```bash
npm install
npm run mock   # http://localhost:4001 — serves /api/v1/* from the spec
```

## Conventions (enforced by the spec)

- Money: **integer paisa**, fields named `*Paisa` (NPR × 100). No floats.
- Paths carry the `/api/v1` prefix so the Express server and the Prism mock
  answer at identical paths on their respective ports.
- Auth: bearer token on everything except `/health` and `/auth/*`.
- Errors: `{ "error": "...", "message": "..." }`.
- Lists: `limit`/`offset` params, plain array responses.

## Relationship to the mock the app ships with

The mobile app has an in-process mock adapter (`ENV=mock`) for offline runs.
This Prism server is the shared, spec-driven mock used by the frontend/backend
teams and contract tests; its shapes are the source of truth the in-process
adapter should converge to. Prism 5 has no `lint` command — booting
`npm run mock` validates the document.
