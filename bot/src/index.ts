import { Octokit } from "octokit";

const BUILD_COMMAND = "/build";

type TelegramUpdate = {
	message?: {
		chat?: {
			id?: number | string;
		};
		text?: string;
	};
};

type SyncResult =
	| {
			kind: "up_to_date";
			sha: string;
		}
	| {
			kind: "updated";
			sha: string;
			message: string;
		}
	| {
			kind: "not_fast_forwardable";
			status: string;
			releaseSha: string;
			devSha: string;
		};

export default {
	async fetch(request, env): Promise<Response> {
		const url = new URL(request.url);

		if (request.method === "GET" && url.pathname === "/health") {
			return new Response(JSON.stringify({ ok: true }), {
				status: 200,
				headers: {
					"content-type": "application/json",
				},
			});
		}

		if (request.method !== "POST") {
			return new Response("Method Not Allowed", { status: 405 });
		}

		let update: TelegramUpdate;
		try {
			update = (await request.json()) as TelegramUpdate;
		} catch {
			return new Response("Invalid JSON", { status: 400 });
		}

		const message = update.message;
		if (!message?.chat?.id || !message.text) {
			return new Response("Ignored", { status: 200 });
		}

		if (message.text !== BUILD_COMMAND) {
			return new Response("Ignored", { status: 200 });
		}

		if (!env.ALLOWED_CHAT_ID || env.ALLOWED_CHAT_ID === "") {
			return new Response("Configuration error. Missing: ALLOWED_CHAT_ID", {
				status: 500,
			});
		}

		if (String(message.chat.id) !== env.ALLOWED_CHAT_ID) {
			return new Response("Ignored", { status: 200 });
		}

		const missingEnv = findMissingBuildEnv(env);
		if (missingEnv.length > 0) {
			return new Response(`Configuration error. Missing: ${missingEnv.join(", ")}`, {
				status: 500,
			});
		}

		try {
			const result = await syncReleaseBranch(env);
			await sendTelegramMessage(
				env.TELEGRAM_BOT_TOKEN,
				message.chat.id,
				formatResultMessage(env, result),
			);
		} catch (error) {
			await sendTelegramMessage(
				env.TELEGRAM_BOT_TOKEN,
				message.chat.id,
				`Build sync failed: ${errorMessage(error)}`,
			);
		}

		return new Response("OK", { status: 200 });
	},
} satisfies ExportedHandler<Env>;

function findMissingBuildEnv(env: Env): string[] {
	const required = [
		"ALLOWED_CHAT_ID",
		"TELEGRAM_BOT_TOKEN",
		"GITHUB_TOKEN",
		"GITHUB_OWNER",
		"GITHUB_REPO",
		"DEV_BRANCH",
		"RELEASE_BRANCH",
	] as const;

	return required.filter((key) => !env[key]);
}

async function syncReleaseBranch(env: Env): Promise<SyncResult> {
	const octokit = new Octokit({ auth: env.GITHUB_TOKEN });
	const [releaseRef, devRef] = await Promise.all([
		octokit.request("GET /repos/{owner}/{repo}/git/ref/{ref}", {
			owner: env.GITHUB_OWNER,
			repo: env.GITHUB_REPO,
			ref: `heads/${env.RELEASE_BRANCH}`,
		}),
		octokit.request("GET /repos/{owner}/{repo}/git/ref/{ref}", {
			owner: env.GITHUB_OWNER,
			repo: env.GITHUB_REPO,
			ref: `heads/${env.DEV_BRANCH}`,
		}),
	]);

	const releaseSha = releaseRef.data.object.sha;
	const devSha = devRef.data.object.sha;

	if (releaseSha === devSha) {
		return { kind: "up_to_date", sha: devSha };
	}

	const compare = await octokit.request(
		"GET /repos/{owner}/{repo}/compare/{basehead}",
		{
			owner: env.GITHUB_OWNER,
			repo: env.GITHUB_REPO,
			basehead: `${env.RELEASE_BRANCH}...${env.DEV_BRANCH}`,
		},
	);

	const status = compare.data.status;
	if (status !== "ahead") {
		return {
			kind: "not_fast_forwardable",
			status,
			releaseSha,
			devSha,
		};
	}

	await octokit.request("PATCH /repos/{owner}/{repo}/git/refs/{ref}", {
		owner: env.GITHUB_OWNER,
		repo: env.GITHUB_REPO,
		ref: `heads/${env.RELEASE_BRANCH}`,
		sha: devSha,
		force: false,
	});

	const devCommit = await octokit.request(
		"GET /repos/{owner}/{repo}/commits/{ref}",
		{
			owner: env.GITHUB_OWNER,
			repo: env.GITHUB_REPO,
			ref: devSha,
		},
	);

	const commitMessage =
		devCommit.data.commit.message.split("\n")[0]?.trim() || "No commit message";

	return {
		kind: "updated",
		sha: devSha,
		message: commitMessage,
	};
}

function formatResultMessage(env: Env, result: SyncResult): string {
	if (result.kind === "up_to_date") {
		return `${env.RELEASE_BRANCH} is already up to date with ${env.DEV_BRANCH} (${shortSha(result.sha)}).`;
	}

	if (result.kind === "not_fast_forwardable") {
		return [
			`Cannot fast-forward ${env.RELEASE_BRANCH} to ${env.DEV_BRANCH}.`,
			`Comparison status: ${result.status}.`,
			`${env.RELEASE_BRANCH}: ${shortSha(result.releaseSha)}`,
			`${env.DEV_BRANCH}: ${shortSha(result.devSha)}`,
		].join("\n");
	}

	return [
		`${env.RELEASE_BRANCH} was fast-forwarded to ${env.DEV_BRANCH}.`,
		`Commit: ${shortSha(result.sha)} - ${result.message}`,
		"Successfully merged. Apps will be deployed shortly.",
	].join("\n");
}

async function sendTelegramMessage(
	botToken: string,
	chatId: number | string,
	text: string,
): Promise<void> {
	const response = await fetch(
		`https://api.telegram.org/bot${botToken}/sendMessage`,
		{
			method: "POST",
			headers: {
				"content-type": "application/json",
			},
			body: JSON.stringify({
				chat_id: chatId,
				text,
			}),
		},
	);

	if (!response.ok) {
		throw new Error(
			`Telegram API returned ${response.status}: ${await response.text()}`,
		);
	}
}

function shortSha(sha: string): string {
	return sha.slice(0, 7);
}

function errorMessage(error: unknown): string {
	if (error instanceof Error) {
		return error.message;
	}

	return "Unknown error";
}
