export const config = {
  authSecret: process.env["AUTH_SECRET"] ?? "dev-only-insecure-secret",
  accessTtlSeconds: 3600,
  refreshTtlSeconds: 30 * 24 * 3600,
  otpTtlSeconds: 120,
  otpMaxRequestsPerWindow: 3,
  otpWindowMs: 10 * 60 * 1000,
  isProd: (process.env["ENV"] ?? "dev") === "prod",
} as const;
