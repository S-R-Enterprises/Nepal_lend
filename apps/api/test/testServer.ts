import type { Server } from "node:http";
import type { AddressInfo } from "node:net";
import { createApp } from "../src/app.js";
import { createPrisma } from "../src/db.js";

export type TestServer = {
  baseUrl: string;
  close: () => Promise<void>;
};

export async function startTestServer(): Promise<TestServer> {
  const prisma = createPrisma();
  const app = createApp(prisma);
  const server = await new Promise<Server>((resolve) => {
    const s = app.listen(0, () => resolve(s));
  });
  const port = (server.address() as AddressInfo).port;
  return {
    baseUrl: `http://127.0.0.1:${port}`,
    close: async () => {
      await new Promise((resolve) => server.close(resolve));
      await prisma.$disconnect();
    },
  };
}

export function uniquePhone(): string {
  const digits = Math.floor(Math.random() * 100_000_000)
    .toString()
    .padStart(8, "0");
  return `98${digits}`;
}
