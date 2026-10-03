import express, {
  type Express,
  type NextFunction,
  type Request,
  type Response,
} from "express";
import type { PrismaClient } from "../generated/prisma/client";
import { authRouter } from "./routes/auth.js";
import { healthRouter } from "./routes/health.js";
import { meRouter } from "./routes/me.js";

export function createApp(prisma: PrismaClient): Express {
  const app = express();
  app.use(express.json());

  app.get("/", (_req, res) => {
    res.json({ service: "nepallend-api", env: process.env["ENV"] ?? "dev" });
  });

  app.use("/api/v1/health", healthRouter(prisma));
  app.use("/api/v1/auth", authRouter(prisma));
  app.use("/api/v1/me", meRouter(prisma));

  app.use((_req, res) => {
    res.status(404).json({ error: "not_found" });
  });

  app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
    console.error(err);
    res.status(500).json({ error: "internal_error" });
  });

  return app;
}
