import { Router } from "express";
import type { PrismaClient } from "../../generated/prisma/client";
import { requireAuth } from "../middleware/auth.js";
import {
  KYC_STEP_IDS,
  kycStatus,
  toUser,
  verifyKycStep,
  type KycStepId,
} from "../services/users.js";

export function meRouter(prisma: PrismaClient): Router {
  const router = Router();
  router.use(requireAuth);

  router.get("/", async (req, res) => {
    const user = await prisma.user.findUnique({ where: { id: req.userId } });
    if (!user) {
      res.status(401).json({ error: "unauthorized", message: "Unknown user" });
      return;
    }
    res.json(toUser(user));
  });

  router.patch("/", async (req, res) => {
    const body = req.body as { name?: unknown; email?: unknown; role?: unknown };
    const data: { name?: string; email?: string | null; role?: string } = {};
    if (body?.name !== undefined) {
      if (typeof body.name !== "string" || body.name.trim().length === 0) {
        res.status(400).json({ error: "validation_error", message: "name must be a non-empty string" });
        return;
      }
      data.name = body.name.trim();
    }
    if (body?.email !== undefined) {
      if (body.email !== null && typeof body.email !== "string") {
        res.status(400).json({ error: "validation_error", message: "email must be a string or null" });
        return;
      }
      data.email = body.email as string | null;
    }
    if (body?.role !== undefined) {
      if (body.role !== "borrower" && body.role !== "lender") {
        res.status(400).json({ error: "validation_error", message: "role must be borrower or lender" });
        return;
      }
      data.role = body.role;
    }
    const user = await prisma.user.update({ where: { id: req.userId }, data });
    res.json(toUser(user));
  });

  router.get("/kyc", async (req, res) => {
    const user = await prisma.user.findUnique({ where: { id: req.userId } });
    if (!user) {
      res.status(401).json({ error: "unauthorized", message: "Unknown user" });
      return;
    }
    res.json(await kycStatus(prisma, user));
  });

  router.post("/kyc/steps/:stepId/verify", async (req, res) => {
    const stepId = req.params.stepId;
    if (!KYC_STEP_IDS.includes(stepId as KycStepId)) {
      res.status(400).json({
        error: "validation_error",
        message: `stepId must be one of: ${KYC_STEP_IDS.join(", ")}`,
      });
      return;
    }
    const user = await prisma.user.findUnique({ where: { id: req.userId } });
    if (!user) {
      res.status(401).json({ error: "unauthorized", message: "Unknown user" });
      return;
    }
    const result = await verifyKycStep(prisma, user, stepId as KycStepId);
    res.json(result.status);
  });

  return router;
}
