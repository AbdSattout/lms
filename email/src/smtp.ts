import { connect } from "cloudflare:sockets";

export interface SmtpConfig {
	host: string;
	port: number;
	username: string;
	password: string;
	from: string;
	fromName?: string;
	startTls: boolean;
}

export interface SendOptions {
	to: string;
	subject: string;
	text?: string;
	html?: string;
}

export interface SmtpResult {
	messageId: string;
}

interface Reply {
	code: number;
	lines: string[];
}

const decoder = new TextDecoder();

class SmtpConnection {
	private socket: Socket;
	private reader: ReadableStreamDefaultReader<Uint8Array>;
	private writer: WritableStreamDefaultWriter<Uint8Array>;
	private buffer = "";

	constructor(socket: Socket) {
		this.socket = socket;
		this.reader = socket.readable.getReader();
		this.writer = socket.writable.getWriter();
	}

	async readLine(): Promise<string> {
		for (;;) {
			const nl = this.buffer.indexOf("\n");
			if (nl !== -1) {
				const line = this.buffer.slice(0, nl).replace(/\r$/, "");
				this.buffer = this.buffer.slice(nl + 1);
				return line;
			}
			const { done, value } = await this.reader.read();
			if (done) throw new Error("SMTP connection closed by server");
			this.buffer += decoder.decode(value, { stream: true });
		}
	}

	async readReply(): Promise<Reply> {
		const lines: string[] = [];
		const first = await this.readLine();
		lines.push(first);
		const code = Number.parseInt(first.slice(0, 3), 10);
		if (Number.isNaN(code)) throw new Error(`Invalid SMTP response: ${first}`);
		while (first.length > 3 && first[3] === "-") {
			const line = await this.readLine();
			lines.push(line);
			if (line.length > 3 && line[3] === " ") break;
			if (!line.startsWith(String(code))) break;
		}
		return { code, lines };
	}

	async writeLine(line: string): Promise<void> {
		const encoder = new TextEncoder();
		await this.writer.write(encoder.encode(line + "\r\n"));
	}

	async writeRaw(text: string): Promise<void> {
		const encoder = new TextEncoder();
		await this.writer.write(encoder.encode(text));
	}

	async upgradeTls(): Promise<void> {
		this.reader.releaseLock();
		this.writer.releaseLock();
		this.socket = this.socket.startTls();
		this.reader = this.socket.readable.getReader();
		this.writer = this.socket.writable.getWriter();
		this.buffer = "";
	}

	async close(): Promise<void> {
		try {
			await this.socket.close();
		} catch {
			// already closed
		}
	}
}

function formatDate(date: Date): string {
	return date.toUTCString().replace("GMT", "+0000");
}

function encodeWord(text: string): string {
	if (/^[\x00-\x7F]*$/.test(text)) return text;
	const bytes = new TextEncoder().encode(text);
	let binary = "";
	for (const byte of bytes) binary += String.fromCharCode(byte);
	return `=?UTF-8?B?${btoa(binary)}?=`;
}

function buildRawMessage(cfg: SmtpConfig, opts: SendOptions, messageId: string): string {
	const boundary = `----=_Part_${Date.now().toString(36)}_${crypto.randomUUID()}`;
	const from = cfg.fromName
		? `${encodeWord(cfg.fromName)} <${cfg.from}>`
		: cfg.from;
	const to = opts.to;

	const single =
		opts.text !== undefined && opts.html === undefined
			? "text/plain"
			: opts.html !== undefined && opts.text === undefined
				? "text/html"
				: null;

	const headers = [
		`From: ${from}`,
		`To: <${to}>`,
		`Subject: ${encodeWord(opts.subject)}`,
		`Message-ID: ${messageId}`,
		`Date: ${formatDate(new Date())}`,
		`MIME-Version: 1.0`,
	];

	if (single) {
		const body = single === "text/plain" ? opts.text! : opts.html!;
		return [
			...headers,
			`Content-Type: ${single}; charset=UTF-8`,
			`Content-Transfer-Encoding: 7bit`,
			"",
			body,
		].join("\r\n");
	}

	const parts: string[] = [];
	if (opts.text !== undefined) {
		parts.push(
			`--${boundary}`,
			"Content-Type: text/plain; charset=UTF-8",
			"Content-Transfer-Encoding: 7bit",
			"",
			opts.text,
		);
	}
	if (opts.html !== undefined) {
		parts.push(
			`--${boundary}`,
			"Content-Type: text/html; charset=UTF-8",
			"Content-Transfer-Encoding: 7bit",
			"",
			opts.html,
		);
	}
	parts.push(`--${boundary}--`);

	return [...headers, `Content-Type: multipart/alternative; boundary="${boundary}"`, "", ...parts].join("\r\n");
}

function assertCode(reply: Reply, expected: number, label: string): void {
	if (reply.code !== expected) {
		throw new Error(`${label} failed: ${reply.code} ${reply.lines.join(" ")}`);
	}
}

export async function sendEmail(cfg: SmtpConfig, opts: SendOptions): Promise<SmtpResult> {
	const socket = connect(
		{ hostname: cfg.host, port: cfg.port },
		{ secureTransport: cfg.startTls ? "starttls" : "off", allowHalfOpen: false },
	);
	const conn = new SmtpConnection(socket);

	try {
		let reply = await conn.readReply();
		assertCode(reply, 220, "Greeting");

		await conn.writeLine(`EHLO ${cfg.host}`);
		reply = await conn.readReply();
		assertCode(reply, 250, "EHLO");

		const capabilities = reply.lines.map((line) => line.slice(4).toUpperCase());

		if (cfg.startTls) {
			if (!capabilities.some((line) => line.startsWith("STARTTLS"))) {
				throw new Error("Server does not advertise STARTTLS");
			}
			await conn.writeLine("STARTTLS");
			reply = await conn.readReply();
			assertCode(reply, 220, "STARTTLS");

			await conn.upgradeTls();

			await conn.writeLine(`EHLO ${cfg.host}`);
			reply = await conn.readReply();
			assertCode(reply, 250, "EHLO (TLS)");
		}

		const credentials = btoa(`\0${cfg.username}\0${cfg.password}`);
		await conn.writeLine(`AUTH PLAIN ${credentials}`);
		reply = await conn.readReply();
		assertCode(reply, 235, "AUTH");

		await conn.writeLine(`MAIL FROM:<${cfg.from}>`);
		reply = await conn.readReply();
		assertCode(reply, 250, "MAIL FROM");

		await conn.writeLine(`RCPT TO:<${opts.to}>`);
		reply = await conn.readReply();
		assertCode(reply, 250, "RCPT TO");

		await conn.writeLine("DATA");
		reply = await conn.readReply();
		assertCode(reply, 354, "DATA");

		const messageId = `<${crypto.randomUUID()}@${cfg.host}>`;
		const raw = buildRawMessage(cfg, opts, messageId);
		const stuffed = raw.replace(/^\./gm, "..");
		await conn.writeRaw(stuffed + "\r\n.\r\n");

		reply = await conn.readReply();
		assertCode(reply, 250, "DATA end");

		return { messageId };
	} finally {
		await conn.close();
	}
}