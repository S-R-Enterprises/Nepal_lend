import { createHash, randomUUID } from "node:crypto";
import { SignJWT, jwtVerify } from "jose";
import { config } from "../config.js";

const secret = new TextEncoder().encode(config.authSecret);

export type AccessTokenPayload = { userId: string; role: string };

export async function signAccessToken(user: {
  id: string;
  role: string;
  phone: string;
}): Promise<string> {
  return new SignJWT({ role: user.role, phone: user.phone })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(user.id)
    .setIssuedAt()
    .setExpirationTime(`${config.accessTtlSeconds}s`)
    .sign(secret);
}

export async function verifyAccessToken(
  token: string,
): Promise<AccessTokenPayload | null> {
  try {
    const { payload } = await jwtVerify(token, secret);
    if (typeof payload.sub !== "string" || typeof payload.role !== "string") {
      return null;
    }
    return { userId: payload.sub, role: payload.role };
  } catch {
    return null;
  }
}

export function newRefreshToken(): { token: string; hash: string } {
  const token = `rt_${randomUUID()}`;
  return { token, hash: sha256(token) };
}

export function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}
