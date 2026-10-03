import { config } from "../config.js";

export type SmsMessage = { to: string; text: string };

export interface SmsSender {
  readonly name: string;
  send(msg: SmsMessage): Promise<void>;
}

/** Dev/staging default: prints to the server log. Never delivers anything. */
export class ConsoleSmsSender implements SmsSender {
  readonly name = "console";

  async send(msg: SmsMessage): Promise<void> {
    if (config.isProd) {
      // Prod must not leak codes into logs — and console never delivers.
      console.error(`[sms:console] ENV=prod with console sender; message to ${msg.to} NOT sent`);
      return;
    }
    console.log(`[sms:console] to=${msg.to} "${msg.text}"`);
  }
}

/**
 * Generic HTTP SMS bridge: POST {to, from, text} with an X-API_KEY header.
 * Point SMS_API_URL at your provider (Spark, Ajax, Hamro, ...) or a thin
 * proxy that adapts its payload shape.
 */
export class HttpSmsSender implements SmsSender {
  readonly name = "http";

  constructor(
    private readonly opts: { url: string; apiKey?: string; senderId: string },
  ) {}

  async send(msg: SmsMessage): Promise<void> {
    const res = await fetch(this.opts.url, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        ...(this.opts.apiKey ? { "x-api-key": this.opts.apiKey } : {}),
      },
      body: JSON.stringify({ to: msg.to, from: this.opts.senderId, text: msg.text }),
    });
    if (!res.ok) {
      const body = await res.text().catch(() => "");
      throw new Error(`SMS provider responded ${res.status}: ${body.slice(0, 200)}`);
    }
  }
}

let override: SmsSender | null = null;
let cached: SmsSender | null = null;
let prodWarned = false;

export function createSmsSender(): SmsSender {
  if (override) return override;
  if (cached) return cached;
  if (config.smsProvider === "http") {
    if (!config.smsApiUrl) {
      throw new Error("SMS_PROVIDER=http requires SMS_API_URL");
    }
    cached = new HttpSmsSender({
      url: config.smsApiUrl,
      apiKey: config.smsApiKey,
      senderId: config.smsSenderId,
    });
  } else {
    if (config.isProd && !prodWarned) {
      console.error("[sms] SMS_PROVIDER is not 'http' — OTPs will NOT be delivered in production");
      prodWarned = true;
    }
    cached = new ConsoleSmsSender();
  }
  return cached;
}

/** Tests only: inject a fake sender (null restores the configured one). */
export function setSmsSenderForTests(sender: SmsSender | null): void {
  override = sender;
}
