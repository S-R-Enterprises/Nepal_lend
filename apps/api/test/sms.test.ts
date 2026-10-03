import { afterEach, describe, expect, it, vi } from "vitest";
import {
  ConsoleSmsSender,
  HttpSmsSender,
  setSmsSenderForTests,
  type SmsSender,
} from "../src/services/sms.js";
import { requestOtp } from "../src/services/otp.js";

function randomPhone(): string {
  const digits = Math.floor(Math.random() * 100_000_000)
    .toString()
    .padStart(8, "0");
  return `98${digits}`;
}

afterEach(() => {
  setSmsSenderForTests(null);
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

describe("ConsoleSmsSender", () => {
  it("logs the message text in dev", async () => {
    const spy = vi.spyOn(console, "log").mockImplementation(() => {});
    await new ConsoleSmsSender().send({ to: "9841234567", text: "code 123456" });
    expect(spy).toHaveBeenCalledWith('[sms:console] to=9841234567 "code 123456"');
  });
});

describe("HttpSmsSender", () => {
  it("POSTs {to, from, text} with the api key header", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, status: 200 });
    vi.stubGlobal("fetch", fetchMock);

    const sender = new HttpSmsSender({
      url: "https://sms.example/send",
      apiKey: "k-123",
      senderId: "NepalLend",
    });
    await sender.send({ to: "9841234567", text: "Your code is 123456" });

    expect(fetchMock).toHaveBeenCalledWith("https://sms.example/send", {
      method: "POST",
      headers: { "content-type": "application/json", "x-api-key": "k-123" },
      body: JSON.stringify({ to: "9841234567", from: "NepalLend", text: "Your code is 123456" }),
    });
  });

  it("throws when the provider responds non-2xx", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ ok: false, status: 503, text: async () => "down" }),
    );
    const sender = new HttpSmsSender({ url: "https://sms.example/send", senderId: "NL" });
    await expect(sender.send({ to: "9841234567", text: "x" })).rejects.toThrow(
      "SMS provider responded 503: down",
    );
  });
});

describe("requestOtp delivery", () => {
  it("returns devCode (non-production) after a successful send", async () => {
    setSmsSenderForTests({
      name: "fake",
      send: async () => {},
    } satisfies SmsSender);
    const result = await requestOtp(randomPhone());
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.devCode).toBe("123456");
      expect(result.expiresInSeconds).toBe(120);
    }
  });

  it("returns sms_failed when the sender throws", async () => {
    setSmsSenderForTests({
      name: "broken",
      send: async () => {
        throw new Error("provider down");
      },
    } satisfies SmsSender);
    const result = await requestOtp(randomPhone());
    expect(result).toEqual({ ok: false, reason: "sms_failed" });
  });
});
