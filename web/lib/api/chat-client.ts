import type {
  ChatMessageResponse,
  ChatMuteResponse,
  ChatMuteUserRequest,
  ConversationResponse,
  PageChatMessageResponse,
} from "@/lib/api/types"

type ChatResult<T> = {
  data?: T
  error?: string
  status?: number
  mutedUntil?: string
}

const backendBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL

let cachedToken: string | null = null
let tokenPromise: Promise<string | null> | null = null

async function getBackendToken(): Promise<string | null> {
  if (cachedToken) return cachedToken
  if (tokenPromise) return tokenPromise

  tokenPromise = fetch("/api/auth/token", { cache: "no-store" })
    .then(async (response) => {
      if (!response.ok) return null
      const data = (await response.json()) as { token?: string }
      cachedToken = data.token ?? null
      return cachedToken
    })
    .catch(() => null)
    .finally(() => {
      tokenPromise = null
    })

  return tokenPromise
}

function extractErrorMessage(data: unknown): string | null {
  if (!data) return null
  if (typeof data === "string" && data) return data

  if (typeof data === "object") {
    const { message, error } = data as {
      message?: unknown
      error?: unknown
    }
    if (typeof message === "string" && message) return message
    if (typeof error === "string" && error) return error
  }

  return null
}

async function chatFetch<T>(
  backendPath: string,
  init?: Omit<RequestInit, "body"> & { body?: unknown }
): Promise<ChatResult<T>> {
  if (!backendBaseUrl) return { error: "حدث خطأ أثناء الاتصال بالخادم" }

  const token = await getBackendToken()
  if (!token) return { error: "انتهت الجلسة، يرجى تسجيل الدخول" }

  const { body, ...rest } = init ?? {}
  const headers = new Headers(rest.headers)
  headers.set("authorization", `Bearer ${token}`)

  const hasBody = body !== undefined
  if (hasBody && !(body instanceof FormData) && !headers.has("content-type")) {
    headers.set("content-type", "application/json")
  }

  const url = new URL(
    backendPath.startsWith("/") ? backendPath : `/${backendPath}`,
    backendBaseUrl
  ).toString()

  let response: Response
  try {
    response = await fetch(url, {
      ...rest,
      headers,
      body: !hasBody
        ? undefined
        : body instanceof FormData
          ? body
          : JSON.stringify(body),
    })
  } catch {
    return { error: "تعذر الاتصال بالخادم" }
  }

  if (response.status === 401) {
    cachedToken = null
    return { error: "انتهت الجلسة، يرجى تسجيل الدخول", status: 401 }
  }

  const data = await response.json().catch(() => null)

  if (!response.ok) {
    const mutedUntil = (data as { mutedUntil?: string } | null)?.mutedUntil
    return {
      error: extractErrorMessage(data) ?? "حدث خطأ أثناء تنفيذ العملية",
      status: response.status,
      ...(mutedUntil ? { mutedUntil } : {}),
    }
  }

  return { data: data as T }
}

export function chatGetCourseConversation(courseId: number) {
  return chatFetch<ConversationResponse>(
    `chat/conversations/courses/${courseId}`
  )
}

export function chatGetMessages(conversationId: number, page = 0, size = 30) {
  const params = new URLSearchParams({ page: String(page), size: String(size) })
  return chatFetch<PageChatMessageResponse>(
    `chat/conversations/${conversationId}/messages?${params.toString()}`
  )
}

export function chatSendMessage(conversationId: number, content: string) {
  return chatFetch<ChatMessageResponse>(
    `chat/conversations/${conversationId}/messages`,
    { method: "POST", body: { content } }
  )
}

export function chatEditMessage(
  conversationId: number,
  messageId: number,
  content: string
) {
  return chatFetch<ChatMessageResponse>(
    `chat/conversations/${conversationId}/messages/${messageId}`,
    { method: "PATCH", body: { content } }
  )
}

export function chatDeleteMessage(conversationId: number, messageId: number) {
  return chatFetch<void>(
    `chat/conversations/${conversationId}/messages/${messageId}`,
    { method: "DELETE" }
  )
}

export function chatMarkAsRead(conversationId: number, messageId: number) {
  return chatFetch<void>(
    `chat/conversations/${conversationId}/messages/${messageId}/read`,
    { method: "POST" }
  )
}

export function chatMuteUser(request: ChatMuteUserRequest) {
  return chatFetch<ChatMuteResponse>("/chat/mutes", {
    method: "POST",
    body: request,
  })
}

export function chatUnmute(muteId: number) {
  return chatFetch<void>(`/chat/mutes/${muteId}`, { method: "DELETE" })
}

export function chatPusherAuth(socketId: string, channelName: string) {
  const params = new URLSearchParams({ socketId, channelName })
  return chatFetch<{ auth: string }>(`/chat/pusher/auth?${params.toString()}`, {
    method: "POST",
  })
}
