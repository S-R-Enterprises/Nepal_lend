import "dotenv/config";
import { createApp } from "./app.js";
import { createPrisma } from "./db.js";

const port = Number(process.env["PORT"] ?? 3000);
const prisma = createPrisma();
const app = createApp(prisma);

const server = app.listen(port, () => {
  console.log(
    `nepallend-api listening on http://localhost:${port} (env=${process.env["ENV"] ?? "dev"})`,
  );
});

function shutdown(signal: string) {
  console.log(`${signal} received, shutting down`);
  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
}

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));
