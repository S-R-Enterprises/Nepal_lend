import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    env: {
      DATABASE_URL: "file:./dev.db",
      ENV: "test",
    },
    include: ["test/**/*.test.ts"],
    // Test files share one SQLite file — run them serially to avoid lock fights.
    fileParallelism: false,
  },
});
