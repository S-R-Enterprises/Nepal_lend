import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { startTestServer, type TestServer } from "./testServer.js";

let ts: TestServer;

beforeAll(async () => {
  ts = await startTestServer();
});

afterAll(async () => {
  await ts.close();
});

describe("GET /", () => {
  it("identifies the service", async () => {
    const res = await fetch(`${ts.baseUrl}/`);
    expect(res.status).toBe(200);
    expect(await res.json()).toMatchObject({ service: "nepallend-api" });
  });
});

describe("GET /api/v1/health", () => {
  it("returns 200 with db ok", async () => {
    const res = await fetch(`${ts.baseUrl}/api/v1/health`);
    expect(res.status).toBe(200);
    const body = (await res.json()) as {
      status: string;
      db: string;
      time: string;
    };
    expect(body.status).toBe("ok");
    expect(body.db).toBe("ok");
    expect(typeof body.time).toBe("string");
  });
});

describe("unknown route", () => {
  it("returns json 404", async () => {
    const res = await fetch(`${ts.baseUrl}/api/v1/nope`);
    expect(res.status).toBe(404);
    expect(await res.json()).toEqual({ error: "not_found" });
  });
});
