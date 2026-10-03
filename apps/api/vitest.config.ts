import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    env: {
      DATABASE_URL: "file:./dev.db",
      ENV: "test",
    },
    include: ["test/**/*.test.ts"],
  },
});
