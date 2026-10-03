export const config = {
  authSecret: process.env["AUTH_SECRET"] ?? "dev-only-insecure-secret",
  accessTtlSeconds: 3600,
  refreshTtlSeconds: 30 * 24 * 3600,
  otpTtlSeconds: 120,
  otpMaxRequestsPerWindow: 3,
  otpWindowMs: 10 * 60 * 1000,
  isProd: (process.env["ENV"] ?? "dev") === "prod",
  smsProvider: process.env["SMS_PROVIDER"] ?? "console", // console | http
  smsApiUrl: process.env["SMS_API_URL"],
  smsApiKey: process.env["SMS_API_KEY"],
  smsSenderId: process.env["SMS_SENDER_ID"] ?? "NepalLend",
} as const;
