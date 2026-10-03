import { randomInt, randomUUID } from "node:crypto";
import { config } from "../config.js";
import { createSmsSender } from "./sms.js";

type Challenge = { phone: string; code: string; expiresAt: number };

const challenges = new Map<string, Challenge>();
const requestLog = new Map<string, number[]>();

function prune(): void {
  const now = Date.now();
  for (const [id, c] of challenges) {
    if (c.expiresAt <= now) challenges.delete(id);
  }
  for (const [phone, times] of requestLog) {
    const fresh = times.filter((t) => now - t < config.otpWindowMs);
    if (fresh.length === 0) requestLog.delete(phone);
    else requestLog.set(phone, fresh);
  }
}

export function maskPhone(phone: string): string {
  return `${phone.slice(0, 4)}***${phone.slice(7)}`;
}

export type RequestOtpResult =
  | { ok: true; requestId: string; expiresInSeconds: number; devCode?: string }
  | { ok: false; reason: "rate_limited" | "sms_failed" };

export async function requestOtp(phone: string): Promise<RequestOtpResult> {
  prune();
  const now = Date.now();
  const times = requestLog.get(phone) ?? [];
  if (times.length >= config.otpMaxRequestsPerWindow) {
    return { ok: false, reason: "rate_limited" };
  }
  times.push(now);
  requestLog.set(phone, times);

  const requestId = randomUUID();
  const code = config.isProd ? String(randomInt(0, 1_000_000)).padStart(6, "0") : "123456";
  challenges.set(requestId, {
    phone,
    code,
    expiresAt: now + config.otpTtlSeconds * 1000,
  });

  const minutes = Math.round(config.otpTtlSeconds / 60);
  try {
    await createSmsSender().send({
      to: phone,
      text: `Your NepalLend verification code is ${code}. It expires in ${minutes} minute${minutes === 1 ? "" : "s"}.`,
    });
  } catch (err) {
    challenges.delete(requestId); // nothing was delivered — don't leave a guessable challenge
    console.error(`[otp] SMS send failed for ${maskPhone(phone)}: ${(err as Error).message}`);
    return { ok: false, reason: "sms_failed" };
  }

  if (!config.isProd) {
    console.log(`[otp] ${maskPhone(phone)} code=${code}`);
  }
  return {
    ok: true,
    requestId,
    expiresInSeconds: config.otpTtlSeconds,
    ...(config.isProd ? {} : { devCode: code }),
  };
}

export function verifyOtp(requestId: string, code: string): string | null {
  prune();
  const challenge = challenges.get(requestId);
  if (!challenge || challenge.expiresAt <= Date.now()) return null;
  if (challenge.code !== code) return null;
  challenges.delete(requestId);
  return challenge.phone;
}
