import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { startTestServer, uniquePhone, type TestServer } from "./testServer.js";

let ts: TestServer;

beforeAll(async () => {
  ts = await startTestServer();
});

afterAll(async () => {
  await ts.close();
});

async function requestOtp(phone: string) {
  const res = await fetch(`${ts.baseUrl}/api/v1/auth/otp/request`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone }),
  });
  return res;
}

async function verifyOtp(requestId: string, code: string) {
  return fetch(`${ts.baseUrl}/api/v1/auth/otp/verify`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ requestId, code }),
  });
}

describe("POST /auth/otp/request", () => {
  it("rejects an invalid phone with 400", async () => {
    const res = await requestOtp("12345");
    expect(res.status).toBe(400);
    expect(await res.json()).toMatchObject({ error: "validation_error" });
  });

  it("returns a masked challenge", async () => {
    const res = await requestOtp(uniquePhone());
    expect(res.status).toBe(200);
    const body = (await res.json()) as {
      requestId: string;
      maskedPhone: string;
      expiresInSeconds: number;
      devCode?: string;
    };
    expect(body.requestId).toBeTruthy();
    expect(body.maskedPhone).toMatch(/^\d{4}\*{3}\d{3}$/);
    expect(body.expiresInSeconds).toBe(120);
    // non-production echo so dev builds can show the code on screen
    expect(body.devCode).toBe("123456");
  });

  it("rate-limits the 4th request for one number", async () => {
    const phone = uniquePhone();
    expect((await requestOtp(phone)).status).toBe(200);
    expect((await requestOtp(phone)).status).toBe(200);
    expect((await requestOtp(phone)).status).toBe(200);
    const fourth = await requestOtp(phone);
    expect(fourth.status).toBe(429);
  });
});

describe("POST /auth/otp/verify", () => {
  it("rejects a wrong code with 401, then accepts 123456", async () => {
    const phone = uniquePhone();
    const challenge = (await (await requestOtp(phone)).json()) as {
      requestId: string;
    };

    const wrong = await verifyOtp(challenge.requestId, "000000");
    expect(wrong.status).toBe(401);

    const ok = await verifyOtp(challenge.requestId, "123456");
    expect(ok.status).toBe(200);
    const session = (await ok.json()) as {
      accessToken: string;
      refreshToken: string;
      isNewUser: boolean;
      user: { phone: string; role: string; kycState: string };
    };
    expect(session.accessToken).toBeTruthy();
    expect(session.refreshToken).toBeTruthy();
    expect(session.isNewUser).toBe(true);
    expect(session.user.phone).toBe(phone);
    expect(session.user.role).toBe("borrower");
    expect(session.user.kycState).toBe("unstarted");

    // challenge consumed — replay fails
    const replay = await verifyOtp(challenge.requestId, "123456");
    expect(replay.status).toBe(401);
  });

  it("returns an existing user on re-login (isNewUser=false)", async () => {
    const phone = uniquePhone();
    const challenge = (await (await requestOtp(phone)).json()) as {
      requestId: string;
    };
    const first = (await (await verifyOtp(challenge.requestId, "123456")).json()) as {
      user: { id: string };
    };

    const secondChallenge = (await (await requestOtp(phone)).json()) as {
      requestId: string;
    };
    const secondRes = await verifyOtp(secondChallenge.requestId, "123456");
    const session = (await secondRes.json()) as {
      isNewUser: boolean;
      user: { id: string };
    };
    expect(session.isNewUser).toBe(false);
    expect(session.user.id).toBe(first.user.id);
  });
});

describe("bearer auth + /me", () => {
  it("401s without a token, then serves the profile", async () => {
    const noToken = await fetch(`${ts.baseUrl}/api/v1/me`);
    expect(noToken.status).toBe(401);

    const phone = uniquePhone();
    const challenge = (await (await requestOtp(phone)).json()) as {
      requestId: string;
    };
    const session = (await (await verifyOtp(challenge.requestId, "123456")).json()) as {
      accessToken: string;
    };
    const auth = {
      Authorization: `Bearer ${session.accessToken}`,
      "Content-Type": "application/json",
    };

    const me = await fetch(`${ts.baseUrl}/api/v1/me`, { headers: auth });
    expect(me.status).toBe(200);
    expect(await me.json()).toMatchObject({ phone, role: "borrower" });

    const patched = await fetch(`${ts.baseUrl}/api/v1/me`, {
      method: "PATCH",
      headers: auth,
      body: JSON.stringify({ name: "Test User" }),
    });
    expect(patched.status).toBe(200);
    expect(await patched.json()).toMatchObject({ name: "Test User" });
  });

  it("rejects a garbage token", async () => {
    const res = await fetch(`${ts.baseUrl}/api/v1/me`, {
      headers: { Authorization: "Bearer not-a-jwt" },
    });
    expect(res.status).toBe(401);
  });
});

describe("KYC", () => {
  it("walks unstarted -> in_review -> verified", async () => {
    const phone = uniquePhone();
    const challenge = (await (await requestOtp(phone)).json()) as {
      requestId: string;
    };
    const session = (await (await verifyOtp(challenge.requestId, "123456")).json()) as {
      accessToken: string;
    };
    const auth = {
      Authorization: `Bearer ${session.accessToken}`,
      "Content-Type": "application/json",
    };

    const initial = (await (await fetch(`${ts.baseUrl}/api/v1/me/kyc`, { headers: auth })).json()) as {
      state: string;
      steps: { id: string; status: string }[];
    };
    expect(initial.state).toBe("unstarted");
    expect(initial.steps).toHaveLength(4);
    expect(initial.steps.every((s) => s.status === "Not started")).toBe(true);

    const afterOne = (await (
      await fetch(`${ts.baseUrl}/api/v1/me/kyc/steps/citizenship/verify`, {
        method: "POST",
        headers: auth,
      })
    ).json()) as { state: string };
    expect(afterOne.state).toBe("in_review");

    await fetch(`${ts.baseUrl}/api/v1/me/kyc/steps/selfie/verify`, {
      method: "POST",
      headers: auth,
    });
    await fetch(`${ts.baseUrl}/api/v1/me/kyc/steps/details/verify`, {
      method: "POST",
      headers: auth,
    });
    const done = (await (
      await fetch(`${ts.baseUrl}/api/v1/me/kyc/steps/bank_statement/verify`, {
        method: "POST",
        headers: auth,
      })
    ).json()) as { state: string; steps: { status: string }[] };
    expect(done.state).toBe("verified");
    expect(done.steps.every((s) => s.status === "Approved")).toBe(true);

    const bad = await fetch(`${ts.baseUrl}/api/v1/me/kyc/steps/face/verify`, {
      method: "POST",
      headers: auth,
    });
    expect(bad.status).toBe(400);
  });
});

describe("POST /auth/logout", () => {
  it("204s with a valid token, 401s without", async () => {
    const phone = uniquePhone();
    const challenge = (await (await requestOtp(phone)).json()) as {
      requestId: string;
    };
    const session = (await (await verifyOtp(challenge.requestId, "123456")).json()) as {
      accessToken: string;
    };

    const anon = await fetch(`${ts.baseUrl}/api/v1/auth/logout`, { method: "POST" });
    expect(anon.status).toBe(401);

    const out = await fetch(`${ts.baseUrl}/api/v1/auth/logout`, {
      method: "POST",
      headers: { Authorization: `Bearer ${session.accessToken}` },
    });
    expect(out.status).toBe(204);
  });
});
