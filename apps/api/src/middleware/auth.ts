import type { NextFunction, Request, Response } from "express";
import { verifyAccessToken } from "../services/tokens.js";

declare global {
  namespace Express {
    interface Request {
      userId?: string;
      userRole?: string;
    }
  }
}

export async function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    res.status(401).json({ error: "unauthorized", message: "Missing bearer token" });
    return;
  }
  const payload = await verifyAccessToken(header.slice("Bearer ".length));
  if (!payload) {
    res.status(401).json({ error: "unauthorized", message: "Invalid or expired token" });
    return;
  }
  req.userId = payload.userId;
  req.userRole = payload.role;
  next();
}
