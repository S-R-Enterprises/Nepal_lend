import { Router } from "express";
import type { PrismaClient } from "../../generated/prisma/client";

export function healthRouter(prisma: PrismaClient): Router {
  const router = Router();

  router.get("/", async (_req, res) => {
    let db: "ok" | "error" = "error";
    try {
      await prisma.$queryRaw`SELECT 1`;
      db = "ok";
    } catch {
      // reported as db: error below
    }
    res.status(db === "ok" ? 200 : 503).json({
      status: db === "ok" ? "ok" : "degraded",
      db,
      env: process.env["ENV"] ?? "dev",
      time: new Date().toISOString(),
    });
  });

  return router;
}
