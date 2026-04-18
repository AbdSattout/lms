# Telegram Build Bot (Cloudflare Worker)

This Worker handles Telegram webhook updates and only responds to a single command:

- accepted chat: `ALLOWED_CHAT_ID`
- accepted command: exactly `/build`

When `/build` is received from the allowed chat, it compares `release` vs `dev` on GitHub and:

- replies that release is already up to date, or
- fast-forwards `release` to `dev` and replies with commit hash/message, or
- replies that fast-forward is not possible.

## Setup

From `bot`:

```bash
bun install
bun run cf-typegen
bun run dev
```

## Required env vars

### Non-secret vars (wrangler.jsonc -> vars)

- `GITHUB_OWNER`: GitHub org/user that owns the repo.
- `GITHUB_REPO`: GitHub repository name.
- `DEV_BRANCH`: source branch to deploy from (default `dev`).
- `RELEASE_BRANCH`: target branch to fast-forward (default `release`).

Set these in `wrangler.jsonc` before deploy.

### Secrets

- `ALLOWED_CHAT_ID`: Telegram chat ID allowed to run `/build`.
- `TELEGRAM_BOT_TOKEN`: Telegram bot token from BotFather.
- `GITHUB_TOKEN`: GitHub token with repo write access for branch ref updates.

Set secrets with Wrangler:

```bash
wrangler secret put ALLOWED_CHAT_ID
wrangler secret put TELEGRAM_BOT_TOKEN
wrangler secret put GITHUB_TOKEN
```

## Deploy

1. Set the Worker name in `wrangler.jsonc` (`name`).
2. Set non-secret vars in `wrangler.jsonc`.
3. Add secrets with `wrangler secret put`.
4. Deploy:

```bash
bun run deploy
```

## Telegram webhook

After deploy, set your webhook URL to:

`https://<your-worker-domain>/`

Use Telegram API:

```bash
curl -X POST "https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/setWebhook" \
  -H "content-type: application/json" \
  -d '{"url":"https://<your-worker-domain>/"}'
```

Check webhook info:

```bash
curl "https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/getWebhookInfo"
```

## Health check

`GET /health` returns:

```json
{"ok":true}
```
