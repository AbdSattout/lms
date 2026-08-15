import { sendEmail, type SendOptions, type SmtpConfig } from "./smtp";
import { openapiSchema, swaggerUi } from "./openapi";

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export default {
	async fetch(request, env, _ctx): Promise<Response> {
		const url = new URL(request.url);

		if (request.method === "GET" && url.pathname === "/openapi.json") {
			return json(200, openapiSchema);
		}

		if (request.method === "GET" && url.pathname === "/docs") {
			return new Response(swaggerUi(), {
				headers: { "Content-Type": "text/html; charset=utf-8" },
			});
		}

		if (request.method === "GET" && (url.pathname === "/" || url.pathname === "/health")) {
			return json(200, { ok: true, service: "lms-email-api" });
		}

		if (request.method !== "POST" || url.pathname !== "/send") {
			return json(404, { error: "not_found" });
		}

		if (!(await authorized(request, env))) {
			return json(401, { error: "unauthorized" });
		}

		let body: unknown;
		try {
			body = await request.json();
		} catch {
			return json(400, { error: "invalid_json" });
		}

		const parsed = validate(body);
		if (!parsed.ok) {
			return json(400, { error: "invalid_request", details: parsed.errors });
		}

		const config = smtpConfig(env);
		if (!config.username || !config.password) {
			return json(500, { error: "not_configured" });
		}

		try {
			const result = await sendEmail(config, parsed.data);
			return json(200, { ok: true, messageId: result.messageId });
		} catch (err) {
			const message = err instanceof Error ? err.message : String(err);
			console.error("send failed", message);
			return json(502, { ok: false, error: "email_failed", detail: message });
		}
	},
} satisfies ExportedHandler<Env>;

function json(status: number, data: unknown): Response {
	return new Response(JSON.stringify(data), {
		status,
		headers: { "Content-Type": "application/json" },
	});
}

async function authorized(request: Request, env: Env): Promise<boolean> {
	const secret = env.API_SECRET;
	if (!secret) return false;
	const header = request.headers.get("authorization") ?? request.headers.get("x-api-key") ?? "";
	const token = header.startsWith("Bearer ") ? header.slice(7) : header;
	if (!token) return false;
	return timingSafeEqual(token, secret);
}

async function timingSafeEqual(a: string, b: string): Promise<boolean> {
	const encoder = new TextEncoder();
	const ah = await crypto.subtle.digest("SHA-256", encoder.encode(a));
	const bh = await crypto.subtle.digest("SHA-256", encoder.encode(b));
	const ab = new Uint8Array(ah);
	const bb = new Uint8Array(bh);
	let diff = 0;
	for (let i = 0; i < ab.length; i++) diff |= ab[i]! ^ bb[i]!;
	return diff === 0;
}

function validate(body: unknown): { ok: true; data: SendOptions } | { ok: false; errors: string[] } {
	if (typeof body !== "object" || body === null) {
		return { ok: false, errors: ["body must be a JSON object"] };
	}
	const record = body as Record<string, unknown>;
	const errors: string[] = [];

	const to = typeof record.to === "string" ? record.to.trim() : "";
	const subject = typeof record.subject === "string" ? record.subject.trim() : "";
	const text = typeof record.text === "string" ? record.text : undefined;
	const html = typeof record.html === "string" ? record.html : undefined;

	if (!to) {
		errors.push("to is required");
	} else if (!EMAIL_RE.test(to)) {
		errors.push("to is not a valid email address");
	}
	if (!subject) errors.push("subject is required");
	if (text === undefined && html === undefined) errors.push("at least one of text or html is required");

	if (errors.length > 0) return { ok: false, errors };
	return { ok: true, data: { to, subject, text, html } };
}

function smtpConfig(env: Env): SmtpConfig {
	return {
		host: env.MAIL_HOST || "smtp.gmail.com",
		port: Number(env.MAIL_PORT || 587),
		username: env.MAIL_USERNAME || "",
		password: env.MAIL_PASSWORD || "",
		from: env.MAIL_FROM || env.MAIL_USERNAME || "",
		fromName: env.MAIL_FROM_NAME,
		startTls: (env.MAIL_SMTP_STARTTLS_ENABLE ?? "true") === "true",
	};
}