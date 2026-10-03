import { Router } from "express";
import type { PrismaClient } from "../../generated/prisma/client";
import { config } from "../config.js";
import { requireAuth } from "../middleware/auth.js";
import { maskPhone, requestOtp, verifyOtp } from "../services/otp.js";
import { newRefreshToken, signAccessToken } from "../services/tokens.js";
import { toUser } from "../services/users.js";

const PHONE_RE = /^9\d{9}$/;

export function authRouter(prisma: PrismaClient): Router {
  const router = Router();

  router.post("/otp/request", async (req, res) => {
    const phone = (req.body as { phone?: unknown })?.phone;
    if (typeof phone !== "string" || !PHONE_RE.test(phone)) {
      res.status(400).json({
        error: "validation_error",
        message: "phone must be a 10-digit number starting with 9",
      });
      return;
    }
    const result = await requestOtp(phone);
    if (!result.ok) {
      if (result.reason === "rate_limited") {
        res.status(429).json({
          error: "rate_limited",
          message: "Too many OTP requests for this number, try again later",
        });
        return;
      }
      res.status(502).json({
        error: "sms_failed",
        message: "Could not send the SMS. Try again later.",
      });
      return;
    }
    const masked = maskPhone(phone);
    res.json({
      requestId: result.requestId,
      phone: masked,
      maskedPhone: masked,
      expiresInSeconds: result.expiresInSeconds,
      ...(result.devCode ? { devCode: result.devCode } : {}),
    });
  });

  router.post("/otp/verify", async (req, res) => {
    const body = req.body as { requestId?: unknown; code?: unknown };
    if (typeof body?.requestId !== "string" || typeof body?.code !== "string") {
      res.status(400).json({
        error: "validation_error",
        message: "requestId and code are required strings",
      });
      return;
    }
    const phone = verifyOtp(body.requestId, body.code);
    if (!phone) {
      res.status(401).json({ error: "invalid_otp", message: "Incorrect or expired code" });
      return;
    }

    let user = await prisma.user.findUnique({ where: { phone } });
    const isNewUser = user === null;
    if (user === null) {
      user = await prisma.user.create({ data: { phone } });
    }

    const accessToken = await signAccessToken(user);
    const { token: refreshToken, hash } = newRefreshToken();
    await prisma.refreshToken.create({
      data: {
        tokenHash: hash,
        userId: user.id,
        expiresAt: new Date(Date.now() + config.refreshTtlSeconds * 1000),
      },
    });

    res.json({
      accessToken,
      refreshToken,
      expiresInSeconds: config.accessTtlSeconds,
      isNewUser,
      user: toUser(user),
    });
  });

  router.post("/logout", requireAuth, async (req, res) => {
    await prisma.refreshToken.updateMany({
      where: { userId: req.userId ?? "", revokedAt: null },
      data: { revokedAt: new Date() },
    });
    res.status(204).end();
  });

  return router;
}
