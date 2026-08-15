export const openapiSchema = {
	openapi: "3.0.3",
	info: {
		title: "LMS Email API",
		version: "0.1.0",
		description:
			"Sends transactional emails via Gmail SMTP from a Cloudflare Worker. Authenticate with `Authorization: Bearer <API_SECRET>`.",
	},
	servers: [{ url: "https://lms-email-api.abdsat.workers.dev" }],
	paths: {
		"/health": {
			get: {
				summary: "Health check",
				security: [],
				responses: {
					"200": {
						description: "Service is up",
						content: {
							"application/json": {
								schema: {
									type: "object",
									properties: {
										ok: { type: "boolean" },
										service: { type: "string" },
									},
								},
							},
						},
					},
				},
			},
		},
		"/send": {
			post: {
				summary: "Send an email",
				description:
					"Sends a transactional email. At least one of `text` or `html` is required.",
				security: [{ apiKey: [] }],
				requestBody: {
					required: true,
					content: {
						"application/json": {
							schema: {
								type: "object",
								required: ["to", "subject"],
								properties: {
									to: {
										type: "string",
										format: "email",
										example: "user@example.com",
									},
									subject: { type: "string", example: "Your OTP code" },
									text: {
										type: "string",
										description: "Plain text body",
										example: "Your OTP code is 123456",
									},
									html: {
										type: "string",
										description: "HTML body",
										example: "<p>Your OTP code is <b>123456</b></p>",
									},
								},
							},
						},
					},
				},
				responses: {
					"200": {
						description: "Email accepted by the SMTP server",
						content: {
							"application/json": {
								schema: {
									type: "object",
									properties: {
										ok: { type: "boolean", enum: [true] },
										messageId: { type: "string" },
									},
								},
							},
						},
					},
					"400": {
						description: "Invalid request body",
						content: {
							"application/json": {
								schema: {
									type: "object",
									properties: {
										error: { type: "string" },
										details: { type: "array", items: { type: "string" } },
									},
								},
							},
						},
					},
					"401": {
						description: "Missing or invalid API secret",
						content: {
							"application/json": {
								schema: {
									type: "object",
									properties: { error: { type: "string" } },
								},
							},
						},
					},
					"502": {
						description: "SMTP delivery failed",
						content: {
							"application/json": {
								schema: {
									type: "object",
									properties: {
										ok: { type: "boolean", enum: [false] },
										error: { type: "string" },
										detail: { type: "string" },
									},
								},
							},
						},
					},
				},
			},
		},
	},
	components: {
		securitySchemes: {
			apiKey: {
				type: "http",
				scheme: "bearer",
				description: "Bearer token: `Authorization: Bearer <API_SECRET>`",
			},
		},
	},
} as const;

export function swaggerUi(): string {
	return `<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<title>LMS Email API - OpenAPI</title>
	<link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
</head>
<body>
	<div id="swagger-ui"></div>
	<script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
	<script>
		window.onload = () => {
			window.ui = SwaggerUIBundle({
				url: "./openapi.json",
				dom_id: "#swagger-ui",
			});
		};
	</script>
</body>
</html>`;
}